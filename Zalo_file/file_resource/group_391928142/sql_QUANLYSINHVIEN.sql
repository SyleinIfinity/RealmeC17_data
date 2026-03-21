-- Tạo database udn nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'udn')
BEGIN
    CREATE DATABASE udn;
END
GO

-- Chuyển sang database udn
USE udn;
GO

-- Tạo bảng sinhvien nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sinhvien')
BEGIN
    CREATE TABLE sinhvien (
        masv VARCHAR(10) PRIMARY KEY,
        hoten NVARCHAR(100) NOT NULL,
        lop VARCHAR(10),
        diachi NVARCHAR(100),
        matkhau VARCHAR(50)
    );
END
GO

-- Xóa dữ liệu cũ nếu có
DELETE FROM sinhvien;
GO

-- Thêm dữ liệu mẫu mới
INSERT INTO sinhvien (masv, hoten, lop, diachi, matkhau) VALUES
('S01', N'Phùng Văn Vũ', '23T1', N'Đà Nẵng', '1234'),
('S02', N'Lê Bảo Ngọc', 'TUD', N'Hải Phòng', '1234'),
('S03', N'Trần Minh Tâm', 'SPT', N'Đà Nẵng', '1234'),
('S04', N'Phạm Hoài Nam', 'SPT', N'Thừa Thiên Huế', '1234'),
('S05', N'Võ Nhật Linh', 'SPT', N'Quảng Nam', '1234'),
('S06', N'Nguyễn Văn Lộc', '15T', N'Quảng Ngãi', '1234'),
('S07', N'Phan Ngọc Yến', '15T', N'Bình Định', '1234'),
('S08', N'Lâm Trọng Nghĩa', '15T', N'Kon Tum', '1234'),
('S09', N'Nguyễn Thị Lan', '15T', N'Nghệ An', '1234'),
('S10', N'Hoàng Đức Anh', '15T', N'Hà Tĩnh', '1234'),
('S11', N'Trịnh Văn Quân', '15T', N'Gia Lai', '1234'),
('S12', N'Đoàn Thu Hà', '15T', N'Thanh Hóa', '1234'),
('S13', N'Bùi Nhật Tân', '15T', N'Lâm Đồng', '1234'),
('S14', N'Lê Văn Vỹ', '22T', N'Lâm Đồng', '1234');
GO

-- Kiểm tra kết quả
SELECT * FROM sinhvien;
GO
