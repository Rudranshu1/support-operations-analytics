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
