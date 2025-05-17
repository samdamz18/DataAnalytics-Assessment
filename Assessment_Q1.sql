-- Assessment_Q1.sql
-- Objective: Identify customers who have at least one funded savings plan 
--            and at least one funded investment plan, and rank them by total deposits.

SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name, -- Since name is null, join both first and last name
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) AS investment_count,
    ROUND(SUM(CASE 
                 WHEN p.is_regular_savings = 1 OR p.is_a_fund = 1 
                 THEN s.confirmed_amount 
                 ELSE 0 
              END) / 100.0, 2) AS total_deposits  -- Convert from kobo to Naira
FROM 
    users_customuser u
JOIN 
    savings_savingsaccount s ON u.id = s.owner_id
JOIN 
    plans_plan p ON s.plan_id = p.id
WHERE 
    s.confirmed_amount > 0  -- Only funded plans
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) > 0
    AND 
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) > 0
ORDER BY 
    total_deposits DESC;
