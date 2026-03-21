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

--INSERT INTO Phần của Nguyễn Tuấn Anh
INSERT INTO LOAIHANG ( MALOAIHANG, TENLOAIHANG)
	VALUES
		('LH000001', N'Lô hàng AA'),
		('LH000002', N'Lô hàng AB'),
		('LH000003', N'Lô hàng AC'),
		('LH000004', N'Lô hàng AD'),
		('LH000005', N'Lô hàng AE'),
		('LH000007', N'Lô hàng AF'),
		('LH000008', N'Lô hàng AG'),
		('LH000009', N'Lô hàng AH'),
		('LH000010', N'Lô hàng AI'),
		('LH000011', N'Lô hàng AJ'),
		('LH000012', N'Lô hàng AK'),
		('LH000013', N'Lô hàng AL'),
		('LH000014', N'Lô hàng AM'),
		('LH000015', N'Lô hàng AN'),
		('LH000016', N'Lô hàng AO'),
		('LH000017', N'Lô hàng AP'),
		('LH000018', N'Lô hàng AQ'),
		('LH000019', N'Lô hàng AR'),
		('LH000020', N'Lô hàng AS');
INSERT INTO MATHANG ( MAHANG, TENHANG, CONGTY_NO, LOAIHANG_NO, SOLUONG, DONVITINH, GIAHANG)
	VALUES
		('MH000001', N'Bánh mì Đồng Tiến', 'CTY00001', 'LH000001', 3, N'Gói', 54000),
		('MH000002', N'Bánh mì Đồng Thạnh', 'CTY00002', 'LH000002', 5, N'Gói', 90000),
		('MH000003', N'Sữa tươi Vinamilk', 'CTY00003', 'LH000003', 4, N'Thùng', 1200000),
		('MH000004', N'Sữa tươi TH TrueMilk', 'CTY00004', 'LH000004', 5, N'Thùng', 1500000 ),
		('MH000005', N'Sữa chua uống Vinamilk', 'CTY00005', 'LH000005', 3, N'Thùng', 1200000),
		('MH000006', N'Bánh bông lan Solite', 'CTY00006', 'LH000006', 3, N'Hộp', 300000),
		('MH000007', N'Bánh quy bơ Dasani', 'CTY00007', 'LH000007', 6, N'Hộp', 420000),
		('MH000008', N'Bánh quy bơ LU', 'CTY00008', 'LH000008', 5, N'Hộp', 200000),
		('MH000009', N'Mứt nho sấy khô', 'CTY00009', 'LH000009', 4, N'Gói', 200000),
		('MH000010', N'Mứt trái cây nhiệt đới', 'CTY00010', 'LH000010', 3, N'Gói', 210000),
		('MH000011', N'Kẹo bốn mùa', 'CTY00011', 'LH000011', 7, N'Gói', 140000),
		('MH000012', N'Kẹo sữa Milkita', 'CTY00012', 'LH000012', 8, N'Gói', 240000),
		('MH000013', N'Kẹo dừa', 'CTY00013', 'LH000013', 5, N'Gói', 100000),
		('MH000014', N'Kẹo nho', 'CTY00014', 'LH000014', 3, N'Gói', 45000),
		('MH000015', N'Thạch rau câu Đồng Thạch', 'CTY00015', 'LH000015', 10, N'Gói', 500000),
		('MH000016', N'Sữa chua nếp cẩm', 'CTY00016', 'LH000016', 3, N'Hộp', 210000),
		('MH000017', N'Thịt ba chỉ bò Mỹ đông lạnh', 'CTY00017', 'LH000017', 5, N'Gói', 1000000),
		('MH000018', N'Xúc xích Đức', 'CTY00018', 'LH000018', 5, N'Gói', 250000),
		('MH000019', N'Cá viên chiên đông lạnh', 'CTY00019', 'LH000019', 6, N'Gói', 300000),
		('MH000020', N'Nước ngọt Mirinda Xá Xị', 'CTY00020', 'LH000020', 7, N'Thùng', 840000);
