WITH regional_frequency AS (
    SELECT
        Region,
        SUM(ClaimNb) AS total_claims,
        SUM(Exposure) AS total_exposure,
        SUM(ClaimNb) / NULLIF(SUM(Exposure), 0) AS claim_frequency
    FROM policies
    GROUP BY Region
), 
regional_severity AS (
    SELECT
        Region,
        AVG(c.ClaimAmount) AS avg_claim_amount
    FROM policies AS p
    INNER JOIN claims AS c 
        ON p.IDpol = c.IDpol
    GROUP BY Region
)
SELECT
    f.Region,
    f.claim_frequency,
    s.avg_claim_amount,
    f.claim_frequency * s.avg_claim_amount AS pure_premium_proxy
FROM regional_frequency AS f
INNER JOIN regional_severity AS s
    ON f.Region = s.Region
ORDER BY pure_premium_proxy DESC;

-- Investigate Champagne-Ardenne

WITH champagne_ardenne_claims AS (
    SELECT 
        p.IDpol,
        c.ClaimAmount
    FROM policies AS p
    INNER JOIN claims AS c 
        ON p.IDpol = c.IDpol
    WHERE p.Region = 'Champagne-Ardenne'
)
SELECT 
    COUNT(*) AS total_records,
    AVG(ClaimAmount) AS avg_claim_amount,
    MAX(ClaimAmount) AS max_claim_amount,
    SUM(ClaimAmount) AS total_claim_amount,
    MAX(ClaimAmount) / NULLIF(SUM(ClaimAmount), 0) AS largest_claim_share
FROM champagne_ardenne_claims;