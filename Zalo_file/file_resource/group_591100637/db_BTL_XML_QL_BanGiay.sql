USE master
GO
IF EXISTS (SELECT * FROM sys.databases WHERE NAME ='db_BTL_XML_QL_BanGiay')
DROP DATABASE db_BTL_XML_QL_BanGiay

go
CREATE DATABASE db_BTL_XML_QL_BanGiay;
go
USE db_BTL_XML_QL_BanGiay;
go

CREATE TABLE NhanVien (
	manhanvien VARCHAR(20) NOT NULL,
	hoten NVARCHAR(50) NOT NULL,
	diachi NVARCHAR(255),
	sdt CHAR(10) NOT NULL,
	email VARCHAR(30) NOT NULL
);
go

ALTER TABLE NhanVien
ADD
	CONSTRAINT PK_NhanVien_manhanvien PRIMARY KEY(manhanvien),
	CONSTRAINT UNI_NhanVien_sdt UNIQUE(sdt),
	CONSTRAINT UNI_NhanVien_email UNIQUE(email)
go


CREATE TABLE TaiKhoan (
	manhanvien VARCHAR(20) NOT NULL,
	matkhau VARCHAR(20) NOT NULL,
	quyen BIT --1: admin (quản trị viên) / 0: nhân viên
);
go

ALTER TABLE TaiKhoan
ADD
	CONSTRAINT PK_TaiKhoan_manhanvien PRIMARY KEY(manhanvien),
	CONSTRAINT FK_NhanVien_TaiKhoan_manhanvien FOREIGN KEY(manhanvien) REFERENCES NhanVien(manhanvien) ON UPDATE CASCADE ON DELETE CASCADE
go

CREATE TABLE HieuGiay (
	mahieugiay VARCHAR(20) NOT NULL,
	tenhieugiay NVARCHAR(255) NOT NULL
);
go

ALTER TABLE HieuGiay 
ADD
	CONSTRAINT PK_HieuGiay_mahieugiay PRIMARY KEY(mahieugiay)
go

CREATE TABLE DanhMuc (
	madanhmuc VARCHAR(20) NOT NULL,
	tendanhmuc NVARCHAR(255) NOT NULL
); 
go
ALTER TABLE DanhMuc 
ADD
	CONSTRAINT PK_DanhMuc_madanhmuc PRIMARY KEY(madanhmuc)
go

CREATE TABLE Giay (
	magiay VARCHAR(20) NOT NULL,
	mahieugiay VARCHAR(20),
	tengiay NVARCHAR(255) NOT NULL,
	size SMALLINT,
	mau NVARCHAR(20),
	dongia DECIMAL(18, 2),
	soluong INT
);
go
ALTER TABLE Giay 
ADD 
	CONSTRAINT PK_Giay_magiay PRIMARY KEY(magiay),
	CONSTRAINT FK_HieuGiay_Giay_mahieugiay FOREIGN KEY(mahieugiay) REFERENCES HieuGiay(mahieugiay) ON UPDATE CASCADE ON DELETE CASCADE

go
CREATE TABLE ChiTietDanhMucGiay(
	madanhmuc VARCHAR(20) NOT NULL,
	magiay VARCHAR(20) NOT NULL
)
go

ALTER TABLE ChiTietDanhMucGiay
ADD
	CONSTRAINT PK_DanhMuc_Giay_madanhmuc_magiay PRIMARY KEY(madanhmuc, magiay),
	CONSTRAINT FK_DanhMuc_ChiTietDanhMucGiay_madanhmuc FOREIGN KEY(madanhmuc) REFERENCES DanhMuc(madanhmuc) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT FK_Giay_ChiTietDanhMucGiay_magiay FOREIGN KEY(magiay) REFERENCES Giay(magiay) ON UPDATE CASCADE ON DELETE CASCADE

go
CREATE TABLE HoaDon (
	mahoadon VARCHAR(20) NOT NULL,
	manhanvien VARCHAR(20),
	tenkhachhang NVARCHAR(50) NOT NULL,
	ngaytao DATETIME,
	phuongthucthanhtoan BIT, --1:tiền mặt / 0: chuyển khoản
	tongtien DECIMAL(18, 2)  NOT NULL,
	trangthai BIT --1: đã thanh toán / 0: chưa thanh toán
);

go
ALTER TABLE HoaDon
ADD
	CONSTRAINT PK_HoaDon_mahoadon PRIMARY KEY(mahoadon),
	CONSTRAINT FK_NhanVien_HoaDon_manhanvien FOREIGN KEY(manhanvien) REFERENCES NhanVien(manhanvien) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT CHK_HoaDon_ngaytao CHECK(ngaytao <= GETDATE()),
	CONSTRAINT CHK_HoaDon_tongtien CHECK(tongtien >= 0)

go
CREATE TABLE ChiTietHoaDon (
	mahoadon VARCHAR(20) NOT NULL,
	magiay VARCHAR(20) NOT NULL,
	soluong INT,
	dongia DECIMAL(18, 2)

);
go
ALTER TABLE ChiTietHoaDon
ADD
	CONSTRAINT PK_HoaDon_Giay_mahoadon_magiay PRIMARY KEY(mahoadon, magiay),
	CONSTRAINT FK_Giay_ChiTietHoaDon_magiay FOREIGN KEY(magiay) REFERENCES Giay(magiay) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT FK_HoaDon_ChiTietHoaDon_mahoadon FOREIGN KEY(mahoadon) REFERENCES HoaDon(mahoadon) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT CHK_ChiTietHoaDon_soluong CHECK(soluong > 0),
	CONSTRAINT CHK_ChiTietHoaDon_dongia CHECK(dongia >= 0)

-----
DELETE FROM ChiTietHoaDon
DELETE FROM ChiTietDanhMucGiay
DELETE FROM HoaDon
DELETE FROM Giay
DELETE FROM HieuGiay
DELETE FROM DanhMuc
DELETE FROM TaiKhoan
DELETE FROM NhanVien

SELECT * FROM ChiTietHoaDon
SELECT * FROM ChiTietDanhMucGiay
SELECT * FROM HoaDon
SELECT * FROM Giay
SELECT * FROM HieuGiay
SELECT * FROM DanhMuc
SELECT * FROM TaiKhoan
SELECT * FROM NhanVien