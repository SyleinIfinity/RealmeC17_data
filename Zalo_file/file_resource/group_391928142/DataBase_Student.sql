IF EXISTS (SELECT * FROM sys.databases WHERE name = N'SinhVien1')
	BEGIN
		USE master
		ALTER database SinhVien1 set single_user with rollback immediate
		DROP DATABASE SinhVien1;
	END
GO
create database SinhVien1
go
use [SinhVien1]
CREATE TABLE student (
    scode CHAR(6) PRIMARY KEY,
    sname NVARCHAR(50),
    class VARCHAR(10),
    address NVARCHAR(100)
);

INSERT INTO student VALUES
('S01', N'Lê Tấn Danh', 'XML01', N'Điện Biên'),
('S02', N'Nguyễn Thị Thu Hằng', 'XML01', N'Lai Châu'),
('S03', N'Ngô Thị Thùy Anh', 'XML02', N'Lào Cai'),
('S04', N'Huỳnh Phú Quốc', 'XML02', N'Hà Giang');
