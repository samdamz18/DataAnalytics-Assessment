-- Assessment_Q2.sql
-- Task: Analyze transaction frequency by calculating average monthly transactions per customer
-- and categorizing them as High, Medium, or Low frequency.

-- Step 1: Count how many transactions each customer had in each month
WITH monthly_transactions AS (
    SELECT
        owner_id,
        -- Normalize transaction date to first of month for monthly grouping
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM 
        savings_savingsaccount
    WHERE 
        transaction_date IS NOT NULL
    GROUP BY 
        owner_id, DATE_FORMAT(transaction_date, '%Y-%m-01')
),

-- Step 2: Compute each customer's average transactions per month
customer_monthly_avg AS (
    SELECT
        owner_id,
        ROUND(AVG(monthly_txn_count), 1) AS avg_txns_per_month
    FROM 
        monthly_transactions
    GROUP BY 
        owner_id
),

-- Step 3: Categorize each customer based on their average monthly transaction count
categorized_customers AS (
    SELECT 
        CASE 
            WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txns_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txns_per_month
    FROM 
        customer_monthly_avg
)

-- Step 4: Summarize how many customers fall into each category,
-- and calculate the overall average monthly transactions per category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txns_per_month), 1) AS avg_transactions_per_month
FROM 
    categorized_customers
GROUP BY 
    frequency_category
-- Order output in logical sequence: High > Medium > Low
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
