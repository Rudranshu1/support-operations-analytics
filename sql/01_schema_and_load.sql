-- ============================================================
-- support_ops_analytics: schema + data load
-- Source: data/support_tickets_cleaned.csv (5000 rows)
-- Run this whole script in MySQL Workbench connected to your
-- local MySQL server.
-- ============================================================

CREATE DATABASE IF NOT EXISTS support_ops_analytics;
USE support_ops_analytics;

DROP TABLE IF EXISTS support_tickets;

CREATE TABLE support_tickets (
    ticket_id               VARCHAR(10)   PRIMARY KEY,
    created_date            DATE          NOT NULL,
    resolved_date           DATETIME      NULL,
    channel                 VARCHAR(20)   NOT NULL,
    category                VARCHAR(30)   NOT NULL,
    priority                VARCHAR(10)   NOT NULL,
    agent                   VARCHAR(10)   NOT NULL,
    resolution_time_hours   DECIMAL(6,2)  NULL,
    satisfaction_score      TINYINT       NULL,
    status                  VARCHAR(15)   NOT NULL
);

-- If LOAD DATA LOCAL INFILE fails with an error about local_infile
-- being disabled, enable it once per Workbench session with:
--   SET GLOBAL local_infile = 1;
-- and make sure Workbench's connection has "Allow LOAD LOCAL INFILE"
-- checked (Edit Connection > Advanced).
--
-- Update the path below to match where this repo actually sits on
-- your machine if it differs.

LOAD DATA LOCAL INFILE 'D:/Projects/MyGitHubProject/Project1-Rebuild/data/support_tickets_cleaned.csv'
INTO TABLE support_tickets
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  -- file is Windows CRLF; matching this exactly avoids a stray \r landing on the last column (status)
IGNORE 1 ROWS
(ticket_id, created_date, @resolved_date, channel, category, priority, agent,
 resolution_time_hours, @satisfaction_score, status)
SET
    -- source data is nanosecond-precision; MySQL DATETIME only takes
    -- microseconds (6 digits), so truncate the extra 3 digits
    resolved_date      = SUBSTRING(@resolved_date, 1, 26),
    satisfaction_score = NULLIF(@satisfaction_score, '');

-- Sanity check: should return 5000
SELECT COUNT(*) AS row_count FROM support_tickets;
