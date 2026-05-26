-- Seed Users
INSERT INTO users (signup_date, country, age_group) VALUES
('2026-01-01 10:00:00', 'US', '25-34'),
('2026-02-15 14:30:00', 'CA', '18-24'),
('2026-03-20 09:15:00', 'UK', '35-54');

-- Seed Items
INSERT INTO items (category, price) VALUES
('Electronics', 899.99),
('Electronics', 45.00),
('Books', 15.99),
('Apparel', 49.99);

-- Seed Clickstream Events (Simulating history relative to May 2026)
INSERT INTO clickstream_events (user_id, item_id, event_type, interaction_duration_secs, timestamp) VALUES
(1, 1, 'impression', 5, '2026-05-20 12:00:00'),
(1, 1, 'click', 45, '2026-05-20 12:01:00'),
(1, 1, 'purchase', 0, '2026-05-20 12:05:00'),
(1, 2, 'click', 12, '2026-05-25 15:00:00'),
(2, 3, 'impression', 2, '2026-05-24 08:00:00'),
(2, 3, 'click', 120, '2026-05-24 08:02:00'),
(3, 4, 'impression', 10, '2026-05-25 19:00:00');
