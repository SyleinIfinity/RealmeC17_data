-- Kịch bản SQL hoàn chỉnh cho dbQUANLYNHAHANG

-- Bước 1: Kiểm tra và xóa DB cũ nếu tồn tại
IF DB_ID('dbQUANLYNHAHANG') IS NOT NULL
BEGIN
    USE master;
    ALTER DATABASE dbQUANLYNHAHANG SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE dbQUANLYNHAHANG;
    PRINT 'Cơ sở dữ liệu cũ dbQUANLYNHAHANG đã được xóa.'
END
GO

-- Bước 2: Tạo lại cơ sở dữ liệu
CREATE DATABASE dbQUANLYNHAHANG;
GO
PRINT 'Cơ sở dữ liệu dbQUANLYNHAHANG đã được tạo mới.'
GO

USE dbQUANLYNHAHANG;
GO

-- Bước 3: Tạo cấu trúc bảng
PRINT 'Đang tạo bảng...'
CREATE TABLE dbo.tbDANHMUC (
    IDDANHMUC INT IDENTITY(1,1) PRIMARY KEY,
    TENDANHMUC NVARCHAR(200) NOT NULL
);

CREATE TABLE dbo.tbMENU (
    IDMON INT IDENTITY(1,1) PRIMARY KEY,
    TENMON NVARCHAR(200) NOT NULL,
    DONVITINH NVARCHAR(100) NULL, -- Sửa lại kiểu dữ liệu theo đề
    DONGIA NUMERIC(18, 0) NULL,
    SOLUONG INT NULL,              -- Sửa lại kiểu dữ liệu theo đề
    HINHANH NVARCHAR(200) NULL,    -- Sửa lại kiểu dữ liệu theo đề
    MOTA NVARCHAR(MAX) NULL,
    IDDANHMUC INT NULL,
    CONSTRAINT FK_MENU_DANHMUC FOREIGN KEY (IDDANHMUC) REFERENCES dbo.tbDANHMUC(IDDANHMUC)
);
GO
PRINT 'Hoàn tất tạo bảng.'
GO

-- Bước 4: Chèn dữ liệu mẫu
PRINT 'Đang chèn dữ liệu mẫu...'
SET IDENTITY_INSERT dbo.tbDANHMUC ON;
INSERT INTO dbo.tbDANHMUC (IDDANHMUC, TENDANHMUC) VALUES
(1, N'Gà'), (2, N'Vịt'), (3, N'Cơm'), (4, N'Canh'), (5, N'Cá');
SET IDENTITY_INSERT dbo.tbDANHMUC OFF;

SET IDENTITY_INSERT dbo.tbMENU ON;
INSERT INTO dbo.tbMENU (IDMON, TENMON, DONVITINH, DONGIA, SOLUONG, HINHANH, MOTA, IDDANHMUC) VALUES
(1, N'Gà Hấp Hành', N'Con', 200000, 10, 'ga_hap_hanh.jpg', N'Gà ta hấp hành lá và gừng tươi, thịt mềm ngọt.', 1),
(2, N'Gà Quay', N'Con', 100000, 10, 'ga_quay.jpg', N'Gà quay da giòn rụm, tẩm ướp gia vị đậm đà.', 1),
(3, N'Gà Tiềm Thuốc Bắc', N'Thố', 50000, 15, 'ga_tiem.jpg', N'Gà ác tiềm thuốc bắc có công dụng bổ can thận, ích khí huyết, còn được dùng để chữa các chứng bệnh hư nhược, tiêu đường, đi tả lâu ngày do tỳ hư.', 1),
(4, N'Vịt Quay Bắc Kinh', N'Con', 350000, 8, 'vit_quay.jpg', N'Vịt quay da giòn theo phong cách Bắc Kinh, ăn kèm bánh tráng và nước sốt.', 2),
(5, N'Cơm Chiên Dương Châu', N'Dĩa', 80000, 50, 'com_chien.jpg', N'Cơm chiên với lạp xưởng, trứng, tôm và các loại rau củ.', 3),
(6, N'Canh Chua Cá Lóc', N'Tô', 120000, 20, 'canh_chua.jpg', N'Canh chua cá lóc nấu với bạc hà, cà chua, giá đỗ theo phong vị miền Nam.', 4);
SET IDENTITY_INSERT dbo.tbMENU OFF;
GO
PRINT 'Hoàn tất chèn dữ liệu.'
GO

-- Bước 5: Tạo các Stored Procedures
PRINT 'Đang tạo Stored Procedures...'
GO

-- Xóa SP cũ nếu tồn tại
IF OBJECT_ID('sp_GetAll_DanhMuc', 'P') IS NOT NULL DROP PROCEDURE sp_GetAll_DanhMuc;
GO
IF OBJECT_ID('sp_Get_Menu_ByDanhMuc', 'P') IS NOT NULL DROP PROCEDURE sp_Get_Menu_ByDanhMuc;
GO
IF OBJECT_ID('sp_Get_Mon_ById', 'P') IS NOT NULL DROP PROCEDURE sp_Get_Mon_ById;
GO

-- Tạo lại SP
CREATE PROCEDURE sp_GetAll_DanhMuc
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDDANHMUC, TENDANHMUC FROM dbo.tbDANHMUC;
END
GO

CREATE PROCEDURE sp_Get_Menu_ByDanhMuc
    @IdDanhMuc INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.tbMENU WHERE IDDANHMUC = @IdDanhMuc;
END
GO

CREATE PROCEDURE sp_Get_Mon_ById
    @IdMon INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.tbMENU WHERE IDMON = @IdMon;
END
GO
PRINT 'Hoàn tất tạo Stored Procedures.'
GO