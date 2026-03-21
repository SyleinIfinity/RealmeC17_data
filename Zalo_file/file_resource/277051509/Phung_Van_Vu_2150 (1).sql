-- Tạo điều kiện kiểm tra xem có database hay chưa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'QLBH_2150')
	BEGIN
		USE master
		ALTER database QLBH_2150 set single_user with rollback immediate
		DROP DATABASE QLBH_2150;
	END

-- tạo database QLDB_2150
create database QLBH_2150
go
-- sử dụng database QLBH_2150
use QLBH_2150
go

-- Tạo bảng: Khách Hàng
CREATE TABLE KhachHang
(
    maKH CHAR(10) NOT NULL PRIMARY KEY,
    tenKH NVARCHAR(50) NOT NULL,
    diaChiKH NVARCHAR(100) NOT NULL,
    SDT VARCHAR(11),
    Email VARCHAR(50) NULL,
    soDuTK MONEY,
    UNIQUE (SDT, Email)
)

-- Tạo bảng: Nhân Viên
CREATE TABLE NhanVien
(
    maNV CHAR(10) NOT NULL PRIMARY KEY,
    tenNV NVARCHAR(50) NOT NULL,
    SDT VARCHAR(11),
    Email VARCHAR(50) NULL,
    gioiTinh nvarchar(10),
    DoB DATE, -- Date of Birthday
    Salary MONEY,
    UNIQUE (SDT, Email)
)

-- Tạo bảng: Đơn Đặt Hàng - Hoá Đơn
CREATE TABLE DonDatHang_HoaDon
(
    maDH CHAR(10) NOT NULL PRIMARY KEY,
	KHNo CHAR(10) NOT NULL FOREIGN KEY (KHNo) REFERENCES KhachHang(maKH)
		ON UPDATE 
			CASCADE
		ON DELETE 
			CASCADE,
	NVNo CHAR(10) NOT NULL FOREIGN KEY (NVNo) REFERENCES NhanVien(maNV)
		ON UPDATE 
			CASCADE
		ON DELETE 
			CASCADE,
    ngayTaoDH DATE,
    diaChiGiaoHang NVARCHAR(100),
    SDTGiaoHang VARCHAR(11) UNIQUE,
    maHoaDonDienTu CHAR(10),
    ngayThanhToan DATE,
    ngayGiaoHang DATE,
    trangThaiDonHang NVARCHAR(100),
)

-- Tạo bảng: Nhà Cung cấp
CREATE TABLE NhaCungCap
(
    maNCC CHAR(10) NOT NULL PRIMARY KEY,
    tenNCC NVARCHAR(50) NOT NULL,
    diaChiNCC NVARCHAR(100),
    SDT VARCHAR(11) NULL UNIQUE,
    nhanVienLienHe NVARCHAR(50) NULL,
)

-- Tạo bảng: Phiếu Nhập
CREATE TABLE PhieuNhap
(
    maPN CHAR(7) NOT NULL PRIMARY KEY,
	NCCNo CHAR(10) NOT NULL,
    ngayNhapHang DATE,
	Foreign key (NCCNo) references NhaCungCap(maNCC)
)

-- Tạo bảng: Sản Phẩm
CREATE TABLE SanPham
(
    maSP CHAR(7) NOT NULL PRIMARY KEY,
    tenSP NVARCHAR(50),
    donGiaBan MONEY check (donGiaBan > 0),
    soLuongHienCon BIGINT,
    soLuongCanDuoi SMALLINT,
)

-- Tạo bảng: Chi Tiết Phiếu Nhập
CREATE TABLE ChiTietPhieuNhap
(
    PNNo CHAR(7),
    SPNo CHAR(7),
    soLuongNhap INT,
    giaNhap MONEY NOT NULL check (giaNhap>0),
    PRIMARY KEY (PNNo, SPNo),
    FOREIGN KEY (PNNo) REFERENCES PhieuNhap(maPN),
    FOREIGN KEY (SPNo) REFERENCES SanPham(maSP)
)

-- Tạo bảng: Chi Tiết Đơn Hàng
CREATE TABLE ChiTietDonHang
(
    DHNo CHAR(10) NOT NULL,
    SPNo CHAR(7) NOT NULL,
    soLuongDat INT,
    donGia MONEY,
    PRIMARY KEY (DHNo, SPNo),
    FOREIGN KEY (DHNo) REFERENCES DonDatHang_HoaDon(maDH)
		ON UPDATE
			NO ACTION
		ON DELETE 
			NO ACTION,
    FOREIGN KEY (SPNo) REFERENCES SanPham(maSP)
		ON UPDATE 
			NO ACTION
		ON DELETE 
			NO ACTION,
)

----------------- Tuần 8: Thay đổi cấu trúc bảng ALTER ----------------------------
-- Tạo bảng: Quốc Gia 
create table  QuocGia
(
	maQG char(10) primary key,
	tenQG nvarchar(100),
)
-- Tạo bảng: Tỉnh Thành Phố
Create table TinhTP
(
	maTP char (10 ) primary key,
	tenTP nvarchar(100) ,
	QGNo char(10),
	constraint FK_TinhTP_QuocGia foreign key (QGNo) references QuocGia(maQG)
		ON UPDATE 
			CASCADE
		ON DELETE 
			CASCADE
)
-- Tạo bảng: Quận, Huyện 
Create table QuanHuyen
(
	maQH char(10) primary keY,
	tenQH nvarchar (100) ,
	TPNo char (10),
	constraint FK_QuanHuyen_TinhTP foreign key (TPNo) references TinhTP(maTP)
		ON UPDATE 
			CASCADE
		ON DELETE 
			CASCADE,
)
-- Tạo bảng: Phường, Xã
Create table PhuongXa
(
	maPX char(10) primary key, 
	tenPX nvarchar (100),
	QHNo char(10),
	constraint FK_PhuongXa_QuanHuyen foreign key (QHNo) references QuanHuyen(maQH)
		ON UPDATE 
			CASCADE
		ON DELETE 
			CASCADE,
)
/*
	Đối với Table Đơn Đặt Hàng - Hóa Đơn
	- Thêm ràng buộc ngày tạo đơn là ngày hiện tại thực tế.
	- Thêm ràng buộc ngày thanh toán phải lớn hơn hoặc bằng ngày tạo đơn.
	- Thêm ràng buộc ngày giao hàng phải lớn hơn hoặc bằng ngày thanh toán.
	- Thêm ràng buộc trạng thái đơn hàng nhận các giá trị sau: "Chờ xác nhận , Đang giao, Đã giao thành công, Đã hủy, Giao không thành công" 
	  trong đó mặc định "Chờ xác nhận".
*/
Alter TABLE DonDatHang_HoaDon
	add constraint DF_DonDatHang_HoaDon_ngayTaoDH default getdate() for ngayTaoDH,
		constraint CK_DonDatHang_HoaDon_ngayThanhToan check (ngayThanhToan >= ngayTaoDH),
		constraint CK_DonDatHang_HoaDon_ngayGiaoHang check (ngayGiaoHang >= ngayThanhToan),
		constraint CK_DonDatHang_HoaDon_trangThaiDonHang check (trangThaiDonHang in (N'Chờ xác nhận', N'Đang giao', N'Đã giao thành công', N'Đã hủy', N'Giao hàng không thành công')),
		constraint DF_DonDatHang_HoaDon_trangThaiDH default N'Chờ xác nhận' for trangThaiDonHang

-- Đối với Table Đơn Đặt Hàng - Hóa Đơn
-- Xóa column diaChiGiaoHang
Alter table DonDatHang_HoaDon 
	Drop column diaChiGiaoHang

-- Bổ sung 2 column DonDatHang_HoaDon_PhuongXa
-- Thêm cột idPX và soNhaTenDuong_DH vào bảng DonDatHang_HoaDon
Alter table DonDatHang_HoaDon
	add idPX char(10),
		soNhaTenDuong_DH nvarchar(100)
-- Thiết lập khóa ngoại cho idPX
Alter table DonDatHang_HoaDon
	add constraint FK_DonDatHang_HoaDon_PhuongXa foreign key (idPX) references PhuongXa(maPX)

-- Đối với Table Khách Hàng
-- Xóa column diaChiKH
Alter table KhachHang
	Drop column diaChiKH

-- Bổ sung 2 column KhachHang
-- Thêm cột PXNo và soNhaTenDuong_KH vào bảng KhachHanng
Alter table KhachHang
	add PXNo char(10),
		soNhaTenDuong_KH nvarchar(100)

-- Thiết lập khóa ngoại cho PXNo
Alter table KhachHang
	add constraint FK_KhachHang_PhuongXa foreign key (PXNo) references PhuongXa(maPX)
		ON UPDATE 
				NO ACTION
			ON DELETE 
				NO ACTION;

-- Đối với Table NhaCungCap
-- Xóa column diaChiNCC
Alter table NhaCungCap
	Drop column diaChiNCC;

-- Bổ sung 2 column NhaCungCap
-- Thêm cột maPX_NCC và soNhaTenDuong_NCC vào bảng NhaCungCap
Alter table NhaCungCap
	add maPX_NCC char(10),
		soNhaTenDuong_NCC nvarchar(100);

-- Thiết lập khóa ngoại cho maPX_NCC
Alter table NhaCungCap
	add constraint FK_NhaCungCap_PhuongXa foreign key (maPX_NCC) references PhuongXa(maPX)
			ON UPDATE 
				CASCADE
			ON DELETE 
				CASCADE;
/*
	Đối với Table Khách Hàng
	- Thêm ràng buộc cho cloumn SDT chỉ gồm toàn chữ số, 10 hoặc 11 số.
	- Thêm ràng buộc cho cloumn Email có kí tự @ và bắt đầu bằng chữu cái.
*/
Alter TABLE KhachHang
	add constraint CK_KhachHang_SDT check (SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
				OR SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint CK_KhachHang_Email check (Email LIKE '[a-zA-Z]%@%');
/*
	Đối với Table Nhân Viên
	- Thêm ràng buộc cho cloumn SDT chỉ gồm toàn chữ số, 10 hoặc 11 số.
	- Thêm ràng buộc cho cloumn Email có kí tự @ và bắt đầu bằng chữu cái.
	- Thêm ràng buộc cho cloumn gioiTinh là 'Nam', 'Nữ' trong đó mặc định là 'Nam'.  
	- Thêm ràng buộc cho cloumn DoB biết nhân viên phải đủ và trên 18 tuổi mới được nhận.
	- Thêm ràng buộc cho cloumn Salary mặc định là 5 triệu và không âm.
*/
Alter TABLE NhanVien
	add constraint CK_NhanVien_SDT check (SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
				OR SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint CK_NhanVien_Email check (Email LIKE '[a-zA-Z]%@%'),
		constraint CK_NhanVien_gioiTinh check (gioiTinh IN('Nam',N'Nữ')),
		constraint DF_NhanVien_gioiTinh default N'Nam' for gioiTinh,
		constraint CK_Age_NhanVien check (DoB<=DATEADD(YEAR, -18, GETDATE())),
		constraint DF_NhanVien_Luong default 5000000 for Salary,
		constraint CK_NhanVien_Luong check (Salary>=0);

/*
	Đối với Table Đơn Đặt Hàng - Hóa Đơn
	- Thêm ràng buộc cho cloumn SDTGiaoHang chỉ gồm toàn chữ số, 10 hoặc 11 số.
*/
Alter TABLE DonDatHang_HoaDon
		add constraint CK_DonDatHang_HoaDon_SDTGiaoHang check (SDTGiaoHang like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
				OR SDTGiaoHang like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
/*
	Đối với Table Nhà Cung cấp
	- Thêm ràng buộc cho cloumn SDT chỉ gồm toàn chữ số, 10 hoặc 11 số.
*/
Alter TABLE NhaCungCap
	add constraint CK_NhaCungCap_SDT check (SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
				OR SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

/*
	Đối với Table SanPham
	- Thêm ràng buộc cho cloumn soLuongHienCon phải lớn hơn hoặc bằng 0.
	- Thêm ràng buộc cho cloumn soLuongCanDoi phải nhỏ hơn hoặc bằng 5 và mặc định là 5.
*/
Alter TABLE SanPham
	add constraint CK_SanPham_soLuongHienCon check (soLuongHienCon >= 0),
		constraint CK_SanPham_soLuongCanDuoi check (soLuongCanDuoi <= 5),
		constraint DF_SanPham_soLuongCanDuoi default 5 for soLuongCanDuoi

---------------Tuần 9 - Nhập liệu cho tất cả các bảng dữ liệu-----------------
-- Đặt định dạng ngày tháng
SET DATEFORMAT dmy;

-- Thêm dữ liệu vào bảng QuocGia
INSERT INTO QuocGia
VALUES
	('QG01', N'Việt Nam'),
	('QG02', N'Trung Quốc'),
	('QG03', N'Mỹ'),
	('QG04', N'Nhật Bản'),
	('QG05', N'Hàn Quốc'),
	('QG06', N'Thái Lan'),
	('QG07', N'CamPuChia'),
	('QG08', N'Lào'),
	('QG09', N'Ấn Độ'),
	('QG10', N'Đức');

-- Thêm dữ liệu vào bảng TinhTP
INSERT INTO TinhTP(maTP, tenTP, QGNo)
VALUES
	('TP01', N'Hà Nội', 'QG01'),
	('TP02', N'TP.HCM', 'QG01'),
	('TP03', N'Đà Nẵng', 'QG01'), 
	('TP04', N'Hải Phòng', 'QG01'), 
	('TP05', N'Tokyo', 'QG04'),
	('TP06', N'Seoul', 'QG05'),
	('TP07', N'Nha Trang', 'QG01'),
	('TP08', N'Trùng Khánh', 'QG02'),
	('TP09', N'Bắc Kinh', 'QG02'),
	('TP10', N'Osaka', 'QG04');

-- Thêm dữ liệu vào bảng QuanHuyen
INSERT INTO QuanHuyen (maQH, tenQH, TPNo)
VALUES
	('QH001', N'Quận Cẩm Lệ', 'TP03'), 
	('QH002', N'Quận Hải Châu', 'TP03'), 
	('QH003', N'Quận Phú Nhuận', 'TP02'), 
	('QH004', N'Quận Tân Bình', 'TP02'), 
	('QH005', N'Quận Hoàn Kiếm', 'TP01'),  
	('QH006', N'Quận Đống Đa', 'TP01'), 
	('QH007', N'Quận Đồ Sơn', 'TP04'), 
	('QH008', N'Minato-ku', 'TP05'), 
	('QH009', N'Huyện An Lão', 'TP04'),
	('QH010', N'Dongdaemun-gu', 'TP06');

-- Thêm dữ liệu vào bảng PhuongXa
INSERT INTO PhuongXa (maPX, tenPX, QHNo)
VALUES
	('PX001', N'Phường Hòa Thọ Tây', 'QH001'),
	('PX002', N'Phường Hòa Thọ Đông', 'QH001'), 
	('PX003', N'Phường Hòa Thuận Tây', 'QH002'), 
	('PX004', N'Phường Thanh Bình', 'QH002'), 
	('PX005', N'Xã An Thọ', 'QH009'),  
	('PX006', N'Phường Tràng Tiền', 'QH005'),
	('PX007', N'Phường Tây Nhất', 'QH003'), 
	('PX008', N'Phường Văn Chương', 'QH006'),
	('PX009', N'Phường Chương Dương', 'QH005'),
	('PX010', N'Phường 8', 'QH004'),
	('PX011', N'Phường Vạn Hương', 'QH007');

-- Thêm dữ liệu vào bảng KhachHang
INSERT INTO KhachHang (maKH, tenKH, SDT, Email, soDuTK, PXNo, soNhaTenDuong_KH)
VALUES
('KH001', N'Nguyễn Văn A',  '0123456789', 'A@gmail.com', 1000000, 'PX002',N'12 Nguyễn Nhàn'     ), 
('KH002', N'Trần Thị B'  ,  '0123456780', 'B@gmail.com', 2000000, 'PX002',N'30 Trần Ngoc Sương' ),
('KH003', N'Phạm Văn C'  ,  '0123456781', 'C@gmail.com', 3000000, 'PX004',N'50 Cao Thắng'       ), 
('KH004', N'Lê Thị D'    ,  '0123456782', 'D@gmail.com', 4000000, 'PX003',N'222 D.2 Tháng 9'    ),
('KH005', N'Nguyễn Văn E',  '0123456783', 'E@gmail.com', 5000000, 'PX003',N'260 Xô Vi Nghệ Tĩnh'), 
('KH007', N'Đinh Văn G'  ,  '0123456785', 'G@gmail.com', 7000000, 'PX009',N'430 Điện Biên Phủ'  ), 
('KH006', N'Trần Thị F'  ,  '0123456784', 'F@gmail.com', 6000000, 'PX008',N'37 An Dương Vương'  ), 
('KH008', N'Lê Thị H'    ,  '0123456786', 'H@gmail.com', 2000000, 'PX005',N'125 Mai Hắc Đế'     ),
('KH009', N'Nguyễn Văn I',  '0123456787', 'I@gmail.com', 9000000, 'PX003',N'228 Nguyễn Hữu Thọ' ),  
('KH010', N'Trần Thị N'  ,  '0123456788', 'J@gmail.com', 1000000, 'PX001',N'20 Nguyẽn Như Đỗ'   );

-- Thêm dữ liệu vào bảng NhanVien
INSERT INTO NhanVien (maNV, tenNV, SDT, Email, gioiTinh, DoB, salary) 
VALUES
	('NV001', N'Trần Thị T', '0123456788', 't@gmail.com', N'Nữ', '1994-10-10', 5400000),
	('NV002', N'Trần Thị L', '0123456780', 'l@gmail.com', default, '1990-02-02', default), 
	('NV003', N'Phạm Văn M', '0123456781', 'm@gmail.com', default, '1995-03-03', 5500000),
	('NV004', N'Lê Thị R', '0123456786', 'r@gmail.com', default, '1993-08-08', 6300000),
	('NV005', N'Nguyễn Văn O', '0123456783', 'o@gmail.com', N'Nữ', '1992-05-05', 7200000), 
	('NV006', N'Trần Thị P', '0123456784', 'p@gmail.com', N'Nữ', '1989-06-06', 6800000),
	('NV007', N'Phạm Văn Q', '0123456785', 'q@gmail.com', default, '1991-07-07', 5900000),
	('NV008', N'Lê Thị N', '0123456782', 'n@gmail.com', default, '1988-04-04', default),
	('NV009', N'Nguyễn Văn S', '0123456787', 's@gmail.com', N'Nữ', '1987-09-09', 6100000),
	('NV010', N'Nguyễn Văn K', '0123456789', 'k@gmail.com', default, '1985-01-01', default);

-- Thêm dữ liệu vào bảng SanPham
INSERT INTO SanPham (maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi) 
VALUES
	('SP001', N'Sản phẩm 1', 100000, 100, 2), 
	('SP002', N'Sản phẩm 2', 200000, 150, 4),
	('SP003', N'Sản phẩm 3', 150000, 200, 1),
	('SP004', N'Sản phẩm 4', 300000, 50, 3),
	('SP005', N'Sản phẩm 5', 250000, 70, default),
	('SP006', N'Sản phẩm 6', 350000, 30, 1),
	('SP007', N'Sản phẩm 7', 400000, 10, 2),
	('SP008', N'Sản phẩm 8', 450000, 20, 3),
	('SP009', N'Sản phẩm 9', 500000, 80, default),
	('SP010', N'Sản phẩm 10', 550000, 60, default);

/*
	- Thêm dữ liệu vào bảng DonDatHang_HoaDon

	- Tồn tại ít nhất 1 khách hàng mua hơn 1 đơn hàng
	- Khách hàng KH007 có 4 đơn hàng khác nhau (DH001, DH002, DH006 và DH008 ).
	- Tồn tại ít nhất 1 nhân viên xử lý hơn 1 đơn hàng
	- Nhân viên NV001 đã xử lý hai đơn hàng khác nhau (DH001, DH008, DH005).
	- Tồn tại ít nhất hai đơn hàng có cùng phường xã cần giao hàng
	- Bốn đơn hàng DH001, DH002, DH006 và DH008 có cùng phường xã cần  giao hàng là phường Thanh Bình , vì cả hai đều được gửi đến KH007.
*/ 
INSERT INTO DonDatHang_HoaDon (maDH, ngayTaoDH, SDTGiaoHang, maHoaDonDienTu, ngayGiaoHang, ngayThanhToan, trangThaiDonHang, KHNo, NVNo, idPX, soNhaTenDuong_DH) 
VALUES
	('DH001', default, '0123456789', 'HD001', getdate()+2, getdate()+1, N'Đã giao thành công', 'KH007', 'NV001', 'PX004', N'50 Cao Thắng'),
	('DH002', default, '0123456780', 'HD002', getdate()+4, getdate()+2, N'Đang giao', 'KH007', 'NV002', 'PX004', N'50 Cao Thắng'),
	('DH003', default, '0123456781', 'HD003', getdate()+2, getdate()+1, N'Đã giao thành công', 'KH002', 'NV001', 'PX008', N'37 An Dương Vương'),
	('DH004', default, '0123456782', 'HD004', getdate()+4, getdate()+2, N'Đang giao', 'KH003', 'NV003', 'PX005', N'125 Mai Hắc Ðế'),
	('DH005', default, '0123456783', 'HD005', getdate()+4, getdate()+2, N'Đã giao thành công', 'KH004', 'NV001', 'PX009', N'430 Ðiện Biên Phủ'),
	('DH006', default, '0123456784', 'HD006', getdate()+2, getdate()+1, N'Đã giao thành công', 'KH007', 'NV002', 'PX004', N'50 Cao Thắng'),
	('DH007', default, '0123456785', 'HD007', getdate()+4, getdate()+2, default, 'KH006', 'NV003', 'PX003', N'260 Xô Viết Nghệ Tĩnh'),
	('DH008', default, '0123456786', 'HD008', getdate()+4, getdate()+2, N'Đang giao', 'KH007', 'NV001', 'PX004', N'50 Cao Thắng'),
	('DH009', default, '0123456787', 'HD009', getdate()+2, getdate()+1, N'Đã giao thành công', 'KH008', 'NV002', 'PX004', N'12 Nguyễn Nhàn'),
	('DH010', default, '0123456788', 'HD010', getdate()+4, getdate()+2, N'Đang giao', 'KH009', 'NV003', 'PX003', N'222 D.2 Tháng 9');

-- Thêm dữ liệu vào bảng NhaCungCap
INSERT INTO NhaCungCap (maNCC, tenNCC, maPX_NCC, soNhaTenDuong_NCC, SDT, nhanVienLienHe)   
VALUES
('NCC001', N'Công ty J', 'PX001', N'357 Đường PQR, Quận LMN', '0951159753', N'Trần Thị J'),
('NCC002', N'Công ty B', 'PX002', N'456 Đường PQR, Quận LMN', '0987654321', N'Trần Thị B'),
('NCC003', N'Công ty C', 'PX003', N'789 Đường XYZ, Quận ABC', '0159753456', N'Phạm Văn C'),
('NCC004', N'Công ty D', 'PX004', N'246 Đường LMN, Quận PQR', '0258951753', N'Lê Thị D'),
('NCC005', N'Công ty G', 'PX005', N'258 Đường XYZ, Quận ABC', '0753159456', N'Phạm Văn G'),
('NCC006', N'Công ty H', 'PX006', N'369 Đường LMN, Quận PQR', '0951753159', N'Lê Thị H'),
('NCC007', N'Công ty E', 'PX007', N'369 Đường ABC, Quận XYZ', '0357951753', N'Nguyễn Văn E'),
('NCC008', N'Công ty F', 'PX007', N'147 Đường PQR, Quận LMN', '0456753159', N'Trần Thị F'),
('NCC009', N'Công ty I', 'PX009', N'159 Đường ABC, Quận XYZ', '0753951753', N'Nguyễn Văn I'),
('NCC010', N'Công ty A', 'PX010', N'123 Đường ABC, Quận XYZ', '0123456789', N'Nguyễn Văn A');
	
-- Thêm dữ liệu vào bảng PhieuNhap
INSERT INTO PhieuNhap (maPN, ngayNhapHang, NCCNo) 
VALUES
	('PN00001', '2023-01-01', 'NCC001'),
	('PN00002', '2023-02-02', 'NCC002'),
	('PN00003', '2023-03-03', 'NCC001'),
	('PN00004', '2023-04-04', 'NCC003'),
	('PN00005', '2023-01-05', 'NCC005'),
	('PN00006', '2023-05-06', 'NCC001'),
	('PN00007', '2023-06-07', 'NCC009'),
	('PN00008', '2023-07-08', 'NCC002'),
	('PN00009', '2023-08-09', 'NCC007'),
	('PN00010', '2023-03-10', 'NCC003');

/*
	- Thêm dữ liệu vào bảng ChiTietDonHang

	- Tồn tại ít nhất một sản phẩm xuất hiện trong nhiều đơn hàng/1 phiếu xuất
	- Trong bảng ChiTietDonHang, sản phẩm SP003 được chèn vào hai đơn hàng khác nhau (DH002 và DH004).
	- Tồn tại ít nhất một đơn hàng/1 phiếu nhập có nhiều hơn 1 loại sản phẩm trong đơn
	- Trong bảng ChiTietDonHang, đơn hàng DH001 có hai loại sản phẩm khác nhau (SP002 và SP003).
*/ 
INSERT INTO ChiTietDonHang (DHNo, SPNo, soLuongDat, donGia) 
VALUES
	('DH005', 'SP002', 8, 100000),	
	('DH001', 'SP002', 3, 200000),
	('DH002', 'SP003', 1, 100000),
	('DH003', 'SP001', 5, 150000),
	('DH001', 'SP003', 9, 300000),
	('DH005', 'SP005', 4, 250000),
	('DH006', 'SP006', 4, 350000),
	('DH007', 'SP007', 4, 400000),
	('DH006', 'SP005', 7, 450000),
	('DH009', 'SP008', 1, 500000);
-- Thêm dữ liệu vào bảng ChiTietPhieuNhap
INSERT INTO ChiTietPhieuNhap (PNNo, SPNo, soLuongNhap, giaNhap)
VALUES
	('PN00001', 'SP001', 6, 90000),
	('PN00002', 'SP002', 5, 180000),
	('PN00003', 'SP003', 2, 140000),
	('PN00004', 'SP009', 9, 480000),
	('PN00005', 'SP004', 5, 280000),
	('PN00006', 'SP005', 7, 380000),
	('PN00007', 'SP006', 4, 430000),
	('PN00008', 'SP007', 12, 230000),
	('PN00009', 'SP008', 8, 320000),
	('PN00010', 'SP010', 6, 500000);

-----------------------------Tuần 10 - Cập nhật, xóa, và truy vấn dữ liệu---------------------------------------------
/*
	Câu 1: 
		- Bổ sung cột KHTT trong bảng KhachHang.
		- Cập nhật giá trị của cột KHTT thành 'Khách hàng thân thiết' với những khách hàng đã từng đặt mua đơn hàng và trạng thái đơn hàng là 'Đã giao thành công'.
*/
Alter table KhachHang
	add KHTT nvarchar(50);
Update KhachHang
set KHTT = N'Khách hàng thân thiết'
from DonDatHang_HoaDon
where KhachHang.maKH=DonDatHang_HoaDon.KHNo
and trangThaiDonHang=N'Đã giao thành công';
-- Hiển thị bảng KhachHang khi cập nhật yêu cầu thành công
select * from KhachHang;

/*
	Câu 2: 
		- Xóa những nhà cung cấp mà chưa từng cung cấp hàng - về nguyên tắc, chỉ lưu thông tin nhà cung cấp nào đã từng cung cấp hàng của công ty/doanh nghiệp mình;
*/
Delete from NhaCungCap
where maNCC not in (
		select distinct NCCNo
		from PhieuNhap);
-- Hiển thị bảng NhaCungCap khi cập nhật yêu cầu thành công
select * from NhaCungCap;

/*
	Câu 3: 
		- Hãy hiển thị thông tin chi tiết của những sản phẩm đã từng được khách hàng mua?
*/
select *
from SanPham
where maSP in (
	select maSP
	from chiTietDonHang
	where DHNo in(
		select maDH
		from DonDatHang_HoaDon
		where trangThaiDonHang = N'Đã giao thành công'));
-- -- Hiển thị bảng ChiTietDonHang khi cập nhật yêu cầu thành công
select * from ChiTietDonHang;

/*
	Câu 4: 
		- Hãy hiển thị thông tin chi tiết của những sản phẩm đã từng được khách hàng mua, 
			và có tổng số lượng sản phẩm được mua lớn hơn 10?
		- Từng được khách hàng mua: trạng thái đơn hàng - Đã giao thành công
*/
select * from SanPham
where maSP in (select SPNo from chiTietDonHang
				where DHNo in (select maDH from DonDatHang_HoaDon 
						where trangThaiDonHang = N'Đã giao thành công')
					group by SPNo
					having SUM(soLuongDat) > 10);

/*
	Câu 5: 
			-Hãy hiển thị thông tin chi tiết của đơn hàng có trạng thái 'Chờ xử lý'?
*/
--
update DonDatHang_HoaDon
set trangThaiDonHang = N'Đã giao thành công'
where maDH in('DH001','DH005','DH007','DH008')
--
update DonDatHang_HoaDon
set trangThaiDonHang = N'Giao hàng không thành công'
where maDH in('DH009')
--
update DonDatHang_HoaDon
set trangThaiDonHang = N'Chờ xác nhận'
where maDH in('DH006','DH010')
--
update DonDatHang_HoaDon
set trangThaiDonHang = N'Đang giao'
where maDH in('DH003','DH004')
--
update DonDatHang_HoaDon
set trangThaiDonHang = N'Đã hủy'
where maDH in('DH002')

Select * from DonDatHang_HoaDon
where trangThaiDonHang = N'Chờ xác nhận'
/*
	Câu 6: 
			- Hãy đếm số đơn hàng theo mỗi trạng thái?
*/
select trangThaiDonHang, COUNT(maDH) as SoLuong 
From DonDatHang_HoaDon
group by trangThaiDonHang