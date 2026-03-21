-- Kiểm tra và xóa DB cũ nếu tồn tại để làm lại từ đầu
IF DB_ID('dbSHOPHOA') IS NOT NULL
BEGIN
    USE master;
    ALTER DATABASE dbSHOPHOA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE dbSHOPHOA;
    PRINT 'Cơ sở dữ liệu cũ dbSHOPHOA đã được xóa.'
END
GO


-- Tạo cơ sở dữ liệu mới
CREATE DATABASE dbSHOPHOA;
GO

USE dbSHOPHOA;
GO

-- Tạo bảng Loại hoa (trong đề ghi là tbNHOM nhưng tên cột là MALOAI, ta dùng tbLOAI cho nhất quán)
CREATE TABLE dbo.tbLOAI (
    MALOAI INT IDENTITY(1,1) PRIMARY KEY,
    TENLOAI NVARCHAR(200) NOT NULL
);
GO

-- Tạo bảng Hoa
CREATE TABLE dbo.tbHOA (
    MAHOA INT IDENTITY(1,1) PRIMARY KEY,
    TENHOA NVARCHAR(200) NOT NULL,
    DONVITINH NVARCHAR(50) NULL,
    SOLUONG INT NULL,
    DONGIA NUMERIC(18, 0) NULL,
    HINHANH NVARCHAR(100) NULL,
    MOTA NVARCHAR(MAX) NULL,
    MALOAI INT NULL,
    CONSTRAINT FK_HOA_LOAI FOREIGN KEY (MALOAI) REFERENCES dbo.tbLOAI(MALOAI)
);
GO

-- Chèn dữ liệu mẫu
INSERT INTO dbo.tbLOAI (TENLOAI) VALUES
(N'HOA HỒNG'),
(N'HOA CẨM CHƯỚNG'),
(N'HOA HƯỚNG DƯƠNG'),
(N'HOA LAN');

INSERT INTO dbo.tbHOA (TENHOA, DONVITINH, SOLUONG, DONGIA, HINHANH, MOTA, MALOAI) VALUES
(N'Hoa hồng đỏ Ecuador', N'Bó', 50, 500000, 'hoa_hong_1.jpg', N'Giỏ hoa hồng đỏ Ecuador sang trọng, biểu tượng cho tình yêu mãnh liệt.', 1),
(N'Hoa hồng phấn Juliet', N'Bó', 30, 750000, 'hoa_hong_2.jpg', N'Loài hoa hồng đắt giá nhất thế giới, mang vẻ đẹp ngọt ngào và kiêu sa.', 1),
(N'Cẩm chướng hồng', N'Bó', 100, 250000, 'cam_chuong_1.jpg', N'Bó hoa cẩm chướng hồng tươi thắm, thích hợp tặng mẹ hoặc bạn bè.', 2),
(N'Hướng dương mặt trời', N'Bó', 80, 300000, 'huong_duong_1.jpg', N'Những bông hoa hướng dương luôn hướng về phía mặt trời, biểu tượng của sự lạc quan.', 3),
(N'Lan hồ điệp trắng', N'Chậu', 20, 1200000, 'lan_ho_diep_1.jpg', N'Chậu lan hồ điệp trắng tinh khôi, món quà sang trọng cho các dịp đặc biệt.', 4);
GO

PRINT 'Tạo và chèn dữ liệu cho dbSHOPHOA thành công!'