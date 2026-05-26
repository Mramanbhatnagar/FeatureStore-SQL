-- Drop tables if they exist for clean execution
DROP TABLE IF EXISTS user_features CASCADE;
DROP TABLE IF EXISTS clickstream_events CASCADE;
DROP TABLE IF EXISTS items CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Users Dimension Table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    signup_date TIMESTAMP NOT NULL,
    country VARCHAR(50),
    age_group VARCHAR(10) CHECK (age_group IN ('18-24', '25-34', '35-54', '55+'))
);

-- 2. Items Dimension Table (With Vector Proxy Components)
CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    -- Simulating high-dimensional vector embeddings for AI similarity
    embedding_norm_factor REAL GENERATED ALWAYS AS (SQRT(price)) STORED 
);

-- 3. High-Volume Clickstream Fact Table
CREATE TABLE clickstream_events (
    event_id BIGSERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    item_id INT REFERENCES items(item_id) ON DELETE CASCADE,
    event_type VARCHAR(20) CHECK (event_type IN ('impression', 'click', 'purchase')),
    interaction_duration_secs INT DEFAULT 0,
    timestamp TIMESTAMP NOT NULL
);

-- 4. ML Feature Store (Target Destination Table)
CREATE TABLE user_features (
    user_id INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    total_clicks_7d INT DEFAULT 0,
    purchase_conversion_rate NUMERIC(5, 4) DEFAULT 0.0000,
    preferred_category VARCHAR(50),
    avg_session_duration_30d NUMERIC(8, 2) DEFAULT 0.00,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
