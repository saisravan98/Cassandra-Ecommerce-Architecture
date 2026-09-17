from cassandra.cluster import Cluster
from cassandra.query import SimpleStatement
import uuid
from datetime import datetime

# Connect to Cassandra
cluster = Cluster(['127.0.0.1'])  # Replace with your Cassandra IP or Astra DB connection details
session = cluster.connect('ecommerce')

# Insert a new user
def insert_user(name, email):
    user_id = uuid.uuid4()
    created_at = datetime.now()
    query = """
    INSERT INTO users (user_id, name, email, created_at)
    VALUES (%s, %s, %s, %s)
    """
    session.execute(query, (user_id, name, email, created_at))
    print(f"Inserted user: {name} with ID {user_id}")

# Query orders for a user
def query_orders_by_user(user_id):
    query = SimpleStatement("""
    SELECT * FROM orders_by_user WHERE user_id = %s
    """)
    result = session.execute(query, (user_id,))
    for row in result:
        print(row)

# Example Usage
if __name__ == "__main__":
    # Insert a new user
    insert_user('John Doe', 'johndoe@example.com')

    # Query orders for the user (replace with an actual UUID)
    query_orders_by_user(uuid.UUID('2d5b8400-3c9e-11ee-be56-0242ac120002'))
