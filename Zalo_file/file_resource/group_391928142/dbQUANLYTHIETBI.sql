-- Kiểm tra và xóa DB cũ nếu tồn tại để làm lại từ đầu
IF DB_ID('dbQUANLYTHIETBI') IS NOT NULL
BEGIN
    USE master;
    ALTER DATABASE dbQUANLYTHIETBI SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE dbQUANLYTHIETBI;
    PRINT 'Cơ sở dữ liệu cũ dbQUANLYTHIETBI đã được xóa.'
END
GO

-- Tạo lại cơ sở dữ liệu
CREATE DATABASE dbQUANLYTHIETBI;
GO
PRINT 'Cơ sở dữ liệu dbQUANLYTHIETBI đã được tạo mới.'
GO

USE dbQUANLYTHIETBI;
GO

-- TẠO BẢNG
PRINT 'Đang tạo bảng...'
CREATE TABLE dbo.tbNHOM (
    MANHOM INT IDENTITY(1,1) PRIMARY KEY,
    TENNHOM NVARCHAR(200) NOT NULL
);

CREATE TABLE dbo.tbTHIETBI (
    MATHIETBI INT IDENTITY(1,1) PRIMARY KEY,
    TENTHIETBI NVARCHAR(200) NOT NULL,
    DONVITINH NVARCHAR(50) NULL,
    SOLUONG INT NULL,
    DONGIA NUMERIC(18, 0) NULL,
    HINHANH NVARCHAR(100) NULL,
    MOTA NVARCHAR(MAX) NULL,
    MANHOM INT NULL,
    CONSTRAINT FK_THIETBI_NHOM FOREIGN KEY (MANHOM) REFERENCES dbo.tbNHOM(MANHOM)
);
GO
PRINT 'Hoàn tất tạo bảng.'
GO

-- CHÈN DỮ LIỆU MẪU
PRINT 'Đang chèn dữ liệu mẫu...'
SET IDENTITY_INSERT dbo.tbNHOM ON;
INSERT INTO dbo.tbNHOM (MANHOM, TENNHOM) VALUES (1, N'RAM'), (2, N'CPU'), (3, N'HARD DISK'), (4, N'KEYBOARD'), (5, N'MOUSE');
SET IDENTITY_INSERT dbo.tbNHOM OFF;

SET IDENTITY_INSERT dbo.tbTHIETBI ON;
INSERT INTO dbo.tbTHIETBI (MATHIETBI, TENTHIETBI, DONVITINH, SOLUONG, DONGIA, HINHANH, MOTA, MANHOM) VALUES
(1, N'256 Mb DDR-333 PC2700 RAM Chip', N'Cái', 50, 200000, 'ram_1.jpg', N'RAM DDR-333 PC2700 dung lượng 256MB.', 1),
(2, N'SO-DIMM 512MB DDR2', N'Cái', 30, 100000, 'ram_2.jpg', N'RAM laptop SO-DIMM DDR2 bus 667MHz.', 1),
(3, N'Kingston DDR2 1GB', N'Cái', 100, 50000, 'ram_3.jpg', N'RAM Kingston DDR2 dung lượng 1GB cho máy tính để bàn.', 1),
(4, N'Intel Core i5-12400F', N'Cái', 40, 4200000, 'cpu_1.jpg', N'CPU Intel Core i5-12400F, 6 nhân 12 luồng.', 2),
(5, N'AMD Ryzen 5 5600X', N'Cái', 35, 4500000, 'cpu_2.jpg', N'CPU AMD Ryzen 5 5600X, 6 nhân 12 luồng.', 2),
(6, N'SSD Western Digital Green 240GB', N'Cái', 60, 650000, 'hdd_1.jpg', N'Ổ cứng SSD WD Green 240GB Sata III.', 3),
(7, N'HDD Seagate Barracuda 1TB', N'Cái', 80, 950000, 'hdd_2.jpg', N'Ổ cứng HDD Seagate Barracuda 1TB 7200RPM.', 3),
(8, N'Bàn phím cơ Fuhlen Ducky', N'Cái', 50, 1200000, 'keyboard_1.jpg', N'Bàn phím cơ chuyên game, có LED RGB.', 4),
(9, N'Bàn phím giả cơ Logitech K120', N'Cái', 100, 250000, 'keyboard_2.jpg', N'Bàn phím văn phòng, bền bỉ, gõ êm.', 4),
(10, N'Chuột Logitech G102', N'Cái', 80, 550000, 'mouse_1.jpg', N'Chuột gaming có dây, mắt đọc chính xác.', 5);
SET IDENTITY_INSERT dbo.tbTHIETBI OFF;
GO
PRINT 'Hoàn tất chèn dữ liệu.'
GO
-- Lấy tất cả nhóm
CREATE PROCEDURE sp_GetAll_Nhom
AS
BEGIN
    SELECT MANHOM, TENNHOM FROM dbo.tbNHOM;
END
GO

-- Lấy thiết bị theo mã nhóm
CREATE PROCEDURE sp_Get_ThietBi_ByNhom
    @MaNhom INT
AS
BEGIN
    SELECT * FROM dbo.tbTHIETBI WHERE MANHOM = @MaNhom;
END
GO

-- Lấy chi tiết thiết bị theo mã thiết bị
CREATE PROCEDURE sp_Get_ThietBi_ById
    @MaThietBi INT
AS
BEGIN
    SELECT * FROM dbo.tbTHIETBI WHERE MATHIETBI = @MaThietBi;
END
GO

-- (Các thủ tục thêm, sửa, xóa theo yêu cầu)
CREATE PROCEDURE sp_Insert_ThietBi
    @TenThietBi NVARCHAR(200),
    @DonViTinh NVARCHAR(50),
    @SoLuong INT,
    @DonGia NUMERIC(18,0),
    @HinhAnh NVARCHAR(100),
    @MoTa NVARCHAR(MAX),
    @MaNhom INT
AS
BEGIN
    INSERT INTO dbo.tbTHIETBI(TENTHIETBI, DONVITINH, SOLUONG, DONGIA, HINHANH, MOTA, MANHOM)
    VALUES (@TenThietBi, @DonViTinh, @SoLuong, @DonGia, @HinhAnh, @MoTa, @MaNhom);
END
GO

PRINT 'Hoàn tất tạo Stored Procedures.'
GO