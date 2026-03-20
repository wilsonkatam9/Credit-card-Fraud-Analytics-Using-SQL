# CREDIT CARD FRAUD ANALYTICS - Using SQL

## Introduction 
This Project focuses on analyzing credit card transaction data to identify fraudulent activities and understand risk patterns. 
The analysis is performed using SQL by transforming raw transaction data into meaningful insights.

---

## Problem Statement 
Financial fraud is a major concern in digital transactions. The objective of this project is to analyze transaction data and identify pattern that distinguish fraudulent transactions from legitimate ones.

---

## Objectives 
- To identify fraudulent transactions in the dataset
- To compare fraud and non-fraud transaction patterns
- To segment transactions based on risk levels
- To calculate fraud percentages across different categories
- To generate insights that can help in fraud prevention

---

## Dataset Description 
File Name : `credit_card_fraud_10k.csv`
Totak Records : 10,000

### Features :
- Transaction amount
- Foreign Transaction
- Location Mismatch
- Device Trust Score
- Transaction Velocity (24h)
- Fraud Label

---

## Tools and technologies
- SQL (MySQL)
- CSV Dataset

---

## Methodology

### Data Cleaning
- Handled missing values
- Standardized data formats
- Ensure data consistency

### Data Analysis
- Performed exploratory analysis
- Compared fraud vs non-fraud transactions
- Analyzed fratures impact on fraud

### Risk Segmentation
Transactions were categorized into :
- Low Risk
- Medium Risk
- High Risk

Based on :
- Transaction Amount
- Foreign transaction
- Location mismatch
- Device trust score

---

## Key Analysis & Queries 

### Foreign Transactions 
``` sql
SELECT
	foreign_transaction,
    count(*) as Total,
    sum(is_fraud) as fraud_cases,
    ROUND(sum(is_fraud) * 100.0 / count(*) , 2 ) as fraud_percentage
from fraud_transactions
group by foreign_transaction ;
```

### Risk Classification 
```sql
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
```

### Accuracy check 
```sql
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
```

## Results
- Low Risk : 0.53% fraud rate
- Medium Risk : 7.71% fraud rate
- High Risk : 38.60% fraud rate

Observation : Fraud percentage increases significantly with higher risk levels.

---

## Key Insights
- High-risk transactions show the highest fraud rate
- Foreign transactions have higher fraud probability
- Location mismatch is a strong fraud indicator
- low-risk transactions have minimal fraud

---

## Conclusion
The project demonstrates how SQL can be effectively used to analyze transaction data and identify fraud patterns. Risk segmentation helps in understanding fraud distribution and improving detection strategies.

---

## Future Work
- Implement machine learning models
- Build dashboards using BI tools
- Develop real-time fraud detection systems

---

## Project Structure
```
credit-card-fraud-analysis/
|
|
 --- credit_card_fraud_10k.csv
|
 --- Fraud_detection_system.sql
|
 --- README.md
```

---

## Author 
Wilson Katam
