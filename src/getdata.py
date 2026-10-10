import pandas as pd
import requests
from math import ceil
import sqlite3 

URL = "https://datasets-server.huggingface.co/rows"
DATASET = "mabilton/fremtpl2"
CONFIG = "freMTPL2freq"
DB_NAME = "insurance_test.db"

params = {
    "dataset": DATASET,
    "config": CONFIG,
    "split": "train",
    "offset": 0,
    "length": 1
}

# Retrieve the total number of rows in the dataset
int_response = requests.get(URL, params=params, timeout = 30)
int_response.raise_for_status()
num_rows = int_response.json()["num_rows_total"]

conn = sqlite3.connect(DB_NAME) # Connect to the SQLite database
conn.execute("""
    CREATE TABLE IF NOT EXISTS checkpoints (
        dataset TEXT PRIMARY KEY,
        next_offset INTEGER NOT NULL
    )
""")
conn.commit()

result = conn.execute(
    "SELECT next_offset FROM checkpoints WHERE dataset = ?",
    (CONFIG,)
).fetchone()

start_offset = result[0] if result else 0
params["length"] = 100 # Hugging Face only allows up to 100 records per request
remaining_rows = num_rows - start_offset
remaining_batches = ceil(remaining_rows / params["length"])
params["offset"] = start_offset

print(f"Resuming from offset {start_offset}")

for batch in range(min(remaining_batches, 10)):
    # Batches in the form of 100 records each
    params["offset"] = start_offset + batch * params["length"]
    print(f"Batch {batch + 1}/{min(remaining_batches, 10)} | Offset: {params['offset']}")

    response = requests.get(URL, params=params, timeout = 30)
    response.raise_for_status()

    data = response.json()
    records = [item["row"] for item in data["rows"]]

    if not records:
        print("No more records returned.")
        break

    batch_df = pd.DataFrame(records)

    batch_df.to_sql(
        name="policies",
        con=conn,
        if_exists="append",
        index=False
    )

    
    next_offset = params["offset"] + len(records)

    conn.execute("""
        INSERT INTO checkpoints (dataset, next_offset)
        VALUES (?, ?)
        ON CONFLICT(dataset)
        DO UPDATE SET next_offset = excluded.next_offset
    """, (CONFIG, next_offset))

    conn.commit()

query = """
    SELECT
        COUNT(*) AS total_policies,
        AVG(DrivAge) AS avg_driver_age,
        SUM(ClaimNb) AS total_claims
    FROM policies;
"""
result = pd.read_sql_query(query, conn)
print(result)

conn.close() # Close the connection to the SQLite database