# EcommerceStore-relationaldb
# Question 1: Build a Complete Database Management System

# Objective:
Design and implement a full-featured relational database using MySQL.

# Instructions:
Choose a real-world use case (e.g., Library Management, Student Records, Clinic Booking System, Inventory Tracking, E-commerce Store, etc.).
Create a relational database schema that includes:
Well-structured tables.
Proper constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE).
Relationships (One-to-One, One-to-Many, Many-to-Many, where applicable).
Use SQL to implement your design. 

# Deliverables:
A single .sql file containing:
CREATE DATABASE statement
CREATE TABLE statements
Relationship constraints

## a mysql relational database on ecommerce store

## 📝 Overview
This project contains a **MySQL relational database schema** for an **E-commerce Store**. The schema is implemented in the file **`ecommerce_schema.sql`**. It demonstrates database design principles such as normalization, relationships, constraints, and indexing.

The schema is designed to support typical e-commerce functionality, including managing customers, products, categories, orders, payments, and reviews.

---

## 🎯 Question 1 Requirements & How They Were Met

### **1. Well-structured tables**
- Each entity (e.g., `customers`, `products`, `orders`) is represented by a dedicated table.
- Columns are typed appropriately (e.g., `VARCHAR` for text, `DECIMAL` for prices, `TIMESTAMP` for dates).

### **2. Proper constraints**
- **PRIMARY KEY**: Every table has a unique identifier (e.g., `customer_id`, `product_id`).
- **FOREIGN KEY**: Used to link related tables (e.g., `orders.customer_id → customers.customer_id`).
- **NOT NULL**: Ensures important fields (e.g., `email`, `price`) must always have values.
- **UNIQUE**: Prevents duplicates in critical fields (e.g., `email` in `customers`, `sku` in `products`).

### **3. Relationships**
- **One-to-Many**: A customer can have many orders (`customers → orders`).
- **One-to-Many**: A customer can have multiple addresses (`customers → addresses`).
- **Many-to-Many**: Products can belong to multiple categories (`products ↔ categories` via `product_categories`).
- **One-to-One (logical)**: Each order can have one payment (`orders → payments`).

### **4. Indexes**
- Indexes were added to speed up queries, e.g., searching for products by `name`, or filtering customers by `created_at`.

---

## 🏗️ Schema Explanation (File: `ecommerce_schema.sql`)

The schema is broken down into key components:

### **1. Customers & Addresses**
- `customers`: Stores basic user info (`first_name`, `last_name`, `email`, `password_hash`).
- `addresses`: A customer can have multiple addresses (home, work). Linked via `customer_id`.

### **2. Categories & Products**
- `categories`: Organizes products (supports parent-child for subcategories).
- `products`: Each product has an SKU, name, description, price, supplier, and active status.
- `product_categories`: Junction table to handle many-to-many between products and categories.

### **3. Suppliers & Inventory**
- `suppliers`: Tracks supplier information.
- `inventories`: Keeps track of stock levels for products and triggers reorder alerts if stock is low.

### **4. Orders & Order Items**
- `orders`: Tracks purchases. Includes references to `customers` and shipping/billing `addresses`.
- `order_items`: Junction table connecting orders and products (captures `quantity`, `unit_price`, `line_total`).

### **5. Payments**
- `payments`: Tracks payments for orders (method, status, transaction reference).
- Linked to `orders` by `order_id`.

### **6. Product Reviews**
- `product_reviews`: Customers can review products with a rating (1–5), title, and body.
- Enforces **one review per customer per product** with a `UNIQUE` constraint.

### **7. Constraints & Data Integrity**
- `ON DELETE CASCADE`: Deleting a customer removes their addresses and reviews.
- `ON DELETE RESTRICT`: Orders cannot exist without valid customers.
- `ON DELETE SET NULL`: Optional fields like `supplier_id` can be null if a supplier is removed.

### **8. Indexes**
- `idx_products_name`: Improves search performance on product names.
- `idx_customers_created`: Helps queries that sort/filter customers by sign-up date.


---

## 📚 Why InnoDB?
- Supports **transactions** (`COMMIT`, `ROLLBACK`), ensuring reliable e-commerce operations.
- Allows **foreign keys**, essential for enforcing relationships.
- Provides **row-level locking**, which is efficient for multi-user systems.
- Ensures **crash recovery** for data integrity.

---

## ✅ Deliverable Summary
- **`CREATE DATABASE` statement**: Initializes the schema.
- **`CREATE TABLE` statements**: Define all entities.
- **Constraints**: Ensure data integrity.
- **Relationships**: Implement one-to-one, one-to-many, and many-to-many.
- **Indexes**: Improve query performance.



