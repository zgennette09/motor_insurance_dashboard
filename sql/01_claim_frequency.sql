/*
Compare claim frequency by region, driver age, and fuel type using the policies table.
Frequency is reported claims divided by total exposure, so groups with different
amounts of time insured can be compared.
*/

-- Compare regions with more than 1,000 policies.

SELECT 
    Region,
    COUNT(*) AS total_policies,
    SUM(ClaimNb) AS total_claims,
    SUM(Exposure) AS total_exposure,
    SUM(ClaimNb) / NULLIF(SUM(Exposure), 0) AS claim_frequency
FROM policies
GROUP BY Region
HAVING total_policies > 1000
ORDER BY claim_frequency DESC;

-- Calculate the frequency of claims by age group. 
SELECT
    CASE
        WHEN DrivAge < 25 THEN 'Young'
        WHEN DrivAge < 40 THEN 'Early Career'
        WHEN DrivAge < 60 THEN 'Middle Age'
        WHEN DrivAge >= 60 THEN 'Senior'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS total_policies,
    SUM(ClaimNb) AS total_claims,
    SUM(Exposure) AS total_exposure,
    SUM(ClaimNb) / NULLIF(SUM(Exposure), 0) AS claim_frequency
FROM policies
GROUP BY age_group
ORDER BY MAX(DrivAge);

-- Compare fuel types within each age group.

SELECT
    CASE
        WHEN DrivAge < 25 THEN 'Young'
        WHEN DrivAge < 40 THEN 'Early Career'
        WHEN DrivAge < 60 THEN 'Middle Age'
        WHEN DrivAge >= 60 THEN 'Senior'
        ELSE 'Unknown'
    END AS age_group,
    VehGas AS fuel_type,
    COUNT(*) AS total_policies,
    SUM(ClaimNb) AS total_claims,
    SUM(Exposure) AS total_exposure,
    SUM(ClaimNb) / NULLIF(SUM(Exposure), 0) AS claim_frequency
FROM policies
GROUP BY age_group, fuel_type
ORDER BY MAX(DrivAge), claim_frequency DESC;

