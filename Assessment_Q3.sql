-- Assessment_Q3.sql
-- Task: Identify active savings or investment plans with no inflow in the past 365 days

WITH latest_inflows AS (
    SELECT 
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM 
        savings_savingsaccount
    WHERE 
        confirmed_amount > 0  -- Only inflow transactions
        AND transaction_date IS NOT NULL
    GROUP BY 
        plan_id, owner_id
),

plan_status AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,

        -- Plan type classification
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS type,

        -- Use last inflow date or fallback to plan creation date
        COALESCE(l.last_transaction_date, p.created_on) AS last_transaction_date,

        -- Days since last transaction (or plan creation if never funded)
        DATEDIFF(CURRENT_DATE, COALESCE(l.last_transaction_date, p.created_on)) AS inactivity_days

    FROM 
        plans_plan p
    LEFT JOIN latest_inflows l ON p.id = l.plan_id

    WHERE 
        -- Include only savings or investment plans
        (p.is_regular_savings = 1 OR p.is_a_fund = 1)

        -- Exclude deleted or archived plans
        AND p.is_archived = 0
        AND p.is_deleted = 0
)

-- Filter for inactive plans over 365 days
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM 
    plan_status
WHERE 
    inactivity_days > 365
ORDER BY 
    inactivity_days DESC;
