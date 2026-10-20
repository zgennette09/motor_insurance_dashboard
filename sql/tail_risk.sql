/*
Explore how large claims affect the portfolio average by capping each claim at
EUR 250,000. Compare average and total payments with the uncapped amounts.
This is a hypothetical payment cap to illustrate tail risk, not a pricing recommendation.
*/

SELECT
    AVG(c.ClaimAmount) AS avg_claim_amount,
    AVG(MIN(c.ClaimAmount, 250000)) AS avg_claim_amount_capped,
    AVG(c.ClaimAmount) - AVG(MIN(c.ClaimAmount, 250000)) AS avg_payment_reduction,
    SUM(c.ClaimAmount) - SUM(MIN(c.ClaimAmount, 250000)) AS total_payment_reduction
FROM policies AS p
INNER JOIN claims AS c
    ON p.IDpol = c.IDpol;