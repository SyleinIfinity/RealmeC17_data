--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'THCSDL2_NHOM1')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''THCSDL2_NHOM1'' 
    BEGIN 
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE THCSDL2_NHOM1;
END
go
create database THCSDL2_NHOM1;
go

use THCSDL2_NHOM1;
go

-- Tạo table1: Khách hàng
CREATE TABLE KHACHHANG --Phần của Huỳnh Minh Dũng:
(
    MAKHACHHANG char(8),
    TENCONGTY nvarchar(100) not null,
    TENGIAODICH nvarchar(100) not null,
    DIACHI nvarchar(100) not null,
    EMAIL varchar(50) not null UNIQUE,
    DIENTHOAI varchar(11) not null,
    FAX varchar(10) null,
	constraint PK_MAKHACHHANG_1 PRIMARY KEY(MAKHACHHANG),
	constraint UQ_EMAIL_1 unique(EMAIL),
	constraint UQ_SDT_1 unique(DIENTHOAI),
	constraint CK_SDT_1 check(DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
						or DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
go
-- Tạo table2: Nhân viên
create table NHANVIEN --Phần của Phan Văn Khánh:
(
	MANHANVIEN char(8),
	HO nvarchar(10) not null,
	TEN nvarchar(40) not null,
	NGAYSINH date,
	NGAYLAMVIEC date,
	DIACHI nvarchar(100) not null,
	DIENTHOAI varchar(11) not null,
	LUONGCOBAN decimal(20, 2),
	PHUCAP decimal(20, 2),
	constraint PK_MANHANVIEN_2 PRIMARY KEY(MANHANVIEN),
	constraint CK_NgaySinh_2 check(NGAYSINH < GETDATE()),
	constraint CK_NgayLamViec_2 check(NGAYLAMVIEC >= GETDATE()),
	constraint UQ_SDT_2 unique(DIENTHOAI),
	constraint CK_SDT_2 check(DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
						or DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	constraint CK_LUONGCOBAN_2 check(LUONGCOBAN >=0),
	constraint CK_PHUCAP_2 check(PHUCAP >=0)
);
go
-- Tạo table3: Đơn đặt hàng
CREATE TABLE DONDATHANG --Phần của Huỳnh Minh Dũng
(
    SOHOADON char(8),
    KHACHHANG_NO char(8),
    NHANVIEN_NO char(8),
    NGAYDATHANG date,
    NGAYGIAOHANG date,
    NGAYCHUYENHANG date,
    NOIGIAOHANG nvarchar(100),
	constraint PK_SOHOADON_3 PRIMARY KEY(SOHOADON),
    constraint FK_KHACHHANG_NO_3 FOREIGN KEY (KHACHHANG_NO) references KHACHHANG(MAKHACHHANG)
									ON UPDATE CASCADE
									ON DELETE CASCADE,
    constraint FK_NHANVIEN_NO_3 FOREIGN KEY (NHANVIEN_NO) references NHANVIEN(MANHANVIEN)
									ON UPDATE CASCADE
									ON DELETE CASCADE
);
go
-- Tạo table4: Nhà cung cấp
create table NHACUNGCAP --Phần của Phạm Văn Lý
(
	MACONGTY char(8),
	TENCONGTY nvarchar(100) not null,
	TENGIAODICH varchar(50) not null,
	DIACHI nvarchar(100),
	DIENTHOAI varchar(11) not null Unique,
	FAX varchar(10),
	EMAIL varchar(50) Unique,
	constraint PK_MACONGTY_4 PRIMARY KEY(MACONGTY),
	constraint UQ_DIENTHOAI_4 unique(DIENTHOAI),
	constraint UQ_EMAIL_4 unique(EMAIL)
);
go
-- Tạo table5: Loại hàng
create table LOAIHANG --Phần của Nguyễn Tuấn Anh
(
	MALOAIHANG char(8),
	TENLOAIHANG nvarchar(100) not null,
	constraint PK_MALOAIHANG_5 PRIMARY KEY(MALOAIHANG)
);
go
-- Tạo table6: Mặt hàng
create table MATHANG --Phần của Nguyễn Tuấn Anh
(
	MAHANG char(8),
	TENHANG nvarchar(100) not null,
	CONGTY_NO char(8) not null,
	LOAIHANG_NO char(8) not null,
	SOLUONG float,
	DONVITINH nvarchar(100),
	GIAHANG decimal(20, 2),
	constraint PK_MAHANG_6 PRIMARY KEY(MAHANG),
	constraint PK_CONGTY_NO_6 FOREIGN KEY(CONGTY_NO) references NHACUNGCAP(MACONGTY)
									ON UPDATE CASCADE
									ON DELETE CASCADE,
	constraint PK_LOAIHANG_NO_6 FOREIGN KEY(LOAIHANG_NO) references LOAIHANG(MALOAIHANG)
									ON UPDATE CASCADE
									ON DELETE CASCADE,
	constraint CK_SOLUONG_6 check(SOLUONG >=0),
	constraint CK_GIAHANG_6 check(GIAHANG >=0)
);
go
-- Tạo table7: Chi tiết đặt hàng
create table CHITIETDATHANG --Phần của Phạm Văn Lý
(
	SOHOADON char(8) not null,
	MAHANG char(8) not null ,
	GIABAN decimal(20, 2),
	SOLUONG float,
	MUCGIAMGIA decimal(5,2),
	constraint PK_SHD_MH_7 PRIMARY KEY(SOHOADON, MAHANG),
	constraint PK_MAHANG_7 FOREIGN KEY(MAHANG) references MATHANG(MAHANG)
									ON UPDATE CASCADE
									ON DELETE CASCADE,
	constraint PK_SOHOADON_7 FOREIGN KEY(SOHOADON) references DONDATHANG(SOHOADON)
									ON UPDATE CASCADE
									ON DELETE CASCADE
);
GO
---(1) Các quan hệ đã được tạo khi tạo bảng lúc đầu

---(2)Phần của Nguyễn Tuấn Anh: Bổ sung ràng buộc bảng CHITIETDATHANG
ALTER TABLE CHITIETDATHANG
		ADD CONSTRAINT DF_SOLUONG_7 DEFAULT 1 FOR SOLUONG,
			CONSTRAINT DF_MUCGIAMGIA_7 DEFAULT 0 FOR MUCGIAMGIA;
GO
---(3)Phần của Huỳnh Minh Dũng: Bổ sung ràng buộc bảng DONDATHANG
ALTER TABLE DONDATHANG
	ADD CONSTRAINT ck_ngayThanhToanGiaoHang CHECK( NGAYGIAOHANG >= NGAYDATHANG
											AND NGAYCHUYENHANG >= NGAYDATHANG
											AND NGAYCHUYENHANG <= NGAYGIAOHANG);
GO
---(4)Phần của Phạm Văn Lý: Bổ sung ràng buộc bảng NHANVIEN
ALTER TABLE NHANVIEN
	ADD CONSTRAINT CK_Tuoi_2 CHECK (YEAR(GETDATE()) - YEAR(NGAYSINH) >= 18 
								AND YEAR(GETDATE()) - YEAR(NGAYSINH) < 60);

---------------------------------------------------------------------------------
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, DIACHI, EMAIL, DIENTHOAI, FAX)
VALUES 
	('KH000001', 'Công ty A', 'Giao dịch A', 'Địa chỉ 1', 'a@gmail.com', '0123456789', NULL),
	('KH000002', 'Công ty B', 'Giao dịch B', 'Địa chỉ 2', 'b@gmail.com', '0123456790', NULL),
	('KH000003', 'Công ty C', 'Giao dịch C', 'Địa chỉ 3', 'c@gmail.com', '0123456791', NULL),
	('KH000004', 'Công ty D', 'Giao dịch D', 'Địa chỉ 4', 'd@gmail.com', '0123456792', NULL),
	('KH000005', 'Công ty E', 'Giao dịch E', 'Địa chỉ 5', 'e@gmail.com', '0123456793', NULL),
	('KH000006', 'Công ty F', 'Giao dịch F', 'Địa chỉ 6', 'f@gmail.com', '0123456794', NULL),
	('KH000007', 'Công ty G', 'Giao dịch G', 'Địa chỉ 7', 'g@gmail.com', '0123456795', NULL),
	('KH000008', 'Công ty H', 'Giao dịch H', 'Địa chỉ 8', 'h@gmail.com', '0123456796', NULL),
	('KH000009', 'Công ty I', 'Giao dịch I', 'Địa chỉ 9', 'i@gmail.com', '0123456797', NULL),
	('KH000010', 'Công ty J', 'Giao dịch J', 'Địa chỉ 10', 'j@gmail.com', '0123456798', NULL),
	('KH000011', 'Công ty K', 'Giao dịch K', 'Địa chỉ 11', 'k@gmail.com', '0123456799', NULL),
	('KH000012', 'Công ty L', 'Giao dịch L', 'Địa chỉ 12', 'l@outlook.com', '0123456700', NULL),
	('KH000013', 'Công ty M', 'Giao dịch M', 'Địa chỉ 13', 'm@outlook.com', '0123456701', NULL),
	('KH000014', 'Công ty N', 'Giao dịch N', 'Địa chỉ 14', 'n@outlook.com', '0123456702', NULL),
	('KH000015', 'Công ty O', 'Giao dịch O', 'Địa chỉ 15', 'o@outlook.com', '0123456703', NULL),
	('KH000016', 'Công ty P', 'Giao dịch P', 'Địa chỉ 16', 'p@outlook.com', '0123456704', NULL),
	('KH000017', 'Công ty Q', 'Giao dịch Q', 'Địa chỉ 17', 'q@outlook.com', '0123456705', NULL),
	('KH000018', 'Công ty R', 'Giao dịch R', 'Địa chỉ 18', 'r@outlook.com', '0123456706', NULL),
	('KH000019', 'Công ty S', 'Giao dịch S', 'Địa chỉ 19', 's@outlook.com', '0123456707', NULL),
	('KH000020', 'Công ty T', 'Giao dịch T', 'Địa chỉ 20', 't@outlook.com', '0123456708', NULL);
INSERT INTO DONDATHANG (SOHOADON, KHACHHANG_NO, NHANVIEN_NO, NGAYDATHANG, NGAYGIAOHANG, NGAYCHUYENHANG, NOIGIAOHANG)
VALUES 
	('SHD00001', 'KH000001', 'NV000001', '2024-10-01', '2024-10-05', '2024-10-05', 'Nơi giao hàng 1'),
	('SHD00002', 'KH000002', 'NV000002', '2024-10-02', '2024-10-07', '2024-10-07', 'Nơi giao hàng 2'),
	('SHD00003', 'KH000003', 'NV000003', '2024-10-03', '2024-10-09', '2024-10-09', 'Nơi giao hàng 3'),
	('SHD00004', 'KH000004', 'NV000004', '2024-10-04', '2024-10-11', '2024-10-11', 'Nơi giao hàng 4'),
	('SHD00005', 'KH000005', 'NV000005', '2024-10-05', '2024-10-13', '2024-10-13', 'Nơi giao hàng 5'),
	('SHD00006', 'KH000006', 'NV000006', '2024-10-06', '2024-10-15', '2024-10-15', 'Nơi giao hàng 6'),
	('SHD00007', 'KH000007', 'NV000007', '2024-10-07', '2024-10-17', '2024-10-17', 'Nơi giao hàng 7'),
	('SHD00008', 'KH000008', 'NV000008', '2024-10-08', '2024-10-19', '2024-10-19', 'Nơi giao hàng 8'),
	('SHD00009', 'KH000009', 'NV000009', '2024-10-09', '2024-10-21', '2024-10-21', 'Nơi giao hàng 9'),
	('SHD00010', 'KH000010', 'NV000010', '2024-10-10', '2024-10-23', '2024-10-23', 'Nơi giao hàng 10'),
	('SHD00011', 'KH000011', 'NV000011', '2024-10-11', '2024-10-25', '2024-10-25', 'Nơi giao hàng 11'),
	('SHD00012', 'KH000012', 'NV000012', '2024-10-12', '2024-10-27', '2024-10-27', 'Nơi giao hàng 12'),
	('SHD00013', 'KH000013', 'NV000013', '2024-10-13', '2024-10-29', '2024-10-29', 'Nơi giao hàng 13'),
	('SHD00014', 'KH000014', 'NV000014', '2024-10-14', '2024-10-31', '2024-10-31', 'Nơi giao hàng 14'),
	('SHD00015', 'KH000015', 'NV000015', '2024-10-15', '2024-11-02', '2024-11-02', 'Nơi giao hàng 15'),
	('SHD00016', 'KH000016', 'NV000016', '2024-10-16', '2024-11-04', '2024-11-04', 'Nơi giao hàng 16'),
	('SHD00017', 'KH000017', 'NV000017', '2024-10-17', '2024-11-06', '2024-11-06', 'Nơi giao hàng 17'),
	('SHD00018', 'KH000018', 'NV000018', '2024-10-18', '2024-11-08', '2024-11-08', 'Nơi giao hàng 18'),
	('SHD00019', 'KH000019', 'NV000019', '2024-10-19', '2024-11-10', '2024-11-10', 'Nơi giao hàng 19'),
	('SHD00020', 'KH000020', 'NV000020', '2024-10-20', '2024-11-12', '2024-11-12', 'Nơi giao hàng 20');