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
    EMAIL varchar(50),
    DIENTHOAI varchar(11),
    FAX varchar(10),
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
	NGAYSINH date not null,
	NGAYLAMVIEC date not null,
	DIACHI nvarchar(100) not null,
	DIENTHOAI varchar(11),
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
--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--TUẦN 6--
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
GO
--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--TUẦN 7--

----Huỳnh Minh Dũng:
--Thêm constraint cho email
ALTER TABLE KHACHHANG
	add CONSTRAINT CK_Email_N check(email like '[a-z]%@%');
GO
--Insert thông tin cho bảng KHÁCH HÀNG
INSERT INTO KHACHHANG (MAKHACHHANG, TENCONGTY, TENGIAODICH, DIACHI, EMAIL, DIENTHOAI, FAX)
VALUES 
	('KH000001', N'Công ty A', N'Giao dịch A', N'Địa chỉ 01', 'dap@gmail.com', '0123456789', NULL),
	('KH000002', N'Công ty B', N'Giao dịch B', N'Địa chỉ 02', 'dbp@gmail.com', '0123456790', NULL),
	('KH000003', N'Công ty C', N'Giao dịch C', N'Địa chỉ 03', 'dcp@gmail.com', '0123456791', NULL),
	('KH000004', N'Công ty D', N'Giao dịch D', N'Địa chỉ 04', 'ddp@gmail.com', '0123456792', NULL),
	('KH000005', N'Công ty E', N'Giao dịch E', N'Địa chỉ 05', 'dep@gmail.com', '0123456793', NULL),
	('KH000006', N'Công ty F', N'Giao dịch F', N'Địa chỉ 06', 'dfp@gmail.com', '0123456794', NULL),
	('KH000007', N'Công ty G', N'Giao dịch G', N'Địa chỉ 07', 'dgp@gmail.com', '0123456795', NULL),
	('KH000008', N'Công ty H', N'Giao dịch H', N'Địa chỉ 08', 'dhp@gmail.com', '0123456796', NULL),
	('KH000009', N'Công ty I', N'Giao dịch I', N'Địa chỉ 09', 'dip@gmail.com', '0123456797', NULL),
	('KH000010', N'Công ty J', N'Giao dịch J', N'Địa chỉ 10', 'djp@gmail.com', '0123456798', NULL),
	('KH000011', N'Công ty K', N'Giao dịch K', N'Địa chỉ 11', 'dkp@gmail.com', '0123456799', NULL),
	('KH000012', N'Công ty L', N'Giao dịch L', N'Địa chỉ 12', 'l@outlook.com', '0123456700', NULL),
	('KH000013', N'Công ty M', N'Giao dịch M', N'Địa chỉ 13', 'm@outlook.com', '0123456701', NULL),
	('KH000014', N'Công ty N', N'Giao dịch N', N'Địa chỉ 14', 'n@outlook.com', '0123456702', NULL),
	('KH000015', N'Công ty O', N'Giao dịch O', N'Địa chỉ 15', 'o@outlook.com', '0123456703', NULL),
	('KH000016', N'Công ty P', N'Giao dịch P', N'Địa chỉ 16', 'p@outlook.com', '0123456704', NULL),
	('KH000017', N'Công ty Q', N'Giao dịch Q', N'Địa chỉ 17', 'q@outlook.com', '0123456705', NULL),
	('KH000018', N'Công ty R', N'Giao dịch R', N'Địa chỉ 18', 'r@outlook.com', '0123456706', NULL),
	('KH000019', N'Công ty S', N'Giao dịch S', N'Địa chỉ 19', 's@outlook.com', '0123456707', NULL),
	('KH000020', N'Công ty T', N'Giao dịch T', N'Địa chỉ 20', 't@outlook.com', '0123456708', NULL);
GO
-----Phan Văn Khánh:
--Xóa constraint cũ ngày làm việc
alter table NHANVIEN
	drop constraint CK_NgayLamViec_2;
GO
--Điều chỉnh lại constraint ngày làm việc
alter table NHANVIEN
	add constraint CK_NgayLamViec_N 
			check(YEAR(GETDATE()) - YEAR(NGAYSINH) >= 18 );
GO
set dateformat dmy;
GO
--Insert thông tin cho bảng NHÂN VIÊN
INSERT NHANVIEN(MANHANVIEN, HO, TEN, NGAYSINH, NGAYLAMVIEC, DIACHI, DIENTHOAI, LUONGCOBAN, PHUCAP)
VALUES
	('NV000001',N'Phan Văn' ,N'AA', '07-01-2005',getdate() + 3, N'01 alo, Quận Sơn Trà, Đà Nãng', '0190234682', 5000000, 200000),
	('NV000002',N'Phan Văn' ,N'AB', '12-01-2005',getdate() + 3, N'02 alo, Quận Sơn Trà, Đà Nãng', '0922934293', 5000000, 200000),
	('NV000003',N'Phan Văn' ,N'AC', '05-01-2005',getdate() + 3, N'03 alo, Quận Sơn Trà, Đà Nãng', '0823346694', 5000000, 200000),
	('NV000004',N'Phan Văn' ,N'AD', '05-01-2005',getdate() + 3, N'04 alo, Quận Sơn Trà, Đà Nãng', '0523465615', 5000000, 200000),
	('NV000005',N'Phan Văn' ,N'AE', '05-01-2005',getdate() + 3, N'05 alo, Quận Sơn Trà, Đà Nãng', '0527755316', 5000000, 200000),
	('NV000006',N'Phan Văn' ,N'AF', '05-01-2005',getdate() + 3, N'06 alo, Quận Sơn Trà, Đà Nãng', '0523456827', 5000000, 200000),
	('NV000007',N'Lê Hoàng' ,N'AG', '12-01-2005',getdate() + 3, N'07 alo, Quận Sơn Trà, Đà Nãng', '0120458782', 5000000, 200000),
	('NV000008',N'Lê Hoàng' ,N'AH', '12-01-2005',getdate() + 8, N'08 alo, Quận Sơn Trà, Đà Nãng', '0302046889', 5000000, 200000),
	('NV000009',N'Lê Hoàng' ,N'AI', '12-01-2005',getdate() + 8, N'09 alo, Quận Sơn Trà, Đà Nãng', '0372343509', 5000000, 200000),
	('NV000010',N'Phan Văn' ,N'AJ', '12-01-2005',getdate() + 3, N'10 alo, Quận Sơn Trà, Đà Nãng', '0176343400', 5000000, 200000),
	('NV000011',N'Nguyễn Lê',N'AK', '07-01-2005',getdate() + 4, N'11 alo, Quận Sơn Trà, Đà Nãng', '0027354632', 5000000, 200000),
	('NV000012',N'Nguyễn Lê',N'AL', '02-01-2005',getdate() + 4, N'12 alo, Quận Sơn Trà, Đà Nãng', '0292344639', 5000000, 200000),
	('NV000013',N'Nguyễn Lê',N'AM', '02-01-2005',getdate() + 3, N'13 alo, Quận Sơn Trà, Đà Nãng', '0198875620', 5000000, 200000),
	('NV000014',N'Phan Văn' ,N'AN', '12-01-2005',getdate() + 3, N'14 alo, Quận Sơn Trà, Đà Nãng', '0125765269', 5000000, 200000),
	('NV000015',N'Phan Văn' ,N'AO', '12-01-2005',getdate() + 3, N'15 alo, Quận Sơn Trà, Đà Nãng', '0923566329', 5000000, 200000),
	('NV000016',N'Phan Văn' ,N'AP', '16-01-2005',getdate() + 3, N'16 alo, Quận Sơn Trà, Đà Nãng', '0923455649', 5000000, 200000),
	('NV000017',N'Phan Văn' ,N'AQ', '13-01-2005',getdate() + 2, N'17 alo, Quận Sơn Trà, Đà Nãng', '0123335449', 5000000, 200000),
	('NV000018',N'Trần Văn' ,N'AO', '13-01-2005',getdate() + 1, N'18 alo, Quận Sơn Trà, Đà Nãng', '0983056440', 5000000, 200000),
	('NV000019',N'Trần Văn' ,N'AS', '13-01-2005',getdate() + 1, N'19 alo, Quận Sơn Trà, Đà Nãng', '0123006893', 5000000, 200000),
	('NV000020',N'Trần Văn' ,N'AT', '02-01-2005',getdate() + 3, N'20 alo, Quận Sơn Trà, Đà Nãng', '0123485892', 5000000, 200000);
GO

----Huỳnh Minh Dũng: Insert thông tin cho bảng ĐƠN ĐẶT HÀNG
set dateformat dmy;
GO
INSERT INTO DONDATHANG (SOHOADON, KHACHHANG_NO, NHANVIEN_NO, NGAYDATHANG, NGAYGIAOHANG, NGAYCHUYENHANG, NOIGIAOHANG)
VALUES 
	('SHD00001', 'KH000001', 'NV000001', '2024-10-01', '2024-10-05', '2024-10-05', 'Nơi giao hàng 01'),
	('SHD00002', 'KH000002', 'NV000002', '2024-10-02', '2024-10-07', '2024-10-07', 'Nơi giao hàng 02'),
	('SHD00003', 'KH000003', 'NV000003', '2024-10-03', '2024-10-09', '2024-10-09', 'Nơi giao hàng 03'),
	('SHD00004', 'KH000004', 'NV000004', '2024-10-04', '2024-10-11', '2024-10-11', 'Nơi giao hàng 04'),
	('SHD00005', 'KH000005', 'NV000005', '2024-10-05', '2024-10-13', '2024-10-13', 'Nơi giao hàng 05'),
	('SHD00006', 'KH000006', 'NV000006', '2024-10-06', '2024-10-15', '2024-10-15', 'Nơi giao hàng 06'),
	('SHD00007', 'KH000007', 'NV000007', '2024-10-07', '2024-10-17', '2024-10-17', 'Nơi giao hàng 07'),
	('SHD00008', 'KH000008', 'NV000008', '2024-10-08', '2024-10-19', '2024-10-19', 'Nơi giao hàng 08'),
	('SHD00009', 'KH000009', 'NV000009', '2024-10-09', '2024-10-21', '2024-10-21', 'Nơi giao hàng 09'),
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
GO

----Phạm Văn Lý:
--Thêm constraint cho email
ALTER TABLE NHACUNGCAP
	add CONSTRAINT CK_Email_N4 check(email like '[a-z]%@%');
GO
-- Insert thông tin cho bảng NHÀ CUNG CẤP
Insert into NHACUNGCAP(MACONGTY, TENCONGTY, TENGIAODICH, DIACHI, DIENTHOAI, FAX, EMAIL)
Values
	('CTY00001', N'Công ty TNHH Thương mại Toàn Cầu'    , N'Giao dịch thứ 01', N'123 Đường Nguyễn Thị M.Khai,TP.HCM', '0987654321', '+842531256', 'toancau@congty.com'),
	('CTY00002', N'Công ty cổ phần ĐT&PT Việt Nam 1'    , N'Giao dịch thứ 02', N'456 Đường Trần Hưng Đạo, TP. HN'	, '0123456789', '+842539854', 'dautu@vietnam.com'),
    ('CTY00003', N'Công ty TNHH Công nghệ mới ViệtN'    , N'Giao dịch thứ 03', N'789 Đường Lê Lợi, TP. Đà Nẵng'		, '0987654320', '+842523789', 'sangtao@viet.com'),
    ('CTY00004', N'Công ty TNHH Giải pháp Xanh Tươi'    , N'Giao dịch thứ 04', N'012 Đường Võ Thị Sáu, TP. HCM'		, '0987654322', '+842556123', 'giaiphap@xanh.com'),
    ('CTY00005', N'Công ty Cổ phần Công nghiệp Ocean'   , N'Giao dịch thứ 05', N'034 Đường Trường Chinh, TP. HÀ Nội', '0987654323', '+842567856', 'daiduong@congnghiep.com'),
    ('CTY00006', N'Công ty TNHH Năng Lượng Mặt Trời'    , N'Giao dịch thứ 06', N'056 Đường Bạch Đằng, TP. Đà Nẵng'  , '0987654324', '+842573254', 'matroi@nangluong.com'),
    ('CTY00007', N'Công ty Cổ phần Thực phẩm VHương'    , N'Giao dịch thứ 07', N'078 Đường Nguyễn Văn Cừ, TP. HCM'  , '0987654325', '+842586987', 'viethuong@thucpham.com'),
    ('CTY00008', N'Công ty TNHH Dịch vụ Thương mại 1'   , N'Giao dịch thứ 08', N'090 Đường Đinh Tiên Hoàng, TP. HN' , '0987654326', '+842598763', 'daithanh@dichvu.com'),
    ('CTY00009', N'Công ty Cổ phần Dược phẩm An Khang'  , N'Giao dịch thứ 09', N'023 Đường Lê Duẩn, TP. Đà Nẵng'    , '0987654327', '+842601357', 'ankhang@duocpham.com'),
    ('CTY00010', N'Công ty TNHH May Mặc Phú Thịnh 001'  , N'Giao dịch thứ 10', N'045 Đường Trần Quốc Toản, TP. HCM' , '0987654328', '+842612468', 'phuthinh@maymac.com'),
    ('CTY00011', N'Công ty Cổ phần Đầu tư Đất Việt 01'  , N'Giao dịch thứ 11', N'067 Đường Hồ Tùng Mậu, TP. Hà Nội' , '0987654329', '+120255512', 'datviet@dautu.com'),
    ('CTY00012', N'Công ty TNHH Công nghệ Việt Phát 1'  , N'Giao dịch thứ 12', N'089 Đường Ngô Quyền, TP. Đà Nẵng'  , '0987654301', '+442079460', 'vietphat@congnghe.com'),
    ('CTY00013', N'Công ty Cổ phần Xây dựng Hòa Bình1'  , N'Giao dịch thứ 13', N'021 Đường Nguyễn Đình Chiểu,TP.HCM', '0987654302', '+331456789', 'hoabinh@xaydung.com'),
    ('CTY00014', N'Công ty TN hữu hạn Điện Lực Á Châu'  , N'Giao dịch thứ 14', N'043 Đường Tôn Đức Thắng, TP. HN'   , '0987654303', '+493012345', 'achau@dienluc.com'),
    ('CTY00015', N'Công ty CP Xuất-nhập khẩu Minh Châu' , N'Giao dịch thứ 15', N'065 Đường Phan Đình Phùng, TP. DN' , '0987654304', '+813123456', 'minhchau@xuatnhapkhau.com'),
    ('CTY00016', N'Công ty TN hữu hạn Sản Xuất Hòa Phát', N'Giao dịch thứ 16', N'087 Đường Trường Sa, TP. HCM'	    , '0987654305', '+612987654', 'hoaphat@sanxuat.com'),
    ('CTY00017', N'Công ty TN hữu hạn Tư Vấn Việt Long' , N'Giao dịch thứ 17', N'090 Đường Hải Phòng, TP. Hà Nội'   , '0987654306', '+656123456', 'vietlong@tuvan.com'),
    ('CTY00018', N'Công ty Cổ phần Thép Miền Nam VNEMT' , N'Giao dịch thứ 18', N'012 Đường Ngọc Khánh, TP. Đà Nẵng' , '0987654307', '+649123456', 'miennam@thep.com'),
    ('CTY00019', N'Công ty TNHH Nước Giải Khát Hồng Phú', N'Giao dịch thứ 19', N'034 Đường Lê Văn Lương, TP. HCM'   , '0987654308', '+349112345', 'hongphuc@nuocgiaiKhat.com'),
    ('CTY00020', N'Công ty Cổ phần Bất Động Sản An Gia' , N'Giao dịch thứ 20', N'056 Đường Duy Tân, TP. HN'		    , '0987654309', '+390612345', 'angiabds@batdongsan.com');
GO

----Nguyễn Tuấn Anh: Insert thông tin cho bảng LOẠI HÀNG
INSERT INTO LOAIHANG ( MALOAIHANG, TENLOAIHANG)
VALUES
	('LH000001', N'Lô hàng AA'),
	('LH000002', N'Lô hàng AB'),
	('LH000003', N'Lô hàng AC'),
	('LH000004', N'Lô hàng AD'),
	('LH000005', N'Lô hàng AE'),
	('LH000006', N'Lô hàng AF'),
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
GO

----Nguyễn Tuấn Anh: Insert thông tin cho bảng MẶT HÀNG
INSERT INTO MATHANG ( MAHANG, TENHANG, CONGTY_NO, LOAIHANG_NO, SOLUONG, DONVITINH, GIAHANG)
VALUES
	('MH000001', N'Bánh mì Đồng Tiến'	  	, 'CTY00001', 'LH000001', 03, N'Gói'  , 54000   ),
	('MH000002', N'Bánh mì Đồng Thạnh'	  	, 'CTY00002', 'LH000002', 05, N'Gói'  , 90000   ),
	('MH000003', N'Sữa tươi Vinamilk'     	, 'CTY00003', 'LH000003', 04, N'Thùng', 1200000 ),
	('MH000004', N'Sữa tươi TH TrueMilk'  	, 'CTY00004', 'LH000004', 05, N'Thùng', 1500000 ),
	('MH000005', N'Sữa chua uống Vinamilk'	, 'CTY00005', 'LH000005', 03, N'Thùng', 1200000 ),
	('MH000006', N'Bánh bông lan Solite'  	, 'CTY00006', 'LH000006', 03, N'Hộp'  , 300000	),
	('MH000007', N'Bánh quy bơ Dasani'	  	, 'CTY00007', 'LH000007', 06, N'Hộp'  , 420000	),
	('MH000008', N'Bánh quy bơ LU'		  	, 'CTY00008', 'LH000008', 05, N'Hộp'  , 200000	),
	('MH000009', N'Mứt nho sấy khô'		  	, 'CTY00009', 'LH000009', 04, N'Gói'  , 200000	),
	('MH000010', N'Mứt trái cây nhiệt đới'	, 'CTY00010', 'LH000010', 03, N'Gói'  , 210000	),
	('MH000011', N'Kẹo bốn mùa'			  	, 'CTY00011', 'LH000011', 07, N'Gói'  , 140000	),
	('MH000012', N'Kẹo sữa Milkita'			, 'CTY00012', 'LH000012', 08, N'Gói'  , 240000	),
	('MH000013', N'Kẹo dừa bến Tre'			, 'CTY00013', 'LH000013', 05, N'Gói'  , 100000	),
	('MH000014', N'Kẹo nho đen Hải Trà'		, 'CTY00014', 'LH000014', 03, N'Gói'  , 45000	),
	('MH000015', N'Thạch rau câu Đồng Thạch', 'CTY00015', 'LH000015', 10, N'Gói'  , 500000  ),
	('MH000016', N'Sữa chua nếp cẩm'		, 'CTY00016', 'LH000016', 03, N'Hộp'  , 210000  ),
	('MH000017', N'Thịt ba chỉ bò đông lạnh', 'CTY00017', 'LH000017', 05, N'Gói'  , 1000000 ),
	('MH000018', N'Xúc xích Đức'			, 'CTY00018', 'LH000018', 05, N'Gói'  , 250000	),
	('MH000019', N'Cá viên chiên đông lạnh'	, 'CTY00019', 'LH000019', 06, N'Gói'  , 300000	),
	('MH000020', N'Nước ngọt Mirinda Xá Xị'	, 'CTY00020', 'LH000020', 07, N'Thùng', 840000	);
GO

----Phạm Văn Lý: Insert thông tin cho bảng CHI TIẾT ĐẶT HÀNG
Insert into CHITIETDATHANG(SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA)
Values
	('SHD00001', 'MH000001', 500000, 3, 0   ),
	('SHD00002', 'MH000002', 520000, 1, 0   ),
	('SHD00003', 'MH000003', 540000, 7, 0.4 ),
	('SHD00004', 'MH000004', 560000, 3, 0   ),
	('SHD00005', 'MH000005', 120000, 1, 0   ),
	('SHD00006', 'MH000006', 150000, 8, 0.35),
	('SHD00007', 'MH000007', 400000, 2, 0   ),
	('SHD00008', 'MH000008', 900000, 1, 0   ),
	('SHD00009', 'MH000009', 700000, 3, 0   ),
	('SHD00010', 'MH000010', 140000, 2, 0   ),
	('SHD00011', 'MH000011', 590000, 4, 0   ),
	('SHD00012', 'MH000012', 300000, 3, 0   ),
	('SHD00013', 'MH000013', 200000, 6, 0.4 ),
	('SHD00014', 'MH000014', 140000, 9, 0.45),
	('SHD00015', 'MH000015', 150000, 3, 0   ),
	('SHD00016', 'MH000016', 230000, 1, 0   ),
	('SHD00017', 'MH000017', 430000, 6, 0.2 ),
	('SHD00018', 'MH000018', 250000, 1, 0   ),
	('SHD00019', 'MH000019', 200000, 3, 0   ),
	('SHD00020', 'MH000020', 100000, 5, 0.1 );
GO
/*
SELECT * FROM KHACHHANG
SELECT * FROM NHANVIEN
SELECT * FROM DONDATHANG
SELECT * FROM NHACUNGCAP
SELECT * FROM LOAIHANG
SELECT * FROM MATHANG
SELECT * FROM CHITIETDATHANG
GO
*/
--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--TUẦN 8--
--Câu a--Câu a--Câu a--Câu a--Câu a: Phan Văn Khánh
--Thêm ngẫu nhiên vài giá trị null cho cột NGAYCHUYENHANG
UPDATE DONDATHANG
SET NGAYCHUYENHANG = NULL
WHERE SOHOADON IN('SHD00001','SHD00003','SHD00005',
				  'SHD00007','SHD00009','SHD00011');
GO
UPDATE DONDATHANG
SET NGAYGIAOHANG = NULL
WHERE SOHOADON IN('SHD00001','SHD00003','SHD00005',
				  'SHD00007','SHD00009','SHD00011');
GO
----Cập nhật lại để giá trị NGAYGIAOHANG == NGAYDATHANG để đảm bảo consraint
UPDATE DONDATHANG
SET NGAYGIAOHANG = NGAYDATHANG
WHERE NGAYCHUYENHANG IS NULL;
GO
----Cập nhật lại để giá trị NGAYCHUYENHANG == NGAYDATHANG
UPDATE DONDATHANG
SET NGAYCHUYENHANG = NGAYDATHANG
WHERE NGAYCHUYENHANG IS NULL;
GO
--Xuất kiểm tra kết quả
SELECT * FROM DONDATHANG;
GO

--Câu b--Câu b--Câu b--Câu b--Câu b: Phan Văn Khánh
----Thêm cho bảng nhà cung vài cái tên công ty VINAMILK
UPDATE NHACUNGCAP
SET TENCONGTY = N'Công ty VINAMILK'
WHERE MACONGTY IN('CTY00001','CTY00004','CTY00009','CTY00012');
GO

----Tăng số lượng hàng của những mặt hàng do công ty VINAMILK cung cấp lên gấp đôi.
UPDATE MATHANG
SET SOLUONG = SOLUONG*2
WHERE CONGTY_NO IN (
    SELECT MACONGTY
    FROM NHACUNGCAP
    WHERE TENCONGTY = N'Công ty VINAMILK');
GO
SELECT * FROM MATHANG;
GO

--Câu c--Câu c--Câu c--Câu c---Câu c: Phạm Văn Lý
--Cập Nhật Địa Chỉ NOIGIAOHANG Của Các Khách Hàng Trong Bảng DONDATHANG Là NULL
 Update DONDATHANG
 Set	NOIGIAOHANG = Null
 Where SOHOADON In('SHD00001','SHD00004', 'SHD00007', 'SHD00018') ;
 GO
--Xuất kiểm tra kết quả
--SELECT * FROM DONDATHANG;
GO
--Cập Nhật Địa Chỉ Cho Khách Hàng
Update DONDATHANG
Set NOIGIAOHANG = k.DIACHI
From DONDATHANG d, KHACHHANG k
Where k.MAKHACHHANG=d.KHACHHANG_NO
AND d.NOIGIAOHANG Is Null;
GO
--Xuất kiểm tra kết quả
--SELECT * FROM DONDATHANG;
GO

--Câu d--Câu d--Câu d--Câu d--Câu d: Nguyễn Tuấn Anh
--Sửa kiểu dữ liệu TENCONGTY
ALTER TABLE NHACUNGCAP
	ALTER COLUMN TENGIAODICH NVARCHAR(255);
GO
--Sửa lại nội dung trong bảng Nhà cung cấp
UPDATE NHACUNGCAP
SET TENGIAODICH = CASE 
    WHEN MACONGTY = 'CTY00001' THEN N'Giao dịch thứ 01'
    WHEN MACONGTY = 'CTY00002' THEN N'Giao dịch thứ 02'
    WHEN MACONGTY = 'CTY00003' THEN N'Giao dịch thứ 03'
    WHEN MACONGTY = 'CTY00004' THEN N'Giao dịch thứ 04'
    WHEN MACONGTY = 'CTY00005' THEN N'Giao dịch thứ 05'
    WHEN MACONGTY = 'CTY00006' THEN N'Giao dịch thứ 06'
    WHEN MACONGTY = 'CTY00007' THEN N'Giao dịch thứ 07'
    WHEN MACONGTY = 'CTY00008' THEN N'Giao dịch thứ 08'
    WHEN MACONGTY = 'CTY00009' THEN N'Giao dịch thứ 09'
    WHEN MACONGTY = 'CTY00010' THEN N'Giao dịch thứ 10'
    WHEN MACONGTY = 'CTY00011' THEN N'Giao dịch thứ 11'
    WHEN MACONGTY = 'CTY00012' THEN N'Giao dịch thứ 12'
    WHEN MACONGTY = 'CTY00013' THEN N'Giao dịch thứ 13'
    WHEN MACONGTY = 'CTY00014' THEN N'Giao dịch thứ 14'
    WHEN MACONGTY = 'CTY00015' THEN N'Giao dịch thứ 15'
    WHEN MACONGTY = 'CTY00016' THEN N'Giao dịch thứ 16'
    WHEN MACONGTY = 'CTY00017' THEN N'Giao dịch thứ 17'
    WHEN MACONGTY = 'CTY00018' THEN N'Giao dịch thứ 18'
    WHEN MACONGTY = 'CTY00019' THEN N'Giao dịch thứ 19'
    WHEN MACONGTY = 'CTY00020' THEN N'Giao dịch thứ 20'
END;
GO
--Thêm tên công ty cho bảng KHACHHANG
UPDATE KHACHHANG
SET TENCONGTY = N'Công ty VINAMILK'
WHERE MAKHACHHANG IN('KH000004');
GO
--Thêm tên giao dịch cho bảng KHACHHANG
UPDATE KHACHHANG
SET TENGIAODICH = N'Giao dịch thứ 04'
WHERE MAKHACHHANG IN('KH000004');
GO

--Thêm tên công ty cho bảng NHACUNGCAP
UPDATE NHACUNGCAP
SET TENCONGTY = N'Công ty E'
WHERE MACONGTY IN('CTY00012');
GO
--Thêm tên giao dịch cho bảng NHACUNGCAP
UPDATE NHACUNGCAP
SET TENGIAODICH = N'Giao dịch E'
WHERE MACONGTY IN('CTY00012');
GO
--Cập nhật địa chỉ
UPDATE KHACHHANG
SET KHACHHANG.DIACHI =  N.DIACHI
FROM NHACUNGCAP N, KHACHHANG K
WHERE (K.TENCONGTY = N.TENCONGTY AND  K.TENGIAODICH = N.TENGIAODICH);
GO
--Cập nhật điện thoại
UPDATE KHACHHANG
SET KHACHHANG.DIENTHOAI = N.DIENTHOAI
FROM NHACUNGCAP N, KHACHHANG K
WHERE ( K.TENCONGTY = N.TENCONGTY AND K.TENGIAODICH = N.TENGIAODICH);
GO
--Cập nhật fax
UPDATE KHACHHANG
SET KHACHHANG.FAX = N.FAX
FROM NHACUNGCAP N, KHACHHANG K
WHERE ( K.TENCONGTY = N.TENCONGTY AND K.TENGIAODICH = N.TENGIAODICH);
GO
--Cập nhật email
UPDATE KHACHHANG
SET KHACHHANG.EMAIL = N.EMAIL
FROM NHACUNGCAP N, KHACHHANG K
WHERE ( K.TENCONGTY = N.TENCONGTY AND K.TENGIAODICH = N.TENGIAODICH);
GO
-- Xuất kết quả kiểm tra
--SELECT * FROM KHACHHANG
--SELECT * FROM NHACUNGCAP
--GO

--Câu e--Câu e--Câu e--Câu e--Câu e: Phạm Văn Lý
--Cập Nhật Lại Thời Gian Cho Đơn Hàng
Update DONDATHANG
Set	NGAYGIAOHANG = '2022-05-08',
	NGAYCHUYENHANG='2022-05-02',
	NGAYDATHANG='2022-05-01'
Where SOHOADON IN ('SHD00003', 'SHD00014');
GO
--Cập Nhật Số Lượng Bán Hàng Cho Nhân Viên
Update CHITIETDATHANG
Set SOLUONG = 120
Where SOHOADON In('SHD00003', 'SHD00014');
GO
--SELECT * FROM NHANVIEN;
--GO
--Tăng Lương Gấp Rưỡi Cho Nhân Viên Có Số Lượng Bán Hàng > 100 Trong Năm 2022
Update NHANVIEN
Set LUONGCOBAN=LUONGCOBAN*1.5
Where  MANHANVIEN IN(
	Select MANHANVIEN
	From NHANVIEN n, DONDATHANG d, CHITIETDATHANG c
	where d.NHANVIEN_NO=n.MANHANVIEN
	AND c.SOHOADON=d.SOHOADON
	AND year(d.NGAYGIAOHANG) = 2022
	Group By MANHANVIEN
	Having sum(c.soluong)>100
);
GO
--SELECT * FROM NHANVIEN;
--GO
--câu f--câu f--câu f--câu f--câu f: Huỳnh Minh Dũng
-- Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất.
UPDATE NHANVIEN
SET PHUCAP = LUONGCOBAN * 0.5
WHERE MANHANVIEN IN (
	Select MANHANVIEN
	From NHANVIEN n, DONDATHANG d, CHITIETDATHANG c
	where d.NHANVIEN_NO = n.MANHANVIEN
	AND c.SOHOADON = d.SOHOADON
    GROUP BY MANHANVIEN
	HAVING SUM(c.SOLUONG) = (
            SELECT MAX(tongHang)
            FROM (
                SELECT SUM(c2.SOLUONG) AS tongHang
                FROM NHANVIEN n2, DONDATHANG d2, CHITIETDATHANG c2  
				WHERE d2.NHANVIEN_NO = n2.MANHANVIEN
                AND c2.SOHOADON = d2.SOHOADON
                GROUP BY n2.MANHANVIEN
            ) AS aka
        )
);
GO
--SELECT * FROM DONDATHANG
--SELECT * FROM CHITIETDATHANG
--SELECT * FROM NHANVIEN
--GO
--câu g--câu g--câu g--câu g--câu g: Huỳnh Minh Dũng
SELECT * FROM NHANVIEN;
UPDATE DONDATHANG
SET NGAYDATHANG = CASE SOHOADON
    WHEN 'SHD00015' THEN '2023-01-10'
    WHEN 'SHD00016' THEN '2023-02-10'
    WHEN 'SHD00017' THEN '2023-03-10'
    WHEN 'SHD00018' THEN '2023-04-10'
    WHEN 'SHD00019' THEN '2023-05-10'
    WHEN 'SHD00020' THEN '2023-06-10'
END,
	NGAYGIAOHANG = CASE SOHOADON
    	WHEN 'SHD00015' THEN '2023-01-15'  
    	WHEN 'SHD00016' THEN '2023-02-15'
    	WHEN 'SHD00017' THEN '2023-03-15'
    	WHEN 'SHD00018' THEN '2023-04-15'
    	WHEN 'SHD00019' THEN '2023-05-15'
    	WHEN 'SHD00020' THEN '2023-06-15'
END,
	NGAYCHUYENHANG = CASE SOHOADON
    	WHEN 'SHD00015' THEN '2023-01-14'
    	WHEN 'SHD00016' THEN '2023-02-14'
    	WHEN 'SHD00017' THEN '2023-03-14'  
    	WHEN 'SHD00018' THEN '2023-04-14'
    	WHEN 'SHD00019' THEN '2023-05-14'
    	WHEN 'SHD00020' THEN '2023-06-14'
END
WHERE SOHOADON IN ('SHD00015', 'SHD00016', 'SHD00017', 
				   'SHD00018', 'SHD00019', 'SHD00020');
GO
-- Giảm 25% lương của những nhân viên trong năm 2023 không lập được bất kỳ đơn đặt hàng nào.
UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 0.75
WHERE MANHANVIEN NOT IN (
	Select MANHANVIEN
	From NHANVIEN n, DONDATHANG d, CHITIETDATHANG c
	where d.NHANVIEN_NO=n.MANHANVIEN
	AND c.SOHOADON=d.SOHOADON
	AND year(d.NGAYDATHANG) = 2023
	group by MANHANVIEN
);
GO
--SELECT * FROM NHANVIEN;
--GO
--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--Tuần 10--

--câu 1 họ tên, địa chỉ, và năm bắt đầu làm việc của các nhân viên trong công ty
SELECT HO + ' ' + TEN AS HO_TEN, DIACHI, YEAR(NGAYLAMVIEC) AS NAM_BAT_DAU_LAM_VIEC
FROM NHANVIEN;

--câu 2 cho biết công ty Việt Tiến đã cung cấp những mặt hàng nào
INSERT INTO NHACUNGCAP (MACONGTY, TENCONGTY, TENGIAODICH, DIACHI, DIENTHOAI, FAX, EMAIL)
VALUES 
	('CTY00021', N'Công ty TNHH Việt Tiến', N'Giao dịch Việt Tiến', N'123 Đường Lê Lợi, TP.HCM', '0987654310', NULL, 'viettien@congty.com');
GO
INSERT INTO LOAIHANG (MALOAIHANG, TENLOAIHANG)
VALUES 
	('LH000021', N'Lô hàng AT'),
	('LH000022', N'Lô hàng AU'),
	('LH000023', N'Lô hàng AV');
GO
INSERT INTO MATHANG (MAHANG, TENHANG, CONGTY_NO, LOAIHANG_NO, SOLUONG, DONVITINH, GIAHANG)
VALUES
	('MH000021', N'Áo sơ mi Việt Tiến', 'CTY00021', 'LH000021', 100, N'Chiếc', 250000),
	('MH000022', N'Quần tây Việt Tiến', 'CTY00021', 'LH000022', 50, N'Chiếc', 300000),
	('MH000023', N'Váy đầm Việt Tiến', 'CTY00021', 'LH000023', 75, N'Chiếc', 350000);
GO

SELECT N.TENCONGTY, M.MAHANG ,M.TENHANG 
FROM MATHANG M
JOIN NHACUNGCAP N ON M.CONGTY_NO = N.MACONGTY
WHERE N.TENCONGTY = N'Công ty TNHH Việt Tiến';
GO

--Câu 3
-- Cho biết những khách hàng là đối tác cung cấp hàng của công ty (cùng tên giao dịch)
SELECT K.MAKHACHHANG, K.TENCONGTY
FROM KHACHHANG K, NHACUNGCAP N
WHERE K.TENGIAODICH = N.TENGIAODICH;

-----------Phạm Văn Lý---------------
--4. Những nhân viên nào của công ty chưa từng lập bất kỳ một hóa đơn đặt hàng nào?

--Xóa đi 3 nhân viên đã lập đơn hàng
Delete From DONDATHANG
Where NHANVIEN_NO in ('NV000001', 'NV000002', 'NV000005');
go

Select MANHANVIEN,Ho, Ten
From NHANVIEN
Where MANHANVIEN not in(
	Select nhanvien_no
	from DONDATHANG
);
go

--5. Mỗi nhân viên của công ty đã lập bao nhiêu đơn đặt hàng (nếu nhân viên chưa hề lập một hóa đơn nào thì cho kết quả là 0)
--Xóa đi 3 nhân viên đã lập đơn hàng
Delete From DONDATHANG
Where NHANVIEN_NO in ('NV000017', 'NV000018', 'NV000019');
go

Select n.Manhanvien, n.ho, n.ten, count(c.sohoadon) as soLuong
From NHANVIEN n
Full Join DONDATHANG d
	on n.MANHANVIEN = d.NHANVIEN_NO
Full Join  CHITIETDATHANG c
	on c.SOHOADON = d.SOHOADON
group by n.Manhanvien, n.ho, n.ten;
go

/*
Câu 6: Cho biết tổng số tiền hàng mà cửa hàng thu được trong mỗi tháng
của năm 2022(Thời gian được tính theo ngày đặt hàng)
*/
UPDATE MATHANG
SET SOLUONG = CASE 
    WHEN MAHANG = 'MH000001' THEN 100
    WHEN MAHANG = 'MH000002' THEN 099
    WHEN MAHANG = 'MH000003' THEN 150
    WHEN MAHANG = 'MH000004' THEN 100
    WHEN MAHANG = 'MH000005' THEN 160
    WHEN MAHANG = 'MH000006' THEN 100
    WHEN MAHANG = 'MH000007' THEN 100
    WHEN MAHANG = 'MH000008' THEN 170
    WHEN MAHANG = 'MH000009' THEN 100
    WHEN MAHANG = 'MH000010' THEN 100
    WHEN MAHANG = 'MH000011' THEN 188
    WHEN MAHANG = 'MH000012' THEN 100
    WHEN MAHANG = 'MH000013' THEN 100
    WHEN MAHANG = 'MH000014' THEN 100
    WHEN MAHANG = 'MH000015' THEN 100
    WHEN MAHANG = 'MH000016' THEN 177
    WHEN MAHANG = 'MH000017' THEN 100
    WHEN MAHANG = 'MH000018' THEN 100
    WHEN MAHANG = 'MH000019' THEN 100
    WHEN MAHANG = 'MH000020' THEN 166
END;
GO
UPDATE MATHANG
SET GIAHANG = CASE 
    WHEN MAHANG = 'MH000001' THEN 100000
    WHEN MAHANG = 'MH000002' THEN 099450
    WHEN MAHANG = 'MH000003' THEN 150120
    WHEN MAHANG = 'MH000004' THEN 100320
    WHEN MAHANG = 'MH000005' THEN 160100
    WHEN MAHANG = 'MH000006' THEN 100100
    WHEN MAHANG = 'MH000007' THEN 100120
    WHEN MAHANG = 'MH000008' THEN 170120
    WHEN MAHANG = 'MH000009' THEN 100132
    WHEN MAHANG = 'MH000010' THEN 100456
    WHEN MAHANG = 'MH000011' THEN 188123
    WHEN MAHANG = 'MH000012' THEN 100466
    WHEN MAHANG = 'MH000013' THEN 100132
    WHEN MAHANG = 'MH000014' THEN 020000
    WHEN MAHANG = 'MH000015' THEN 100789
    WHEN MAHANG = 'MH000016' THEN 177466
    WHEN MAHANG = 'MH000017' THEN 100741
    WHEN MAHANG = 'MH000018' THEN 100852
    WHEN MAHANG = 'MH000019' THEN 100369
    WHEN MAHANG = 'MH000020' THEN 166357
END;


SELECT * FROM MATHANG
SELECT * FROM CHITIETDATHANG

SELECT NC.TENCONGTY as 'Tên công ty', MH.MAHANG,MONTH(DH.NGAYDATHANG) as 'Tháng', 
       YEAR(DH.NGAYDATHANG) as 'Năm',
       SUM(CT.SOLUONG * (CT.GIABAN * (1 - CT.MUCGIAMGIA))) as 'Tổng tiền hàng thu được',
	   SUM(CT.SOLUONG * (CT.GIABAN * (1 - CT.MUCGIAMGIA)) - (CT.SOLUONG * MH.GIAHANG)) as 'Tổng tiền lời'
FROM CHITIETDATHANG CT, MATHANG MH, NHACUNGCAP NC, DONDATHANG DH
WHERE MH.MAHANG = CT.MAHANG
AND MH.CONGTY_NO = NC.MACONGTY
AND CT.SOHOADON = DH.SOHOADON
AND YEAR(DH.NGAYDATHANG) = 2022
GROUP BY NC.TENCONGTY, MH.MAHANG,MONTH(DH.NGAYDATHANG), YEAR(DH.NGAYDATHANG)