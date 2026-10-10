-- Lab Work 5: Database Constraints
-- Part 1: CHECK Constraints

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

CREATE TABLE products_catalog (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);
-- Task 1.4: Testing CHECK Constraints

-- Valid employees
INSERT INTO employees VALUES
(1, 'John', 'Smith', 25, 3000),
(2, 'Anna', 'Brown', 40, 4500);

-- Invalid: age is below 18
-- INSERT INTO employees VALUES
-- (3, 'Tom', 'Green', 16, 2000);

-- Invalid: salary must be greater than 0
-- INSERT INTO employees VALUES
-- (4, 'Kate', 'White', 30, -100);

-- Valid products
INSERT INTO products_catalog VALUES
(1, 'Laptop', 1000, 800),
(2, 'Phone', 500, 400);

-- Invalid: discount_price must be less than regular_price
-- INSERT INTO products_catalog VALUES
-- (3, 'Tablet', 500, 600);

-- Valid bookings
INSERT INTO bookings VALUES
(1, '2026-10-10', '2026-10-12', 2),
(2, '2026-10-15', '2026-10-18', 5);

-- Invalid: check_out_date must be after check_in_date
-- INSERT INTO bookings VALUES
-- (3, '2026-10-20', '2026-10-19', 2);

-- Invalid: num_guests must be between 1 and 10
-- INSERT INTO bookings VALUES
-- (4, '2026-10-20', '2026-10-22', 11);
-- =========================================
-- Part 2: NOT NULL Constraints
-- Task 2.1: NOT NULL Implementation

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);
-- Task 2.3: Testing NOT NULL Constraints

-- Valid customers
INSERT INTO customers VALUES
(1, 'john@example.com', '123456789', '2026-10-10'),
(2, 'anna@example.com', NULL, '2026-10-10');

-- Invalid: email cannot be NULL
-- INSERT INTO customers VALUES
-- (3, NULL, '987654321', '2026-10-10');

-- Invalid: registration_date cannot be NULL
-- INSERT INTO customers VALUES
-- (4, 'tom@example.com', '555123456', NULL);

-- Valid inventory
INSERT INTO inventory VALUES
(1, 'Laptop', 10, 1200, CURRENT_TIMESTAMP),
(2, 'Mouse', 25, 20, CURRENT_TIMESTAMP);

-- Invalid: quantity cannot be NULL
-- INSERT INTO inventory VALUES
-- (3, 'Keyboard', NULL, 50, CURRENT_TIMESTAMP);

-- Invalid: unit_price must be greater than 0
-- INSERT INTO inventory VALUES
-- (4, 'Monitor', 5, -100, CURRENT_TIMESTAMP);
-- =========================================
-- Part 3: UNIQUE Constraints

-- Task 3.1: Single Column UNIQUE
CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_enrollment
        UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Named UNIQUE Constraints
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

-- Valid users
INSERT INTO users VALUES
(1, 'john_smith', 'john@example.com', CURRENT_TIMESTAMP),
(2, 'anna_brown', 'anna@example.com', CURRENT_TIMESTAMP);

-- Invalid: username must be unique
-- INSERT INTO users VALUES
-- (3, 'john_smith', 'tom@example.com', CURRENT_TIMESTAMP);

-- Invalid: email must be unique
-- INSERT INTO users VALUES
-- (4, 'tom_green', 'john@example.com', CURRENT_TIMESTAMP);

-- Valid course enrollments
INSERT INTO course_enrollments VALUES
(1, 101, 'CS101', 'Fall 2026'),
(2, 101, 'CS102', 'Fall 2026'),
(3, 101, 'CS101', 'Spring 2027');

-- Invalid: same student, course and semester
-- INSERT INTO course_enrollments VALUES
-- (4, 101, 'CS101', 'Fall 2026');
-- =========================================
-- Part 4: PRIMARY KEY Constraints

-- Task 4.1: Single Column Primary Key
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'Sales', 'Astana'),
(3, 'Finance', 'Shymkent');

-- Invalid: duplicate primary key
-- INSERT INTO departments VALUES
-- (1, 'Marketing', 'Almaty');

-- Invalid: primary key cannot be NULL
-- INSERT INTO departments VALUES
-- (NULL, 'HR', 'Astana');

-- Task 4.2: Composite Primary Key
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);
-- Task 4.3: Comparison Exercise
--
-- 1. Difference between UNIQUE and PRIMARY KEY:
-- PRIMARY KEY uniquely identifies each row and cannot be NULL.
-- UNIQUE prevents duplicate values but can allow NULL values.
--
-- 2. Single-column vs. composite PRIMARY KEY:
-- A single-column primary key identifies a row using one column.
-- A composite primary key uses two or more columns together.
--
-- 3. One PRIMARY KEY but multiple UNIQUE constraints:
-- A table has one PRIMARY KEY constraint, which may contain
-- multiple columns. It can have multiple UNIQUE constraints
-- to enforce uniqueness on different columns or combinations.
-- =========================================
-- Part 5: FOREIGN KEY Constraints

-- Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES
(1, 'John Smith', 1, '2025-09-01'),
(2, 'Anna Brown', 2, '2025-10-15'),
(3, 'Tom Green', 3, '2026-01-10');

-- Invalid: dept_id 99 does not exist
-- INSERT INTO employees_dept VALUES
-- (4, 'Kate White', 99, '2026-02-01');

-- Task 5.2: Multiple Foreign Keys
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES
(1, 'George Orwell', 'United Kingdom'),
(2, 'Jane Austen', 'United Kingdom');

INSERT INTO publishers VALUES
(1, 'Penguin Books', 'London'),
(2, 'Oxford Press', 'Oxford');

INSERT INTO books VALUES
(1, '1984', 1, 1, 1949, 'ISBN001'),
(2, 'Animal Farm', 1, 2, 1945, 'ISBN002'),
(3, 'Pride and Prejudice', 2, 1, 1813, 'ISBN003');
-- =========================================
-- Task 5.3: ON DELETE Options

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id)
        ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Books');

INSERT INTO products_fk VALUES
(1, 'Laptop', 1),
(2, 'Keyboard', 1),
(3, 'Novel', 2);

INSERT INTO orders VALUES
(1, '2026-10-10'),
(2, '2026-10-11');

INSERT INTO order_items VALUES
(1, 1, 1, 2),
(2, 1, 2, 1),
(3, 2, 3, 4);

-- Test 1: RESTRICT
-- This should fail because category 1 has products.
-- DELETE FROM categories WHERE category_id = 1;

-- Test 2: CASCADE
-- This should delete order 1 and its associated order_items.
-- DELETE FROM orders WHERE order_id = 1;

-- Verification query for CASCADE:
-- SELECT * FROM order_items;

-- DELETE FROM categories
-- WHERE category_id = 1;
--
-- DELETE FROM orders
-- WHERE order_id = 1;
--
-- SELECT * FROM order_items
-- ORDER BY item_id;
-- Test Results:
-- RESTRICT: Deleting category 1 failed because products reference it.
-- CASCADE: Deleting order 1 automatically deleted its order_items.
-- Verification: Only item_id 3 remained in order_items.
-- =========================================
-- PRIMARY KEY: uniquely identifies each record.
-- FOREIGN KEY: maintains relationships between tables.
-- UNIQUE: prevents duplicate customer email addresses.
-- NOT NULL: requires important fields to contain values.
-- CHECK: validates prices, stock, order status and quantity.
-- ON DELETE RESTRICT: prevents deletion of referenced records.
-- ON DELETE CASCADE: deletes related order details automatically.
-- Part 6: Practical Application
-- Task 6.1: E-commerce Database Design

CREATE TABLE shop_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE shop_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE shop_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES shop_customers(customer_id)
        ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN (
            'pending', 'processing', 'shipped',
            'delivered', 'cancelled'
        )
    )
);

CREATE TABLE shop_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES shop_orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES shop_products(product_id)
        ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);
-- Task 6.1: Insert Sample Data

-- 5 customers
INSERT INTO shop_customers VALUES
(1, 'John Smith', 'john@shop.com', '87010000001', '2026-09-01'),
(2, 'Anna Brown', 'anna@shop.com', '87010000002', '2026-09-02'),
(3, 'Tom Green', 'tom@shop.com', NULL, '2026-09-03'),
(4, 'Kate White', 'kate@shop.com', '87010000004', '2026-09-04'),
(5, 'Mike Black', 'mike@shop.com', '87010000005', '2026-09-05');

-- 5 products
INSERT INTO shop_products VALUES
(1, 'Laptop', 'Gaming laptop', 1200, 10),
(2, 'Mouse', 'Wireless mouse', 25, 50),
(3, 'Keyboard', 'Mechanical keyboard', 75, 30),
(4, 'Monitor', '27-inch monitor', 300, 15),
(5, 'Headphones', 'Wireless headphones', 100, 20);

-- 5 orders
INSERT INTO shop_orders VALUES
(1, 1, '2026-10-01', 1225, 'pending'),
(2, 2, '2026-10-02', 75, 'processing'),
(3, 3, '2026-10-03', 300, 'shipped'),
(4, 4, '2026-10-04', 100, 'delivered'),
(5, 5, '2026-10-05', 400, 'cancelled');

-- 5 order details
INSERT INTO shop_order_details VALUES
(1, 1, 1, 1, 1200),
(2, 1, 2, 1, 25),
(3, 2, 3, 1, 75),
(4, 3, 4, 1, 300),
(5, 4, 5, 1, 100);
-- =========================================
-- Part 6.2: Testing Constraints

-- Test 1: Duplicate customer email (should fail)
-- INSERT INTO shop_customers VALUES
-- (6, 'Test User', 'john@shop.com', NULL, '2026-10-10');

-- Test 2: Negative product price (should fail)
-- INSERT INTO shop_products VALUES
-- (6, 'Bad Product', 'Invalid price', -50, 10);

-- Test 3: Negative stock quantity (should fail)
-- INSERT INTO shop_products VALUES
-- (7, 'Bad Product', 'Invalid stock', 50, -5);

-- Test 4: Invalid order status (should fail)
-- INSERT INTO shop_orders VALUES
-- (6, 1, '2026-10-10', 100, 'unknown');

-- Test 5: Zero order quantity (should fail)
-- INSERT INTO shop_order_details VALUES
-- (6, 1, 1, 0, 1200);

-- Test 6: Non-existent customer (should fail)
-- INSERT INTO shop_orders VALUES
-- (7, 99, '2026-10-10', 100, 'pending');

-- Test Results:
-- UNIQUE: Prevents duplicate customer emails.
-- CHECK: Prevents negative prices and stock, invalid statuses,
-- and quantities that are not positive.
-- FOREIGN KEY: Prevents orders referencing missing customers.