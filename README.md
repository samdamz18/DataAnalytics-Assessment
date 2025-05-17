# DataAnalytics-Assessment
Assessment scripts for data analytics

### Assessment_Q1.sql  -  Cross-Selling Opportunity: Savings + Investment Plans

**Objective:**  
Identify customers who have both a funded savings plan and a funded investment plan (cross-selling insight), and rank them by total deposits.

**Approach:**
- Joined the `savings_savingsaccount`, `users_customuser`, and `plans_plan` tables using foreign keys (`owner_id` and `plan_id`).
- Filtered only funded plans using `confirmed_amount > 0`.
- Used conditional `COUNT()` with `CASE WHEN` to separately count savings (`is_regular_savings = 1`) and investment plans (`is_a_fund = 1`).
- Summed all relevant deposits and converted from kobo to naira using `/ 100.0`.
- Applied `HAVING` to ensure both plan types are present per customer.
- Sorted by `total_deposits` to surface high-value clients.

**Challenges:**
- The name column is null, had to concatenate both first and last names
- Initially considered separate subqueries for savings and investment counts, but opted for `CASE` in aggregate functions for clarity and performance.
- Ensured data type precision with `ROUND(... / 100.0, 2)` to avoid integer division or rounding errors.

### Assessment_Q2.sql  -  Transaction Frequency Analysis

**Objective:**  
Segment users by how frequently they transact each month, to classify them into High, Medium, or Low frequency.

**Approach:**
- Used `savings_savingsaccount.transaction_date` to group transactions by customer and month.
- Calculated the average number of monthly transactions per customer.
- Categorized users:
  - High Frequency: ≥ 10 transactions/month
  - Medium Frequency: 3–9 transactions/month
  - Low Frequency: ≤ 2 transactions/month
- Used `DATE_FORMAT(..., '%Y-%m-01')` to default all transaction for an owner_id in a month to the first day for month grouping.

**Challenges:**
- I assumed this is for inflows only, since the assessment only specified the savings_savingsaccount transaction table and not withdrawals_withdrawal

### Assessment_Q3.sql  -  Account Inactivity Alert

**Objective:** 
Find active savings or investment accounts with **no inflow in the last 365 days**.

**Approach:**
- Used inflow transactions (`confirmed_amount > 0`) to determine last activity date.
- Included accounts with **no inflow ever** by falling back to `created_on`.
- Excluded archived and deleted plans via `is_archived = 0 AND is_deleted = 0`.
- Calculated inactivity using `DATEDIFF(CURRENT_DATE, last_transaction_date)`.
- Filtered for `inactivity_days > 365`.

**Challenges:**
- To make the report more fine-tuned, i removed deleted and archived records.
- I included those that have not had any transaction at all, since this fits the scenerio painted by the ops team. This is done by falling back to `created_on`







