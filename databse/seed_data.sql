-- Clear out existing seed data if re-running (optional, safe for clean initialization)
TRUNCATE TABLE transactions, orders, users RESTART IDENTITY CASCADE;

-- Insert Users (Diverse developer profiles)
INSERT INTO users (username, email) VALUES 
('alice_dev', 'alice@example.com'),
('bob_backend', 'bob@example.com'),
('charlie_data', 'charlie@example.com'),
('dev_guru', 'dev@example.com'),
('aryan_s', 'aryan@example.com'),
('alidev', 'alie@example.com'),
('priya_eng', 'priya@example.com'),
('rohan_db', 'rohan@example.com'),
('sneha_cloud', 'sneha@example.com'),
('vikram_sys', 'vikram@example.com');

-- Insert Orders (Varying amounts, statuses, and user distributions)
INSERT INTO orders (user_id, total_amount, status) VALUES 
-- Alice's orders
(1, 150.00, 'completed'),
(1, 154.00, 'pending'),
(1, 153.00, 'completed'),
(1, 120.00, 'pending'),
(1, 89.99, 'completed'),

-- Bob's orders
(2, 299.99, 'pending'),
(2, 450.50, 'completed'),
(2, 75.00, 'cancelled'),

-- Charlie's orders
(3, 1250.00, 'completed'),
(3, 310.00, 'completed'),

-- Dev Guru's orders
(4, 55.00, 'completed'),
(4, 620.00, 'pending'),

-- Aryan's orders
(5, 410.00, 'completed'),
(5, 99.00, 'completed'),

-- Alidev's orders
(6, 180.00, 'completed'),

-- Priya's orders
(7, 950.00, 'completed'),
(7, 45.00, 'pending'),

-- Rohan's orders
(8, 330.00, 'completed'),
(8, 120.00, 'completed'),

-- Sneha's orders
(9, 890.00, 'completed'),

-- Vikram's orders
(10, 450.00, 'pending'),
(10, 110.00, 'completed');

-- Insert Transactions (Linking successful/paid orders to payment gateways)
INSERT INTO transactions (order_id, gateway, amount) VALUES 
(1, 'stripe', 150.00),
(3, 'paypal', 153.00),
(5, 'stripe', 89.99),
(7, 'stripe', 450.50),
(9, 'apple_pay', 1250.00),
(10, 'stripe', 310.00),
(11, 'paypal', 55.00),
(13, 'stripe', 410.00),
(14, 'paypal', 99.00),
(15, 'stripe', 180.00),
(16, 'apple_pay', 950.00),
(18, 'stripe', 330.00),
(19, 'paypal', 120.00),
(20, 'stripe', 890.00),
(22, 'stripe', 110.00);