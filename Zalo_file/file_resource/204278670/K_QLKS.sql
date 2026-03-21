--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'K_QLKS')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''K_QLKS'' 
    BEGIN
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE K_QLKS;
END
GO
-- TẠO DATABASE
CREATE DATABASE K_QLKS;
GO
USE K_QLKS;
GO

-- ========================
-- 1. BẢNG VaiTro
-- ========================
CREATE TABLE VaiTro (
    maVaiTro INT PRIMARY KEY,
    tenVaiTro NVARCHAR(50) NOT NULL -- 'Khach', 'NhanVien'
);
GO

-- ========================
-- 2. BẢNG NguoiDung
-- ========================
CREATE TABLE NguoiDung (
    maNguoiDung INT IDENTITY PRIMARY KEY,
    hoTen NVARCHAR(100) NULL,
    taiKhoan VARCHAR(50) UNIQUE NOT NULL,
    matKhau NVARCHAR(50) NOT NULL,
    sdt varchar(11) NULL,
    email VARCHAR(50) NULL,
    maVaiTro INT NOT NULL FOREIGN KEY REFERENCES VaiTro(maVaiTro)
);
GO

-- ========================
-- 3. BẢNG LoaiPhong
-- ========================
CREATE TABLE LoaiPhong (
    maLoaiPhong INT PRIMARY KEY,
    tenLoaiPhong NVARCHAR(255),
    giaTien DECIMAL(18,2)
);
GO

-- ========================
-- 4. BẢNG Phong
-- ========================
CREATE TABLE Phong (
    maPhong INT PRIMARY KEY,
    tenPhong NVARCHAR(50),
    maLoaiPhong INT NOT NULL,
    trangThai NVARCHAR(20),
    FOREIGN KEY(maLoaiPhong) REFERENCES LoaiPhong(maLoaiPhong)
);
GO

-- ========================
-- 5. BẢNG DatPhong
-- ========================
CREATE TABLE DatPhong (
    maDatPhong INT IDENTITY PRIMARY KEY,
    maNguoiDung INT NOT NULL FOREIGN KEY REFERENCES NguoiDung(maNguoiDung),
    maPhong INT NOT NULL FOREIGN KEY REFERENCES Phong(maPhong),
    ngayDat DATETIME DEFAULT GETDATE(),
    ngayNhan DATETIME,
    ngayTra DATETIME,
    trangThai NVARCHAR(20), -- 'ChoDuyet', 'ChapNhan', 'TuChoi', 'DaHuy', 'HoanThanh'
    maNhanVienDuyet INT NULL FOREIGN KEY REFERENCES NguoiDung(maNguoiDung)
);
GO

-- ========================
-- 6. BẢNG HoaDon
-- ========================
CREATE TABLE HoaDon (
    maHoaDon INT IDENTITY PRIMARY KEY,
    maDatPhong INT NOT NULL FOREIGN KEY REFERENCES DatPhong(maDatPhong),
    ngayThanhToan DATETIME DEFAULT GETDATE(),
    tongTien DECIMAL(18,2),
    trangThai NVARCHAR(20) DEFAULT 'ChuaThanhToan'
);
