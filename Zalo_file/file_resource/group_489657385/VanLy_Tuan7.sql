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
---(4)Phần của Phạm Văn Lý: Bổ sung ràng buộc bảng NHANVIEN
ALTER TABLE NHANVIEN
	ADD CONSTRAINT CK_Tuoi_2 CHECK (YEAR(GETDATE()) - YEAR(NGAYSINH) >= 18 
								AND YEAR(GETDATE()) - YEAR(NGAYSINH) < 60);

--Insert bảng Chi Tiết Đặt Hàng của Phạm Văn Lý
Insert into [dbo].[CHITIETDATHANG]([SOHOADON], [MAHANG], [GIABAN], [SOLUONG], [MUCGIAMGIA])
Values
	('SHD00001', 'MH000001', 50000, 3, 0),
	('SHD00002', 'MH000002', 52000, 1, 0),
	('SHD00003', 'MH000003', 54000, 7, 0.4),
	('SHD00004', 'MH000004', 56000, 3, 0),
	('SHD00005', 'MH000005', 12000, 1, 0),
	('SHD00006', 'MH000006', 150000, 8, 0.35),
	('SHD00007', 'MH000007', 40000, 2, 0),
	('SHD00008', 'MH000008', 90000, 1, 0),
	('SHD00009', 'MH000009', 70000, 3, 0),
	('SHD00010', 'MH000010', 140000, 2, 0),
	('SHD00011', 'MH000011', 59000, 4, 0),
	('SHD00012', 'MH000012', 30000, 3, 0),
	('SHD00013', 'MH000013', 20000, 6, 0.4),
	('SHD00014', 'MH000014', 140000, 9, 0.45),
	('SHD00015', 'MH000015', 150000, 3, 0),
	('SHD00016', 'MH000016', 230000, 1, 0),
	('SHD00017', 'MH000017', 43000, 6, 0.2),
	('SHD00018', 'MH000018', 25000, 1, 0),
	('SHD00019', 'MH000019', 20000, 3, 0),
	('SHD00020', 'MH000020', 10000, 5, 0.1),
	('SHD00021', 'MH000021', 50000, 1, 0);

--Insert bảng Nhà Cung Cấp của Phạm Văn Lý
Insert into [dbo].[NHACUNGCAP]([MACONGTY], [TENCONGTY], [TENGIAODICH], [DIACHI], [DIENTHOAI], [FAX], [EMAIL])
Values
	('CTY00001', N'Công ty TNHH Thương mại Toàn Cầu', N'Giao dịch thứ 1', N'123 Đường Nguyễn Thị Minh Khai, TP. HCM', '0987654321', '+842531256', 'toancau@congty.com'),
	('CTY00002', N'Công ty Cổ phần Đầu tư Phát triển Việt Nam', N'Giao dịch thứ 2', N'456 Đường Trần Hưng Đạo, TP. HN', '0123456789', '+842539854', 'dautu@vietnam.com'),
    ('CTY00003', N'Công ty TNHH Công nghệ Sáng Tạo Việt', N'Giao dịch thứ 3', N'789 Đường Lê Lợi, TP. Đà Nẵng', '0987654320', '+842523789', 'sangtao@viet.com'),
    ('CTY00004', N'Công ty TNHH Giải pháp Xanh', N'Giao dịch thứ 4', N'12 Đường Võ Thị Sáu, TP. HCM', '0987654322', '+842556123', 'giaiphap@xanh.com'),
    ('CTY00005', N'Công ty Cổ phần Công nghiệp Đại Dương', N'Giao dịch thứ 5', N'34 Đường Trường Chinh, TP. HN', '0987654323', '+842567856', 'daiduong@congnghiep.com'),
    ('CTY00006', N'Công ty TNHH Năng Lượng Mặt Trời', N'Giao dịch thứ 6', N'56 Đường Bạch Đằng, TP. Đà Nẵng', '0987654324', '+842573254', 'matroi@nangluong.com'),
    ('CTY00007', N'Công ty Cổ phần Thực phẩm Việt Hương', N'Giao dịch thứ 7', N'78 Đường Nguyễn Văn Cừ, TP. HCM', '0987654325', '+842586987', 'viethuong@thucpham.com'),
    ('CTY00008', N'Công ty TNHH Dịch vụ Thương mại Đại Thành', N'Giao dịch thứ 8', N'90 Đường Đinh Tiên Hoàng, TP. HN', '0987654326', '+842598763', 'daithanh@dichvu.com'),
    ('CTY00009', N'Công ty Cổ phần Dược phẩm An Khang', N'Giao dịch thứ 9', N'23 Đường Lê Duẩn, TP. Đà Nẵng', '0987654327', '+842601357', 'ankhang@duocpham.com'),
    ('CTY00010', N'Công ty TNHH May Mặc Phú Thịnh', N'Giao dịch thứ 10', N'45 Đường Trần Quốc Toản, TP. HCM', '0987654328', '+842612468', 'phuthinh@maymac.com'),
    ('CTY00011', N'Công ty Cổ phần Đầu tư Đất Việt', N'Giao dịch thứ 11', N'67 Đường Hồ Tùng Mậu, TP. HN', '0987654329', '+120255512 ', 'datviet@dautu.com'),
    ('CTY00012', N'Công ty TNHH Công nghệ Việt Phát', N'Giao dịch thứ 12', N'89 Đường Ngô Quyền, TP. Đà Nẵng', '0987654301', '+442079460', 'vietphat@congnghe.com'),
    ('CTY00013', N'Công ty Cổ phần Xây dựng Hòa Bình', N'Giao dịch thứ 13', N'21 Đường Nguyễn Đình Chiểu, TP. HCM', '0987654302', '+331456789', 'hoabinh@xaydung.com'),
    ('CTY00014', N'Công ty TNHH Điện Lực Á Châu', N'Giao dịch thứ 14', N'43 Đường Tôn Đức Thắng, TP. HN', '0987654303', '+493012345', 'achau@dienluc.com'),
    ('CTY00015', N'Công ty Cổ phần Xuất nhập khẩu Minh Châu', N'Giao dịch thứ 15', N'65 Đường Phan Đình Phùng, TP. Đà Nẵng', '0987654304', '+813123456 ', 'minhchau@xuatnhapkhau.com'),
    ('CTY00016', N'Công ty TNHH Sản Xuất Hòa Phát', N'Giao dịch thứ 16', N'87 Đường Trường Sa, TP. HCM', '0987654305', '+612987654', 'hoaphat@sanxuat.com'),
    ('CTY00017', N'Công ty TNHH Tư Vấn Việt Long', N'Giao dịch thứ 17', N'90 Đường Hải Phòng, TP. HN', '0987654306', '+656123456', 'vietlong@tuvan.com'),
    ('CTY00018', N'Công ty Cổ phần Thép Miền Nam', N'Giao dịch thứ 18', N'12 Đường Ngọc Khánh, TP. Đà Nẵng', '0987654307', '+649123456', 'miennam@thep.com'),
    ('CTY00019', N'Công ty TNHH Nước Giải Khát Hồng Phúc', N'Giao dịch thứ 19', N'34 Đường Lê Văn Lương, TP. HCM', '0987654308', '+349112345', 'hongphuc@nuocgiaiKhat.com'),
    ('CTY00020', N'Công ty Cổ phần Bất Động Sản An Gia', N'Giao dịch thứ 20', N'56 Đường Duy Tân, TP. HN', '0987654309', '+390612345', 'angiabds@batdongsan.com');