CREATE DATABASE bank_segmentation;
USE bank_segmentation;

CREATE TABLE transactions_raw (
    TransactionID VARCHAR(20),
    CustomerID VARCHAR(20),
    CustomerDOB VARCHAR(15),
    CustGender VARCHAR(5),
    CustLocation VARCHAR(100),
    CustAccountBalance DECIMAL(15,2),
    TransactionDate VARCHAR(15),
    TransactionTime VARCHAR(10),
    TransactionAmount DECIMAL(15,2)
);


SET SQL_SAFE_UPDATES = 0;

DROP TABLE IF EXISTS transactions_clean;
CREATE TABLE transactions_clean AS
SELECT
    TransactionID,
    CustomerID,
    CASE
        WHEN CustomerDOB REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN STR_TO_DATE(CustomerDOB, '%d/%m/%Y')
        WHEN CustomerDOB REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$'
            THEN STR_TO_DATE(CustomerDOB, '%d/%m/%y')
        ELSE NULL
    END AS DOB,
    CASE WHEN CustGender IN ('M','F') THEN CustGender ELSE 'Unknown' END AS Gender,
    UPPER(TRIM(COALESCE(CustLocation, 'Unknown'))) AS Location,
    CustAccountBalance,
    CASE
        WHEN TransactionDate REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN STR_TO_DATE(TransactionDate, '%d/%m/%Y')
        WHEN TransactionDate REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$'
            THEN STR_TO_DATE(TransactionDate, '%d/%m/%y')
        ELSE NULL
    END AS TxnDate,
    TransactionAmount
FROM transactions_raw
WHERE CustomerID IS NOT NULL
  AND TransactionAmount > 0;

ALTER TABLE transactions_clean ADD COLUMN Age INT;

UPDATE transactions_clean
SET Age = TIMESTAMPDIFF(YEAR, DOB, CURDATE())
WHERE DOB IS NOT NULL
  AND YEAR(DOB) > 1900
  AND DOB <= CURDATE();

DROP TABLE IF EXISTS customer_rfm;
CREATE TABLE customer_rfm AS
SELECT
    CustomerID,
    MAX(Gender) AS Gender,
    MAX(Location) AS Location,
    MAX(Age) AS Age,
    MAX(CustAccountBalance) AS AccountBalance,
    COUNT(TransactionID) AS Frequency,
    SUM(TransactionAmount) AS Monetary,
    DATEDIFF((SELECT MAX(TxnDate) FROM transactions_clean), MAX(TxnDate)) AS Recency,
    MIN(TxnDate) AS FirstTransaction,
    MAX(TxnDate) AS LastTransaction
FROM transactions_clean
GROUP BY CustomerID;

DROP TABLE IF EXISTS customer_rfm_sample;
CREATE TABLE customer_rfm_sample AS
SELECT * FROM customer_rfm
ORDER BY RAND()
LIMIT 100000;

SELECT * FROM customer_rfm_sample;
