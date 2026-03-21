--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'QLBH_2124')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''QLBH_2124'' 
    BEGIN 
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE QLBH_2124;
END;
go
--Tao database Quan Li Ban Hang
create database QLBH_2124;
go
--Lenh tao database hoan thanh thi su dung luon database qua lenh use
use QLBH_2124;
go
--Tao bang thu nhat: Khach Hang
create table KhachHang
(
	maKH  char(7),
	tenKH nvarchar(100),
	diaChiKH nvarchar(100),
	SDT varchar(11) unique,
	Email varchar(50) unique,
	soDuTaiKhoan Money,
	Primary Key(maKH)
);
go
-- Tao bang thu hai: Nhan vien
create table NhanVien
(
	maNV char(7), 
	tenNV nvarchar(100),
	Email Varchar(50) unique,
	gioiTinh Bit not null,
	DoB Date not null,
	Salary Money,
	Primary Key(maNV)
);
go
-- Tao bang thu ba: San Pham
create table SanPham
(
	maSP char(7), 
	tenSP nvarchar(100),
	donGiaBan Money,
	soLuongHienCon Bigint,
	soLuongCanDuoi Smallint,
	Primary Key(maSP)
);
go
-- Tao bang thu tu: NhaCungCap
create table NhaCungCap
(
	maNCC char(7),
	tenNCC nvarchar(100),
	diaChiNCC nvarchar(100),
	SDT varchar(11) unique,
	nhanVienLienHe nvarchar(100),
	Primary Key(maNCC)
);
go
-- Tao bang thu nam: Phieu Nhap
create table PhieuNhap
(
	maPN  char(7),
	NCCNo char(7),--Bo sung khoa ngoai
	ngayNhapHang date,
	Primary Key(maPN), 
	Foreign Key(NCCNo) references NhaCungCap(maNCC)
);
go
-- Tao bang thu sau: Chi Tiet Phieu Nhap
create table ChiTietPhieuNhap
(
	maPN char(7),
	maSP char(7),
	PNNo char(7),
	SPNo char(7),
	soLuongNhap Int,
	giaNhap Money,
	Primary Key(maPN,maSP),
	Foreign Key(PNNo) references  PhieuNhap(maPN),
	Foreign Key(SPNo) references  SanPham(maSP)
	
);
go
-- Tao bang thu bay: Don Dat Hang Hoa Don
create table DonDatHang_HoaDon
(
	maDH char(7),
	KHNo char(7), --Bo sung khoa ngoai
	NVNo char(7), --Bo sung khoa ngoai
	ngayTaoDH date,
	diaChiGiaoHang nvarchar(100),
	SDTGiaoHang varchar(11) unique,
	maHoaDonDienTu char(15) unique,
	ngayThanhToan date,
	ngayGiaoHang date,
	trangThaiDonHang nvarchar(100),
	Primary Key(maDH),
	Foreign Key(KHNo) references  KhachHang(maKH),
	Foreign Key(NVNo) references  NhanVien(maNV)
);
go
-- Tao bang thu tam: Chi Tiet Don Hang
create table ChiTietDonHang
(
	maDH char(7),
	maSP char(7),
	DHNo char(7),
	SPNo char(7),
	soLuongDat Int,
	donGia Money,
	Primary Key(maDH,maSP),
	Foreign Key(DHNo) references DonDatHang_HoaDon(maDH),
	Foreign Key(SPNo) references  SanPham(maSP)
);
go
--Bài tuần 8:
---Tạo bảng thứ 9: Quốc gia
create table QuocGia
(
	maQG char(7),
	tenQG nvarchar(100),
	Primary Key(maQG)
);
go
---Tạo bảng thứ 10: Tỉnh thành
create table TinhThanh
(
	maTT char(7),
	tenTT nvarchar(100),
	QGNo char(7),
	Primary Key(maTT),
	Foreign Key(QGNo) references QuocGia(maQG)
			ON DELETE CASCADE
			ON UPDATE CASCADE
);
go
---Tạo bảng thứ 11: Quận Huyện
create table QuanHuyen
(
	maQH char(7),
	tenQH nvarchar(100),
	TTNo char(7),
	Primary Key(maQH),
	Foreign Key(TTNo) references TinhThanh(maTT)
			ON DELETE CASCADE
			ON UPDATE CASCADE
);
go
---Tạo bảng thứ 12: Phường Xã
create table PhuongXa
(
	maPX char(7),
	tenPX nvarchar(100),
	QHNo char(7),
	Primary Key(maPX),
	Foreign Key(QHNo) references QuanHuyen(maQH)
			ON DELETE CASCADE
			ON UPDATE CASCADE
);
go
--Thay đổi cấu trúc bảng với lệnh Alter Table....
--Cập nhật bảng1: Khách Hàng
--- Xóa: Địa chỉ khách hàng
Alter table KhachHang
	drop column diaChiKH;
go
--- Thêm: diaChiKHNo, SoNha_TenDuong
Alter table KhachHang
	Add SoNha_TenDuong_KH nvarchar(100),
		diaChiKHNo char(7) not null
go
--- Cập nhật: diaChiKHNo(FK),SDT(CK),Email(CK),SoDuTK(CK,DF)
Alter table KhachHang
	Add constraint FK_diaChiKHNo 
			Foreign Key(diaChiKHNo) references PhuongXa(maPX)
					ON DELETE CASCADE
					ON UPDATE CASCADE,
		constraint CK_SDT_KH check
		(SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
		or SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint CK_Email_KH check (Email like '[a-z]%@%'),
		constraint DF_soDuTaiKhoan_KH default 0 for soDuTaiKhoan,
		constraint CK_soDuTaiKhoan_KH check (soDuTaiKhoan >=0);
go
-- Cập nhật bảng 2: Nhân Viên
---Xóa: nothing
---Thêm: SDT
Alter table NhanVien
	Add SDT char(11);
go
---Cập nhật: SDT(CK,UQ), Email(CK), gioitinh(DF,CK), DayofBirth(CK), salary(CK,DF) 
Alter table NhanVien
	Add constraint CK_SDT_NV check
		(SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
		or SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint UQ_SDT_NV unique(SDT),
		constraint CK_Email_NV check (Email like '[a-z]%@%'),
		constraint DF_gioiTinh_NV default 0 for gioiTinh,
		constraint CK_gioiTinh_NV check (gioiTinh in(1,0)),
		constraint CK_DoB_NV check (DoB <= DATEADD(YEAR,-18,GETDATE())),
		constraint DF_Salary_NV default 5000000 for Salary,
		constraint CK_Salary_NV check (Salary >=0);
go

--Cập nhật bảng 3: Sản Phẩm
---Xóa: nothing
---Thêm: nothing
---Cập nhật: donGiaBan(CK,DF), soLuongHienCon(CK,DF), soLuongCanDuoi(CK,DF)
Alter table SanPham
	Add constraint CK_donGiaBan_SP check (donGiaBan >=0),
		constraint DF_donGiaBan_SP default 0 for donGiaBan,
		constraint CK_soLuongHienCon check (soLuongHienCon>=0),
		constraint DF_soLuongHienCon default 0 for soLuongHienCon,
		constraint CK_soLuongCanDuoi check (soLuongCanDuoi<=5),
		constraint DF_soLuongCanDuoi default 5 for soLuongCanDuoi;
go
--Cập nhật bảng 4: NhaCungCap
---Xóa: diaChiNCC
Alter table NhaCungCap
	drop column diaChiNCC;
go
---Thêm: diaChiNCCNo, SoNha_TenDuong
Alter table NhaCungCap
	Add SoNha_TenDuong_NCC nvarchar(100),
		diaChiNCCNo char(7) not null;
go
---Cập nhật: diaChiNCCNo(FK), SDT(CK)
Alter table NhaCungCap
	Add constraint FK_diaChiNCCNo 
			Foreign Key(diaChiNCCNo) references PhuongXa(maPX)
					ON DELETE CASCADE
					ON UPDATE CASCADE,
		constraint CK_SDT_NCC check
			(SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			or SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
go
--Cập nhật bảng 5: Phieu Nhap
---Xóa: nothing
---Thêm: nothing
---Cập Nhật: ngayNhapHang(DF)
Alter table PhieuNhap
	Add constraint DF_ngayNhapHang default Getdate() for ngayNhapHang;
go
--Cập nhật bảng 6: Chi Tiet Phieu Nhap
---Xóa: nothing
---Thêm: nothing
---Cập Nhật: soLuongNhap(CK,DF), giaNhap(CK,DF)
Alter table ChiTietPhieuNhap
	Add constraint CK_soLuongNhap_CTPN check (soLuongNhap >=0),
		constraint DF_soLuongNhap_CTPN default 0 for soLuongNhap,
		constraint CK_giaNhap_CTPN check (giaNhap >=0),
		constraint DF_giaNhap_CTPN default 0 for giaNhap;
go
--Cập nhật bảng 7: Don Dat Hang_ Hoa Don
---Xóa: diaChiGiaoHang
Alter table DonDatHang_HoaDon
	drop column diaChiGiaoHang;
go
---Thêm: diaChiGiaoHangNo, SoNha_TenDuong_DDHHD
Alter table DonDatHang_HoaDon
	Add SoNha_TenDuong_DDHHD nvarchar(100),
		diaChiGiaoHangNo char(7) not null;
go
---Cập Nhật:  diaChiGiaoHangNo(FK), ngayTaoDH(CK), SDTGiaoHang(CK), ngayThanhToan(CK), ngayGiaoHang(CK),trangThaiDonHang(DF,CK)
Alter table DonDatHang_HoaDon
	Add constraint FK_diaChiGiaoHangNo
			Foreign Key(diaChiGiaoHangNo) references PhuongXa(maPX)
					ON DELETE CASCADE
					ON UPDATE CASCADE,
		constraint DF_ngayTaoDH_DDHHD default getdate() for ngayTaoDH,
		constraint CK_SDTGiaoHang_DDHHD check 
			(SDTGiaoHang like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			or SDTGiaoHang like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint CK_GH_TToan_NH_DDHHD check (ngayThanhToan>=ngayTaoDH
										or ngayThanhToan<=ngayGiaoHang
										or ngayGiaoHang>=ngayTaoDH),
		constraint DF_trangThaiDonHang_DDHHD default 'null' for trangThaiDonHang,
		constraint CK_trangThaiDonHang_DDHHD check (trangThaiDonHang in(N'Thành công', 'Thất bại'));
go
--Cập nhật bảng 8: Chi tiet Don Hang
---Xóa: nothing
---Thêm: nothing
---Cập Nhật: soLuongDat(DF,CK), donGia(DF,CK)
Alter table ChiTietDonHang
	Add constraint DF_soLuongDat_CTDH default 0 for soLuongDat,
		constraint CK_soLuongDat_CTDH check (soLuongDat>=0),
		constraint DF_donGia_CTDH default 0 for donGia,
		constraint CK_donGia_CTDH check (donGia>=0);
go
----Tuần 9-----Tuần 9----Tuần 9-----Tuần 9---Tuần 9------Tuần 9------Tuần 9------Tuần 9-------Tuần 9---------Tuần 9-----Tuần 9--------Tuần 9-----------
--Nhập dữ liệu
---Nhập dữ liệu bảng 9: Quốc Gia
Insert into QuocGia(maQG,tenQG)
Values
			('QG001',N'Ấn Độ'),
			('QG002',N'Việt Nam'),
			('QG003',N'Thái Lan'),
			('QG004',N'Singapore'),
			('QG005',N'Hàn Quốc'),
			('QG006',N'Mông Cổ'),
			('QG007',N'Nhật Bản'),
			('QG008',N'Thụy Điển'),
			('QG009',N'Malaysia'),
			('QG010',N'Ba Lan');
go
---Nhập dữ liệu bảng 10: Tỉnh Thành
Insert into TinhThanh(maTT,tenTT,QGNo)
Values
			('TT001',N'Thành Phố Đà Nẵng'      ,'QG002'),
			('TT002',N'Tỉnh Quảng Nam'         ,'QG002'),
			('TT003',N'Thành Phố Hà Nội'       ,'QG002'),
			('TT004',N'Thành Phố Hồ Chí Minh'  ,'QG002'),
			('TT005',N'Thành Phố Cần THơ'      ,'QG002'),
			('TT006',N'Tỉnh Quảng Ngãi'        ,'QG002'),
			('TT007',N'Tỉnh Thừa Thiên Huế'    ,'QG002'),
			('TT008',N'Tỉnh Bà Rịa - Vũng Tàu' ,'QG002'),
			('TT009',N'Tỉnh Quảng Ninh'        ,'QG002'),
			('TT010',N'Thành Phố Hải Phòng'    ,'QG002');
go
---Nhập dữ liệu bảng 11: Quận Huyện
Insert into QuanHuyen(maQH,tenQH,TTNo)
Values
			('QH001',N'Quận Sơn Trà'   ,'TT001'),
			('QH002',N'Huyện Duy Xuyên','TT002'),
			('QH003',N'Quận Đống Đa'   ,'TT003'),
			('QH004',N'Quận Bình Thạnh','TT004'),
			('QH005',N'Quận Ninh Kiều' ,'TT005'),
			('QH006',N'Huyện Trà Bồng' ,'TT006'),
			('QH007',N'Huyện Hương Trà','TT007'),
			('QH008',N'Huyện Côn Đảo'  ,'TT008'),
			('QH009',N'Huyện Cô Tô'    ,'TT009'),
			('QH010',N'Quận Hồng Bàng' ,'TT010');
go
---Nhập dữ liệu bảng 12: Phường Xã
Insert into PhuongXa(maPX,tenPX,QHNo)
Values
			('PX001',N'Phường An Hải Tây' ,'QH001'),
			('PX002',N'Xã Nam Phước	'     ,'QH002'),
			('PX003',N'Phường Nam Đồng'   ,'QH003'),
			('PX004',N'Phường 01'         ,'QH004'),
			('PX005',N'Phường An Hòa'     ,'QH005'),
			('PX006',N'Xã Trà Hiệp'       ,'QH006'),
			('PX007',N'Xã Phú Đa'         ,'QH007'),
			('PX008',N'Xã An Hải'         ,'QH008'),
			('PX009',N'Xã Trần Châu'      ,'QH009'),
			('PX010',N'Phường Quang Trung','QH010');
go
---Nhập dữ liệu cho bảng 1: Khách Hàng 
Insert into KhachHang(maKH, tenKH,SDT,Email,soDuTaiKhoan,SoNha_TenDuong_KH,diaChiKHNo)
Values 
			('KH001', N'Nguyễn Văn An' , '0901234567', 'nguyenvanan@gmail.com' , '1000000', N'123 Đường Nguyễn Hữu Thọ' , 'PX001'),
			('KH002', N'Trần Thị Bé'   , '0912345678', 'tranthibe@gmail.com'   , '2500000', N'456 Đường Lê Lợi'         , 'PX002'),
			('KH003', N'Lê Văn Cam'    , '0923456789', 'levancam@gmail.com'    , '750000' , N'789 Đường Trần Hưng Đạo'  , 'PX003'),
			('KH004', N'Phạm Thị Duyên', '0934567890', 'phamthiduyen@gmail.com', '3200000', N'321 Đường Phạm Văn Đồng'  , 'PX004'),
			('KH005', N'Nguyễn Văn Em' , '0945678901', 'nguyenvanem@gmail.com' , '1800000', N'654 Đường Nguyễn Trãi'    , 'PX005'),
			('KH006', N'Trần Văn Phát' , '0956789012', 'tranvanphat@gmail.com' , '900000' , N'987 Đường Lê Văn Sỹ'      , 'PX006'),
			('KH007', N'Lê Thị Giang'  , '0967890123', 'lethigiang@gmail.com'  , '2200000', N'135 Đường Võ Thị Sáu'     , 'PX007'),
			('KH008', N'Phạm Văn Huy'  , '0978901234', 'phamvanhuy@gmail.com'  , '1500000', N'246 Đường Đinh Tiên Hoàng', 'PX008'),
			('KH009', N'Nguyễn Thị Len', '0989012345', 'nguyenthilen@gmail.com', '600000' , N'369 Đường Hùng Vương'     , 'PX009'),
			('KH010', N'Trần Văn Việt' , '0990123456', 'tranvanviet@gmail.com' , '4000000', N'147 Đường Nguyễn Văn Cừ'  , 'PX010');
go
---Nhập dữ liệu cho bảng 2: Nhân Viên
--Sử dụng lệnh set dateformat để đảm bảo thứ tự dữ liệu day-month-year
set dateformat dmy;
Insert into NhanVien(maNV,tenNV,Email,gioiTinh,DoB,Salary,SDT)
Values
			('NV001', N'Nguyễn Thị An'   , 'nguyenthian@gmail.com'   , '1' , '13-08-2005', '5000000', '0805863245'),
			('NV002', N'Trần Văn Bình'   , 'trnvanbinh@gmail.com'    , '0' , '22-11-2003', '6000000', '0712345678'),
			('NV003', N'Lê Thị Cẩm'      , 'lethicam@gmail.com'      , '1' , '05-03-2000', '5500000', '0623456789'),
			('NV004', N'Phạm Minh Duy'   , 'phamminhduy@gmail.com'   , '0' , '18-07-1998', '7000000', '0534567890'),
			('NV005', N'Nguyễn Thị Hương', 'nguyenthihuong@gmail.com', '1' , '25-12-1995', '4500000', '0443678901'),
			('NV006', N'Trần Văn Hải'    , 'tranvanhai@gmail.com'    , '0' , '30-04-2001', '4800000', '0356789012'),
			('NV007', N'Lê Văn Kiên'     , 'levankien@gmail.com'     , '0' , '15-09-1997', '5200000', '0267890123'),
			('NV008', N'Phạm Thị Mai'    , 'phamthimai@gmail.com'    , '1' , '10-10-1999', '5300000', '0178901234'),
			('NV009', N'Nguyễn Văn Nam'  , 'nguyenvannam@gmail.com'  , '0' , '20-01-2004', '5900000', '0789012345'),
			('NV010', N'Trần Thị Oanh'   , 'tranthioanh@gmail.com'   , '1' , '27-06-2002', '6100000', '0990123456');
go
---Nhập dữ liệu cho bảng 3: Sản Phẩm
Insert into SanPham(maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi)
Values
			('SP001', N'Sản phẩm A', '20000' , '50'  ,'5'),
			('SP002', N'Sản phẩm B', '40000' , '60'  ,'5'),
			('SP003', N'Sản phẩm C', '60000' , '80'  ,'5'),
			('SP004', N'Sản phẩm D', '80000' , '30'  ,'5'),
			('SP005', N'Sản phẩm E', '100000' , '90' ,'5'),
			('SP006', N'Sản phẩm F', '120000' , '45' ,'5'),
			('SP007', N'Sản phẩm G', '140000' , '32' ,'5'),
			('SP008', N'Sản phẩm H', '160000' , '98' ,'5'),
			('SP009', N'Sản phẩm J', '180000' , '55' ,'5'),
			('SP010', N'Sản phẩm K', '200000' , '52' ,'5');
go
---Nhập dữ liệu cho bảng 4: Nhà Cung Cấp
Insert into NhaCungCap(maNCC, tenNCC, SDT, nhanVienLienHe, SoNha_TenDuong_NCC, diaChiNCCNo)
values
			('NCC001', 'Công ty A', '0123456789', 'Nguyễn Văn A', '123 Đường ABC', 'PX001'),
			('NCC002', 'Công ty B', '0987654321', 'Trần Thị B'  , '456 Đường XYZ', 'PX002'),
			('NCC003', 'Công ty C', '0112233445', 'Lê Văn C'    , '789 Đường DEF', 'PX003'),
			('NCC004', 'Công ty D', '0223344556', 'Phạm Thị D'  , '321 Đường GHI', 'PX004'),
			('NCC005', 'Công ty E', '0334455667', 'Hoàng Văn E' , '654 Đường JKL', 'PX005'),
			('NCC006', 'Công ty F', '0445566778', 'Ngô Thị F'   , '987 Đường MNO', 'PX006'),
			('NCC007', 'Công ty G', '0556677889', 'Đỗ Văn G'    , '123 Đường PQR', 'PX007'),
			('NCC008', 'Công ty H', '0667788990', 'Trịnh Thị H' , '456 Đường STU', 'PX008'),
			('NCC009', 'Công ty I', '0778899001', 'Nguyễn Văn I', '789 Đường VWX', 'PX009'),
			('NCC010', 'Công ty J', '0889900112', 'Trần Thị J'  , '321 Đường YZ' , 'PX010');

go
---Nhập dữ liệu cho bảng 5: Phiếu Nhập
--Sử dụng lệnh set dateformat để đảm bảo thứ tự dữ liệu day-month-year
set dateformat dmy;
Insert into PhieuNhap(maPN, NCCNo, ngayNhapHang)
values
			('PN001', 'NCC001', '01-01-2020'),
			('PN002', 'NCC002', '01-01-2020'),
			('PN003', 'NCC003', '01-01-2020'),
			('PN004', 'NCC004', '01-01-2020'),
			('PN005', 'NCC005', '01-01-2020'),
			('PN006', 'NCC006', '01-01-2020'),
			('PN007', 'NCC007', '01-01-2020'),
			('PN008', 'NCC008', '01-01-2020'),
			('PN009', 'NCC009', '01-01-2020'),
			('PN010', 'NCC010', '01-01-2020');

go
---Nhập dữ liệu cho bảng 6: Chi Tiết Phiếu Nhập
Insert into ChiTietPhieuNhap(maPN, maSP, PNNo, SPNo, soLuongNhap, giaNhap)
values
			('PN001', 'SP001', 'PN001', 'SP001', 100, 50000),
			('PN001', 'SP002', 'PN001', 'SP002', 200, 30000),
			('PN002', 'SP001', 'PN002', 'SP001', 150, 50000),
			('PN003', 'SP003', 'PN003', 'SP003', 120, 40000),
			('PN004', 'SP004', 'PN004', 'SP004', 180, 45000),
			('PN005', 'SP005', 'PN005', 'SP005', 160, 35000),
			('PN006', 'SP006', 'PN006', 'SP006', 140, 55000),
			('PN007', 'SP007', 'PN007', 'SP007', 130, 60000),
			('PN008', 'SP008', 'PN008', 'SP008', 110, 65000),
			('PN009', 'SP009', 'PN009', 'SP009', 170, 70000),
			('PN010', 'SP010', 'PN010', 'SP010', 190, 75000);

go
---Nhập dữ liệu cho bảng 7: Đơn Đặt Hàng Hóa Đơn
--Sử dụng lệnh set dateformat để đảm bảo thứ tự dữ liệu day-month-year
set dateformat dmy;
Insert into DonDatHang_HoaDon(maDH,KHNo,NVNo,ngayTaoDH,SDTGiaoHang,maHoaDonDienTu,ngayThanhToan,ngayGiaoHang,trangThaiDonHang,SoNha_TenDuong_DDHHD,diaChiGiaoHangNo)
values
			('DH001', 'KH001', 'NV001', '10-10-2024', '0123456989', 'HD001', '2024-10-15', '2024-10-20', 'Thành Công', '789 Đường DEF', 'PX003'),
			('DH002', 'KH002', 'NV001', '10-12-2024', '0987654321', 'HD002', '2024-10-17', '2024-10-22', 'Thành Công', '123 Đường GHI', 'PX004'),
			('DH003', 'KH001', 'NV002', '14-10-2024', '0123456789', 'HD003', '2024-10-19', '2024-10-24', 'Thành Công', '789 Đường DEF', 'PX003'),
			('DH004', 'KH003', 'NV003', '16-10-2024', '0112233445', 'HD004', '2024-10-21', '2024-10-26', 'Thành Công', '456 Đường XYZ', 'PX005'),
			('DH005', 'KH004', 'NV004', '18-10-2024', '0223344556', 'HD005', '2024-10-23', '2024-10-28', 'Thành Công', '321 Đường ABC', 'PX006'),
			('DH006', 'KH005', 'NV005', '20-10-2024', '0334455667', 'HD006', '2024-10-25', '2024-10-30', 'Thành Công', '654 Đường DEF', 'PX007'),
			('DH007', 'KH006', 'NV006', '22-10-2024', '0445566778', 'HD007', '2024-10-27', '2024-11-01', 'Thành Công', '987 Đường GHI', 'PX008'),
			('DH008', 'KH007', 'NV007', '24-10-2024', '0556677889', 'HD008', '2024-10-29', '2024-11-03', 'Thành Công', '123 Đường JKL', 'PX009'),
			('DH009', 'KH008', 'NV008', '26-10-2024', '0667788990', 'HD009', '2024-10-31', '2024-11-05', 'Thành Công', '456 Đường MNO', 'PX010'),
			('DH010', 'KH009', 'NV009', '28-10-2024', '0778899001', 'HD010', '2024-11-02', '2024-11-07', 'Thành Công', '789 Đường PQR', 'PX001');

go
---Nhập dữ liệu cho bảng 8: Chi Tiết Đơn Hàng
Insert into ChiTietDonHang(maDH,maSP,DHNo,SPNo,soLuongDat,donGia)
values	
			('DH001', 'SP001', 'DH001', 'SP001', 100, 50000),
			('DH001', 'SP002', 'DH001', 'SP002', 200, 30000),
			('DH002', 'SP002', 'DH002', 'SP002', 150, 50000),
			('DH003', 'SP003', 'DH003', 'SP003', 120, 40000),
			('DH004', 'SP004', 'DH004', 'SP004', 180, 45000),
			('DH005', 'SP005', 'DH005', 'SP005', 160, 35000),
			('DH006', 'SP006', 'DH006', 'SP006', 140, 55000),
			('DH007', 'SP007', 'DH007', 'SP007', 130, 60000),
			('DH008', 'SP008', 'DH008', 'SP008', 110, 65000),
			('DH009', 'SP009', 'DH009', 'SP009', 170, 70000),
			('DH010', 'SP010', 'DH010', 'SP010', 190, 75000);



