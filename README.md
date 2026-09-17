```markdown
# High-Throughput E-Commerce NoSQL Management System

A distributed, query-optimized NoSQL database architecture built on **Apache Cassandra** engineered to support high-throughput, write-heavy e-commerce transactional workloads. 

This system demonstrates advanced NoSQL data modeling techniques, transitioning away from traditional relational joins toward query-first table designs. By utilizing strategic partition key hashing, hardware-level clustering order, automated data lifecycle policies (TTL), and Size-Tiered Compaction Strategy (STCS), the architecture guarantees scalable, sub-10ms read/write latencies.

---

## 🚀 Key Architectural Highlights

* **Query-Driven Data Modeling:** Engineered denormalized data models (`orders_by_user`, `order_items`) designed around strict read patterns, eliminating multi-table joins and preventing cross-node cluster hops.
* **Single-Partition Routing:** Partitioned the `orders_by_user` table by `user_id` and clustered by `order_date DESC`. This enforces physical on-disk chronological ordering to stream a customer's recent orders instantly via single-partition reads.
* **Storage Optimization & Compaction:** Configured **Size-Tiered Compaction Strategy (STCS)** tailored specifically for write-heavy, append-only order ingestion, minimizing disk I/O fragmentation and write amplification.
* **Automated Data Retention (TTL):** Applied native **Time-To-Live (TTL)** policies (`604800` seconds / 7 days) for transient/cancelled order states, automating database pruning without the need for expensive background cleanup batch jobs.
* **Performance Tracing & Latency Benchmarks:** Validated query paths via Cassandra's native `TRACING` utility; confirmed the absolute elimination of full-table scans with end-to-end execution latencies bounded between **2–10 ms**.
* **Cluster Reliability:** Monitored cluster ring status, token distributions, and load using `nodetool status`, ensuring zero node hotspots and active **Up/Normal (UN)** status across all replicas.

---

## 🛠️ Data Model & Access Patterns

### Schema Overview

```sql
ecommerce (Keyspace: NetworkTopologyStrategy, RF=3)
 ├── users              -> PRIMARY KEY (user_id)
 ├── orders_by_user     -> PRIMARY KEY ((user_id), order_date) WITH CLUSTERING ORDER BY (order_date DESC)
 └── order_items        -> PRIMARY KEY ((order_id), item_id)

```

| Table | Partition Key | Clustering Column | Target Application Query |
| --- | --- | --- | --- |
| `users` | `user_id` | *None* | Lookup user profile information by unique ID. |
| `orders_by_user` | `user_id` | `order_date DESC` | Stream order history for a specific customer, sorted most recent first. |
| `order_items` | `order_id` | `item_id ASC` | Retrieve all line items and pricing totals associated with a specific order ID. |

---

## 💻 Tech Stack & Utilities

* **Database Engine:** Apache Cassandra 5.0+ (NoSQL / Distributed LSM-tree)
* **Query Interface:** CQL (Cassandra Query Language)
* **Application Client:** Python 3.10+, `cassandra-driver` (DataStax)
* **Cluster Management & Monitoring:** Nodetool

### File Structure

| File | Description |
| --- | --- |
| `schema.cql` | DDL and DML scripts generating the keyspace, tables, clustering logic, and seed data. |
| `app.py` | Python DataStax driver script establishing cluster connection and executing CRUD operations. |
| `ecommerce_report.pdf` | Comprehensive architectural documentation, tracing proofs, and cluster health evaluations. |
| `requirements.txt` | Python package dependencies. |

---

## ⚡ Local Setup & Execution

### 1. Prerequisites

Ensure Apache Cassandra is installed and running locally. Verify cluster health:

```bash
nodetool status

```

### 2. Deploy the Keyspace and Schema

Launch CQLSH and execute the schema initialization script:

```bash
cqlsh -f schema.cql

```

### 3. Run Application Client (Python)

Initialize your virtual environment, install the driver, and run the parameterized script:

```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
python3 app.py

```

### 4. Query Performance Tracing

To verify single-partition routing and sub-10ms latencies, open `cqlsh` and enable tracing:

```sql
USE ecommerce;
TRACING ON;
SELECT * FROM orders_by_user WHERE user_id = 2d5b8400-3c9e-11ee-be56-0242ac120002;
TRACING OFF;

```

```

```
