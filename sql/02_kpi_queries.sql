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
SELECT
    agent,
    COUNT(*)                          AS ticket_count,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM support_tickets
GROUP BY agent
ORDER BY avg_resolution_hours ASC;
