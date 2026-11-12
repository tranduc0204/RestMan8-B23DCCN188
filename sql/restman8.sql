-- =====================================================================
-- RestMan8 (Đề 18) - Script tạo cơ sở dữ liệu restman8
-- Trần Anh Đức - B23DCCN188
-- MySQL Server 8.0, bảng mã utf8mb4
--
-- Cách chạy: MySQL Workbench > File > Open SQL Script > chọn file này > Execute (⚡)
-- CHÚ Ý: script XÓA database restman8 cũ (nếu có) rồi tạo lại từ đầu.
-- =====================================================================

DROP DATABASE IF EXISTS restman8;
CREATE DATABASE restman8 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE restman8;

-- =====================================================================
-- 1. NHÂN VIÊN - VAI TRÒ
-- =====================================================================
CREATE TABLE tblEmployee8 (
  id               INT          NOT NULL AUTO_INCREMENT,
  name             VARCHAR(255) NOT NULL,
  dateOfBirth      DATE         NOT NULL,
  gender           VARCHAR(255) NOT NULL,
  phoneNumber      VARCHAR(255) NOT NULL,
  address          VARCHAR(255) NOT NULL,
  email            VARCHAR(255) NOT NULL,
  username         VARCHAR(255) NOT NULL,
  password         VARCHAR(255) NOT NULL,
  hireDate         DATE         NOT NULL,
  terminationDate  DATE         NULL,
  employmentStatus VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_employee_username (username)
) ENGINE=InnoDB;

CREATE TABLE tblRole8 (
  id          INT          NOT NULL AUTO_INCREMENT,
  roleName    VARCHAR(255) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblRoleAssignment8 (
  id               INT          NOT NULL AUTO_INCREMENT,
  startDate        DATE         NOT NULL,
  endDate          DATE         NULL,
  assignmentStatus VARCHAR(255) NOT NULL,
  tblEmployee8id   INT          NOT NULL,
  tblRole8id       INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roleassignment (tblEmployee8id, tblRole8id, startDate),
  CONSTRAINT fk_roleassignment_employee FOREIGN KEY (tblEmployee8id) REFERENCES tblEmployee8 (id),
  CONSTRAINT fk_roleassignment_role     FOREIGN KEY (tblRole8id)     REFERENCES tblRole8 (id)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. KHÁCH HÀNG - THẺ THÀNH VIÊN
-- =====================================================================
CREATE TABLE tblCustomer8 (
  id          INT          NOT NULL AUTO_INCREMENT,
  name        VARCHAR(255) NOT NULL,
  phoneNumber VARCHAR(255) NOT NULL,
  email       VARCHAR(255) NULL,
  dateOfBirth DATE         NULL,
  address     VARCHAR(255) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customer_phone (phoneNumber)
) ENGINE=InnoDB;

CREATE TABLE tblMembershipCard8 (
  id             INT          NOT NULL AUTO_INCREMENT,
  cardTier       VARCHAR(255) NOT NULL,
  loyaltyPoint   INT          NOT NULL DEFAULT 0,
  issueDate      DATE         NOT NULL,
  cardStatus     VARCHAR(255) NOT NULL,
  tblCustomer8id INT          NOT NULL,
  tblEmployee8id INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_membershipcard_customer (tblCustomer8id),
  CONSTRAINT fk_membershipcard_customer FOREIGN KEY (tblCustomer8id) REFERENCES tblCustomer8 (id),
  CONSTRAINT fk_membershipcard_employee FOREIGN KEY (tblEmployee8id) REFERENCES tblEmployee8 (id)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. THỰC ĐƠN
-- =====================================================================
CREATE TABLE tblDishCategory8 (
  id           INT          NOT NULL AUTO_INCREMENT,
  categoryName VARCHAR(255) NOT NULL,
  description  VARCHAR(255) NULL,
  status       VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblDish8 (
  id                 INT          NOT NULL AUTO_INCREMENT,
  dishName           VARCHAR(255) NOT NULL,
  description        VARCHAR(255) NULL,
  image              VARCHAR(255) NULL,
  servingStatus      VARCHAR(255) NOT NULL,
  tblDishCategory8id INT          NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_dish_category FOREIGN KEY (tblDishCategory8id) REFERENCES tblDishCategory8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblSize8 (
  id          INT          NOT NULL AUTO_INCREMENT,
  sizeName    VARCHAR(255) NOT NULL,
  description VARCHAR(255) NULL,
  status      VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblDishSize8 (
  id            INT          NOT NULL AUTO_INCREMENT,
  unitPrice     FLOAT        NOT NULL,
  servingStatus VARCHAR(255) NOT NULL,
  tblDish8id    INT          NOT NULL,
  tblSize8id    INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_dishsize (tblDish8id, tblSize8id),
  CONSTRAINT fk_dishsize_dish FOREIGN KEY (tblDish8id) REFERENCES tblDish8 (id),
  CONSTRAINT fk_dishsize_size FOREIGN KEY (tblSize8id) REFERENCES tblSize8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblCombo8 (
  id          INT          NOT NULL AUTO_INCREMENT,
  comboName   VARCHAR(255) NOT NULL,
  unitPrice   FLOAT        NOT NULL,
  description VARCHAR(255) NULL,
  image       VARCHAR(255) NULL,
  status      VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblComboItem8 (
  id             INT NOT NULL AUTO_INCREMENT,
  quantity       INT NOT NULL,
  tblCombo8id    INT NOT NULL,
  tblDishSize8id INT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_comboitem (tblCombo8id, tblDishSize8id),
  CONSTRAINT fk_comboitem_combo    FOREIGN KEY (tblCombo8id)    REFERENCES tblCombo8 (id),
  CONSTRAINT fk_comboitem_dishsize FOREIGN KEY (tblDishSize8id) REFERENCES tblDishSize8 (id)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. BÀN - KHUNG GIỜ - PHIẾU ĐẶT BÀN - LƯỢT SỬ DỤNG BÀN - HÓA ĐƠN
-- =====================================================================
CREATE TABLE tblTable8 (
  id          INT          NOT NULL AUTO_INCREMENT,
  tableNumber VARCHAR(255) NOT NULL,
  capacity    INT          NOT NULL,
  location    VARCHAR(255) NOT NULL,
  tableStatus VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_table_number (tableNumber)
) ENGINE=InnoDB;

CREATE TABLE tblTimeSlot8 (
  id         INT          NOT NULL AUTO_INCREMENT,
  startTime  TIME         NOT NULL,
  endTime    TIME         NOT NULL,
  slotStatus VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblReservation8 (
  id              INT          NOT NULL AUTO_INCREMENT,
  reservationDate DATE         NOT NULL,
  note            VARCHAR(255) NULL,
  createdAt       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status          VARCHAR(255) NOT NULL,
  tblTable8id     INT          NOT NULL,
  tblTimeSlot8id  INT          NOT NULL,
  tblEmployee8id  INT          NULL,      -- null khi phiếu chưa được nhân viên xác nhận
  tblCustomer8id  INT          NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_reservation_table    FOREIGN KEY (tblTable8id)    REFERENCES tblTable8 (id),
  CONSTRAINT fk_reservation_timeslot FOREIGN KEY (tblTimeSlot8id) REFERENCES tblTimeSlot8 (id),
  CONSTRAINT fk_reservation_employee FOREIGN KEY (tblEmployee8id) REFERENCES tblEmployee8 (id),
  CONSTRAINT fk_reservation_customer FOREIGN KEY (tblCustomer8id) REFERENCES tblCustomer8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblTableSession8 (
  id                INT          NOT NULL AUTO_INCREMENT,
  startedAt         TIMESTAMP    NULL,
  endedAt           TIMESTAMP    NULL,
  status            VARCHAR(255) NOT NULL,
  tblTable8id       INT          NOT NULL,
  tblReservation8id INT          NULL,    -- null khi khách đến trực tiếp, không đặt trước
  tblCustomer8id    INT          NULL,    -- null khi khách vãng lai không lưu thông tin
  tblEmployee8id    INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_tablesession_reservation (tblReservation8id),
  CONSTRAINT fk_tablesession_table       FOREIGN KEY (tblTable8id)       REFERENCES tblTable8 (id),
  CONSTRAINT fk_tablesession_reservation FOREIGN KEY (tblReservation8id) REFERENCES tblReservation8 (id),
  CONSTRAINT fk_tablesession_customer    FOREIGN KEY (tblCustomer8id)    REFERENCES tblCustomer8 (id),
  CONSTRAINT fk_tablesession_employee    FOREIGN KEY (tblEmployee8id)    REFERENCES tblEmployee8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblInvoice8 (
  id                 INT          NOT NULL AUTO_INCREMENT,
  paidAt             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  discountAmount     FLOAT        NOT NULL DEFAULT 0,
  paymentMethod      VARCHAR(255) NOT NULL,
  status             VARCHAR(255) NOT NULL,
  tblTableSession8id INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_invoice_tablesession (tblTableSession8id),
  CONSTRAINT fk_invoice_tablesession FOREIGN KEY (tblTableSession8id) REFERENCES tblTableSession8 (id)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. ĐƠN ĐẶT MÓN
-- =====================================================================
CREATE TABLE tblFoodOrder8 (
  id                 INT          NOT NULL AUTO_INCREMENT,
  orderChannel       VARCHAR(255) NOT NULL,
  orderedAt          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status             VARCHAR(255) NOT NULL,
  tblTableSession8id INT          NOT NULL,
  tblEmployee8id     INT          NULL,    -- null khi đơn đặt trực tuyến chưa được nhân viên tiếp nhận
  PRIMARY KEY (id),
  CONSTRAINT fk_foodorder_tablesession FOREIGN KEY (tblTableSession8id) REFERENCES tblTableSession8 (id),
  CONSTRAINT fk_foodorder_employee     FOREIGN KEY (tblEmployee8id)     REFERENCES tblEmployee8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblFoodOrderDishItem8 (
  id              INT          NOT NULL AUTO_INCREMENT,
  quantity        INT          NOT NULL,
  unitPrice       FLOAT        NOT NULL,
  status          VARCHAR(255) NOT NULL,
  tblFoodOrder8id INT          NOT NULL,
  tblDishSize8id  INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_foodorderdishitem (tblFoodOrder8id, tblDishSize8id),
  CONSTRAINT fk_foodorderdishitem_order    FOREIGN KEY (tblFoodOrder8id) REFERENCES tblFoodOrder8 (id),
  CONSTRAINT fk_foodorderdishitem_dishsize FOREIGN KEY (tblDishSize8id)  REFERENCES tblDishSize8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblFoodOrderComboItem8 (
  id              INT          NOT NULL AUTO_INCREMENT,
  quantity        INT          NOT NULL,
  unitPrice       FLOAT        NOT NULL,
  status          VARCHAR(255) NOT NULL,
  tblFoodOrder8id INT          NOT NULL,
  tblCombo8id     INT          NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_foodordercomboitem (tblFoodOrder8id, tblCombo8id),
  CONSTRAINT fk_foodordercomboitem_order FOREIGN KEY (tblFoodOrder8id) REFERENCES tblFoodOrder8 (id),
  CONSTRAINT fk_foodordercomboitem_combo FOREIGN KEY (tblCombo8id)     REFERENCES tblCombo8 (id)
) ENGINE=InnoDB;

-- =====================================================================
-- 6. NHÀ CUNG CẤP - NGUYÊN LIỆU - PHIẾU NHẬP
-- =====================================================================
CREATE TABLE tblSupplier8 (
  id                INT          NOT NULL AUTO_INCREMENT,
  supplierName      VARCHAR(255) NOT NULL,
  phoneNumber       VARCHAR(255) NOT NULL,
  email             VARCHAR(255) NULL,
  address           VARCHAR(255) NOT NULL,
  partnershipStatus VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblIngredient8 (
  id               INT          NOT NULL AUTO_INCREMENT,
  ingredientName   VARCHAR(255) NOT NULL,
  unitOfMeasure    VARCHAR(255) NOT NULL,
  description      VARCHAR(255) NULL,
  ingredientStatus VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE tblIngredientImportReceipt8 (
  id             INT          NOT NULL AUTO_INCREMENT,
  importedAt     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  receiptStatus  VARCHAR(255) NOT NULL,
  tblSupplier8id INT          NOT NULL,
  tblEmployee8id INT          NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_importreceipt_supplier FOREIGN KEY (tblSupplier8id) REFERENCES tblSupplier8 (id),
  CONSTRAINT fk_importreceipt_employee FOREIGN KEY (tblEmployee8id) REFERENCES tblEmployee8 (id)
) ENGINE=InnoDB;

CREATE TABLE tblIngredientImportReceiptItem8 (
  id                            INT   NOT NULL AUTO_INCREMENT,
  quantityImported              FLOAT NOT NULL,
  unitCost                      FLOAT NOT NULL,
  tblIngredientImportReceipt8id INT   NOT NULL,
  tblIngredient8id              INT   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_importreceiptitem (tblIngredientImportReceipt8id, tblIngredient8id),
  CONSTRAINT fk_importreceiptitem_receipt    FOREIGN KEY (tblIngredientImportReceipt8id) REFERENCES tblIngredientImportReceipt8 (id),
  CONSTRAINT fk_importreceiptitem_ingredient FOREIGN KEY (tblIngredient8id)              REFERENCES tblIngredient8 (id)
) ENGINE=InnoDB;

-- =====================================================================
-- DỮ LIỆU MẪU (phục vụ chạy thử 2 module)
-- =====================================================================

-- Vai trò và nhân viên (đăng nhập module 1: quanli / 123456)
INSERT INTO tblRole8 (id, roleName, description) VALUES
  (1, 'Quản lí nhà hàng',   'Quản lí món ăn, combo, nhà cung cấp, nguyên liệu và xem thống kê'),
  (2, 'Nhân viên bán hàng', 'Xác nhận đặt bàn, nhận khách, nhận gọi món và thanh toán'),
  (3, 'Nhân viên kho',      'Nhập nguyên liệu, quản lí nguyên liệu và nhà cung cấp');

INSERT INTO tblEmployee8 (id, name, dateOfBirth, gender, phoneNumber, address, email, username, password, hireDate, terminationDate, employmentStatus) VALUES
  (1, 'Trần Văn Quản', '1990-05-12', 'Nam', '0912345678', 'Hà Đông, Hà Nội',    'quanli@restman8.vn',  'quanli',  '123456', '2022-01-10', NULL, 'Đang làm việc'),
  (2, 'Lê Thị Bán',    '1998-09-03', 'Nữ',  '0987654321', 'Thanh Xuân, Hà Nội', 'banhang@restman8.vn', 'banhang', '123456', '2023-03-01', NULL, 'Đang làm việc'),
  (3, 'Phạm Văn Kho',  '1995-02-20', 'Nam', '0901234567', 'Cầu Giấy, Hà Nội',   'kho@restman8.vn',     'kho',     '123456', '2023-06-15', NULL, 'Đang làm việc');

INSERT INTO tblRoleAssignment8 (startDate, endDate, assignmentStatus, tblEmployee8id, tblRole8id) VALUES
  ('2022-01-10', NULL, 'Đang hiệu lực', 1, 1),
  ('2023-03-01', NULL, 'Đang hiệu lực', 2, 2),
  ('2023-06-15', NULL, 'Đang hiệu lực', 3, 3);

-- Loại món ăn, kích cỡ (module 1)
INSERT INTO tblDishCategory8 (id, categoryName, description, status) VALUES
  (1, 'Món khai vị',  'Các món ăn nhẹ trước bữa chính', 'Đang sử dụng'),
  (2, 'Món chính',    'Các món ăn chính trong bữa',     'Đang sử dụng'),
  (3, 'Đồ uống',      'Nước giải khát và đồ uống',      'Đang sử dụng'),
  (4, 'Món theo mùa', 'Món chỉ bán theo mùa',           'Ngừng sử dụng');

INSERT INTO tblSize8 (id, sizeName, description, status) VALUES
  (1, 'Nhỏ',      'Phần ăn cho một người',        'Đang sử dụng'),
  (2, 'Vừa',      'Phần ăn cho hai người',        'Đang sử dụng'),
  (3, 'Lớn',      'Phần ăn cho ba đến bốn người', 'Đang sử dụng'),
  (4, 'Siêu lớn', 'Phần ăn cho nhóm đông',        'Ngừng sử dụng');

-- Món ăn có sẵn (dùng "Phở bò tái" để thử ngoại lệ 8.2 trùng tên;
-- "Gà rán" của kịch bản chính CHƯA có nên thêm được)
INSERT INTO tblDish8 (id, dishName, description, image, servingStatus, tblDishCategory8id) VALUES
  (1, 'Phở bò tái', 'Phở bò tái truyền thống', NULL, 'Đang phục vụ', 2),
  (2, 'Nem rán',    'Nem rán giòn chấm nước mắm chua ngọt', NULL, 'Đang phục vụ', 1);

INSERT INTO tblDishSize8 (unitPrice, servingStatus, tblDish8id, tblSize8id) VALUES
  (45000, 'Đang phục vụ', 1, 1),
  (60000, 'Đang phục vụ', 1, 2),
  (35000, 'Đang phục vụ', 2, 1),
  (60000, 'Đang phục vụ', 2, 2);

-- Khung giờ (module 2)
INSERT INTO tblTimeSlot8 (id, startTime, endTime, slotStatus) VALUES
  (1, '10:00:00', '12:00:00', 'Đang áp dụng'),
  (2, '12:00:00', '14:00:00', 'Đang áp dụng'),
  (3, '18:00:00', '20:00:00', 'Đang áp dụng'),
  (4, '20:00:00', '22:00:00', 'Đang áp dụng');

-- Bàn (module 2)
INSERT INTO tblTable8 (id, tableNumber, capacity, location, tableStatus) VALUES
  (1, 'B01', 4,  'Tầng 1', 'Đang sử dụng'),
  (2, 'B02', 2,  'Tầng 1', 'Đang sử dụng'),
  (3, 'B03', 4,  'Tầng 1', 'Đang sử dụng'),
  (4, 'B05', 6,  'Tầng 2', 'Đang sử dụng'),
  (5, 'B09', 10, 'Tầng 2', 'Đang sử dụng'),
  (6, 'B11', 4,  'Tầng 3', 'Ngừng sử dụng');

-- Khách hàng: KH 135 đúng với kịch bản chính (số điện thoại 0364978258)
INSERT INTO tblCustomer8 (id, name, phoneNumber, email, dateOfBirth, address) VALUES
  (135, 'Nguyễn Văn B', '0364978258', 'ABC@gmail.com',      '1990-11-11', 'Hà Nội'),
  (136, 'Trần Thị C',   '0977111222', 'tranthic@gmail.com', '1992-04-08', 'Đống Đa, Hà Nội');

INSERT INTO tblMembershipCard8 (cardTier, loyaltyPoint, issueDate, cardStatus, tblCustomer8id, tblEmployee8id) VALUES
  ('Bạc', 120, '2025-06-01', 'Đang hoạt động', 136, 2);

-- Phiếu đặt bàn có sẵn: B01, B02 đã được đặt ngày 20/12/2026, khung 18:00-20:00
-- => khi tìm đúng ngày + khung giờ này chỉ còn B03, B05, B09 (khớp bảng trong kịch bản)
INSERT INTO tblReservation8 (reservationDate, note, status, tblTable8id, tblTimeSlot8id, tblEmployee8id, tblCustomer8id) VALUES
  ('2026-12-20', 'Sinh nhật',     'Đã xác nhận',  1, 3, 2,    136),
  ('2026-12-20', NULL,            'Chờ xác nhận', 2, 3, NULL, 136);

-- Nhà cung cấp, nguyên liệu (ngoài phạm vi 2 module, để có dữ liệu tham khảo)
INSERT INTO tblSupplier8 (supplierName, phoneNumber, email, address, partnershipStatus) VALUES
  ('Công ty Thực phẩm Sạch Hà Nội', '0243567890', 'lienhe@thucphamsach.vn', 'Long Biên, Hà Nội', 'Đang hợp tác');

INSERT INTO tblIngredient8 (ingredientName, unitOfMeasure, description, ingredientStatus) VALUES
  ('Thịt bò',  'kg', 'Thịt bò thăn',       'Đang sử dụng'),
  ('Bánh phở', 'kg', 'Bánh phở tươi',      'Đang sử dụng'),
  ('Gà ta',    'con', 'Gà ta nguyên con',  'Đang sử dụng');
