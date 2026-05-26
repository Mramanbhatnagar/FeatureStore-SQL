-- Create an Automated Feature Generation Procedure
CREATE OR REPLACE PROCEDURE refresh_ml_feature_store()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Upsert features to prevent duplicate keys and keep pipeline idempotent
    INSERT INTO user_features (
        user_id, 
        total_clicks_7d, 
        purchase_conversion_rate, 
        preferred_category, 
        avg_session_duration_30d, 
        last_updated_at
    )
    WITH time_bounded_clicks AS (
        -- AI Window Function: Count clicks within the last 7 days from reference date
        SELECT 
            user_id,
            COUNT(*) FILTER (WHERE event_type = 'click') AS clicks_7d,
            AVG(interaction_duration_secs) FILTER (WHERE timestamp >= NOW() - INTERVAL '30 days') AS avg_dur_30d
        FROM clickstream_events
        WHERE timestamp >= NOW() - INTERVAL '30 days'
        GROUP BY user_id
    ),
    conversion_metrics AS (
        -- Advanced Aggregation for conversion ratios (critical target for ML models)
        SELECT 
            user_id,
            COUNT(*) FILTER (WHERE event_type = 'purchase')::NUMERIC / 
            NULLIF(COUNT(*) FILTER (WHERE event_type = 'click'), 0)::NUMERIC AS conversion_rate
        FROM clickstream_events
        GROUP BY user_id
    ),
    category_preferences AS (
        -- Analytical Window Partitioning to find each user's favorite product category
        SELECT DISTINCT ON (user_id)
            user_id,
            category
        FROM (
            SELECT 
                ce.user_id,
                i.category,
                COUNT(*) as interaction_count,
                DENSE_RANK() OVER (PARTITION BY ce.user_id ORDER BY COUNT(*) DESC, i.category ASC) as rank
            FROM clickstream_events ce
            JOIN items i ON ce.item_id = i.item_id
            GROUP BY ce.user_id, i.category
        ) ranked_categories
        WHERE rank = 1
    )
    SELECT 
        u.user_id,
        COALESCE(tbc.clicks_7d, 0),
        COALESCE(cm.conversion_rate, 0.0000),
        COALESCE(cp.category, 'Unknown'),
        COALESCE(tbc.avg_dur_30d, 0.00),
        CURRENT_TIMESTAMP
    FROM users u
    LEFT JOIN time_bounded_clicks tbc ON u.user_id = tbc.user_id
    LEFT JOIN conversion_metrics cm ON u.user_id = cm.user_id
    LEFT JOIN category_preferences cp ON u.user_id = cp.user_id
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        total_clicks_7d = EXCLUDED.total_clicks_7d,
        purchase_conversion_rate = EXCLUDED.purchase_conversion_rate,
        preferred_category = EXCLUDED.preferred_category,
        avg_session_duration_30d = EXCLUDED.avg_session_duration_30d,
        last_updated_at = EXCLUDED.last_updated_at;
END;
$$;

-- Run pipeline calculation
CALL refresh_ml_feature_store();

-- Verify calculation output
SELECT * FROM user_features;
