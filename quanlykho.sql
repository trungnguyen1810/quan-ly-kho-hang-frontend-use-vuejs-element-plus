-- =============================================
-- HỆ THỐNG QUẢN LÝ KHO HÀNG CHUYÊN NGHIỆP
-- Database Schema cho MySQL
-- =============================================

-- Tạo database
CREATE DATABASE IF NOT EXISTS warehouse_management
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE warehouse_management;

-- =============================================
-- 1. BẢNG QUẢN LÝ NGƯỜI DÙNG VÀ PHÂN QUYỀN
-- =============================================

-- Bảng vai trò/quyền hạn
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng người dùng
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- =============================================
-- 2. BẢNG QUẢN LÝ KHO VÀ VỊ TRÍ LƯU TRỮ
-- =============================================

-- Bảng kho chính
CREATE TABLE warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    manager_id INT,
    total_capacity DECIMAL(15,3),
    used_capacity DECIMAL(15,3) DEFAULT 0,
    capacity_unit VARCHAR(10) DEFAULT 'm3',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (manager_id) REFERENCES users(id)
);

-- Bảng khu vực trong kho
CREATE TABLE warehouse_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    zone_type ENUM('receiving', 'storage', 'picking', 'shipping', 'quarantine') NOT NULL,
    temperature_min DECIMAL(5,2),
    temperature_max DECIMAL(5,2),
    humidity_min DECIMAL(5,2),
    humidity_max DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE KEY unique_zone_code (warehouse_id, code)
);

-- Bảng vị trí lưu trữ cụ thể (rack/shelf/bin)
CREATE TABLE storage_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zone_id INT NOT NULL,
    code VARCHAR(30) NOT NULL,
    location_type ENUM('rack', 'shelf', 'bin', 'floor') NOT NULL,
    aisle VARCHAR(10),
    rack VARCHAR(10),
    shelf VARCHAR(10),
    bin VARCHAR(10),
    max_weight DECIMAL(10,3),
    max_volume DECIMAL(10,3),
    current_weight DECIMAL(10,3) DEFAULT 0,
    current_volume DECIMAL(10,3) DEFAULT 0,
    barcode VARCHAR(50),
    qr_code VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE,
    is_blocked BOOLEAN DEFAULT FALSE,
    block_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (zone_id) REFERENCES warehouse_zones(id),
    UNIQUE KEY unique_location_code (zone_id, code)
);

-- =============================================
-- 3. BẢNG QUẢN LÝ SẢN PHẨM VÀ DANH MỤC
-- =============================================

-- Bảng danh mục sản phẩm
CREATE TABLE product_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    parent_id INT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_id) REFERENCES product_categories(id)
);

-- Bảng nhà cung cấp
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_code VARCHAR(20),
    payment_terms INT DEFAULT 30,
    credit_limit DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng đơn vị tính
CREATE TABLE units_of_measure (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(10),
    base_unit_id INT NULL,
    conversion_factor DECIMAL(10,6) DEFAULT 1,
    
    FOREIGN KEY (base_unit_id) REFERENCES units_of_measure(id)
);

-- Bảng sản phẩm chính
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT,
    brand VARCHAR(100),
    model VARCHAR(100),
    barcode VARCHAR(50),
    qr_code VARCHAR(100),
    
    -- Đơn vị tính
    base_unit_id INT NOT NULL,
    purchase_unit_id INT,
    sale_unit_id INT,
    
    -- Thông tin vật lý
    weight DECIMAL(10,3),
    length DECIMAL(10,3),
    width DECIMAL(10,3),
    height DECIMAL(10,3),
    volume DECIMAL(10,3),
    
    -- Thông tin kho
    min_stock_level DECIMAL(12,3) DEFAULT 0,
    max_stock_level DECIMAL(12,3),
    reorder_point DECIMAL(12,3),
    reorder_quantity DECIMAL(12,3),
    
    -- Thông tin tài chính
    cost_price DECIMAL(15,4),
    selling_price DECIMAL(15,4),
    
    -- Thông tin bảo quản
    requires_serial BOOLEAN DEFAULT FALSE,
    requires_batch BOOLEAN DEFAULT FALSE,
    requires_expiry BOOLEAN DEFAULT FALSE,
    shelf_life_days INT,
    storage_temperature_min DECIMAL(5,2),
    storage_temperature_max DECIMAL(5,2),
    storage_humidity_min DECIMAL(5,2),
    storage_humidity_max DECIMAL(5,2),
    
    -- Trạng thái
    is_active BOOLEAN DEFAULT TRUE,
    is_sellable BOOLEAN DEFAULT TRUE,
    is_purchasable BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    FOREIGN KEY (base_unit_id) REFERENCES units_of_measure(id),
    FOREIGN KEY (purchase_unit_id) REFERENCES units_of_measure(id),
    FOREIGN KEY (sale_unit_id) REFERENCES units_of_measure(id)
);

-- Bảng nhà cung cấp sản phẩm
CREATE TABLE product_suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supplier_sku VARCHAR(50),
    supplier_name VARCHAR(200),
    cost_price DECIMAL(15,4),
    lead_time_days INT,
    min_order_quantity DECIMAL(12,3),
    is_preferred BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    UNIQUE KEY unique_product_supplier (product_id, supplier_id)
);

-- =============================================
-- 4. BẢNG QUẢN LÝ TỒN KHO
-- =============================================

-- Bảng tồn kho theo sản phẩm và kho
CREATE TABLE inventory_summary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    available_quantity DECIMAL(15,3) DEFAULT 0,
    reserved_quantity DECIMAL(15,3) DEFAULT 0,
    on_order_quantity DECIMAL(15,3) DEFAULT 0,
    total_quantity DECIMAL(15,3) DEFAULT 0,
    average_cost DECIMAL(15,4) DEFAULT 0,
    total_value DECIMAL(18,4) DEFAULT 0,
    last_movement_date TIMESTAMP NULL,
    last_count_date TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE KEY unique_warehouse_product (warehouse_id, product_id)
);

-- Bảng lô hàng (batch/lot)
CREATE TABLE inventory_batches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    serial_number VARCHAR(50),
    quantity DECIMAL(15,3) NOT NULL,
    available_quantity DECIMAL(15,3) NOT NULL,
    cost_price DECIMAL(15,4),
    manufactured_date DATE,
    expiry_date DATE,
    received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    supplier_id INT,
    purchase_order_id INT,
    quality_status ENUM('pending', 'approved', 'rejected', 'quarantine') DEFAULT 'pending',
    notes TEXT,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    UNIQUE KEY unique_batch (warehouse_id, product_id, batch_number, serial_number)
);

-- Bảng vị trí lưu trữ chi tiết
CREATE TABLE inventory_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    location_id INT NOT NULL,
    quantity DECIMAL(15,3) NOT NULL,
    allocated_quantity DECIMAL(15,3) DEFAULT 0,
    last_movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id),
    FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    UNIQUE KEY unique_batch_location (batch_id, location_id)
);

-- =============================================
-- 5. BẢNG PHIẾU NHẬP/XUẤT KHO
-- =============================================

-- Bảng phiếu kho (chung cho nhập/xuất)
CREATE TABLE warehouse_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_code VARCHAR(30) NOT NULL UNIQUE,
    transaction_type ENUM('inbound', 'outbound', 'transfer', 'adjustment', 'cycle_count') NOT NULL,
    warehouse_id INT NOT NULL,
    reference_type VARCHAR(50), -- 'purchase_order', 'sales_order', 'transfer_order', etc.
    reference_id INT,
    reference_code VARCHAR(50),
    
    -- Thông tin đối tác
    partner_type ENUM('supplier', 'customer', 'warehouse') NULL,
    partner_id INT NULL,
    partner_name VARCHAR(200),
    
    -- Thông tin giao dịch
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_date TIMESTAMP NULL,
    completed_date TIMESTAMP NULL,
    
    -- Trạng thái
    status ENUM('draft', 'confirmed', 'in_progress', 'completed', 'cancelled') DEFAULT 'draft',
    
    -- Thông tin người thực hiện
    created_by INT NOT NULL,
    approved_by INT NULL,
    processed_by INT NULL,
    
    -- Ghi chú
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (processed_by) REFERENCES users(id)
);

-- Bảng chi tiết phiếu kho
CREATE TABLE warehouse_transaction_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    batch_number VARCHAR(50),
    serial_number VARCHAR(50),
    location_id INT,
    
    -- Số lượng
    planned_quantity DECIMAL(15,3) NOT NULL,
    actual_quantity DECIMAL(15,3),
    unit_id INT NOT NULL,
    
    -- Giá trị
    unit_cost DECIMAL(15,4),
    total_cost DECIMAL(18,4),
    
    -- Thông tin lô hàng (cho nhập kho)
    manufactured_date DATE,
    expiry_date DATE,
    
    -- Trạng thái
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    
    FOREIGN KEY (transaction_id) REFERENCES warehouse_transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    FOREIGN KEY (unit_id) REFERENCES units_of_measure(id)
);

-- =============================================
-- 6. BẢNG KIỂM KÊ KHO
-- =============================================

-- Bảng kế hoạch kiểm kê
CREATE TABLE cycle_counts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    count_code VARCHAR(30) NOT NULL UNIQUE,
    warehouse_id INT NOT NULL,
    count_type ENUM('full', 'partial', 'abc', 'location', 'product') NOT NULL,
    
    -- Phạm vi kiểm kê
    zone_ids JSON,
    location_ids JSON,
    product_ids JSON,
    category_ids JSON,
    
    -- Thời gian
    planned_date DATE NOT NULL,
    start_date TIMESTAMP NULL,
    end_date TIMESTAMP NULL,
    
    -- Trạng thái và người thực hiện
    status ENUM('planned', 'in_progress', 'completed', 'cancelled') DEFAULT 'planned',
    created_by INT NOT NULL,
    assigned_to JSON, -- Array of user IDs
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Bảng chi tiết kiểm kê
CREATE TABLE cycle_count_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cycle_count_id INT NOT NULL,
    product_id INT NOT NULL,
    location_id INT,
    batch_number VARCHAR(50),
    
    -- Số liệu hệ thống
    system_quantity DECIMAL(15,3) NOT NULL,
    system_cost DECIMAL(15,4),
    
    -- Số liệu thực tế
    counted_quantity DECIMAL(15,3),
    counted_by INT,
    count_date TIMESTAMP NULL,
    
    -- Chênh lệch
    variance_quantity DECIMAL(15,3) GENERATED ALWAYS AS (counted_quantity - system_quantity),
    variance_value DECIMAL(18,4) GENERATED ALWAYS AS ((counted_quantity - system_quantity) * system_cost),
    
    -- Trạng thái
    status ENUM('pending', 'counted', 'adjusted', 'approved') DEFAULT 'pending',
    notes TEXT,
    
    FOREIGN KEY (cycle_count_id) REFERENCES cycle_counts(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    FOREIGN KEY (counted_by) REFERENCES users(id)
);

-- =============================================
-- 7. BẢNG THEO DÕI CHUYỂN ĐỘNG KHO
-- =============================================

-- Bảng lịch sử chuyển động kho (audit trail)
CREATE TABLE inventory_movements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    batch_id INT,
    location_id INT,
    
    -- Thông tin giao dịch
    transaction_id INT,
    transaction_code VARCHAR(30),
    movement_type ENUM('in', 'out', 'transfer', 'adjustment') NOT NULL,
    
    -- Số lượng
    quantity DECIMAL(15,3) NOT NULL,
    unit_id INT NOT NULL,
    unit_cost DECIMAL(15,4),
    total_cost DECIMAL(18,4),
    
    -- Số dư sau giao dịch
    running_balance DECIMAL(15,3),
    
    -- Thông tin thời gian
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    
    -- Tham chiếu
    reference_type VARCHAR(50),
    reference_id INT,
    notes TEXT,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id),
    FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    FOREIGN KEY (transaction_id) REFERENCES warehouse_transactions(id),
    FOREIGN KEY (unit_id) REFERENCES units_of_measure(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_warehouse_product_date (warehouse_id, product_id, movement_date),
    INDEX idx_transaction (transaction_id),
    INDEX idx_movement_date (movement_date)
);

-- =============================================
-- 8. BẢNG CẤU HÌNH HỆ THỐNG
-- =============================================

-- Bảng cấu hình chung
CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- Bảng số sequence cho mã phiếu
CREATE TABLE sequence_numbers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sequence_name VARCHAR(50) NOT NULL UNIQUE,
    prefix VARCHAR(10),
    current_number INT DEFAULT 0,
    increment_by INT DEFAULT 1,
    min_length INT DEFAULT 6,
    reset_yearly BOOLEAN DEFAULT TRUE,
    last_reset_year INT
);

-- =============================================
-- 9. DỮ LIỆU MẪU
-- =============================================

-- Chèn dữ liệu vai trò
INSERT INTO roles (name, description, permissions) VALUES
('Super Admin', 'Quản trị viên hệ thống', '["all"]'),
('Warehouse Manager', 'Quản lý kho', '["warehouse_manage", "inventory_view", "reports_view"]'),
('Inventory Staff', 'Nhân viên kho', '["inventory_manage", "transactions_create"]'),
('Viewer', 'Chỉ xem', '["inventory_view", "reports_view"]');

-- Chèn đơn vị tính cơ bản
INSERT INTO units_of_measure (code, name, symbol) VALUES
('PCS', 'Cái', 'cái'),
('KG', 'Kilogram', 'kg'),
('G', 'Gram', 'g'),
('L', 'Lít', 'l'),
('ML', 'Mililít', 'ml'),
('M', 'Mét', 'm'),
('CM', 'Centimet', 'cm'),
('BOX', 'Thùng', 'thùng'),
('PACK', 'Gói', 'gói');

-- Chèn cấu hình sequence
INSERT INTO sequence_numbers (sequence_name, prefix, current_number, min_length) VALUES
('warehouse_in', 'WI', 0, 6),
('warehouse_out', 'WO', 0, 6),
('transfer', 'TF', 0, 6),
('adjustment', 'ADJ', 0, 6),
('cycle_count', 'CC', 0, 6);

-- Chèn cấu hình hệ thống
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('default_warehouse_id', '1', 'number', 'Kho mặc định'),
('auto_create_location', 'true', 'boolean', 'Tự động tạo vị trí khi nhập hàng'),
('require_approval_inbound', 'false', 'boolean', 'Yêu cầu phê duyệt phiếu nhập'),
('require_approval_outbound', 'true', 'boolean', 'Yêu cầu phê duyệt phiếu xuất'),
('negative_inventory_allowed', 'false', 'boolean', 'Cho phép tồn kho âm'),
('cost_method', 'FIFO', 'string', 'Phương pháp tính giá (FIFO/LIFO/AVG)');

-- =============================================
-- 10. INDEXES VÀ OPTIMIZATIONS
-- =============================================

-- Indexes cho hiệu suất
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_inventory_summary_warehouse ON inventory_summary(warehouse_id);
CREATE INDEX idx_inventory_batches_expiry ON inventory_batches(expiry_date);
CREATE INDEX idx_transactions_date ON warehouse_transactions(transaction_date);
CREATE INDEX idx_transactions_status ON warehouse_transactions(status);
CREATE INDEX idx_locations_zone ON storage_locations(zone_id);
CREATE INDEX idx_locations_available ON storage_locations(is_available);

-- =============================================
-- 11. STORED PROCEDURES CƠ BẢN
-- =============================================

DELIMITER //

-- Procedure cập nhật tồn kho
CREATE PROCEDURE UpdateInventorySummary(
    IN p_warehouse_id INT,
    IN p_product_id INT
)
BEGIN
    DECLARE v_available_qty DECIMAL(15,3) DEFAULT 0;
    DECLARE v_reserved_qty DECIMAL(15,3) DEFAULT 0;
    DECLARE v_avg_cost DECIMAL(15,4) DEFAULT 0;
    DECLARE v_total_value DECIMAL(18,4) DEFAULT 0;
    
    -- Tính tổng số lượng có sẵn
    SELECT COALESCE(SUM(available_quantity), 0) INTO v_available_qty
    FROM inventory_batches 
    WHERE warehouse_id = p_warehouse_id AND product_id = p_product_id;
    
    -- Tính giá trung bình và tổng giá trị
    SELECT 
        COALESCE(AVG(cost_price), 0),
        COALESCE(SUM(available_quantity * cost_price), 0)
    INTO v_avg_cost, v_total_value
    FROM inventory_batches 
    WHERE warehouse_id = p_warehouse_id 
      AND product_id = p_product_id 
      AND available_quantity > 0;
    
    -- Cập nhật hoặc chèn mới
    INSERT INTO inventory_summary (
        warehouse_id, product_id, available_quantity, 
        total_quantity, average_cost, total_value, last_movement_date
    ) VALUES (
        p_warehouse_id, p_product_id, v_available_qty,
        v_available_qty, v_avg_cost, v_total_value, NOW()
    )
    ON DUPLICATE KEY UPDATE
        available_quantity = v_available_qty,
        total_quantity = v_available_qty,
        average_cost = v_avg_cost,
        total_value = v_total_value,
        last_movement_date = NOW();
END //

-- Function tạo mã phiếu tự động
CREATE FUNCTION GenerateTransactionCode(p_sequence_name VARCHAR(50))
RETURNS VARCHAR(30)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_prefix VARCHAR(10);
    DECLARE v_current_number INT;
    DECLARE v_min_length INT;
    DECLARE v_result VARCHAR(30);
    
    -- Lấy thông tin sequence
    SELECT prefix, current_number + 1, min_length
    INTO v_prefix, v_current_number, v_min_length
    FROM sequence_numbers
    WHERE sequence_name = p_sequence_name;
    
    -- Cập nhật số hiện tại
    UPDATE sequence_numbers 
    SET current_number = v_current_number
    WHERE sequence_name = p_sequence_name;
    
    -- Tạo mã
    SET v_result = CONCAT(
        v_prefix,
        DATE_FORMAT(NOW(), '%y%m'),
        LPAD(v_current_number, v_min_length, '0')
    );
    
    RETURN v_result;
END //

DELIMITER ;

-- =============================================
-- 12. VIEWS HỖ TRỢ BÁO CÁO
-- =============================================

-- View tổng quan tồn kho
CREATE VIEW v_inventory_overview AS
SELECT 
    w.name as warehouse_name,
    p.sku,
    p.name as product_name,
    pc.name as category_name,
    s.available_quantity,
    s.reserved_quantity,
    s.total_quantity,
    s.average_cost,
    s.total_value,
    p.min_stock_level,
    p.reorder_point,
    CASE 
        WHEN s.available_quantity <= p.min_stock_level THEN 'Low Stock'
        WHEN s.available_quantity <= p.reorder_point THEN 'Reorder'
        ELSE 'OK'
    END as stock_status
FROM inventory_summary s
JOIN warehouses w ON s.warehouse_id = w.id
JOIN products p ON s.product_id = p.id
LEFT JOIN product_categories pc ON p.category_id = pc.id
WHERE s.total_quantity > 0;

-- View sắp hết hạn
CREATE VIEW v_expiring_products AS
SELECT 
    w.name as warehouse_name,
    p.sku,
    p.name as product_name,
    b.batch_number,
    b.available_quantity,
    b.expiry_date,
    DATEDIFF(b.expiry_date, CURDATE()) as days_to_expiry
FROM inventory_batches b
JOIN warehouses w ON b.warehouse_id = w.id
JOIN products p ON b.product_id = p.id
WHERE b.expiry_date IS NOT NULL 
  AND b.available_quantity > 0
  AND DATEDIFF(b.expiry_date, CURDATE()) <= 30
ORDER BY days_to_expiry ASC;


-- =============================================
-- 13. MODULE QUẢN LÝ ĐƠN HÀNG & PICKING
-- =============================================

-- Bảng khách hàng
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_code VARCHAR(20),
    credit_limit DECIMAL(15,2),
    payment_terms INT DEFAULT 0,
    customer_type ENUM('retail', 'wholesale', 'distributor') DEFAULT 'retail',
    price_group VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng đơn hàng
CREATE TABLE sales_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    
    -- Thông tin đơn hàng
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date TIMESTAMP NULL,
    promised_date TIMESTAMP NULL,
    
    -- Thông tin giao hàng
    delivery_address TEXT,
    delivery_method VARCHAR(50),
    shipping_cost DECIMAL(12,2) DEFAULT 0,
    
    -- Thông tin tài chính  
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Trạng thái
    status ENUM('draft', 'confirmed', 'picking', 'packed', 'shipped', 'delivered', 'cancelled') DEFAULT 'draft',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    
    -- Người xử lý
    sales_person_id INT,
    created_by INT NOT NULL,
    approved_by INT,
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (sales_person_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Bảng chi tiết đơn hàng
CREATE TABLE sales_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    line_number INT NOT NULL,
    
    -- Số lượng
    ordered_quantity DECIMAL(15,3) NOT NULL,
    picked_quantity DECIMAL(15,3) DEFAULT 0,
    shipped_quantity DECIMAL(15,3) DEFAULT 0,
    unit_id INT NOT NULL,
    
    -- Giá
    unit_price DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    line_total DECIMAL(15,2) GENERATED ALWAYS AS (
        (ordered_quantity * unit_price) - discount_amount
    ),
    
    -- Allocation
    allocation_status ENUM('pending', 'partial', 'full') DEFAULT 'pending',
    
    notes TEXT,
    
    FOREIGN KEY (order_id) REFERENCES sales_orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (unit_id) REFERENCES units_of_measure(id),
    UNIQUE KEY unique_order_line (order_id, line_number)
);

-- Bảng phân bổ hàng (allocation)
CREATE TABLE inventory_allocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    batch_id INT NOT NULL,
    location_id INT NOT NULL,
    
    allocated_quantity DECIMAL(15,3) NOT NULL,
    picked_quantity DECIMAL(15,3) DEFAULT 0,
    
    allocation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    allocated_by INT NOT NULL,
    
    status ENUM('allocated', 'picked', 'released') DEFAULT 'allocated',
    
    FOREIGN KEY (order_item_id) REFERENCES sales_order_items(id),
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id),
    FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    FOREIGN KEY (allocated_by) REFERENCES users(id)
);

-- Bảng nhiệm vụ picking
CREATE TABLE picking_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_number VARCHAR(30) NOT NULL UNIQUE,
    warehouse_id INT NOT NULL,
    zone_id INT,
    
    -- Liên kết đơn hàng
    order_ids JSON, -- Array of order IDs
    
    -- Thông tin picking
    picking_method ENUM('order', 'batch', 'zone', 'wave') DEFAULT 'order',
    pick_type ENUM('piece', 'case', 'pallet') DEFAULT 'piece',
    
    -- Thời gian
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    scheduled_date TIMESTAMP NULL,
    started_date TIMESTAMP NULL,
    completed_date TIMESTAMP NULL,
    
    -- Người thực hiện
    assigned_to INT,
    picked_by INT,
    
    -- Trạng thái
    status ENUM('created', 'assigned', 'in_progress', 'completed', 'cancelled') DEFAULT 'created',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    
    -- Thống kê
    total_items INT DEFAULT 0,
    picked_items INT DEFAULT 0,
    total_locations INT DEFAULT 0,
    visited_locations INT DEFAULT 0,
    
    notes TEXT,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (zone_id) REFERENCES warehouse_zones(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    FOREIGN KEY (picked_by) REFERENCES users(id)
);

-- Bảng chi tiết picking
CREATE TABLE picking_task_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    allocation_id INT NOT NULL,
    sequence_number INT NOT NULL,
    
    -- Thông tin sản phẩm
    product_id INT NOT NULL,
    batch_number VARCHAR(50),
    location_id INT NOT NULL,
    
    -- Số lượng
    required_quantity DECIMAL(15,3) NOT NULL,
    picked_quantity DECIMAL(15,3) DEFAULT 0,
    unit_id INT NOT NULL,
    
    -- Trạng thái
    status ENUM('pending', 'picking', 'picked', 'short') DEFAULT 'pending',
    
    -- Thời gian picking
    pick_started_at TIMESTAMP NULL,
    pick_completed_at TIMESTAMP NULL,
    
    -- Ghi chú (lý do short pick, etc.)
    notes TEXT,
    
    FOREIGN KEY (task_id) REFERENCES picking_tasks(id),
    FOREIGN KEY (allocation_id) REFERENCES inventory_allocations(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    FOREIGN KEY (unit_id) REFERENCES units_of_measure(id)
);

-- =============================================
-- 14. MODULE QUẢN LÝ SHIPPING & PACKING
-- =============================================

-- Bảng đơn vị vận chuyển
CREATE TABLE shipping_carriers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    
    -- Cấu hình API tracking
    api_endpoint VARCHAR(500),
    api_key VARCHAR(200),
    tracking_url_template VARCHAR(500),
    
    -- Giá cước
    base_rate DECIMAL(10,2),
    rate_per_kg DECIMAL(10,4),
    rate_per_km DECIMAL(10,4),
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng loại đóng gói
CREATE TABLE packaging_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Kích thước
    length DECIMAL(10,3),
    width DECIMAL(10,3),
    height DECIMAL(10,3),
    weight DECIMAL(10,3),
    max_weight DECIMAL(10,3),
    
    -- Chi phí
    cost DECIMAL(10,2) DEFAULT 0,
    
    is_active BOOLEAN DEFAULT TRUE
);

-- Bảng lô hàng xuất
CREATE TABLE shipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_number VARCHAR(30) NOT NULL UNIQUE,
    warehouse_id INT NOT NULL,
    carrier_id INT,
    
    -- Thông tin giao hàng
    ship_to_name VARCHAR(200) NOT NULL,
    ship_to_address TEXT NOT NULL,
    ship_to_phone VARCHAR(20),
    ship_to_email VARCHAR(100),
    
    -- Thông tin vận chuyển
    service_type VARCHAR(50),
    tracking_number VARCHAR(100),
    
    -- Thời gian
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ship_date TIMESTAMP NULL,
    estimated_delivery TIMESTAMP NULL,
    actual_delivery TIMESTAMP NULL,
    
    -- Trọng lượng & kích thước
    total_weight DECIMAL(10,3),
    total_volume DECIMAL(10,3),
    package_count INT DEFAULT 0,
    
    -- Chi phí
    shipping_cost DECIMAL(12,2),
    insurance_cost DECIMAL(12,2),
    
    -- Trạng thái
    status ENUM('created', 'packed', 'shipped', 'in_transit', 'delivered', 'returned', 'cancelled') DEFAULT 'created',
    
    -- Người xử lý
    created_by INT NOT NULL,
    packed_by INT,
    shipped_by INT,
    
    notes TEXT,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (carrier_id) REFERENCES shipping_carriers(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (packed_by) REFERENCES users(id),
    FOREIGN KEY (shipped_by) REFERENCES users(id)
);

-- Bảng đơn hàng trong lô hàng
CREATE TABLE shipment_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    order_id INT NOT NULL,
    
    FOREIGN KEY (shipment_id) REFERENCES shipments(id),
    FOREIGN KEY (order_id) REFERENCES sales_orders(id),
    UNIQUE KEY unique_shipment_order (shipment_id, order_id)
);

-- Bảng kiện hàng
CREATE TABLE packages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    package_number VARCHAR(30) NOT NULL,
    shipment_id INT NOT NULL,
    packaging_type_id INT,
    
    -- Kích thước thực tế
    length DECIMAL(10,3),
    width DECIMAL(10,3),  
    height DECIMAL(10,3),
    weight DECIMAL(10,3),
    
    -- Tracking
    tracking_number VARCHAR(100),
    
    -- Người đóng gói
    packed_by INT,
    packed_date TIMESTAMP NULL,
    
    notes TEXT,
    
    FOREIGN KEY (shipment_id) REFERENCES shipments(id),
    FOREIGN KEY (packaging_type_id) REFERENCES packaging_types(id),
    FOREIGN KEY (packed_by) REFERENCES users(id),
    UNIQUE KEY unique_package_number (shipment_id, package_number)
);

-- Bảng nội dung kiện hàng
CREATE TABLE package_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    package_id INT NOT NULL,
    order_item_id INT NOT NULL,
    product_id INT NOT NULL,
    batch_number VARCHAR(50),
    serial_number VARCHAR(50),
    
    quantity DECIMAL(15,3) NOT NULL,
    unit_id INT NOT NULL,
    
    FOREIGN KEY (package_id) REFERENCES packages(id),
    FOREIGN KEY (order_item_id) REFERENCES sales_order_items(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (unit_id) REFERENCES units_of_measure(id)
);

-- =============================================
-- 15. MODULE BÁO CÁO VÀ PHÂN TÍCH
-- =============================================

-- Bảng lưu cache báo cáo
CREATE TABLE report_cache (
    id INT AUTO_INCREMENT PRIMARY KEY,
    report_name VARCHAR(100) NOT NULL,
    parameters JSON,
    data JSON,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    generated_by INT,
    
    FOREIGN KEY (generated_by) REFERENCES users(id),
    INDEX idx_report_name (report_name),
    INDEX idx_expires_at (expires_at)
);

-- Bảng KPI dashboard
CREATE TABLE kpi_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,4),
    metric_target DECIMAL(15,4),
    warehouse_id INT,
    period_type ENUM('daily', 'weekly', 'monthly', 'yearly') NOT NULL,
    period_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE KEY unique_metric_period (metric_name, warehouse_id, period_type, period_date)
);

-- =============================================
-- 16. MODULE QUẢN LÝ PURCHASE ORDER
-- =============================================

-- Bảng đơn đặt hàng
CREATE TABLE purchase_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    po_number VARCHAR(30) NOT NULL UNIQUE,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    
    -- Thông tin đơn hàng
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date TIMESTAMP NULL,
    
    -- Thông tin tài chính
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Trạng thái
    status ENUM('draft', 'sent', 'confirmed', 'partial_received', 'received', 'closed', 'cancelled') DEFAULT 'draft',
    
    -- Người xử lý
    buyer_id INT,
    created_by INT NOT NULL,
    approved_by INT,
    
    -- Điều khoản
    payment_terms VARCHAR(100),
    delivery_terms VARCHAR(100),
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Bảng chi tiết đơn đặt hàng
CREATE TABLE purchase_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    line_number INT NOT NULL,
    
    -- Số lượng
    ordered_quantity DECIMAL(15,3) NOT NULL,
    received_quantity DECIMAL(15,3) DEFAULT 0,
    unit_id INT NOT NULL,
    
    -- Giá
    unit_cost DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    line_total DECIMAL(15,2) GENERATED ALWAYS AS (
        (ordered_quantity * unit_cost) - discount_amount
    ),
    
    -- Thông tin giao hàng
    required_date TIMESTAMP NULL,
    
    notes TEXT,
    
    FOREIGN KEY (po_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (unit_id) REFERENCES units_of_measure(id),
    UNIQUE KEY unique_po_line (po_id, line_number)
);

-- =============================================
-- 17. MODULE QUẢN LÝ CHẤT LƯỢNG
-- =============================================

-- Bảng tiêu chuẩn chất lượng
CREATE TABLE quality_standards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    product_category_id INT,
    
    -- Tiêu chí kiểm tra
    inspection_criteria JSON,
    sampling_method ENUM('full', 'random', 'statistical') DEFAULT 'random',
    sample_size_percent DECIMAL(5,2) DEFAULT 10,
    acceptance_level DECIMAL(5,2) DEFAULT 95,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_category_id) REFERENCES product_categories(id)
);

-- Bảng kiểm tra chất lượng
CREATE TABLE quality_inspections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inspection_number VARCHAR(30) NOT NULL UNIQUE,
    batch_id INT NOT NULL,
    standard_id INT,
    
    -- Thông tin kiểm tra
    inspection_type ENUM('incoming', 'production', 'outgoing', 'random') NOT NULL,
    inspection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inspector_id INT NOT NULL,
    
    -- Mẫu kiểm tra
    total_quantity DECIMAL(15,3),
    sample_quantity DECIMAL(15,3),
    
    -- Kết quả
    passed_quantity DECIMAL(15,3) DEFAULT 0,
    failed_quantity DECIMAL(15,3) DEFAULT 0,
    overall_result ENUM('pass', 'fail', 'conditional') DEFAULT 'pass',
    
    -- Actions
    action_required ENUM('none', 'quarantine', 'return', 'rework') DEFAULT 'none',
    
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id),
    FOREIGN KEY (standard_id) REFERENCES quality_standards(id),
    FOREIGN KEY (inspector_id) REFERENCES users(id)
);

-- Bảng chi tiết kiểm tra
CREATE TABLE quality_inspection_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inspection_id INT NOT NULL,
    criteria_name VARCHAR(100) NOT NULL,
    expected_value VARCHAR(100),
    actual_value VARCHAR(100),
    result ENUM('pass', 'fail', 'na') NOT NULL,
    notes TEXT,
    
    FOREIGN KEY (inspection_id) REFERENCES quality_inspections(id)
);

-- =============================================
-- 18. ADVANCED STORED PROCEDURES
-- =============================================

DELIMITER //

-- Procedure phân bổ tồn kho cho đơn hàng (FIFO)
CREATE PROCEDURE AllocateInventoryFIFO(
    IN p_order_item_id INT,
    IN p_required_quantity DECIMAL(15,3)
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_batch_id INT;
    DECLARE v_location_id INT;
    DECLARE v_available_qty DECIMAL(15,3);
    DECLARE v_allocate_qty DECIMAL(15,3);
    DECLARE v_remaining_qty DECIMAL(15,3) DEFAULT p_required_quantity;
    
    DECLARE batch_cursor CURSOR FOR
        SELECT 
            b.id, 
            il.location_id,
            LEAST(il.quantity - il.allocated_quantity, v_remaining_qty) as available_qty
        FROM sales_order_items soi
        JOIN inventory_batches b ON soi.product_id = b.product_id
        JOIN inventory_locations il ON b.id = il.batch_id
        JOIN sales_orders so ON soi.order_id = so.id
        WHERE soi.id = p_order_item_id
          AND b.warehouse_id = so.warehouse_id
          AND il.quantity > il.allocated_quantity
          AND b.available_quantity > 0
        ORDER BY b.received_date ASC, b.id ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN batch_cursor;
    
    allocation_loop: LOOP
        FETCH batch_cursor INTO v_batch_id, v_location_id, v_available_qty;
        
        IF done = 1 OR v_remaining_qty <= 0 THEN
            LEAVE allocation_loop;
        END IF;
        
        SET v_allocate_qty = LEAST(v_available_qty, v_remaining_qty);
        
        IF v_allocate_qty > 0 THEN
            -- Tạo allocation record
            INSERT INTO inventory_allocations (
                order_item_id, batch_id, location_id, 
                allocated_quantity, allocated_by
            ) VALUES (
                p_order_item_id, v_batch_id, v_location_id,
                v_allocate_qty, 1
            );
            
            -- Cập nhật allocated quantity trong location
            UPDATE inventory_locations 
            SET allocated_quantity = allocated_quantity + v_allocate_qty
            WHERE batch_id = v_batch_id AND location_id = v_location_id;
            
            SET v_remaining_qty = v_remaining_qty - v_allocate_qty;
        END IF;
    END LOOP;
    
    CLOSE batch_cursor;
    
    -- Cập nhật trạng thái allocation cho order item
    UPDATE sales_order_items 
    SET allocation_status = CASE 
        WHEN v_remaining_qty = 0 THEN 'full'
        WHEN v_remaining_qty < p_required_quantity THEN 'partial'
        ELSE 'pending'
    END
    WHERE id = p_order_item_id;
    
END //

-- Procedure tự động tạo picking task
CREATE PROCEDURE CreatePickingTask(
    IN p_warehouse_id INT,
    IN p_order_ids JSON,
    IN p_picking_method ENUM('order', 'batch', 'zone', 'wave')
)
BEGIN
    DECLARE v_task_id INT;
    DECLARE v_task_number VARCHAR(30);
    DECLARE v_sequence INT DEFAULT 1;
    
    -- Tạo task number
    SET v_task_number = GenerateTransactionCode('picking_task');
    
    -- Tạo picking task
    INSERT INTO picking_tasks (
        task_number, warehouse_id, order_ids, 
        picking_method, status, total_items
    ) VALUES (
        v_task_number, p_warehouse_id, p_order_ids,
        p_picking_method, 'created', 0
    );
    
    SET v_task_id = LAST_INSERT_ID();
    
    -- Thêm các allocation items vào task
    INSERT INTO picking_task_items (
        task_id, allocation_id, sequence_number,
        product_id, batch_number, location_id,
        required_quantity, unit_id
    )
    SELECT 
        v_task_id,
        ia.id,
        ROW_NUMBER() OVER (ORDER BY sl.aisle, sl.rack, sl.shelf, sl.bin),
        ia.batch_id,
        ib.batch_number,
        ia.location_id,
        ia.allocated_quantity,
        soi.unit_id
    FROM inventory_allocations ia
    JOIN sales_order_items soi ON ia.order_item_id = soi.id
    JOIN sales_orders so ON soi.order_id = so.id
    JOIN inventory_batches ib ON ia.batch_id = ib.id
    JOIN storage_locations sl ON ia.location_id = sl.id
    WHERE JSON_CONTAINS(p_order_ids, CAST(so.id AS JSON))
      AND ia.status = 'allocated';
    
    -- Cập nhật số lượng items
    UPDATE picking_tasks 
    SET total_items = (
        SELECT COUNT(*) FROM picking_task_items WHERE task_id = v_task_id
    )
    WHERE id = v_task_id;
    
    SELECT v_task_id as task_id, v_task_number as task_number;
    
END //

-- Function tính ABC analysis
CREATE FUNCTION CalculateABCCategory(
    p_product_id INT,
    p_warehouse_id INT,
    p_months INT
) RETURNS CHAR(1)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_total_value DECIMAL(18,4);
    DECLARE v_cumulative_percent DECIMAL(5,2);
    
    -- Tính tổng giá trị xuất kho trong period
    SELECT COALESCE(SUM(ABS(quantity) * unit_cost), 0) 
    INTO v_total_value
    FROM inventory_movements 
    WHERE product_id = p_product_id 
      AND warehouse_id = p_warehouse_id
      AND movement_type = 'out'
      AND movement_date >= DATE_SUB(NOW(), INTERVAL p_months MONTH);
    
    -- Tính % tích lũy so với tổng
    SELECT 
        COALESCE(
            100 * SUM(ranked.total_value) / 
            (SELECT SUM(total_values.val) FROM (
                SELECT SUM(ABS(quantity) * unit_cost) as val
                FROM inventory_movements 
                WHERE warehouse_id = p_warehouse_id
                  AND movement_type = 'out'
                  AND movement_date >= DATE_SUB(NOW(), INTERVAL p_months MONTH)
                GROUP BY product_id
            ) total_values), 0
        )
    INTO v_cumulative_percent
    FROM (
        SELECT 
            product_id,
            SUM(ABS(quantity) * unit_cost) as total_value
        FROM inventory_movements 
        WHERE warehouse_id = p_warehouse_id
          AND movement_type = 'out'
          AND movement_date >= DATE_SUB(NOW(), INTERVAL p_months MONTH)
        GROUP BY product_id
        HAVING total_value >= v_total_value
    ) ranked;
    
    RETURN CASE 
        WHEN v_cumulative_percent <= 80 THEN 'A'
        WHEN v_cumulative_percent <= 95 THEN 'B'
        ELSE 'C'
    END;
END //

DELIMITER ;

-- =============================================
-- 19. TRIGGERS TỰ ĐỘNG CẬP NHẬT
-- =============================================

DELIMITER //

-- Trigger cập nhật tồn kho khi có movement
CREATE TRIGGER tr_inventory_movement_after_insert
AFTER INSERT ON inventory_movements
FOR EACH ROW
BEGIN
    CALL UpdateInventorySummary(NEW.warehouse_id, NEW.product_id);
END //

-- Trigger cập nhật used capacity của warehouse
CREATE TRIGGER tr_update_warehouse_capacity
AFTER UPDATE ON inventory_summary
FOR EACH ROW
BEGIN
    UPDATE warehouses 
    SET used_capacity = (
        SELECT COALESCE(SUM(
            s.total_quantity * COALESCE(p.volume, 0)
        ), 0)
        FROM inventory_summary s
        JOIN products p ON s.product_id = p.id
        WHERE s.warehouse_id = NEW.warehouse_id
    )
    WHERE id = NEW.warehouse_id;
END //

-- Trigger tự động tạo batch khi nhập hàng mà chưa có batch
CREATE TRIGGER tr_auto_create_batch
BEFORE INSERT ON warehouse_transaction_items
FOR EACH ROW
BEGIN
    DECLARE v_batch_exists INT DEFAULT 0;
    DECLARE v_transaction_type VARCHAR(20);
    
    -- Lấy loại transaction
    SELECT transaction_type INTO v_transaction_type
    FROM warehouse_transactions 
    WHERE id = NEW.transaction_id;
    
    -- Chỉ xử lý cho inbound transactions
    IF v_transaction_type = 'inbound' AND NEW.batch_number IS NOT NULL THEN
        -- Kiểm tra batch đã tồn tại chưa
        SELECT COUNT(*) INTO v_batch_exists
        FROM inventory_batches 
        WHERE product_id = NEW.product_id 
          AND batch_number = NEW.batch_number;
        
        -- Tạo batch mới nếu chưa có
        IF v_batch_exists = 0 THEN
            INSERT INTO inventory_batches (
                warehouse_id, product_id, batch_number, 
                quantity, available_quantity, cost_price,
                manufactured_date, expiry_date
            ) VALUES (
                (SELECT warehouse_id FROM warehouse_transactions WHERE id = NEW.transaction_id),
                NEW.product_id, NEW.batch_number,
                NEW.planned_quantity, NEW.planned_quantity, NEW.unit_cost,
                NEW.manufactured_date, NEW.expiry_date
            );
        END IF;
    END IF;
END //

DELIMITER ;

-- =============================================
-- 20. VIEWS BÁO CÁO NÂNG CAO
-- =============================================

-- View ABC Analysis
CREATE VIEW v_abc_analysis AS
SELECT 
    w.name as warehouse_name,
    p.sku,
    p.name as product_name,
    pc.name as category_name,
    SUM(ABS(im.quantity * im.unit_cost)) as total_value,
    COUNT(im.id) as movement_count,
    CalculateABCCategory(p.id, w.id, 12) as abc_category,
    s.available_quantity,
    s.total_value as current_value
FROM inventory_movements im
JOIN warehouses w ON im.warehouse_id = w.id
JOIN products p ON im.product_id = p.id
LEFT JOIN product_categories pc ON p.category_id = pc.id
LEFT JOIN inventory_summary s ON im.warehouse_id = s.warehouse_id AND im.product_id = s.product_id
WHERE im.movement_type = 'out'
  AND im.movement_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY im.warehouse_id, im.product_id
ORDER BY total_value DESC;

-- View hiệu suất picking
CREATE VIEW v_picking_performance AS
SELECT 
    u.full_name as picker_name,
    DATE(pt.completed_date) as pick_date,
    COUNT(pt.id) as tasks_completed,
    SUM(pt.total_items) as items_picked,
    AVG(TIMESTAMPDIFF(MINUTE, pt.started_date, pt.completed_date)) as avg_pick_time_minutes,
    SUM(pt.total_items) / AVG(TIMESTAMPDIFF(MINUTE, pt.started_date, pt.completed_date)) as items_per_minute,
    SUM(pt.visited_locations) as locations_visited,
    AVG(pt.visited_locations / pt.total_locations * 100) as location_efficiency_percent
FROM picking_tasks pt
JOIN users u ON pt.picked_by = u.id
WHERE pt.status = 'completed'
  AND pt.completed_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.id, DATE(pt.completed_date)
ORDER BY pick_date DESC, items_per_minute DESC;

-- View tình trạng đơn hàng
CREATE VIEW v_order_status_summary AS
SELECT 
    so.status,
    COUNT(*) as order_count,
    SUM(so.total_amount) as total_value,
    AVG(DATEDIFF(NOW(), so.order_date)) as avg_age_days,
    COUNT(CASE WHEN so.required_date < NOW() THEN 1 END) as overdue_count
FROM sales_orders so
WHERE so.status NOT IN ('delivered', 'cancelled')
GROUP BY so.status
ORDER BY 
    CASE so.status 
        WHEN 'urgent' THEN 1
        WHEN 'high' THEN 2
        WHEN 'normal' THEN 3
        WHEN 'low' THEN 4
    END;

-- View chi phí lưu kho
CREATE VIEW v_storage_cost_analysis AS
SELECT 
    w.name as warehouse_name,
    wz.name as zone_name,
    pc.name as category_name,
    COUNT(DISTINCT sl.id) as total_locations,
    COUNT(DISTINCT il.location_id) as occupied_locations,
    ROUND(COUNT(DISTINCT il.location_id) / COUNT(DISTINCT sl.id) * 100, 2) as occupancy_rate,
    SUM(ib.available_quantity * COALESCE(p.volume, 0)) as total_volume_used,
    SUM(ib.available_quantity * ib.cost_price) as total_inventory_value,
    AVG(DATEDIFF(NOW(), ib.received_date)) as avg_storage_days
FROM warehouses w
JOIN warehouse_zones wz ON w.id = wz.warehouse_id
JOIN storage_locations sl ON wz.id = sl.zone_id
LEFT JOIN inventory_locations il ON sl.id = il.location_id
LEFT JOIN inventory_batches ib ON il.batch_id = ib.id
LEFT JOIN products p ON ib.product_id = p.id
LEFT JOIN product_categories pc ON p.category_id = pc.id
GROUP BY w.id, wz.id, pc.id
ORDER BY w.name, wz.name, total_inventory_value DESC;

-- View sản phẩm chậm luân chuyển
CREATE VIEW v_slow_moving_products AS
SELECT 
    w.name as warehouse_name,
    p.sku,
    p.name as product_name,
    pc.name as category_name,
    s.available_quantity,
    s.total_value,
    s.last_movement_date,
    DATEDIFF(NOW(), s.last_movement_date) as days_since_last_movement,
    COALESCE(recent_movements.movement_count, 0) as movements_last_90_days,
    CASE 
        WHEN DATEDIFF(NOW(), s.last_movement_date) > 365 THEN 'Dead Stock'
        WHEN DATEDIFF(NOW(), s.last_movement_date) > 180 THEN 'Very Slow'
        WHEN DATEDIFF(NOW(), s.last_movement_date) > 90 THEN 'Slow'
        ELSE 'Normal'
    END as movement_category
FROM inventory_summary s
JOIN warehouses w ON s.warehouse_id = w.id
JOIN products p ON s.product_id = p.id
LEFT JOIN product_categories pc ON p.category_id = pc.id
LEFT JOIN (
    SELECT 
        warehouse_id, 
        product_id, 
        COUNT(*) as movement_count
    FROM inventory_movements 
    WHERE movement_date >= DATE_SUB(NOW(), INTERVAL 90 DAY)
      AND movement_type = 'out'
    GROUP BY warehouse_id, product_id
) recent_movements ON s.warehouse_id = recent_movements.warehouse_id 
                  AND s.product_id = recent_movements.product_id
WHERE s.available_quantity > 0
  AND DATEDIFF(NOW(), s.last_movement_date) > 30
ORDER BY days_since_last_movement DESC, s.total_value DESC;

-- =============================================
-- 21. STORED PROCEDURES BÁO CÁO
-- =============================================

DELIMITER //

-- Procedure báo cáo tồn kho theo thời gian
CREATE PROCEDURE GetInventorySnapshot(
    IN p_warehouse_id INT,
    IN p_snapshot_date DATE,
    IN p_product_id INT
)
BEGIN
    CREATE TEMPORARY TABLE temp_snapshot AS
    SELECT 
        im.product_id,
        p.sku,
        p.name as product_name,
        SUM(CASE WHEN im.movement_type = 'in' THEN im.quantity ELSE -im.quantity END) as quantity,
        AVG(im.unit_cost) as avg_cost
    FROM inventory_movements im
    JOIN products p ON im.product_id = p.id
    WHERE im.warehouse_id = COALESCE(p_warehouse_id, im.warehouse_id)
      AND DATE(im.movement_date) <= p_snapshot_date
      AND (p_product_id IS NULL OR im.product_id = p_product_id)
    GROUP BY im.product_id
    HAVING quantity > 0;
    
    SELECT 
        ts.*,
        (ts.quantity * ts.avg_cost) as total_value,
        pc.name as category_name,
        s.name as supplier_name
    FROM temp_snapshot ts
    JOIN products p ON ts.product_id = p.id
    LEFT JOIN product_categories pc ON p.category_id = pc.id
    LEFT JOIN product_suppliers ps ON p.id = ps.product_id AND ps.is_preferred = TRUE
    LEFT JOIN suppliers s ON ps.supplier_id = s.id
    ORDER BY total_value DESC;
    
    DROP TEMPORARY TABLE temp_snapshot;
END //

-- Procedure báo cáo doanh thu theo sản phẩm
CREATE PROCEDURE GetProductSalesReport(
    IN p_warehouse_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_category_id INT
)
BEGIN
    SELECT 
        p.sku,
        p.name as product_name,
        pc.name as category_name,
        SUM(soi.shipped_quantity) as total_quantity_sold,
        SUM(soi.shipped_quantity * soi.unit_price) as total_revenue,
        AVG(soi.unit_price) as avg_selling_price,
        COUNT(DISTINCT so.id) as order_count,
        COUNT(DISTINCT so.customer_id) as customer_count,
        MIN(so.order_date) as first_sale_date,
        MAX(so.order_date) as last_sale_date
    FROM sales_orders so
    JOIN sales_order_items soi ON so.id = soi.order_id
    JOIN products p ON soi.product_id = p.id
    LEFT JOIN product_categories pc ON p.category_id = pc.id
    WHERE so.warehouse_id = COALESCE(p_warehouse_id, so.warehouse_id)
      AND DATE(so.order_date) BETWEEN p_start_date AND p_end_date
      AND so.status IN ('shipped', 'delivered')
      AND (p_category_id IS NULL OR p.category_id = p_category_id)
      AND soi.shipped_quantity > 0
    GROUP BY p.id
    ORDER BY total_revenue DESC;
END //

-- Procedure phân tích hiệu suất kho
CREATE PROCEDURE GetWarehousePerformanceReport(
    IN p_warehouse_id INT,
    IN p_period_months INT
)
BEGIN
    DECLARE v_start_date DATE DEFAULT DATE_SUB(NOW(), INTERVAL p_period_months MONTH);
    
    -- Thống kê tổng quan
    SELECT 
        'Overview' as metric_category,
        'Total Orders Processed' as metric_name,
        COUNT(DISTINCT so.id) as metric_value,
        'orders' as unit
    FROM sales_orders so
    WHERE so.warehouse_id = p_warehouse_id
      AND so.order_date >= v_start_date
    
    UNION ALL
    
    SELECT 
        'Overview' as metric_category,
        'Total Items Shipped' as metric_name,
        SUM(soi.shipped_quantity) as metric_value,
        'items' as unit
    FROM sales_orders so
    JOIN sales_order_items soi ON so.id = soi.order_id
    WHERE so.warehouse_id = p_warehouse_id
      AND so.order_date >= v_start_date
      AND so.status IN ('shipped', 'delivered')
    
    UNION ALL
    
    SELECT 
        'Performance' as metric_category,
        'Average Pick Time' as metric_name,
        AVG(TIMESTAMPDIFF(MINUTE, pt.started_date, pt.completed_date)) as metric_value,
        'minutes' as unit
    FROM picking_tasks pt
    WHERE pt.warehouse_id = p_warehouse_id
      AND pt.completed_date >= v_start_date
      AND pt.status = 'completed'
    
    UNION ALL
    
    SELECT 
        'Performance' as metric_category,
        'Order Fulfillment Rate' as metric_name,
        ROUND(
            COUNT(CASE WHEN so.status IN ('shipped', 'delivered') THEN 1 END) * 100.0 / 
            COUNT(*), 2
        ) as metric_value,
        'percent' as unit
    FROM sales_orders so
    WHERE so.warehouse_id = p_warehouse_id
      AND so.order_date >= v_start_date
      AND so.status != 'cancelled'
    
    UNION ALL
    
    SELECT 
        'Accuracy' as metric_category,
        'Inventory Accuracy' as metric_name,
        ROUND(
            COUNT(CASE WHEN ABS(cci.variance_quantity) <= 0.01 THEN 1 END) * 100.0 / 
            COUNT(*), 2
        ) as metric_value,
        'percent' as unit
    FROM cycle_counts cc
    JOIN cycle_count_items cci ON cc.id = cci.cycle_count_id
    WHERE cc.warehouse_id = p_warehouse_id
      AND cc.end_date >= v_start_date
      AND cci.status = 'approved';
END //

DELIMITER ;

-- =============================================
-- 22. INDEXES BỔ SUNG CHO HIỆU SUẤT
-- =============================================

-- Indexes cho bảng inventory_movements (quan trọng cho performance)
CREATE INDEX idx_movements_warehouse_product_date ON inventory_movements(warehouse_id, product_id, movement_date DESC);
CREATE INDEX idx_movements_type_date ON inventory_movements(movement_type, movement_date);
CREATE INDEX idx_movements_reference ON inventory_movements(reference_type, reference_id);

-- Indexes cho sales orders
CREATE INDEX idx_sales_orders_customer_date ON sales_orders(customer_id, order_date);
CREATE INDEX idx_sales_orders_status_date ON sales_orders(status, order_date);
CREATE INDEX idx_sales_orders_warehouse_date ON sales_orders(warehouse_id, order_date);

-- Indexes cho picking
CREATE INDEX idx_picking_tasks_warehouse_status ON picking_tasks(warehouse_id, status);
CREATE INDEX idx_picking_tasks_assigned_date ON picking_tasks(assigned_to, created_date);
CREATE INDEX idx_picking_items_task_sequence ON picking_task_items(task_id, sequence_number);

-- Indexes cho inventory batches
CREATE INDEX idx_batches_product_expiry ON inventory_batches(product_id, expiry_date);
CREATE INDEX idx_batches_warehouse_product ON inventory_batches(warehouse_id, product_id);
CREATE INDEX idx_batches_received_date ON inventory_batches(received_date);

-- Indexes cho locations
CREATE INDEX idx_locations_warehouse_available ON storage_locations(zone_id, is_available, is_blocked);

-- =============================================
-- 23. CẤU HÌNH PARTITIONING (CHO HỆ THỐNG LỚN)
-- =============================================

-- Partition cho bảng inventory_movements theo tháng (comment out nếu không cần)
/*
ALTER TABLE inventory_movements 
PARTITION BY RANGE (YEAR(movement_date) * 100 + MONTH(movement_date)) (
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION p202404 VALUES LESS THAN (202405),
    PARTITION p202405 VALUES LESS THAN (202406),
    PARTITION p202406 VALUES LESS THAN (202407),
    PARTITION p202407 VALUES LESS THAN (202408),
    PARTITION p202408 VALUES LESS THAN (202409),
    PARTITION p202409 VALUES LESS THAN (202410),
    PARTITION p202410 VALUES LESS THAN (202411),
    PARTITION p202411 VALUES LESS THAN (202412),
    PARTITION p202412 VALUES LESS THAN (202501),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
*/

-- =============================================
-- 24. EVENT SCHEDULERS TỰ ĐỘNG
-- =============================================

-- Bật event scheduler
SET GLOBAL event_scheduler = ON;

DELIMITER //

-- Event tự động cập nhật KPI hàng ngày
CREATE EVENT IF NOT EXISTS ev_daily_kpi_update
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
BEGIN
    -- Cập nhật KPI inventory turnover
    INSERT INTO kpi_metrics (metric_name, metric_value, warehouse_id, period_type, period_date)
    SELECT 
        'inventory_turnover',
        CASE 
            WHEN AVG(s.total_value) > 0 THEN
                SUM(ABS(im.quantity * im.unit_cost)) / AVG(s.total_value)
            ELSE 0
        END,
        im.warehouse_id,
        'daily',
        CURDATE()
    FROM inventory_movements im
    JOIN inventory_summary s ON im.warehouse_id = s.warehouse_id AND im.product_id = s.product_id
    WHERE DATE(im.movement_date) = CURDATE()
      AND im.movement_type = 'out'
    GROUP BY im.warehouse_id
    ON DUPLICATE KEY UPDATE 
        metric_value = VALUES(metric_value);
    
    -- Cập nhật KPI order fulfillment rate
    INSERT INTO kpi_metrics (metric_name, metric_value, warehouse_id, period_type, period_date)
    SELECT 
        'order_fulfillment_rate',
        ROUND(
            COUNT(CASE WHEN status IN ('shipped', 'delivered') THEN 1 END) * 100.0 / 
            COUNT(*), 2
        ),
        warehouse_id,
        'daily',
        CURDATE()
    FROM sales_orders 
    WHERE DATE(order_date) = CURDATE()
      AND status != 'cancelled'
    GROUP BY warehouse_id
    ON DUPLICATE KEY UPDATE 
        metric_value = VALUES(metric_value);
        
    -- Cập nhật KPI storage utilization
    INSERT INTO kpi_metrics (metric_name, metric_value, warehouse_id, period_type, period_date)
    SELECT 
        'storage_utilization',
        ROUND(used_capacity / total_capacity * 100, 2),
        id,
        'daily',
        CURDATE()
    FROM warehouses 
    WHERE total_capacity > 0
    ON DUPLICATE KEY UPDATE 
        metric_value = VALUES(metric_value);
END //

-- Event tự động dọn dẹp dữ liệu cũ
CREATE EVENT IF NOT EXISTS ev_cleanup_old_data
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-01-07 02:00:00'
DO
BEGIN
    -- Xóa report cache cũ hơn 7 ngày
    DELETE FROM report_cache 
    WHERE expires_at < NOW() OR generated_at < DATE_SUB(NOW(), INTERVAL 7 DAY);
    
    -- Xóa KPI metrics cũ hơn 2 năm (chỉ giữ daily)
    DELETE FROM kpi_metrics 
    WHERE period_type = 'daily' 
      AND period_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
      
    -- Archive inventory movements cũ hơn 1 năm (có thể chuyển sang bảng archive)
    -- DELETE FROM inventory_movements 
    -- WHERE movement_date < DATE_SUB(NOW(), INTERVAL 1 YEAR);
END //

-- Event cảnh báo sản phẩm sắp hết hạn
CREATE EVENT IF NOT EXISTS ev_expiry_alerts
ON SCHEDULE EVERY 1 DAY  
STARTS '2024-01-01 08:00:00'
DO
BEGIN
    -- Cập nhật quality status cho batch sắp hết hạn
    UPDATE inventory_batches 
    SET quality_status = 'quarantine',
        notes = CONCAT(COALESCE(notes, ''), ' - Auto quarantined: Expiring soon')
    WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
      AND expiry_date > CURDATE()
      AND quality_status = 'approved'
      AND available_quantity > 0;
      
    -- Log cảnh báo (có thể tích hợp với hệ thống notification)
    INSERT INTO system_settings (setting_key, setting_value, setting_type, description)
    SELECT 
        CONCAT('expiry_alert_', DATE_FORMAT(NOW(), '%Y%m%d')),
        JSON_OBJECT(
            'alert_date', CURDATE(),
            'expired_batches', COUNT(CASE WHEN expiry_date <= CURDATE() THEN 1 END),
            'expiring_soon', COUNT(CASE WHEN expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN 1 END)
        ),
        'json',
        'Daily expiry alert summary'
    FROM inventory_batches 
    WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
      AND available_quantity > 0
    ON DUPLICATE KEY UPDATE 
        setting_value = VALUES(setting_value),
        updated_at = NOW();
END //

DELIMITER ;

-- =============================================
-- 25. FUNCTIONS TIỆN ÍCH BỔ SUNG
-- =============================================

DELIMITER //

-- Function tính lead time trung bình của supplier
CREATE FUNCTION GetSupplierLeadTime(p_supplier_id INT, p_months INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_avg_lead_time DECIMAL(5,2);
    
    SELECT AVG(DATEDIFF(wt.completed_date, po.order_date))
    INTO v_avg_lead_time
    FROM purchase_orders po
    JOIN warehouse_transactions wt ON po.id = wt.reference_id 
    WHERE po.supplier_id = p_supplier_id
      AND wt.reference_type = 'purchase_order'
      AND wt.transaction_type = 'inbound'
      AND wt.status = 'completed'
      AND po.order_date >= DATE_SUB(NOW(), INTERVAL p_months MONTH);
    
    RETURN COALESCE(v_avg_lead_time, 0);
END //

-- Function tính stock coverage (số ngày tồn kho đủ dùng)
CREATE FUNCTION GetStockCoverage(p_product_id INT, p_warehouse_id INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_current_stock DECIMAL(15,3);
    DECLARE v_daily_consumption DECIMAL(15,3);
    DECLARE v_coverage_days INT;
    
    -- Lấy tồn kho hiện tại
    SELECT available_quantity INTO v_current_stock
    FROM inventory_summary 
    WHERE product_id = p_product_id AND warehouse_id = p_warehouse_id;
    
    -- Tính mức tiêu thụ trung bình 30 ngày qua
    SELECT AVG(daily_out) INTO v_daily_consumption
    FROM (
        SELECT 
            DATE(movement_date) as move_date,
            SUM(ABS(quantity)) as daily_out
        FROM inventory_movements 
        WHERE product_id = p_product_id 
          AND warehouse_id = p_warehouse_id
          AND movement_type = 'out'
          AND movement_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        GROUP BY DATE(movement_date)
    ) daily_movements;
    
    -- Tính số ngày coverage
    SET v_coverage_days = CASE 
        WHEN COALESCE(v_daily_consumption, 0) > 0 THEN
            FLOOR(COALESCE(v_current_stock, 0) / v_daily_consumption)
        ELSE 999
    END;
    
    RETURN v_coverage_days;
END //

-- Function tính accuracy rate của cycle count
CREATE FUNCTION GetCycleCountAccuracy(p_warehouse_id INT, p_months INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_accuracy_rate DECIMAL(5,2);
    
    SELECT 
        ROUND(
            COUNT(CASE WHEN ABS(variance_quantity) <= 0.01 THEN 1 END) * 100.0 / 
            COUNT(*), 2
        )
    INTO v_accuracy_rate
    FROM cycle_counts cc
    JOIN cycle_count_items cci ON cc.id = cci.cycle_count_id
    WHERE cc.warehouse_id = p_warehouse_id
      AND cc.end_date >= DATE_SUB(NOW(), INTERVAL p_months MONTH)
      AND cci.status = 'approved';
    
    RETURN COALESCE(v_accuracy_rate, 0);
END //

DELIMITER ;

-- =============================================
-- 26. DỮ LIỆU MẪU BỔ SUNG
-- =============================================

-- Thêm các loại đóng gói phổ biến
INSERT INTO packaging_types (code, name, description, length, width, height, weight, max_weight, cost) VALUES
('BOX_S', 'Thùng carton nhỏ', 'Thùng carton 20x15x10cm', 20, 15, 10, 0.1, 5.0, 5000),
('BOX_M', 'Thùng carton trung', 'Thùng carton 30x25x20cm', 30, 25, 20, 0.2, 10.0, 8000),
('BOX_L', 'Thùng carton lớn', 'Thùng carton 40x35x30cm', 40, 35, 30, 0.3, 20.0, 12000),
('ENVELOPE', 'Túi bao thư', 'Túi bao thư chống nước', 25, 18, 1, 0.01, 0.5, 2000),
('BUBBLE', 'Túi xốp hơi', 'Túi xốp hơi bảo vệ', 30, 20, 5, 0.05, 2.0, 3000);

-- Thêm nhà vận chuyển mẫu
INSERT INTO shipping_carriers (code, name, contact_person, phone, email, base_rate, rate_per_kg) VALUES
('GHTK', 'Giao Hang Tiet Kiem', 'Nguyen Van A', '1900-1234', 'support@ghtk.vn', 15000, 2000),
('GHN', 'Giao Hang Nhanh', 'Tran Thi B', '1900-5678', 'support@ghn.vn', 18000, 2200),
('VIETTEL', 'Viettel Post', 'Le Van C', '1900-9090', 'support@viettelpost.vn', 16000, 2100),
('VNPOST', 'Vietnam Post', 'Pham Thi D', '1900-5454', 'support@vnpost.vn', 12000, 1800);

-- Thêm cấu hình nâng cao
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_system) VALUES
('auto_allocate_orders', 'true', 'boolean', 'Tự động phân bổ hàng khi xác nhận đơn', FALSE),
('picking_sequence_method', 'location', 'string', 'Phương pháp sắp xếp picking (location/product)', FALSE),
('expiry_warning_days', '30', 'number', 'Số ngày cảnh báo trước khi hết hạn', FALSE),
('min_stock_warning', 'true', 'boolean', 'Cảnh báo khi dưới mức tồn tối thiểu', FALSE),
('batch_picking_enabled', 'true', 'boolean', 'Cho phép picking theo batch', FALSE),
('quality_inspection_required', 'false', 'boolean', 'Bắt buộc kiểm tra chất lượng khi nhập', FALSE),
('barcode_verification_required', 'true', 'boolean', 'Bắt buộc scan barcode khi picking', FALSE),
('location_verification_required', 'true', 'boolean', 'Bắt buộc xác nhận vị trí khi picking', FALSE);

-- =============================================
-- 27. FINAL DOCUMENTATION & NOTES
-- =============================================

/*
=================================================================
               HƯỚNG DẪN SỬ DỤNG HỆ THỐNG
=================================================================

1. SETUP BAN ĐẦU:
   - Tạo users và phân quyền trong bảng 'users' và 'roles'
   - Thiết lập warehouse, zones, và locations
   - Import danh mục sản phẩm và sản phẩm
   - Cấu hình suppliers và customers

2. QUY TRÌNH NHẬP KHO:
   - Tạo Purchase Order
   - Tạo Warehouse Transaction (inbound)
   - Scan/nhập chi tiết hàng hóa
   - Quality inspection (nếu cần)
   - Confirm transaction → Cập nhật tồn kho

3. QUY TRÌNH XUẤT KHO:
   - Tạo Sales Order
   - Auto/Manual allocation
   - Tạo Picking Task
   - Execute picking
   - Packing & Shipping
   - Confirm delivery

4. KIỂM KÊ KHO:
   - Tạo Cycle Count plan
   - Execute counting
   - Review variance
   - Create adjustments

5. BÁO CÁO CHÍNH:
   - Inventory Overview (v_inventory_overview)
   - ABC Analysis (v_abc_analysis) 
   - Expiring Products (v_expiring_products)
   - Slow Moving (v_slow_moving_products)
   - Performance metrics (KPI tables)

6. OPTIMIZATION TIPS:
   - Sử dụng indexes đã tạo
   - Enable partitioning cho dữ liệu lớn
   - Chạy scheduled events
   - Regular maintenance procedures

7. SECURITY & BACKUP:
   - Backup định kỳ
   - Monitor user activities
   - Review và update permissions
   - Archive old data

=================================================================
                        CHANGELOG
=================================================================
Version 1.0 - Initial release
- Core inventory management
- Warehouse operations
- Order processing
- Reporting framework
- Performance optimization

=================================================================
*/
- =============================================
-- 28. MODULE TÍCH HỢP API & WEBHOOK
-- =============================================

-- Bảng API integrations
CREATE TABLE api_integrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    integration_name VARCHAR(100) NOT NULL,
    integration_type ENUM('erp', 'ecommerce', 'shipping', 'accounting', 'crm') NOT NULL,
    endpoint_url VARCHAR(500),
    api_key VARCHAR(500),
    api_secret VARCHAR(500),
    headers JSON,
    auth_type ENUM('api_key', 'oauth', 'basic', 'bearer') DEFAULT 'api_key',
    
    -- Cấu hình sync
    sync_enabled BOOLEAN DEFAULT TRUE,
    sync_frequency ENUM('realtime', 'hourly', 'daily', 'manual') DEFAULT 'hourly',
    last_sync TIMESTAMP NULL,
    next_sync TIMESTAMP NULL,
    
    -- Mapping fields
    field_mappings JSON,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    connection_status ENUM('connected', 'disconnected', 'error') DEFAULT 'disconnected',
    last_error TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng webhook logs
CREATE TABLE webhook_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    integration_id INT,
    webhook_type VARCHAR(50) NOT NULL,
    payload JSON,
    headers JSON,
    response_status INT,
    response_body TEXT,
    processing_time_ms INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (integration_id) REFERENCES api_integrations(id),
    INDEX idx_webhook_type_created (webhook_type, created_at),
    INDEX idx_integration_created (integration_id, created_at)
);

-- =============================================
-- 29. MODULE MOBILE & BARCODE
-- =============================================

-- Bảng mobile devices
CREATE TABLE mobile_devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL UNIQUE,
    device_name VARCHAR(100) NOT NULL,
    device_type ENUM('handheld', 'tablet', 'phone') NOT NULL,
    os_type ENUM('android', 'ios', 'windows') NOT NULL,
    os_version VARCHAR(20),
    app_version VARCHAR(20),
    
    -- Assignment
    assigned_to INT,
    warehouse_id INT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_sync TIMESTAMP NULL,
    battery_level INT,
    
    -- Registration
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    INDEX idx_device_user (assigned_to),
    INDEX idx_device_activity (last_activity)
);

-- Bảng barcode printing queue
CREATE TABLE barcode_print_queue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    print_job_id VARCHAR(50) NOT NULL UNIQUE,
    barcode_type ENUM('product', 'location', 'batch', 'package', 'shipment') NOT NULL,
    target_id INT NOT NULL,
    barcode_format ENUM('code128', 'code39', 'qr', 'datamatrix') DEFAULT 'code128',
    
    -- Print details
    template_name VARCHAR(50),
    copies INT DEFAULT 1,
    printer_name VARCHAR(100),
    
    -- Queue status
    status ENUM('pending', 'printing', 'completed', 'failed') DEFAULT 'pending',
    created_by INT NOT NULL,
    processed_at TIMESTAMP NULL,
    
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_print_status (status, created_at)
);

-- =============================================
-- 30. MODULE ADVANCED ANALYTICS
-- =============================================

-- Bảng demand forecasting
CREATE TABLE demand_forecasts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    forecast_date DATE NOT NULL,
    forecast_period ENUM('daily', 'weekly', 'monthly') NOT NULL,
    
    -- Forecast values
    predicted_demand DECIMAL(15,3),
    confidence_level DECIMAL(5,2),
    lower_bound DECIMAL(15,3),
    upper_bound DECIMAL(15,3),
    
    -- Model info
    model_type ENUM('linear', 'seasonal', 'arima', 'ml') DEFAULT 'linear',
    model_accuracy DECIMAL(5,2),
    
    -- Actual vs predicted (filled later)
    actual_demand DECIMAL(15,3),
    forecast_error DECIMAL(15,3),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    UNIQUE KEY unique_forecast (product_id, warehouse_id, forecast_date, forecast_period),
    INDEX idx_forecast_date (forecast_date),
    INDEX idx_forecast_product (product_id, forecast_date)
);

-- Bảng safety stock recommendations
CREATE TABLE safety_stock_recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    
    -- Current levels
    current_safety_stock DECIMAL(15,3),
    current_reorder_point DECIMAL(15,3),
    
    -- Recommended levels
    recommended_safety_stock DECIMAL(15,3),
    recommended_reorder_point DECIMAL(15,3),
    
    -- Calculation basis
    service_level_target DECIMAL(5,2) DEFAULT 95.00,
    lead_time_days INT,
    demand_variability DECIMAL(10,6),
    lead_time_variability DECIMAL(10,6),
    
    -- Status
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    reviewed_by INT,
    reviewed_at TIMESTAMP NULL,
    
    calculation_date DATE NOT NULL,
    valid_until DATE,
    
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (reviewed_by) REFERENCES users(id),
    INDEX idx_calculation_date (calculation_date),
    INDEX idx_status (status)
);

-- =============================================
-- 31. MODULE COST MANAGEMENT
-- =============================================

-- Bảng cost centers
CREATE TABLE cost_centers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id INT,
    warehouse_id INT,
    
    -- Budget
    annual_budget DECIMAL(15,2),
    monthly_budget DECIMAL(15,2),
    
    -- Manager
    manager_id INT,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_id) REFERENCES cost_centers(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (manager_id) REFERENCES users(id)
);

-- Bảng chi phí hoạt động
CREATE TABLE operating_costs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cost_center_id INT NOT NULL,
    cost_type ENUM('storage', 'handling', 'transportation', 'labor', 'utilities', 'equipment', 'maintenance', 'other') NOT NULL,
    cost_category ENUM('fixed', 'variable', 'semi_variable') NOT NULL,
    
    description TEXT,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- Allocation
    allocation_method ENUM('direct', 'volume', 'weight', 'value', 'activity') DEFAULT 'direct',
    allocation_basis DECIMAL(15,6),
    
    -- Period
    cost_date DATE NOT NULL,
    period_type ENUM('daily', 'monthly', 'quarterly', 'yearly') DEFAULT 'monthly',
    
    -- Reference
    reference_type VARCHAR(50),
    reference_id INT,
    reference_code VARCHAR(50),
    
    -- Approval
    approved_by INT,
    approved_at TIMESTAMP NULL,
    
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cost_center_id) REFERENCES cost_centers(id),
    FOREIGN KEY (approved_by) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_cost_date (cost_date),
    INDEX idx_cost_type (cost_type, cost_date)
);

-- =============================================
-- 32. FINAL ADVANCED PROCEDURES
-- =============================================

DELIMITER //

-- Procedure tính toán safety stock tự động
CREATE PROCEDURE CalculateSafetyStock(
    IN p_product_id INT,
    IN p_warehouse_id INT,
    IN p_service_level DECIMAL(5,2),
    IN p_analysis_months INT
)
BEGIN
    DECLARE v_avg_demand DECIMAL(15,3);
    DECLARE v_demand_std DECIMAL(15,3);
    DECLARE v_avg_lead_time DECIMAL(5,2);
    DECLARE v_lead_time_std DECIMAL(5,2);
    DECLARE v_safety_stock DECIMAL(15,3);
    DECLARE v_reorder_point DECIMAL(15,3);
    DECLARE v_z_score DECIMAL(5,4);
    
    -- Z-score cho service level (95% = 1.645, 99% = 2.326)
    SET v_z_score = CASE 
        WHEN p_service_level >= 99 THEN 2.326
        WHEN p_service_level >= 95 THEN 1.645
        WHEN p_service_level >= 90 THEN 1.282
        ELSE 1.000
    END;
    
    -- Tính demand trung bình và độ lệch chuẩn
    SELECT 
        AVG(daily_demand),
        STDDEV(daily_demand)
    INTO v_avg_demand, v_demand_std
    FROM (
        SELECT 
            DATE(movement_date) as demand_date,
            SUM(ABS(quantity)) as daily_demand
        FROM inventory_movements 
        WHERE product_id = p_product_id 
          AND warehouse_id = p_warehouse_id
          AND movement_type = 'out'
          AND movement_date >= DATE_SUB(NOW(), INTERVAL p_analysis_months MONTH)
        GROUP BY DATE(movement_date)
    ) daily_demands;
    
    -- Tính lead time trung bình (từ suppliers)
    SELECT 
        AVG(lead_time_days),
        STDDEV(lead_time_days)
    INTO v_avg_lead_time, v_lead_time_std
    FROM product_suppliers ps
    WHERE ps.product_id = p_product_id 
      AND ps.is_active = TRUE;
    
    -- Tính safety stock theo công thức: Z * SQRT(LT * σD² + D² * σLT²)
    SET v_safety_stock = v_z_score * SQRT(
        (COALESCE(v_avg_lead_time, 7) * POW(COALESCE(v_demand_std, 0), 2)) +
        (POW(COALESCE(v_avg_demand, 0), 2) * POW(COALESCE(v_lead_time_std, 0), 2))
    );
    
    SET v_reorder_point = (COALESCE(v_avg_demand, 0) * COALESCE(v_avg_lead_time, 7)) + v_safety_stock;
    
    -- Lưu recommendation
    INSERT INTO safety_stock_recommendations (
        product_id, warehouse_id, 
        current_safety_stock, current_reorder_point,
        recommended_safety_stock, recommended_reorder_point,
        service_level_target, lead_time_days,
        demand_variability, lead_time_variability,
        calculation_date, valid_until
    ) VALUES (
        p_product_id, p_warehouse_id,
        (SELECT min_stock_level FROM products WHERE id = p_product_id),
        (SELECT reorder_point FROM products WHERE id = p_product_id),
        v_safety_stock, v_reorder_point,
        p_service_level, COALESCE(v_avg_lead_time, 7),
        COALESCE(v_demand_std, 0), COALESCE(v_lead_time_std, 0),
        CURDATE(), DATE_ADD(CURDATE(), INTERVAL 3 MONTH)
    )
    ON DUPLICATE KEY UPDATE
        recommended_safety_stock = v_safety_stock,
        recommended_reorder_point = v_reorder_point,
        calculation_date = CURDATE(),
        valid_until = DATE_ADD(CURDATE(), INTERVAL 3 MONTH);
        
    SELECT v_safety_stock as recommended_safety_stock, 
           v_reorder_point as recommended_reorder_point;
END //

-- Procedure phân tích cost per unit
CREATE PROCEDURE AnalyzeCostPerUnit(
    IN p_warehouse_id INT,
    IN p_period_months INT
)
BEGIN
    SELECT 
        p.sku,
        p.name as product_name,
        
        -- Volume data
        SUM(ABS(im.quantity)) as total_volume_handled,
        
        -- Direct costs
        AVG(im.unit_cost) as avg_unit_cost,
        SUM(ABS(im.quantity) * im.unit_cost) as total_inventory_value,
        
        -- Allocated costs
        COALESCE(cost_allocation.storage_cost_per_unit, 0) as storage_cost_per_unit,
        COALESCE(cost_allocation.handling_cost_per_unit, 0) as handling_cost_per_unit,
        
        -- Total cost per unit
        AVG(im.unit_cost) + 
        COALESCE(cost_allocation.storage_cost_per_unit, 0) + 
        COALESCE(cost_allocation.handling_cost_per_unit, 0) as total_cost_per_unit,
        
        -- Margins
        p.selling_price,
        p.selling_price - (
            AVG(im.unit_cost) + 
            COALESCE(cost_allocation.storage_cost_per_unit, 0) + 
            COALESCE(cost_allocation.handling_cost_per_unit, 0)
        ) as gross_margin_per_unit
        
    FROM inventory_movements im
    JOIN products p ON im.product_id = p.id
    LEFT JOIN (
        -- Subquery để tính cost allocation
        SELECT 
            im2.product_id,
            SUM(CASE WHEN oc.cost_type = 'storage' THEN 
                oc.amount / NULLIF(total_volume.volume, 0) ELSE 0 END) as storage_cost_per_unit,
            SUM(CASE WHEN oc.cost_type = 'handling' THEN 
                oc.amount / NULLIF(total_transactions.transactions, 0) ELSE 0 END) as handling_cost_per_unit
        FROM inventory_movements im2
        JOIN cost_centers cc ON cc.warehouse_id = im2.warehouse_id
        JOIN operating_costs oc ON cc.id = oc.cost_center_id
        CROSS JOIN (
            SELECT SUM(ABS(quantity)) as volume 
            FROM inventory_movements 
            WHERE warehouse_id = p_warehouse_id
              AND movement_date >= DATE_SUB(NOW(), INTERVAL p_period_months MONTH)
        ) total_volume
        CROSS JOIN (
            SELECT COUNT(*) as transactions 
            FROM inventory_movements 
            WHERE warehouse_id = p_warehouse_id
              AND movement_date >= DATE_SUB(NOW(), INTERVAL p_period_months MONTH)
        ) total_transactions
        WHERE im2.warehouse_id = p_warehouse_id
          AND im2.movement_date >= DATE_SUB(NOW(), INTERVAL p_period_months MONTH)
          AND oc.cost_date >= DATE_SUB(NOW(), INTERVAL p_period_months MONTH)
        GROUP BY im2.product_id
    ) cost_allocation ON im.product_id = cost_allocation.product_id
    
    WHERE im.warehouse_id = p_warehouse_id
      AND im.movement_date >= DATE_SUB(NOW(), INTERVAL p_period_months MONTH)
    GROUP BY im.product_id
    ORDER BY total_cost_per_unit DESC;
END //

DELIMITER ;

-- =============================================
-- 33. ADVANCED VIEWS FOR MANAGEMENT DASHBOARD
-- =============================================

-- View dashboard tổng quan
CREATE VIEW v_executive_dashboard AS
SELECT 
    'inventory_value' as metric,
    SUM(total_value) as current_value,
    NULL as target_value,
    'VND' as currency,
    'Total inventory value across all warehouses' as description
FROM inventory_summary
WHERE total_quantity > 0

UNION ALL

SELECT 
    'order_fulfillment_rate' as metric,
    ROUND(AVG(
        CASE WHEN so.status IN ('shipped', 'delivered') THEN 100.0 ELSE 0 END
    ), 2) as current_value,
    95.0 as target_value,
    '%' as currency,
    'Orders fulfilled successfully in last 30 days' as description
FROM sales_orders so
WHERE so.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  AND so.status != 'cancelled'

UNION ALL

SELECT 
    'inventory_turnover' as metric,
    ROUND(AVG(CASE 
        WHEN s.total_value > 0 THEN yearly_sales.sales_value / s.total_value 
        ELSE 0 
    END), 2) as current_value,
    12.0 as target_value,
    'times/year' as currency,
    'Annual inventory turnover ratio' as description
FROM inventory_summary s
LEFT JOIN (
    SELECT 
        im.warehouse_id,
        im.product_id,
        SUM(ABS(im.quantity * im.unit_cost)) as sales_value
    FROM inventory_movements im
    WHERE im.movement_type = 'out'
      AND im.movement_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY im.warehouse_id, im.product_id
) yearly_sales ON s.warehouse_id = yearly_sales.warehouse_id 
               AND s.product_id = yearly_sales.product_id
WHERE s.total_quantity > 0;

-- View real-time warehouse status
CREATE VIEW v_warehouse_status_realtime AS
SELECT 
    w.name as warehouse_name,
    w.code as warehouse_code,
    
    -- Capacity metrics
    ROUND(w.used_capacity / w.total_capacity * 100, 2) as capacity_utilization_percent,
    w.used_capacity,
    w.total_capacity,
    w.capacity_unit,
    
    -- Inventory metrics
    COUNT(DISTINCT s.product_id) as total_skus,
    SUM(s.total_quantity) as total_units,
    SUM(s.total_value) as total_value,
    
    -- Activity metrics
    active_orders.order_count as active_orders,
    picking_tasks.task_count as active_picking_tasks,
    
    -- Alerts
    expiring_items.expiring_count as items_expiring_soon,
    low_stock.low_stock_count as low_stock_items
    
FROM warehouses w
LEFT JOIN inventory_summary s ON w.id = s.warehouse_id AND s.total_quantity > 0
LEFT JOIN (
    SELECT warehouse_id, COUNT(*) as order_count
    FROM sales_orders 
    WHERE status IN ('confirmed', 'picking', 'packed')
    GROUP BY warehouse_id
) active_orders ON w.id = active_orders.warehouse_id
LEFT JOIN (
    SELECT warehouse_id, COUNT(*) as task_count
    FROM picking_tasks 
    WHERE status IN ('assigned', 'in_progress')
    GROUP BY warehouse_id
) picking_tasks ON w.id = picking_tasks.warehouse_id
LEFT JOIN (
    SELECT ib.warehouse_id, COUNT(*) as expiring_count
    FROM inventory_batches ib
    WHERE ib.expiry_date <= DATE_ADD(NOW(), INTERVAL 30 DAY)
      AND ib.available_quantity > 0
    GROUP BY ib.warehouse_id
) expiring_items ON w.id = expiring_items.warehouse_id
LEFT JOIN (
    SELECT s2.warehouse_id, COUNT(*) as low_stock_count
    FROM inventory_summary s2
    JOIN products p2 ON s2.product_id = p2.id
    WHERE s2.available_quantity <= p2.min_stock_level
    GROUP BY s2.warehouse_id
) low_stock ON w.id = low_stock.warehouse_id

WHERE w.is_active = TRUE
GROUP BY w.id
ORDER BY w.name;

-- =============================================
-- FINAL SYSTEM DOCUMENTATION
-- =============================================

/*
=================================================================
           HỆ THỐNG QUẢN LÝ KHO HÀNG CHUYÊN NGHIỆP
                    PHIÊN BẢN HOÀN CHỈNH
=================================================================

🏗️ KIẾN TRÚC HỆ THỐNG:
├── Core Modules (1-12): Quản lý cơ bản
├── Advanced Operations (13-17): Picking, Shipping, Quality
├── Analytics & Reporting (18-19): KPI, Forecasting  
├── Integration & Mobile (28-29): API, Barcode, Mobile
├── Cost Management (30-31): Chi phí, Budget
└── Executive Dashboard (32-33): Báo cáo cấp cao

📊 TÍNH NĂNG CHÍNH:
✅ Multi-warehouse management với zones/locations
✅ Advanced inventory tracking (batch, serial, expiry)
✅ Automated allocation (FIFO/LIFO/Average)
✅ Intelligent picking optimization
✅ Quality control workflows
✅ Real-time cost analysis
✅ Demand forecasting
✅ Mobile integration ready
✅ Executive dashboards
✅ API webhooks
✅ Performance analytics

🔧 PERFORMANCE FEATURES:
- Optimized indexes cho queries nhanh
- Partitioning support cho big data
- Automated maintenance jobs
- Caching layer cho reports
- Event schedulers

📱 MOBILE & INTEGRATION:
- Barcode/QR code support
- Mobile device management
- API integration framework
- Webhook logging
- Real-time sync

💰 COST MANAGEMENT:
- Activity-based costing
- Cost center allocation
- Budget tracking
- ROI analysis

📈 ANALYTICS & FORECASTING:
- ABC analysis
- Demand forecasting
- Safety stock optimization
- Performance KPIs
- Executive dashboards

🚀 DEPLOYMENT CHECKLIST:
1. ✅ Import database schema
2. ✅ Configure initial data
3. ✅ Set up users & permissions
4. ✅ Configure warehouses
5. ✅ Import products & suppliers
6. ✅ Enable scheduled events
7. ✅ Test mobile integration
8. ✅ Configure API endpoints
9. ✅ Set up monitoring
10. ✅ Train users

⚡ RECOMMENDED HARDWARE:
- CPU: 8+ cores for large warehouses
- RAM: 16GB+ for optimal performance  
- Storage: SSD with RAID for reliability
- Network: Gigabit for real-time sync

🔒 SECURITY FEATURES:
- Role-based access control
- Audit trails for all changes
- API authentication
- Data encryption ready
- Backup procedures

=================================================================
                    END OF DATABASE SCHEMA
=================================================================
*/