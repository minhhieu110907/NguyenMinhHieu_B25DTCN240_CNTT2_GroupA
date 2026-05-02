CREATE DATABASE shopping_management;
USE shopping_management;

-- Bảng Users
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    current_address VARCHAR(255)
);

-- Bảng Categories
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100)
);

-- Bảng Products
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    product_name VARCHAR(100),
    current_price DECIMAL(10, 2), 
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Bảng Orders
CREATE TABLE Orders (
    order_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_address VARCHAR(255), -- Snapshot địa chỉ
    total_money DECIMAL(12, 2),
    status ENUM('Pending', 'Paid', 'Cancelled') DEFAULT 'Pending',
    PRIMARY KEY (order_id, order_date),
    INDEX (user_id), 
    INDEX (status)
) PARTITION BY RANGE (MONTH(order_date)) (
    PARTITION p1 VALUES LESS THAN (2),
    PARTITION p2 VALUES LESS THAN (3),
    PARTITION p3 VALUES LESS THAN (4),
    PARTITION p4 VALUES LESS THAN (5),
    PARTITION p5 VALUES LESS THAN (6),
    PARTITION p6 VALUES LESS THAN (7),
    PARTITION p7 VALUES LESS THAN (8),
    PARTITION p8 VALUES LESS THAN (9),
    PARTITION p9 VALUES LESS THAN (10),
    PARTITION p10 VALUES LESS THAN (11),
    PARTITION p11 VALUES LESS THAN (12),
    PARTITION p12 VALUES LESS THAN MAXVALUE
);

-- Bảng Order_Details: Lưu snapshot giá trị lúc mua 
CREATE TABLE Order_Details (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Thêm 5 Users 
INSERT INTO Users (full_name, email, current_address) VALUES
('Nguyễn Minh Hiếu', 'hieu@ptit.com', 'Hà Nội'),
('Trần Thị B', 'b@gmail.com', 'Hồ Chí Minh'),
('Lê Văn C', 'c@gmail.com', 'Đà Nẵng'),
('Phạm Thị D', 'd@gmail.com', 'Huế'),
('Hoàng Văn E', 'e@gmail.com', 'Cần Thơ');

-- Thêm Categories
INSERT INTO Categories (category_name) VALUES ('Electronics'), ('Clothing');

-- Thêm 5 Products 
INSERT INTO Products (category_id, product_name, current_price, stock_quantity) VALUES
(1, 'Laptop Dell Precision', 2000.00, 15),
(1, 'iPhone 15', 1000.00, 30),
(1, 'Logitech Mouse', 50.00, 100),
(2, 'Áo thun', 20.00, 200),
(2, 'Bàn phím cơ', 150.00, 50);

-- Thêm 5 Orders
INSERT INTO Orders (order_id, user_id, order_date, shipping_address, total_money, status) VALUES
(1, 1, '2026-05-01 10:00:00', 'Hà Nội', 2050.00, 'Paid'),
(2, 2, '2026-06-15 14:30:00', 'Hồ Chí Minh', 1000.00, 'Pending'),
(3, 3, '2026-07-20 09:15:00', 'Đà Nẵng', 60.00, 'Paid'),
(4, 1, '2026-05-25 18:00:00', 'Hà Nội', 1000.00, 'Paid'),
(5, 4, '2026-08-10 11:45:00', 'Huế', 20.00, 'Cancelled');

-- Thêm Order_Details 
INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 2000.00), (1, 3, 1, 50.00),
(2, 2, 1, 1000.00),
(3, 4, 3, 20.00),
(4, 2, 1, 1000.00),
(5, 4, 1, 20.00);

-- Q1. Lấy danh sách tất cả đơn hàng
SELECT o.order_id, o.order_date, u.full_name, o.total_money 
FROM Orders o 
JOIN Users u ON o.user_id = u.user_id;

-- Q2. Tìm tất cả sản phẩm thuộc category = 'Electronics'
SELECT p.* 
FROM Products p 
JOIN Categories c ON p.category_id = c.category_id 
WHERE c.category_name = 'Electronics';

-- Q3. Tìm danh sách users (user_id, full_name, email)
SELECT user_id, full_name, email FROM Users;

-- Q4. Tính tổng số tiền tất cả đơn hàng trong hệ thống.
SELECT SUM(total_money) AS total_revenue FROM Orders;

-- Q5. Tính tổng số lượng sản phẩm đã bán theo từng product
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_quantity 
FROM Products p 
JOIN Order_Details od ON p.product_id = od.product_id 
GROUP BY p.product_id, p.product_name;

-- Q6. Tìm sản phẩm có tổng số lượng bán lớn nhất.
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_quantity 
FROM Products p 
JOIN Order_Details od ON p.product_id = od.product_id 
GROUP BY p.product_id, p.product_name 
ORDER BY total_quantity DESC 
LIMIT 1;

-- Q7. Lấy danh sách đơn hàng kèm số lượng sản phẩm trong đơn
SELECT o.order_id, u.full_name, o.total_money, SUM(od.quantity) AS total_items 
FROM Orders o 
JOIN Users u ON o.user_id = u.user_id 
JOIN Order_Details od ON o.order_id = od.order_id 
GROUP BY o.order_id, u.full_name, o.total_money;

-- Q8. Tìm sản phẩm không xuất hiện trong bất kỳ Order_Details nào (Sản phẩm ế)
SELECT p.* 
FROM Products p 
LEFT JOIN Order_Details od ON p.product_id = od.product_id 
WHERE od.order_id IS NULL;

-- Q9. Tìm danh sách users đã từng mua hàng, kèm số đơn hàng của mỗi user.
SELECT u.user_id, u.full_name, COUNT(o.order_id) AS total_orders 
FROM Users u 
JOIN Orders o ON u.user_id = o.user_id 
GROUP BY u.user_id, u.full_name;

-- Q10. Tìm sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm.
SELECT * FROM Products 
WHERE current_price > (SELECT AVG(current_price) FROM Products);

-- Q11. Tìm users có tổng chi tiêu lớn hơn mức trung bình của tất cả users.
SELECT u.user_id, u.full_name, SUM(o.total_money) AS total_spent 
FROM Users u 
JOIN Orders o ON u.user_id = o.user_id 
GROUP BY u.user_id, u.full_name 
HAVING total_spent > (
    SELECT AVG(user_total) FROM (
        SELECT SUM(total_money) AS user_total FROM Orders GROUP BY user_id
    ) AS avg_table
);

-- Q12. Tìm đơn hàng có giá trị lớn nhất trong hệ thống.
SELECT * FROM Orders ORDER BY total_money DESC LIMIT 1;

-- Q13. Tìm category có tổng doanh thu cao nhất.
-- Sử dụng unit_price lúc mua để tính doanh thu thực tế
SELECT c.category_id, c.category_name, SUM(od.quantity * od.unit_price) AS total_revenue 
FROM Categories c 
JOIN Products p ON c.category_id = p.category_id 
JOIN Order_Details od ON p.product_id = od.product_id 
GROUP BY c.category_id, c.category_name 
ORDER BY total_revenue DESC 
LIMIT 1;

-- Q14. Tìm top 3 sản phẩm bán chạy nhất.
-- Ưu tiên theo quantity giảm dần, nếu bằng nhau thì product_id nhỏ hơn đứng trước.
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_quantity 
FROM Products p 
JOIN Order_Details od ON p.product_id = od.product_id 
GROUP BY p.product_id, p.product_name 
ORDER BY total_quantity DESC, p.product_id ASC 
LIMIT 3;

-- Q15. Tìm users chưa từng đặt bất kỳ đơn hàng nào.
SELECT * FROM Users 
WHERE user_id NOT IN (SELECT user_id FROM Orders);