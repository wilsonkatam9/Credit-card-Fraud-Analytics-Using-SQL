
-- Creating the Table 'fraud_transaction'
CREATE TABLE fraud_transactions (
    transaction_id INT PRIMARY KEY,
    amount DECIMAL(10,2),
    transaction_hour INT,
    merchant_category VARCHAR(50),
    foreign_transaction INT,
    location_mismatch INT,
    device_trust_score DECIMAL(5,2),
    velocity_last_24h INT,
    cardholder_age INT,
    is_fraud INT
);

-- imported data check

select * from fraud_transactions limit 10 ;

select count(*) from fraud_transactions ;





-- Basic data Understanding
-- [ Fraud vs Non_Fraud ]
SELECT 
	CASE
		when is_fraud = 1 then 'Fraud'
		ELSE 'Non_fraud'
	END AS type,
    count(*) as Total
from fraud_transactions
group by type ;





-- DATA CLEANING
-- 1) NULL CHECK 
SELECT 
	sum(case when amount is null then 1 else 0 end ) as amount_nulls,
    sum(case when transaction_hour is null then 1 else 0 end ) as transaction_hour_nulls,
    sum(case when merchant_category is null then 1 else 0 end ) as merchant_category_nulls,
    sum(case when device_trust_score is null then 1 else 0 end ) as device_trust_score_nulls
from fraud_transactions ;

-- 2) Duplicate check
SELECT 
	transaction_id,
    count(*) 
from fraud_transactions
group by transaction_id
having count(*) > 1 ;





-- Data Understanding 
-- 1) Fraud vs Amount
SELECT 
	is_fraud,
    AVG(amount) as avg_amount
from fraud_transactions
Group by is_fraud ;

-- 2) Foreign Transactions
SELECT
	foreign_transaction,
    count(*) as Total,
    sum(is_fraud) as fraud_cases,
    ROUND(sum(is_fraud) * 100.0 / count(*) , 2 ) as fraud_percentage
from fraud_transactions
group by foreign_transaction ;

-- 3) Location Mismatch
SELECT
	location_mismatch,
    count(*) as Total,
    sum(is_fraud) as fraud_cases,
    ROUND(sum(is_fraud) * 100.0 / count(*) , 2 ) as fraud_percentage
from fraud_transactions
group by location_mismatch ;

-- 4) Velocity 
SELECT
	velocity_last_24h,
    count(*) as Total,
    sum(is_fraud) as fraud_cases,
    ROUND(sum(is_fraud) * 100.0 / count(*) , 2 ) as fraud_percentage
from fraud_transactions
group by velocity_last_24h 
order by velocity_last_24h ASC ;

-- 5) Device Trust
SELECT 
    CASE 
        WHEN device_trust_score < 40 THEN 'Low Trust'
        WHEN device_trust_score < 70 THEN 'Medium Trust'
        ELSE 'High Trust'
    END AS trust_category,
    
    COUNT(*) AS total,
    SUM(is_fraud) AS fraud_cases,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_percentage

FROM fraud_transactions
GROUP BY trust_category;

-- 6) Merchant Category 
SELECT 
    merchant_category,
    COUNT(*) AS total,
    SUM(is_fraud) AS fraud_cases,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_percentage
FROM fraud_transactions
GROUP BY merchant_category
ORDER BY fraud_cases DESC;





-- Building Risk score
SELECT *,
	(
		case when amount > 200 then 20 else 0 end +
		case when foreign_transaction = 1 then 30 else 0 end +
		case when location_mismatch = 1 then 30 else 0 end +
		case when velocity_last_24h >= 5 then 40 else 0 end +
		case when device_trust_score < 0.4 then 30 else 0 end 
	) as risk_score
from fraud_transactions ;
	




-- Risk classification
SELECT *,
    CASE 
        When risk_score >= 80 Then 'High Risk'
        When risk_score >= 40 Then 'Medium Risk'
        Else 'Low Risk'
    End as risk_level
FROM (
    SELECT *,
        (
            Case When amount > 200 Then 20 Else 0 End +
            Case When foreign_transaction = 1 Then 30 Else 0 End +
            Case When location_mismatch = 1 Then 30 Else 0 End +
            Case When velocity_last_24h >= 5 Then 40 Else 0 End +
            Case When device_trust_score < 0.4 Then 30 Else 0 End
        ) as risk_score
    FROM fraud_transactions
) t;





-- Accuracy Check 
SELECT 
    risk_level,
    COUNT(*) AS total,
    SUM(is_fraud) AS fraud_cases,
    ROUND(SUM(is_fraud) * 100.0 / COUNT(*), 2) AS fraud_percentage
FROM (
    SELECT *,
        CASE 
            WHEN risk_score >= 80 THEN 'High Risk'
            WHEN risk_score >= 40 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM (
        SELECT *,
            (
                CASE WHEN amount > 200 THEN 20 ELSE 0 END +
                CASE WHEN foreign_transaction = 1 THEN 30 ELSE 0 END +
                CASE WHEN location_mismatch = 1 THEN 30 ELSE 0 END +
                CASE WHEN velocity_last_24h >= 5 THEN 40 ELSE 0 END +
                CASE WHEN device_trust_score < 0.4 THEN 30 ELSE 0 END
            ) AS risk_score
        FROM fraud_transactions
    ) t1
) t2
GROUP BY risk_level ;






