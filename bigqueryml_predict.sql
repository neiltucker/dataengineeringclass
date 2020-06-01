# Verify that the model bqml_lab.model_2017 already exists
SELECT country, SUM(predicted_label) as total_predicted_purchases
FROM ML.PREDICT(MODEL `bqml_lab.model_2017`, (
SELECT
  IFNULL(device.operatingSystem, "") AS os,
  device.isMobile AS is_mobile,
  IFNULL(totals.pageviews, 0) AS pageviews,
  IFNULL(geoNetwork.country, "") AS country
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170201' AND '20170331'))
GROUP BY country
ORDER BY total_predicted_purchases DESC
LIMIT 10
