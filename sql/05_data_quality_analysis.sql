/*
The dataset has a claim count of 36,102 but only 26,444 severity records. The
dashboard calculates a pure premium proxy by multiplying frequency and severity.
Multiplying two metrics with mismatched values holds the assumption that
the matched records are representative of the population.

The data source notes this inconsistency, but reasons for it are not mentioned.

This analysis seeks to discover if certain age groups or regions have more missing 
severity records than others, which could bias the pure premium proxy in those segments.
*/

-- Overall
WITH claims_by_policy AS (
    SELECT
        IDpol,
        COUNT(*) AS severity_records
    FROM claims
    GROUP BY IDpol
)
SELECT
    SUM(p.ClaimNb) AS reported_claims,
    SUM(COALESCE(c.severity_records, 0)) AS matched_severity_records,
    SUM(p.ClaimNb)
        - SUM(COALESCE(c.severity_records, 0))
        AS net_record_shortfall,
    1.0 * (
        SUM(p.ClaimNb)
        - SUM(COALESCE(c.severity_records, 0))
    ) / NULLIF(SUM(p.ClaimNb), 0) AS net_shortfall_ratio
FROM policies AS p
LEFT JOIN claims_by_policy AS c
    ON p.IDpol = c.IDpol;

-- Age Group
WITH claims_by_policy AS (
    SELECT
        IDpol,
        COUNT(*) AS severity_records
    FROM claims
    GROUP BY IDpol
),
age_group_claims AS (
    SELECT
        CASE
            WHEN p.DrivAge < 25 THEN 'Young'
            WHEN p.DrivAge < 40 THEN 'Early Career'
            WHEN p.DrivAge < 60 THEN 'Middle Age'
            ELSE 'Senior'
        END AS age_group,
        MAX(p.DrivAge) AS max_age,
        SUM(p.ClaimNb) AS reported_claims,
        SUM(COALESCE(c.severity_records, 0))
            AS matched_severity_records
    FROM policies AS p
    LEFT JOIN claims_by_policy AS c
        ON p.IDpol = c.IDpol
    GROUP BY age_group
)
SELECT
    age_group,
    reported_claims,
    matched_severity_records,
    reported_claims - matched_severity_records
        AS net_record_shortfall,
    1.0 * (reported_claims - matched_severity_records)
        / NULLIF(reported_claims, 0) AS net_shortfall_ratio
FROM age_group_claims
ORDER BY max_age;

-- Region
WITH claims_by_policy AS (
    SELECT
        IDpol,
        COUNT(*) AS severity_records
    FROM claims
    GROUP BY IDpol
),
region_claims AS (
    SELECT
        p.Region,
        SUM(p.ClaimNb) AS total_claims,
        SUM(COALESCE(c.severity_records, 0)) AS matched_severity_records
    FROM policies AS p
    LEFT JOIN claims_by_policy AS c
        ON p.IDpol = c.IDpol
    GROUP BY p.Region
)
SELECT
    Region,
    total_claims,
    matched_severity_records,
    total_claims - matched_severity_records AS missing_severity_records,
    (total_claims - matched_severity_records) * 1.0 / NULLIF(total_claims, 0) AS missing_severity_ratio
FROM region_claims
ORDER BY Region;

-- Policy Level Difference
WITH claims_by_policy AS (
    SELECT
        IDpol,
        COUNT(*) AS severity_records
    FROM claims
    GROUP BY IDpol
),
policy_level_diff AS (
    SELECT
        p.IDpol,
        p.ClaimNb - COALESCE(c.severity_records, 0) AS net_difference
    FROM policies AS p
    LEFT JOIN claims_by_policy AS c
        ON p.IDpol = c.IDpol
    GROUP BY p.IDpol
)
SELECT
    COUNT(CASE WHEN net_difference > 0 THEN 1 END) AS policies_with_less_severity_records,
    COUNT(CASE WHEN net_difference < 0 THEN 1 END) AS policies_with_more_severity_records,
    COUNT(CASE WHEN net_difference = 0 THEN 1 END) AS policies_with_equal_records
FROM policy_level_diff;