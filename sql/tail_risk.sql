/*
The query discovered a large tail risk. Just 4 claims brought the young drivers average claim
up by 3500. 

A basic idea to deal with this risk is to impose a maximum claim amount. This motivates
the following query, which is to compare the mean standard claim amount overall with the expected
claim amount while having a maximum claim EUR 250,000, modeled by MIN(c.ClaimAmount, 250000). 

This assumes a frictionless insurance market, 
where the insurer can set any maximum claim amount and the insured will accept it. This does
not represent any real world scenarios and should not be used to make any real world decisions.
*/

SELECT
    AVG(c.ClaimAmount) AS avg_claim_amount,
    AVG(MIN(c.ClaimAmount, 250000)) AS avg_claim_amount_capped,
    AVG(c.ClaimAmount) - AVG(MIN(c.ClaimAmount, 250000)) AS avg_payment_reduction,
    SUM(c.ClaimAmount) - SUM(MIN(c.ClaimAmount, 250000)) AS total_payment_reduction
FROM policies AS p
INNER JOIN claims AS c
    ON p.IDpol = c.IDpol;