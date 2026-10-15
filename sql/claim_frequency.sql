-- Calculate the frequency of claims by region. The frequency of claims is calculated by the total number of claims divided by the exposure.

SELECT 
    Region,
    COUNT(*) as total_policies,
    SUM(ClaimNb) as total_claims,
    SUM(Exposure) as total_exposure,
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
    COUNT(*) as total_policies,
    SUM(ClaimNb) as total_claims,
    SUM(Exposure) as total_exposure,
    SUM(ClaimNb) / NULLIF(SUM(Exposure), 0) AS claim_frequency
FROM policies
GROUP BY age_group
ORDER BY MAX(DrivAge);

-- Investigate frequency based on age and vehicle type. 

SELECT
    CASE
        WHEN DrivAge < 25 THEN 'Young'
        WHEN DrivAge < 40 THEN 'Early Career'
        WHEN DrivAge < 60 THEN 'Middle Age'
        WHEN DrivAge >= 60 THEN 'Senior'
        ELSE 'Unknown'
    END AS age_group,
    VehGas as fuel_type,
    COUNT(*) as total_policies,
    SUM(ClaimNb) as total_claims,
    SUM(Exposure) as total_exposure,
    SUM(ClaimNb) / NULLIF(SUM(Exposure), 0) AS claim_frequency
FROM policies
GROUP BY age_group, fuel_type
ORDER BY MAX(DrivAge), claim_frequency DESC;

