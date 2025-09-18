-- E-commerce store schema for MySQL
-- File: ecommerce_schema.sql
-- Encoded for MySQL (InnoDB)

CREATE DATABASE `ecommerce_store` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
USE `ecommerce_store`;


-- Customers

CREATE TABLE `customers` (
  `customer_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(30) DEFAULT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `uk_customers_email` (`email`)
) ENGINE=InnoDB;


-- Addresses (one customer can have many addresses)

CREATE TABLE `addresses` (
  `address_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `label` VARCHAR(50) DEFAULT 'home', -- e.g., home, work
  `street` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(100) DEFAULT NULL,
  `postal_code` VARCHAR(20) DEFAULT NULL,
  `country` VARCHAR(100) NOT NULL,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_addresses_customer` (`customer_id`),
  CONSTRAINT `fk_addresses_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Categories (hierarchical via parent_id)

CREATE TABLE `categories` (
  `category_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `parent_id` INT UNSIGNED DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_categories_slug` (`slug`),
  CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Suppliers

CREATE TABLE `suppliers` (
  `supplier_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `contact_email` VARCHAR(255) DEFAULT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB;


-- Products

CREATE TABLE `products` (
  `product_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sku` VARCHAR(64) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `supplier_id` INT UNSIGNED DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uk_products_sku` (`sku`),
  KEY `idx_products_supplier` (`supplier_id`),
  CONSTRAINT `fk_products_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Product <-> Category (many-to-many)

CREATE TABLE `product_categories` (
  `product_id` BIGINT UNSIGNED NOT NULL,
  `category_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`product_id`,`category_id`),
  KEY `idx_product_categories_category` (`category_id`),
  CONSTRAINT `fk_pc_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Inventory (stock per product, per supplier warehouse optional)

CREATE TABLE `inventories` (
  `inventory_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  `reorder_level` INT NOT NULL DEFAULT 0,
  `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  KEY `idx_inventories_product` (`product_id`),
  CONSTRAINT `fk_inventories_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Orders

CREATE TABLE `orders` (
  `order_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `shipping_address_id` BIGINT UNSIGNED DEFAULT NULL,
  `billing_address_id` BIGINT UNSIGNED DEFAULT NULL,
  `order_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `subtotal` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `shipping_cost` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `tax` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `total` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`order_id`),
  KEY `idx_orders_customer` (`customer_id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_shipping_address` FOREIGN KEY (`shipping_address_id`) REFERENCES `addresses` (`address_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_billing_address` FOREIGN KEY (`billing_address_id`) REFERENCES `addresses` (`address_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Order Items (many-to-many between orders and products)

CREATE TABLE `order_items` (
  `order_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT UNSIGNED NOT NULL DEFAULT 1,
  `unit_price` DECIMAL(12,2) NOT NULL,
  `line_total` DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `idx_order_items_product` (`product_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Payments

CREATE TABLE `payments` (
  `payment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(12,2) NOT NULL,
  `method` ENUM('card','paypal','bank_transfer','cash_on_delivery') NOT NULL,
  `status` ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  `transaction_ref` VARCHAR(255) DEFAULT NULL,
  `paid_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `idx_payments_order` (`order_id`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- Product Reviews (one customer can review many products)

CREATE TABLE `product_reviews` (
  `review_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `rating` TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
  `title` VARCHAR(200) DEFAULT NULL,
  `body` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `idx_reviews_product` (`product_id`),
  KEY `idx_reviews_customer` (`customer_id`),
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reviews_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `uk_review_one_per_customer_product` UNIQUE (`product_id`,`customer_id`)
) ENGINE=InnoDB;


-- Useful indexes (examples)

CREATE INDEX `idx_products_name` ON `products` (`name`(100));
CREATE INDEX `idx_customers_created` ON `customers` (`created_at`);

