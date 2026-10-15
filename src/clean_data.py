from pathlib import Path
import pandas as pd

ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data" / "raw"

freq = pd.read_csv(DATA_DIR / "freMTPL2freq.csv")
sev = pd.read_csv(DATA_DIR / "freMTPL2sev.csv")

for name, df in [("Policies", freq), ("Claims", sev)]:
    print(f"\n{name}")
    print("Shape:", df.shape)
    print("\nColumns:", df.columns.tolist())
    print("\nData types:")
    print(df.dtypes)
    print("\nMissing values:")
    print(df.isna().sum())
    print("\nFirst five rows:")
    print(df.head())


print("Non-integer policy IDs:",
      (freq["IDpol"] % 1 != 0).sum())

print("Duplicate policy IDs:",
      freq["IDpol"].duplicated().sum())

print("Duplicate claim rows:",
      sev.duplicated().sum())

print("Unique claim policy IDs:",
      sev["IDpol"].nunique())


print("\nExposure summary:")
print(freq["Exposure"].describe())

print("\nClaim count distribution:")
print(freq["ClaimNb"].value_counts().sort_index())

print("\nClaim amount summary:")
print(sev["ClaimAmount"].describe())

print("\nInvalid exposure:",
      (freq["Exposure"] <= 0).sum())

print("Negative claim amounts:",
      (sev["ClaimAmount"] < 0).sum())


policy_ids = set(freq["IDpol"])
claim_ids = set(sev["IDpol"])

unmatched_claims = (~sev["IDpol"].isin(policy_ids)).sum()

print("Claims without matching policy:", unmatched_claims)
print("Total claims reported by policies:", freq["ClaimNb"].sum())
print("Number of severity records:", len(sev))


# Convert policy identifiers to integer
freq["IDpol"] = freq["IDpol"].astype("int64")

# Confirm the conversion worked
print(freq["IDpol"].dtype)
print(sev["IDpol"].dtype)

# Identify claims with no matching policy
sev["HasMatchingPolicy"] = sev["IDpol"].isin(freq["IDpol"])

print(sev["HasMatchingPolicy"].value_counts())


claim_counts = (
    sev.groupby("IDpol")
    .size()
    .reset_index(name="SeverityRecordCount")
)

comparison = freq[["IDpol", "ClaimNb"]].merge(
    claim_counts,
    on="IDpol",
    how="left"
)

comparison["SeverityRecordCount"] = (
    comparison["SeverityRecordCount"].fillna(0).astype(int)
)

comparison["Difference"] = (
    comparison["ClaimNb"] - comparison["SeverityRecordCount"]
)

print(comparison["Difference"].value_counts().sort_index())
print("Policies with mismatched counts:",
      (comparison["Difference"] != 0).sum())

# Store into database insurance.db
import sqlite3

DATABASE_DIR = ROOT_DIR / "data" / "insurance.db"
conn = sqlite3.connect(DATABASE_DIR)

freq.to_sql("policies", conn, if_exists="replace", index=False)
sev.to_sql("claims", conn, if_exists="replace", index=False)

conn.close()
