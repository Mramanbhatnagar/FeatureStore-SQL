-- 1. Create a Composite Index optimized for time-series window slicing
CREATE INDEX idx_clickstream_user_time 
ON clickstream_events (user_id, timestamp, event_type);

-- 2. Create an index on the Feature Store table for instant model scoring lookups
CREATE UNIQUE INDEX idx_user_features_lookup 
ON user_features (user_id);

-- Explain plan analyzer check to prove index usage
EXPLAIN ANALYZE
SELECT total_clicks_7d, purchase_conversion_rate, preferred_category
FROM user_features
WHERE user_id = 1;
