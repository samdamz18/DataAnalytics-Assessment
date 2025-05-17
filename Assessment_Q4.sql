-- Assessment_Q4.sql

-- Step 1: Aggregate total transactions and total inflow value (in Naira) per customer
WITH customer_transactions AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) / 100.0 AS total_value_naira -- Convert from kobo to Naira
    FROM 
        savings_savingsaccount s
    WHERE 
        confirmed_amount > 0
    GROUP BY 
        s.owner_id
),

-- Step 2: Calculate account tenure in months since signup for each customer
customer_tenure AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURRENT_DATE) AS tenure_months
    FROM 
        users_customuser u
    WHERE 
        u.is_active = 1
),

-- Step 3: Combine transactions and tenure, and calculate estimated CLV
clv_calc AS (
    SELECT 
        ct.owner_id AS customer_id,
        ct.total_transactions,
        ct.total_value_naira,
        ct.total_value_naira * 0.001 AS total_profit_naira, -- 0.1% of total value as profit
        t.name,
        t.tenure_months,

        -- CLV formula: (transactions / tenure) * 12 * avg profit per transaction
        ROUND(
            (ct.total_transactions / NULLIF(t.tenure_months, 0)) * 12 * 
            (ct.total_value_naira * 0.001 / NULLIF(ct.total_transactions, 0)), -- Use NULLIF to avoid division by zero
            2
        ) AS estimated_clv
    FROM 
        customer_transactions ct
    JOIN customer_tenure t ON ct.owner_id = t.customer_id
)

-- Step 4: Final result ordered by estimated CLV
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM 
    clv_calc
ORDER BY 
    estimated_clv DESC;
