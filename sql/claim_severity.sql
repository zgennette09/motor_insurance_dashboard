/*
Explore claim severity by joining policies and claim amounts on IDpol.
Compare average claim amounts by driver age, inspect the largest claims, and
check the young-driver average after excluding claims of EUR 280,000 or more.
*/

-- Join claims and policies to analyze claim severity by age 

SELECT
    CASE
        WHEN p.DrivAge < 25 THEN 'Young'
        WHEN p.DrivAge < 40 THEN 'Early Career'
        WHEN p.DrivAge < 60 THEN 'Middle Age'
        WHEN p.DrivAge >= 60 THEN 'Senior'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS total_claims,
    AVG(c.ClaimAmount) AS avg_claim_amount,
    SUM(c.ClaimAmount) AS total_claim_amount
FROM policies AS p
INNER JOIN claims AS c 
    ON p.IDpol = c.IDpol
GROUP BY age_group
ORDER BY avg_claim_amount DESC;

-- Find the 10 largest claims

SELECT
    c.IDpol,
    p.DrivAge,
    p.Region,
    c.ClaimAmount
FROM policies AS p
INNER JOIN claims AS c
    ON p.IDpol = c.IDpol
ORDER BY c.ClaimAmount DESC
LIMIT 10;

-- Calculate average severity of young drivers with claim amount under 280000

SELECT
    AVG(c.ClaimAmount) AS avg_claim_amount
FROM policies AS p
INNER JOIN claims AS c
    ON p.IDpol = c.IDpol
WHERE p.DrivAge < 25 AND c.ClaimAmount < 280000;