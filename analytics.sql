-- 1. Basic funnel totals per day
SELECT
  event_date,
  SUM(CASE WHEN event_name = 'lead_form_view' THEN 1 ELSE 0 END) as views,
  SUM(CASE WHEN event_name = 'lead_submit_attempt' THEN 1 ELSE 0 END) as submits,
  SUM(CASE WHEN event_name = 'otp_sent' THEN 1 ELSE 0 END) as otp_sent,
  SUM(CASE WHEN event_name = 'otp_verified' THEN 1 ELSE 0 END) as otp_verified,
  SUM(CASE WHEN event_name = 'lead_created' THEN 1 ELSE 0 END) as leads_created
FROM events_table
WHERE event_date BETWEEN '2025-09-01' AND '2025-09-15'
GROUP BY event_date
ORDER BY event_date;




-- QLR % over a period (example)
WITH leads AS (
  SELECT lead_id,
         MAX(CASE WHEN event_name = 'lead_created' THEN 1 ELSE 0 END) AS created,
         MAX(CASE WHEN event_name = 'otp_verified' THEN 1 ELSE 0 END) AS otp_verified,
         MAX(CASE WHEN event_name = 'dealer_contact_attempted' THEN 1 ELSE 0 END) AS contacted
  FROM events_table
  WHERE event_date BETWEEN '2025-09-01' AND '2025-09-15'
  GROUP BY lead_id
)
SELECT
  COUNT(*) AS total_leads,
  SUM(CASE WHEN otp_verified = 1 AND contacted = 1 THEN 1 ELSE 0 END) AS qualified_leads,
  ROUND(100.0 * SUM(CASE WHEN otp_verified = 1 AND contacted = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS qlr_pct
FROM leads;


SELECT
  COUNT(*) FILTER (WHERE event_name = 'otp_sent') AS otp_sent_count,
  COUNT(*) FILTER (WHERE event_name = 'otp_verified') AS otp_verified_count,
  ROUND(100.0 * COUNT(*) FILTER (WHERE event_name = 'otp_verified') / NULLIF(COUNT(*) FILTER (WHERE event_name = 'otp_sent'),0),2) AS otp_success_pct
FROM events_table
WHERE event_date BETWEEN '2025-09-01' AND '2025-09-15';
