create database StudentDB;
go
USE StudentDB;
GO

CREATE TABLE Students (
    Id INT PRIMARY KEY IDENTITY(1,1),
    MaSV VARCHAR(10) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    Lop NVARCHAR(50)
);
GO

-- Thêm dữ liệu mẫu
INSERT INTO Students (MaSV, HoTen, Lop)
VALUES
('SV001', N'Nguyễn Văn A', N'Lớp 12A1'),
('SV002', N'Trần Thị B', N'Lớp 11B2'),
('SV003', N'Lê Văn C', N'Lớp 10C3');
GO