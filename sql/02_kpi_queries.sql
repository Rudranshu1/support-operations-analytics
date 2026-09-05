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
