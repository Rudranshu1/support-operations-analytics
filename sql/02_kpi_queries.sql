-- ============================================================
-- support_ops_analytics: KPI queries
-- ============================================================

USE support_ops_analytics;

-- 1. Ticket volume by category
SELECT
    category,
    COUNT(*) AS ticket_count
FROM support_tickets
GROUP BY category
ORDER BY ticket_count DESC;

-- 2. Ticket volume by channel
SELECT
    channel,
    COUNT(*) AS ticket_count
FROM support_tickets
GROUP BY channel
ORDER BY ticket_count DESC;

-- 3. Average resolution time by agent
-- Excludes 'Unknown' - that's a data-cleaning placeholder for tickets with
-- no assigned agent (see data/generate_messy_data.py), not a real agent,
-- so it shouldn't be ranked against actual agent performance.
SELECT
    agent,
    COUNT(*)                          AS ticket_count,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM support_tickets
WHERE agent <> 'Unknown'
GROUP BY agent
ORDER BY avg_resolution_hours ASC;

-- How many tickets have no assigned agent (call this out separately,
-- don't just silently drop it)
SELECT COUNT(*) AS unassigned_agent_tickets
FROM support_tickets
WHERE agent = 'Unknown';

-- 4. Average satisfaction score by category
-- COUNT(satisfaction_score) only counts non-NULL responses, so we can see
-- the response rate alongside the score itself instead of hiding it.
SELECT
    category,
    COUNT(*)                          AS ticket_count,
    COUNT(satisfaction_score)         AS responses,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction
FROM support_tickets
GROUP BY category
ORDER BY avg_satisfaction DESC;

-- 5. Average resolution time by priority (SLA sanity check -
-- Urgent should resolve fastest, Low slowest)
SELECT
    priority,
    COUNT(*)                             AS ticket_count,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM support_tickets
GROUP BY priority
ORDER BY FIELD(priority, 'Urgent', 'High', 'Medium', 'Low');

-- 6. Monthly ticket volume trend
SELECT
    DATE_FORMAT(created_date, '%Y-%m') AS month,
    COUNT(*)                           AS ticket_count
FROM support_tickets
GROUP BY month
ORDER BY month;

-- 7. Reopened ticket rate (quality/rework metric)
SELECT
    COUNT(*)                                          AS total_tickets,
    SUM(status = 'Reopened')                           AS reopened_count,
    ROUND(100.0 * SUM(status = 'Reopened') / COUNT(*), 2) AS reopened_rate_pct
FROM support_tickets;

