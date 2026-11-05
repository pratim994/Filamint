-- Create dedicated replication user and grant permissions
CREATE ROLE filament WITH LOGIN REPLICATION PASSWORD 'secure_filament_password';
GRANT ALL PRIVILEGES ON DATABASE app_db TO filament;

-- Create core application schema tables
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    total_amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    gateway VARCHAR(50),
    amount NUMERIC(10, 2) NOT NULL,
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Establish publication for logical replication decoding
CREATE PUBLICATION filament_pub FOR TABLE users, orders, transactions;




create materialized view cust_fin as
select
    u.user_id as id,
    u.username as customer_name,
    u.email as addr,
    count(distinct o.order_id) as tot_order,
    coalesce(sum(o.total_amount), 0) as tot_order_amt,
    count(distinct t.transaction_id) as total_txn

from user u
left join orders o  on u.user_id = o.user_id
left join transactions t on o.order_id = t.order_id
group by u.user_id, u.username, u.email;


create unique index ifc not exist idx_customer_sum
on cust_fin(id);

refresh materialized view concurrently cust_fin;


SELECT 
    slot_name, 
    active, 
    plugin,
    -- Bytes behind the current WAL head
    pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn) AS byte_lag,
    -- Approximate time lag based on local write time if available
    to_timestamp(lsn_to_number(confirmed_flush_lsn)) as last_flushed_lsn
FROM pg_replication_slots 
WHERE slot_name LIKE '%filament%';



















