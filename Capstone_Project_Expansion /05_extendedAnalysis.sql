-- Q1: Does weather affect daily attendance?
SELECT
  w.condition_code,
  ROUND(AVG(daily.visit_count)) AS avg_daily_visits,
  ROUND(AVG(daily.avg_spend_usd)) AS avg_spend_per_day
FROM dim_weather w
LEFT JOIN (
  SELECT
    date_id,
    COUNT(DISTINCT visit_id) AS visit_count,
    AVG(spend_cents_clean / 100.0) AS avg_spend_usd
  FROM fact_visits
  GROUP BY date_id
) daily ON daily.date_id = w.date_id
GROUP BY w.condition_code
ORDER BY avg_daily_visits DESC;

-- Q2: Do guests spend more on rainy days (captive audience → more food/merch)?
SELECT
  w.condition_code,
  ROUND(AVG(p.amount_cents_clean / 100.0)) AS avg_purchase_usd,
  COUNT(p.purchase_id) AS total_purchases
FROM dim_weather w
JOIN fact_visits v ON v.date_id = w.date_id
JOIN fact_purchases p ON p.visit_id = v.visit_id
GROUP BY w.condition_code
ORDER BY avg_purchase_usd DESC;

-- Q3: Weather impact on ride satisfaction and wait times
SELECT
  w.condition_code,
  a.category AS ride_category,
  ROUND(AVG(re.wait_minutes)) AS avg_wait,
  ROUND(AVG(re.satisfaction_rating)) AS avg_satisfaction
FROM dim_weather w
JOIN fact_visits v ON v.date_id = w.date_id
JOIN fact_ride_events re ON re.visit_id = v.visit_id
JOIN dim_attraction a ON a.attraction_id = re.attraction_id
WHERE re.wait_minutes IS NOT NULL
GROUP BY w.condition_code, a.category
ORDER BY w.condition_code, a.category;

