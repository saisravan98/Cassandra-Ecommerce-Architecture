-- ==========================================================
-- E-Commerce High-Throughput NoSQL Architecture (Apache Cassandra)
-- Keyspace: Multi-DC replication strategy for fault-tolerance
-- ==========================================================

CREATE KEYSPACE IF NOT EXISTS ecommerce
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'datacenter1': 3
};

USE ecommerce;

-- ----------------------------------------------------------
-- 1. Users Table (Core entity profile lookup)
-- Partition Key: user_id (uniform distribution across token ring)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id UUID,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP,
    PRIMARY KEY (user_id)
);

-- ----------------------------------------------------------
-- 2. Orders By User Table (Query-first access pattern)
-- Partition Key: user_id (single-node partition routing)
-- Clustering Key: order_date DESC (hardware-level chronological sorting)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders_by_user (
    user_id UUID,
    order_date TIMESTAMP,
    order_id UUID,
    total DECIMAL,
    status TEXT,
    PRIMARY KEY ((user_id), order_date)
) WITH CLUSTERING ORDER BY (order_date DESC)
  AND compaction = { 'class': 'SizeTieredCompactionStrategy' };

-- ----------------------------------------------------------
-- 3. Order Items Table (Line-item retrieval per transaction)
-- Partition Key: order_id (co-locates all items of an order)
-- Clustering Key: item_id (unique line item isolation)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
    order_id UUID,
    item_id UUID,
    product_id UUID,
    product_name TEXT,
    quantity INT,
    price DECIMAL,
    PRIMARY KEY ((order_id), item_id)
);

-- ----------------------------------------------------------
-- Seed Data & Access Pattern Verification
-- ----------------------------------------------------------
INSERT INTO users (user_id, name, email, created_at)
VALUES (2d5b8400-3c9e-11ee-be56-0242ac120002, 'Alice Smith', 'alice@example.com', toTimestamp(now()));

-- Seed active order
INSERT INTO orders_by_user (user_id, order_date, order_id, total, status)
VALUES (2d5b8400-3c9e-11ee-be56-0242ac120002, toTimestamp(now()), 6f5d7c90-3c9e-11ee-be56-0242ac120002, 149.99, 'shipped');

-- Seed line items
INSERT INTO order_items (order_id, item_id, product_id, product_name, quantity, price)
VALUES (6f5d7c90-3c9e-11ee-be56-0242ac120002, uuid(), uuid(), 'Bluetooth Speaker', 2, 74.99);

-- Transient cart / cancellation retention via TTL (Auto-expire in 7 days = 604800s)
INSERT INTO orders_by_user (user_id, order_date, order_id, total, status)
VALUES (2d5b8400-3c9e-11ee-be56-0242ac120002, toTimestamp(now()), uuid(), 59.99, 'cancelled')
USING TTL 604800;
