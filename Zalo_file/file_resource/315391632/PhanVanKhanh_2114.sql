--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'QLBH_2114')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''QLBH_2114'' 
    BEGIN
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE QLBH_2114;
END
go
--tạo database tên "QLBH" - Quản lý bán hàng
create database QLBH_2114;
go
--Sử dụng database "QLBH" -- Quản lý bán hàng
USE QLBH_2114;
go
--Tạo table1: Khách hàng
create table KhachHang
(
	maKH char(8),
	tenKH nvarchar(50) not null,
	diaChiKH nvarchar(200) not null,
	SDT varchar(11) not null unique
			check(ISNUMERIC(SDT) = 1),	--Kiểm tra để giá trị nhập vào toàn là số(trả về 1), không phải thì báo lỗi(trả về 0).
	Email varchar(50) not null unique,
	soDuTaiKhoan decimal(15, 2) not null, --xài kiểu decimal thay cho kiểu money,
	constraint PK_maKH PRIMARY KEY(maKH)
);
go
--Tạo table2: Nhân viên
create table NhanVien
(
	maNV char(8),
	tenNV nvarchar(50) not null,
	SDT varchar(11) unique not null
		check(ISNUMERIC(SDT) = 1),	--Kiểm tra để giá trị nhập vào toàn là số(trả về 1), không phải thì báo lỗi(trả về 0).
	Email varchar(50) not null unique,
	gioiTinh bit not null,
	--Tạo 1 gender_HienThi là cột tính toán sử dụng câu lệnh CASE để kiểm tra giá trị của gioiTinh
	--Trả về “nam” nếu giá trị là 1, và “nữ” nếu giá trị là 0.
	--Thêm persisted để giá trị của cột tính toán sẽ được lưu trữ trong table.
    gender_HienThi AS (CASE when gioiTinh = 1 then 'nam' else N'Nữ' end) PERSISTED,
	DoB date not null default GETDATE() --khi chưa có giá trị nào thì mặc định lấy giá trị ngày hôm nay
		check(DoB < GETDATE()), --Ngày sinh tất nhiên phải trước hôm nay rồi
	Salary money not null,
	constraint PK_maNV PRIMARY KEY(maNV)
);
go
--Tạo table3: Sản Phẩm
CREATE TABLE SanPham
(
    maSP char(8),
    tenSP nvarchar(200) not null,
    donGiaBan money not null,
    soLuongHienCon bigint not null,
    soLuongCanDuoi smallint not null,
	constraint PK_maSP PRIMARY KEY(maSP)
);
go
--Tạo table4: Nhà cung cấp
CREATE TABLE NhaCungCap
(
    maNCC char(8),
    tenNCC nvarchar(50),
    diaChiNCC nvarchar(200),
    SDT varchar(11) not null
		check(ISNUMERIC(SDT) = 1) ,	--Kiểm tra để giá trị nhập vào toàn là số(trả về 1), không phải thì báo lỗi(trả về 0).
    nhanVienLienHe nvarchar(50) null,
	constraint PK_maNCC PRIMARY KEY(maNCC)
);
go
--Tạo table5: Phiếu nhập
CREATE TABLE PhieuNhap
(
    maPN char(8),
    maNCC char(8), --Bổ sung khóa ngoại
    ngayNhaphang date not null,
	constraint PK_maPN PRIMARY KEY(maPN),
	constraint FK_NCC_5 FOREIGN KEY(maNCC) references NhaCungCap(maNCC) --Khóa ngoại từ bảng nhaCungCap
						ON DELETE CASCADE
						ON UPDATE CASCADE
);
go
--Tạo table6: Chi tiết phiếu nhập
CREATE TABLE ChiTietPhieuNhap
(
    maPN char(8),
    maSP char(8),
    soLuongNhap int not null,
    giaNhap money, --xài kiểu decimal thay cho kiểu money,
	constraint PK_maPN_maSP PRIMARY KEY(maPN, maSP),
	constraint FK_maPN_6 FOREIGN KEY(maPN) references PhieuNhap(maPN)	--Khóa ngoại từ bảng PhieuNhap
							ON DELETE CASCADE
							ON UPDATE CASCADE,
	constraint FK_maSP_6 FOREIGN KEY(maSP) references sanPham(maSP)		--Khóa ngoại từ bảng SanPham
							ON DELETE CASCADE
							ON UPDATE CASCADE
);
go
--Tạo table7: đơn đặt hàng - hóa đơn
create table DonDatHang_HoaDon
(
	maDH char(8),
	maKH char(8),	--Bổ sung khóa ngoại
	maNV char(8),	--Bổ sung khóa ngoại
	ngayTaoHoaDon date default GETDATE(), --khi chưa có giá trị nào thì mặc định lấy giá trị ngày hôm nay
	diaChiGiaoHang nvarchar(200) not null,
	SDTGiaoHang varchar(11) not null
			check(ISNUMERIC(SDTGiaoHang) = 1),	--Kiểm tra để giá trị nhập vào toàn là số(trả về 1), không phải thì báo lỗi(trả về 0).
    nhanVienLienHe nvarchar(50) null,
	maHoaDonDienTu char(8) not null,
	ngayThanhToan date not null,
	ngayGiaoHang date, --khi chưa có giá trị nào thì mặc định lấy giá trị ngày hôm nay
	trangThaiDonHang nvarchar(200),
	constraint PK_maDH PRIMARY KEY(maDH),
	constraint FK_maKH_7 FOREIGN KEY(maKH) references KhachHang(maKH)	--Khóa ngoại từ bảng KhachHang
							ON DELETE CASCADE
							ON UPDATE CASCADE,
	constraint FK_maNV_7 FOREIGN KEY(maNV) references NhanVien(maNV)		--Khóa ngoại từ bảng NhanVien
							ON DELETE CASCADE
							ON UPDATE CASCADE
);
go
--Tạo trigger để tạo điều kiện so sánh table7
CREATE TRIGGER Check_DonDatHang_HoaDon
ON DonDatHang_HoaDon
AFTER INSERT, UPDATE	--Trigger sẽ kích hoạt khi ta thực hiện insert hoặc update
AS
BEGIN
    IF EXISTS (	--Kiểm tra khi cập nhập hay chèn dữ liệu vô thì có thỏa mãn những điều kiện dưới đây không
        SELECT 1
        FROM inserted	--Chứa các giá trị mới dduocj cập nhật, chèn vào
        WHERE ngayTaoHoaDon > ngayGiaoHang
           or ngayThanhToan < ngayTaoHoaDon
           or ngayThanhToan > ngayGiaoHang
    )
    BEGIN --Nếu bất kì điều kiện trên đúng thì sẽ thực hiện những hành động dưới này
		--Báo lỗi “Ngày giao hàng hoặc ngày thanh toán không hợp lệ.”, 16 là mức độ nghiêm trọng.
        RAISERROR ('Ngày giao hàng hoặc ngày thanh toán không hợp lệ.', 16, 1);
		--Hoàn tác, hủy thao tác INSERT hay UPDATE kích hoạt lỗi.
        ROLLBACK TRANSACTION;
    END
END;
go
--Tạo table8: Chi Tiết đơn hàng
create table ChiTietDonHang
(
	maDH char(8),
	maSP char(8),
	soLuongDat int not null,
	donGia money, --xài kiểu decimal thay cho kiểu money,
	constraint PK_maDH_maSP PRIMARY KEY(maDH, maSP),
	constraint FK_maDH_8 FOREIGN KEY(maDH) references DonDatHang_HoaDon(maDH)
							ON DELETE CASCADE
							ON UPDATE CASCADE,	--Khóa ngoại từ bảng Check_DonDatHang_HoaDon
	constraint FK_maSP_8 FOREIGN KEY(maSP) references SanPham(maSP)
							ON DELETE CASCADE
							ON UPDATE CASCADE	--Khóa ngoại từ bảng SanPham
);

--Bài tuần 8: cập nhật lại các thông tin-----------------------------------------------------------------------------------------------------------------------------------------------------
--Xóa trigger đã tạo
drop trigger Check_DonDatHang_HoaDon;
go
--Tạo mới bảng 9: Quốc gia
create table QuocGia
(
	maQuocGia char(8),
	tenQuocGia nvarchar(100),
	constraint PK_maQuocGia PRIMARY KEY(maQuocGia)
);
go
--Tạo mới bảng 10: Tỉnh thành
create table TinhThanh
(
	maTinhThanh char(8),
	QuocGia_No char(8) not null,
	tenTinhthanh nvarchar(100),
	constraint PK_maTinhThanh PRIMARY KEY(maTinhThanh),
	constraint FK_QuocGia_No FOREIGN KEY(QuocGia_No) references QuocGia(maQuocGia)
								ON DELETE CASCADE
								ON UPDATE CASCADE
);
go
--Tạo mới bảng 11: Quận Huyện
create table QuanHuyen
(
	maQuanHuyen char(8),
	TinhThanh_No char(8) not null,
	tenQuanHuyen nvarchar(100),
	constraint PK_maQuanHuyen PRIMARY KEY(maQuanHuyen),
	constraint FK_TinhThanh_No FOREIGN KEY(TinhThanh_No) references TinhThanh(maTinhThanh)
								ON DELETE CASCADE
								ON UPDATE CASCADE
);
go
--Tạo mới bảng 12: Phường xã
create table PhuongXa
(
	maPhuongXa char(8),
	QuanHuyen_No char(8) not null,
	tenPhuongXa nvarchar(100) not null,
	constraint PK_maPhuongXa PRIMARY KEY(maPhuongXa),
	constraint FK_QuanHuyen_No FOREIGN KEY(QuanHuyen_No) references QuanHuyen(maQuanHUyen)
								ON DELETE CASCADE
								ON UPDATE CASCADE
);
go
--Tiến hành cập nhật, thay đổi bảng1: Khách hàng
-- Xóa: CK_SDT, diaChiKH
alter table KhachHang
	drop constraint CK__KhachHang__SDT__398D8EEE,
		 column diaChiKH
go
-- Thêm: diaChiKHNo, SoNha_TenDuong
alter table KhachHang
	add diaChiKHNo char(8) not null,
		SoNha_TenDuong nvarchar(100) not null;
go
-- Cập nhật: diaChiKHNo(FK), SDT(CK), Email(CK), soDuTaiKhoan(CK,DF)
alter table KhachHang
	add constraint FK_diaChiKHNo
			FOREIGN KEY(diaChiKHNo) references PhuongXa(maPhuongXa)
					ON DELETE CASCADE
					ON UPDATE CASCADE,
		constraint CK_SDT_KH check(SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
							or SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint CK_Email_KH check(Email like '[a-z]%@%'),
		constraint DF_soDuTaiKhoan default 0 for soDuTaiKhoan,
		constraint CK_soDuTaiKhoan check(soDuTaiKhoan >=0);
go
--Tiến hành cập nhật, thay đổi bảng2: Nhân viên
-- Xóa: gender_HienThi, SDT(CK) DoB(CK)
alter table NhanVien
	drop column gender_HienThi,
		 constraint CK__NhanVien__SDT__3E52440B,
		 constraint DF__NhanVien__DoB__3F466844;
GO
-- Thêm: GioiTinhHienThi(Tạo sau khi có constraint của giới tính)
-- Cập nhật: Email(CK), GioiTinh(CK,DF), DoB(CK), Salary(CK,DF)
alter table NhanVien
	add constraint CK_SDT_NV check(SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
							or SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint CK_Email_NV check(Email like '[a-z]%@%'),
		constraint CK_GioiTinh check(gioiTinh IN (1, 0)),
		constraint DF_GioiTinh default 1 for gioiTinh,
		GioiTinhHienThi AS(CASE when gioiTinh = 1 THEN N'Nam' else N'Nữ' END),
		constraint CK_DoB check(DoB <= DATEADD(YEAR, -18, GETDATE())),
		constraint DF_Salary default 5000000 for Salary,
		constraint CK_Salary check(Salary >=0);
go
--Tiến hành cập nhật, thay đổi bảng3: Sản Phẩm
-- Xóa: nothing
-- Thêm: nothing
-- Cập nhật:donGiaBan(CK,DF), soLuongHienCon(CK,DF), soLuongCanDuoi(CK,DF)
alter table SanPham
	add constraint CK_donGiaBan check(donGiaBan >= 0),
		constraint DF_donGiaBan default 0 for donGiaBan,
		constraint DF_soLuongHienCon default 0 for soLuongHienCon,
		constraint CK_soLuongHienCon check(soLuongHienCon >=0),
		constraint DF_soLuongCanDuoi default 5 for soLuongCanDuoi,
		constraint CK_soLuongCanDuoi check(soLuongCanDuoi <=5);
go
--Tiến hành cập nhật, thay đổi bảng4: nhà cung cấp
--Xóa: diaChiNCC, CK_SDT
alter table NhaCungCap
	drop column diaChiNCC,
		 constraint CK__NhaCungCap__SDT__44FF419A;
go
--Thêm: diaChiNCCNo, SoNha_TenDuong
alter table NhaCungCap
	add diaChiNCCNo char(8) not null,
		SoNha_TenDuong nvarchar(100) not null;
go
--Cập nhật: diaChiNCCNo(FK), SDT(CK,UQ)
alter table NhaCungCap
	add constraint CK_diaChiNCCNo 
			FOREIGN KEY(diaChiNCCNo) references PhuongXa(maPhuongXa)
					ON DELETE CASCADE
					ON UPDATE CASCADE,
		constraint CK_SDT_NCC check(SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
							or SDT like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint UQ_SDT_NCC unique(SDT);
GO
--Tiến hành cập nhật, thay đổi bảng5: Phiếu nhập
-- Xóa: nothing
-- Thêm: nothing
-- Cập nhật: ngayNhaphang(DF)
alter table PhieuNhap
	add constraint DF_ngayNhaphang default getdate() for ngayNhaphang;
go
--Tiến hành cập nhật, thay đổi bảng6: Chi tiết phiếu nhập
-- Xóa: nothing
-- Thêm:nothing
-- Cập nhật: soLuongNhap(CK,DF)
alter table ChiTietPhieuNhap
	add constraint DF_soLuongNhap default 0 for soLuongNhap,
		constraint CK_soLuongNhap check(soLuongNhap >=0);
go
--Tiến hành cập nhật, thay đổi bảng7: Đơn đặt hàng hóa đơn
-- Xóa: diaChiGiaoHang, CK_SDT
alter table DonDatHang_HoaDon
	drop column diaChiGiaoHang,
		 constraint CK__DonDatHan__SDTGi__4F7CD00D,
		 constraint DF__DonDatHan__ngayT__4E88ABD4
go
-- Thêm: diaChiGiaoHangNo, SoNha_TenDuong
alter table DonDatHang_HoaDon
	add diaChiGiaoHangNo char(8) not null,
		SoNha_TenDuong nvarchar(100) not null;
go
-- Cập nhật: diaChiGiaoHangNo(FK), SDT(UQ,CK), trangThaiDonHang(DF,CK)
--				ngayThanhToan(CK), ngayToaHoaDon(CK)
alter table DonDatHang_HoaDon
	add constraint DF_ngayTaoHoaDon default getdate() for ngayTaoHoaDon,
		constraint CK_GiaoHang check(ngayTaoHoaDon <= ngayGiaoHang 
									or ngayThanhToan >= ngayTaoHoaDon 
									or ngayThanhToan <= ngayGiaoHang),
		constraint FK_diaChiGiaoHangNo
				FOREIGN KEY(diaChiGiaoHangNo) references PhuongXa(maPhuongXa)
					ON DELETE NO ACTION
					ON UPDATE NO ACTION,
		constraint UQ_SDTGiaoHang unique(SDTGiaoHang),
		constraint CK_SDTGiaoHang check(SDTGiaoHang like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
							or SDTGiaoHang like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
		constraint DF_trangThaiDonHang default 'Không thành công' for trangThaiDonHang,
		constraint CK_trangThaiDonHang 
							CHECK(trangThaiDonHang IN(N'Thành công', N'Không thành công'));
GO
--Tiến hành cập nhật, thay đổi bảng8: Chi tiết đơn hàng
-- Xóa: nothing
-- Thêm: nothing
-- Cập nhật: soLuongDat(CK,DF), donGia(DF,CK)
alter table ChiTietDonHang
	add constraint DF_soLuongDat default 0 for soLuongDat,
		constraint CK_soLuongDat check(soLuongDat >= 0),
		constraint DF_donGia default 0 for donGia,
		constraint CK_donGia check(donGia >=0);
GO
------------Học bù chủ nhật--------Học bù chủ nhật------------Học bù chủ nhật------Học bù chủ nhật--------Học bù chủ nhật--------Học bù chủ nhật---------Học bù chủ nhật----------Học bù chủ nhật------------Học bù chủ nhật-----------Học bù chủ nhật-------------Học bù chủ nhật----------------------------
-- INSERT INTO QuocGia(maQuocGia,tenQuocGia)
-- VALUES('VIETNAM', N'Việt Nam');
-- go
-- INSERT INTO TinhThanh(maTinhThanh,QuocGia_No,tenTinhthanh)
-- VALUES('DANANG1','VIETNAM',N'Thanh phố Đà Nẵng');
-- go
-- INSERT INTO QuanHuyen(maQuanHuyen,TinhThanh_No,tenQuanHuyen)
-- VALUES('SONTRA01','DANANG1',N'Quận Sơn Trà');
-- go
-- INSERT INTO	PhuongXa(maPhuongXa,QuanHuyen_No, tenPhuongXa)
-- VALUES('AHAIDONG','SONTRA01',N'Phường an hải đông');
-- go
-- INSERT INTO KhachHang(maKH,tenKH,SDT, Email,soDuTaiKhoan,diaChiKHNo,SoNha_TenDuong)
-- VALUES('DN000001',N'Khánh sky', '9876543210', 'khanhsky2k5nam@gmail.com', 32165131,'AHAIDONG',N'05 đường tùm lum');
-- go
-- INSERT INTO	NhanVien(maNV, tenNV, SDT, Email, gioiTinh,DoB,Salary)
-- VALUES('NV000001',N'Dúi idols', '9867534210','nhsky2k5nam@gmail.com', 1, '2005-01-01', 564656456);
-- go
-- set dateformat dmy;
-- go
-- INSERT INTO DonDatHang_HoaDon(maDH,maKH,maNV,ngayTaoHoaDon,SDTGiaoHang,nhanVienLienHe,maHoaDonDienTu,ngayThanhToan,ngayGiaoHang,trangThaiDonHang,diaChiGiaoHangNo,SoNha_TenDuong)
-- VALUES('K0000001','DN000001','NV000001',getdate(),'01234567890',N'Phan Văn Khánh','DNK00001', '2024-01-09', '2024-01-10', 'Thành công', 'AHAIDONG', N'02/05 Đào Duy Anh')
---
---

---Bài tập tuần 9:-------Bài tập tuần 9:---------Bài tập tuần 9:---------Bài tập tuần 9:-----------Bài tập tuần 9:-------------Bài tập tuần 9:------------Bài tập tuần 9:-------Bài tập tuần 9:-------Bài tập tuần 9:------Bài tập tuần 9:---------Bài tập tuần 9:--------------------------
---insert ra 10 dòng dữ liệu của các bảng:
--sử dụng lệnh set dateformat để đảm bảo thứ tự dữ liệu day-month-year
set dateformat dmy; 
----Bảng Quốc gia:
INSERT INTO QuocGia(maQuocGia,tenQuocGia)
VALUES
    ('VIETNAM1', N'Việt Nam'),
    ('HANQUOC1', N'Hàn Quốc'),
    ('NHATBAN1', N'Nhật Bản'),
    ('RUSSIAN1', N'Liên Bang Nga'),
    ('THAILAN1', N'Thái Lan'),
    ('NOKOREA1', N'Bắc Triều Tiên'),
    ('HOAKY001', N'Hoa Kỳ'),
    ('ENGLAND1', N'Anh Quốc'),
    ('SINGAPO1', N'Xin ga po'),
    ('CHINA001', N'Trung Quốc');
go
----Bảng: Tỉnh Thành
INSERT INTO TinhThanh(maTinhThanh,QuocGia_No,tenTinhthanh)
VALUES
    ('TP000001','VIETNAM1',N'Thành phố Đà Nẵng'),
    ('TP000002','VIETNAM1',N'Thành phố Đắk Lắk'),
    ('TP000003','VIETNAM1',N'Thành phố Hà Nội'),
    ('TP000004','VIETNAM1',N'Thành phố SàiGòn'),
    ('TP000005','VIETNAM1',N'Thành phố Quảng Nam'),
    ('TP000006','THAILAN1',N'Thành phố BanCok'),
    ('TP000007','THAILAN1',N'Thành phố Hat Y'),
    ('TP000008','HANQUOC1',N'Thành phố Seoul'),
    ('TP000009','RUSSIAN1',N'Thành phố AbaKa'),
    ('TP000010','RUSSIAN1',N'Thành phố Aliba');
go
----Bảng: Quận Huyện
INSERT INTO QuanHuyen(maQuanHuyen,TinhThanh_No,tenQuanHuyen)
VALUES
    ('QH000001','TP000001',N'Quận Sơn Trà'	),
    ('QH000002','TP000001',N'Quận Liên Hiểu'),
    ('QH000003','TP000002',N'Buôn Mai Thuột'),
    ('QH000004','TP000002',N'Huyện Cư Kuinh'),
    ('QH000005','TP000003',N'Quận Đình Làng'),
    ('QH000006','TP000009',N'Quận Đống Đa 1'),
    ('QH000007','TP000009',N'Quận Một nắng '),
    ('QH000008','TP000004',N'Quận 7 bi rồng'),
    ('QH000009','TP000005',N'Huyện Tây Gian'),
    ('QH000010','TP000005',N'Huyện Đông Gia');
go
----Bảng: Phường Xã
INSERT INTO	PhuongXa(maPhuongXa,QuanHuyen_No, tenPhuongXa)
VALUES
    ('PHUONG01','QH000001',N'Phường An Hải Đông'),
    ('PHUONG02','QH000001',N'Phường An Hải Tâyy'),
    ('PHUONG03','QH000002',N'Phường Hòa Khá Nam'),
    ('PHUONG04','QH000002',N'Phường Hòa Khá Bắc'),
    ('PHUONG05','QH000003',N'Phường Khánh Xuânn'),
    ('PHUONG06','QH000003',N'Phường Ae Tam Kaoo'),
    ('PHUONG07','QH000004',N'Xã Hòa Hiệp No Tám'),
    ('PHUONG08','QH000009',N'Xã Ae Tiêu Tiền ko'),
    ('PHUONG09','QH000009',N'Phường Thành Côngg'),
    ('PHUONG10','QH000005',N'Phường TRúc Bạch 0');
go
----Bảng: Khách hàng
INSERT INTO KhachHang(maKH,tenKH,SDT, Email,soDuTaiKhoan,diaChiKHNo,SoNha_TenDuong)
VALUES
    ('KH000001',N'Phannn Văn A', '09123456711', 'phannnvanAA@gmail.com', 50000000,'PHUONG04',N'01 đường Phạm Cự Lượng Tô'),
    ('KH000002',N'Phannn Văn B', '09811543210', 'phannnvanBA@gmail.com', 40000000,'PHUONG05',N'02 đường Nguyễn Công Trứu'),
    ('KH000003',N'Phannn Văn C', '09877774210', 'phannnvanCA@gmail.com', 13210000,'PHUONG02',N'03 đường Trần Hưng Đạo Dụ'),
    ('KH000004',N'Phannn Văn D', '79111772369', 'phannnvanDV@gmail.com', 79841000,'PHUONG02',N'04 đường Hà Thị Thân Mếnn'),
    ('KH000005',N'Phannn Văn E', '09124897689', 'phannnvanEV@gmail.com', 54641300,'PHUONG10',N'05 đường Hoàng Văn Thái B'),
    ('KH000006',N'Nguyễn Văn A', '99325894101', 'nguyenvanAV@gmail.com', 97654132,'PHUONG03',N'06 đường Trần Đức Tuấn No'),
    ('KH000007',N'Nguyễn Văn B', '96325844102', 'nguyenvanBQ@gmail.com', 45641300,'PHUONG04',N'06 đường ba ba ba jackpot'),
    ('KH000008',N'Nguyễn Văn C', '96325844103', 'nguyenvanCQ@gmail.com', 56465450,'PHUONG01',N'06 đường Ngũ vị hương Nam'),
    ('KH000009',N'Nguyễn Văn D', '96325844104', 'nguyenvanDQ@gmail.com', 73213100,'PHUONG05',N'06 đường Đào Duy Anh Chào'),
    ('KH000010',N'Nguyễn Văn E', '96325844105', 'nguyenvanEO@gmail.com', 81321000,'PHUONG01',N'06 đường Võ VĂn Kiệt Xuất');
go
----Bảng: Nhân Viên
INSERT INTO	NhanVien(maNV, tenNV, SDT, Email, gioiTinh,DoB,Salary)
VALUES
    ('NV000001',N'Cu li số 01', '0002356789','nhsky2k1Anam@gmail.com', 1, '01-01-2001', default),
    ('NV000002',N'Cu li số 02', '9007643210','nhsky2k2Bnam@gmail.com', 1, '02-01-2002', default),
    ('NV000003',N'Cu li số 03', '9006134210','nhsky2k3Cnam@gmail.com', 0, '03-01-2003', default),
    ('NV000004',N'Cu li số 04', '0147112369','nhsky2k4Dnam@gmail.com', 1, '04-01-2004', default),
    ('NV000005',N'Cu li số 05', '0124017689','nhsky2k5Enam@gmail.com', 0, '05-01-2005', default),
    ('NV000006',N'Cu li số 06', '0445057689','nhsky2k4Anam@gmail.com', 1, '05-01-2004', default),
    ('NV000007',N'Cu li số 07', '0125057689','nhsky2k3Bnam@gmail.com', 1, '05-01-2003', default),
    ('NV000008',N'Cu li số 08', '0126657689','nhsky2k2Cnam@gmail.com', 0, '05-01-2002', default),
    ('NV000009',N'Cu li số 09', '0196657689','nhsky2k1Dnam@gmail.com', 1, '05-01-2001', default),
    ('NV000010',N'Cu li số 10', '0126657789','nhsky2kkEgay@gmail.com', 0, '05-01-2000', default);
go
----Bảng: Sản Phẩm
INSERT INTO SanPham(maSP,tenSP,donGiaBan,soLuongHienCon,soLuongCanDuoi)
VALUES
    ('SP000001',N'Sản phẩm số 01',11000, 25000, 1),
    ('SP000002',N'Sản phẩm số 02',11000, 30000, 2),
    ('SP000003',N'Sản phẩm số 03',21250, 12110, 3),
    ('SP000004',N'Sản phẩm số 04',60500, 30110, 2),
    ('SP000005',N'Sản phẩm số 05',54600, 60110, 2),
    ('SP000006',N'Sản phẩm số 06',64000, 70770, 4),
    ('SP000007',N'Sản phẩm số 07',84000, 50770, 2),
    ('SP000008',N'Sản phẩm số 08',70000, 45770, 2),
    ('SP000009',N'Sản phẩm số 09',81000, 36660, 4),
    ('SP000010',N'Sản phẩm số 10',41000, 67660, 4);
go
----Bảng: Nhà Cung Cấp
INSERT INTO NhaCungCap(maNCC, tenNCC, SDT, nhanVienLienHe, diaChiNCCNo,SoNha_TenDuong)
VALUES
    ('NCC00001', N'Nhà cung cấp 01', '0113453789', N'Phannn Văn A', 'PHUONG01', N'01 đường Đại ca ta'),
    ('NCC00002', N'Nhà cung cấp 02', '9816541210', N'Phannn Văn B', 'PHUONG03', N'02 đường Xã hội đe'),
    ('NCC00003', N'Nhà cung cấp 03', '9867531210', N'Phannn Văn C', 'PHUONG03', N'03 đường bố đời ta'),
    ('NCC00004', N'Nhà cung cấp 04', '0147852369', N'Phannn Văn D', 'PHUONG10', N'04 đường Báo hiếuu'),
    ('NCC00005', N'Nhà cung cấp 05', '0128357689', N'Phannn Văn E', 'PHUONG08', N'05 đường chông gai'),
    ('NCC00006', N'Nhà cung cấp 06', '0166357612', N'Nguyễn Văn A', 'PHUONG03', N'06 đường Bất lực 1'),
    ('NCC00007', N'Nhà cung cấp 07', '0122357452', N'Nguyễn Văn B', 'PHUONG07', N'07 đường nhựa name'),
    ('NCC00008', N'Nhà cung cấp 08', '0124777459', N'Nguyễn Văn C', 'PHUONG07', N'08 đường bê tôngCT'),
    ('NCC00009', N'Nhà cung cấp 09', '5544357799', N'Nguyễn Văn D', 'PHUONG09', N'09 đường nhân gian'),
    ('NCC00010', N'Nhà cung cấp 10', '3399357389', N'Nguyễn Văn E', 'PHUONG05', N'10 đường Ô gà TâyB');
go
----Bảng: Phiếu nhập
INSERT INTO PhieuNhap(maPN,maNCC,ngayNhaphang)
VALUES
    ('PN00004', 'NCC00001', '01-01-2023'),
    ('PN00005', 'NCC00002', '02-01-2023'),
    ('PN00006', 'NCC00003', '03-01-2023'),
    ('PN00007', 'NCC00003', '04-01-2023'),
    ('PN00008', 'NCC00005', '05-01-2023'),
    ('PN00009', 'NCC00005', '06-01-2023'),
    ('PN00010', 'NCC00007', '07-01-2023'),
    ('PN00020', 'NCC00008', '08-01-2023'),
    ('PN00012', 'NCC00009', '09-01-2023'),
    ('PN00013', 'NCC00010', '10-01-2023');
go
----Bảng: Chi tiết phiếu nhập
INSERT INTO ChiTietPhieuNhap(maPN,maSP,soLuongNhap,giaNhap)
VALUES
    ('PN00004', 'SP000001', 1000, 8000),
    ('PN00004', 'SP000002',  500, 1200),
    ('PN00005', 'SP000003',  200, 2000),
    ('PN00006', 'SP000004',  300, 3000),
    ('PN00007', 'SP000005',  400, 4000),
    ('PN00008', 'SP000006',  500, 5000),
    ('PN00009', 'SP000007',  600, 6000),
    ('PN00010', 'SP000008',  700, 7000),
    ('PN00008', 'SP000009',  800, 8000),
    ('PN00006', 'SP000010',  900, 9000);
go
-- Bảng: đơn đặt hàng - hóa đơn
INSERT INTO DonDatHang_HoaDon(maDH, maKH, maNV, ngayTaoHoaDon, SDTGiaoHang, nhanVienLienHe,
	maHoaDonDienTu, ngayThanhToan, ngayGiaoHang, trangThaiDonHang, diaChiGiaoHangNo, SoNha_TenDuong)
VALUES
    ('DH000001', 'KH000001', 'NV000001', GETDATE(), '0199422789', N'Nguyễn Văn MIN',
         'HD00001', '2024-01-01', '2024-01-10', default	, 'PHUONG01', N'01 đường Đại to'),
    ('DH000002', 'KH000002', 'NV000002', GETDATE(), '0998114321', N'Huỳnh Minh AIN',
         'HD00002', '2024-01-02', '2024-01-11', default	, 'PHUONG02', N'02 đường bố đời'),
    ('DH000003', 'KH000001', 'NV000001', GETDATE(), '0128456789', N'Phannn Văn XIN',
         'HD00003', '2024-01-03', '2024-01-12', default	, 'PHUONG01', N'01 đường tình T'),
    ('DH000004', 'KH000002', 'NV000002', GETDATE(), '0987114321', N'Phannn Văn NNP',
         'HD00004', '2024-01-04', '2024-01-13', default	, 'PHUONG04', N'02 đường làm ăn'),
    ('DH000005', 'KH000003', 'NV000003', GETDATE(), '0986133421', N'Phannn Văn AZP',
         'HD00005', '2024-01-05', '2024-01-14', default	, 'PHUONG04', N'03 đường Mai sa'),
    ('DH000006', 'KH000004', 'NV000010', GETDATE(), '0147832369', N'Nguyễn Văn AQP',
         'HD00006', '2024-01-06', '2024-01-15', default	, 'PHUONG04', N'04 đường đời nà'),
    ('DH000007', 'KH000006', 'NV000001', GETDATE(), '0124777689', N'Nguyễn Văn AIP',
         'HD00007', '2024-01-07', '2024-01-16', default	, 'PHUONG05', N'05 đường ga góc'),
    ('DH000008', 'KH000006', 'NV000002', GETDATE(), '9632767410', N'Nguyễn Văn AHP',
         'HD00008', '2024-01-08', '2024-01-17', default	, 'PHUONG06', N'06 đường phèn C'),
    ('DH000009', 'KH000006', 'NV000003', GETDATE(), '9632567411', N'Trương Văn AYP',
         'HD00009', '2024-01-09', '2024-01-18', default	, 'PHUONG06', N'07 đường số 333'),
    ('DH000010', 'KH000005', 'NV000004', GETDATE(), '9632427412', N'Trương Văn AYP',
         'HD00010', '2024-01-10', '2024-01-19', default	, 'PHUONG08', N'08 đường số 5HS');
GO
----Bảng: Chi Tiết đơn hàng
INSERT INTO ChiTietDonHang(maDH,maSP, soLuongDat,donGia)
VALUES
	('DH000001', 'SP000004', 7, 1000),
	('DH000002', 'SP000003', 19, 1000),
	('DH000003', 'SP000004', 1, 1000),
    ('DH000004', 'SP000003', 5, 1000),
    ('DH000003', 'SP000007', 3,  1500),
    ('DH000004', 'SP000009', 2,  2225),
    ('DH000005', 'SP000004', 3,  6050),
    ('DH000006', 'SP000004', 4,  566 ),
    ('DH000007', 'SP000006', 10,  650 ),
    ('DH000008', 'SP000007', 6,  870 ),
    ('DH000009', 'SP000007', 7,  700 ),
    ('DH000010', 'SP000009', 8,  200 ),
    ('DH000001', 'SP000010', 9,  400 );
go
--câu a: 
--      Sản phẩm(SP000001) xuất hiện trong cả DonDatHang_HoaDon(DH00003) và PhieuNhap(PN00004).
--câu b:
--      ChiTietDonHang(DH00003) có hai sản phẩm là  SP000001 và SP000002.
--      Phiếu nhập PN00004 có hai sản phẩm SP000001 và SP000002.
--câu c:
--(1)   Khách hàng KH000001 có hai đơn hàng là  DH00001 và DH00003.
--(2)   Khách hàng KH000002 có hai đơn hàng là  DH00002 và DH00004.
--câu d:
--(1)   Nhân viên NV000001 xử lý hai đơn hàng là DH00001 và DH00003.
--(2)   Nhân viên NV000002 xử lý hai đơn hàng là DH00002 và DH00004.
--câu e:
--(1)   Đơn hàng DH00003 và DH00001 đều giao hàng tại PHUONG01.
--(2)   Đơn hàng DH00008 và DH00009 đều giao hàng tại PHUONG06.


---Tuần 10------Tuần 10-----Tuần 10------Tuần 10------Tuần 10-----Tuần 10------Tuần 10------Tuần 10-------Tuần 10------Tuần 10------Tuần 10-----Tuần 10-------Tuần 10-----Tuần 10------Tuần 10------Tuần 10-----
--Insert thêm dữ liệu
----Bảng: Tỉnh Thành
INSERT INTO TinhThanh(maTinhThanh,QuocGia_No,tenTinhthanh)
VALUES
    ('TP000011','VIETNAM1',N'Thành phố số 01'),
    ('TP000012','VIETNAM1',N'Thành phố số 02'),
    ('TP000013','VIETNAM1',N'Thành phố số 03'),
    ('TP000014','VIETNAM1',N'Thành phố số 04'),
    ('TP000015','VIETNAM1',N'Thành phố số 05'),
    ('TP000016','VIETNAM1',N'Thành phố số 34'),
    ('TP000017','VIETNAM1',N'Thành phố Một Mảnhhh'),
    ('TP000018','HANQUOC1',N'Thành phố Small bird'),
    ('TP000019','RUSSIAN1',N'Thành phố Luân Hồi 1'),
    ('TP000020','RUSSIAN1',N'Thành phố Ảo Mộng 07');
GO
----Bảng: Quận Huyện
INSERT INTO QuanHuyen(maQuanHuyen,TinhThanh_No,tenQuanHuyen)
VALUES
	('QH000011','TP000008',N'Quận Trà Sơn 1'),
    ('QH000012','TP000008',N'Quận Chiểu Lie'),
    ('QH000013','TP000009',N'Ban Maoi Thuột'),
    ('QH000014','TP000009',N'Huyện Ka Kuinh'),
    ('QH000015','TP000010',N'Quận Mười Đình'),
    ('QH000016','TP000010',N'Quận Đa cấp XL'),
    ('QH000017','TP000015',N'Quận số 10 Tây'),
    ('QH000018','TP000015',N'Quận số 5 Đông'),
    ('QH000019','TP000017',N'Huyện Giang Ta'),
    ('QH000020','TP000017',N'Huyện Gian Cán');
GO
----Bảng: Phường Xã
INSERT INTO	PhuongXa(maPhuongXa,QuanHuyen_No, tenPhuongXa)
VALUES
    ('PHUONG11','QH000009',N'Phường An Hải TâyB'),
    ('PHUONG12','QH000010',N'Phường An Hải NamB'),
    ('PHUONG13','QH000010',N'Phường Hòa Khá Đẹp'),
    ('PHUONG14','QH000002',N'Phường Hòa Khá Tây'),
    ('PHUONG15','QH000003',N'Phường Xuânn Khánh'),
    ('PHUONG16','QH000003',N'Phường Tam Kaoo Ae'),
    ('PHUONG17','QH000004',N'Xã No Tám Hòa Hiệp'),
    ('PHUONG18','QH000004',N'Xã Tiêu Tiền ko Ae'),
    ('PHUONG19','QH000005',N'Phường Côngg Thành'),
    ('PHUONG20','QH000005',N'Phường 0 TRúc Bạch');
GO
----Bảng: Khách hàng
INSERT INTO KhachHang(maKH,tenKH,SDT, Email,soDuTaiKhoan,diaChiKHNo,SoNha_TenDuong)
VALUES
    ('KH000011',N'Phannn Văn A', '00173746119', 'phannnvanAO@gmail.com',
                        50000000,'PHUONG07',N'01 đường Phạm Cự Tô Lượng'),
    ('KH000012',N'Phannn Văn B', '09876743210', 'phannnvanBO@gmail.com',
                        40000000,'PHUONG01',N'02 đường Công Trứu Nguyễn'),
    ('KH000013',N'Phannn Văn C', '09867774210', 'phannnvanCT@gmail.com',
                        13210000,'PHUONG12',N'03 đường Đạo Dụ Trần Hưng'),
    ('KH000014',N'Phannn Văn D', '00147732369', 'phannnvanDT@gmail.com',
                        79841000,'PHUONG04',N'04 đường Hà Thị Thận Lâuu'),
    ('KH000015',N'Phannn Văn E', '00121737679', 'phannnvanET@gmail.com',
                        54641300,'PHUONG14',N'05 đường Thái B Hoàng Văn'),
    ('KH000016',N'Nguyễn Văn A', '96325734101', 'nguyenvanAA@gmail.com',
                        97654132,'PHUONG13',N'06 đường No Trần Đức Tuấn'),
    ('KH000017',N'Nguyễn Văn B', '96325731102', 'nguyenvanBA@gmail.com',
                        45641300,'PHUONG09',N'06 đường jackpot ba ba ba'),
    ('KH000018',N'Nguyễn Văn C', '11325737103', 'nguyenvanCA@gmail.com',
                        56465450,'PHUONG19',N'06 đường hương Nam Ngũ vị'),
    ('KH000019',N'Nguyễn Văn D', '96325731104', 'nguyenvanDA@gmail.com',
                        73213100,'PHUONG15',N'06 đường Anh Chào Đào Duy'),
    ('KH000020',N'Nguyễn Văn E', '96311771107', 'nguyenvanEA@gmail.com',
                        81321000,'PHUONG05',N'06 đường Kiệt Xuất Võ VĂn');
GO
----Bảng: Nhân Viên
INSERT INTO	NhanVien(maNV, tenNV, SDT, Email, gioiTinh,DoB,Salary)
VALUES
    ('NV000011',N'Cu li số 11', '0123451189','nhsky2k1Agay@gmail.com', 1, '01-01-2001', default),
    ('NV000012',N'Cu li số 12', '9876541110','nhsky2k2Bboy@gmail.com', 1, '02-01-2002', default),
    ('NV000013',N'Cu li số 13', '9867531110','nhsky2k3Cbay@gmail.com', 0, '03-01-2003', default),
    ('NV000014',N'Cu li số 14', '0147856669','nhsky2k4Dbay@gmail.com', 1, '04-01-2004', default),
    ('NV000015',N'Cu li số 15', '0124356689','nhsky2k5Eles@gmail.com', 0, '05-01-2005', default),
    ('NV000016',N'Cu li số 16', '0444356689','nhsky2k4Ales@gmail.com', 1, '05-01-2004', default),
    ('NV000017',N'Cu li số 17', '0121157689','nhsky2k3Bgay@gmail.com', 1, '05-01-2003', default),
    ('NV000018',N'Cu li số 18', '0121112489','nhsky2k2Cgay@gmail.com', 0, '05-01-2002', default),
    ('NV000019',N'Cu li số 19', '0191112489','nhsky2k1Dnuu@gmail.com', 1, '05-01-2001', default),
    ('NV000020',N'Cu li số 20', '0124312489','nhsky2kkEnuu@gmail.com', 0, '05-01-2000', default);
GO
----Bảng: Sản Phẩm
INSERT INTO SanPham(maSP,tenSP,donGiaBan,soLuongHienCon,soLuongCanDuoi)
VALUES
	('SP000011',N'Sản phẩm số 11',11000, 25440, 2),
    ('SP000012',N'Sản phẩm số 12',15000, 30440, 1),
    ('SP000013',N'Sản phẩm số 13',22250, 12600, 1),
    ('SP000014',N'Sản phẩm số 14',69500, 30300, 2),
    ('SP000015',N'Sản phẩm số 15',59600, 60300, 3),
    ('SP000016',N'Sản phẩm số 16',69000, 70300, 3),
    ('SP000017',N'Sản phẩm số 17',87000, 50000, 4),
    ('SP000018',N'Sản phẩm số 18',76000, 45110, 1),
    ('SP000019',N'Sản phẩm số 19',86000, 36110, 4),
    ('SP000020',N'Sản phẩm số 20',46000, 67110, 4);
GO
----Bảng: Nhà Cung Cấp
INSERT INTO NhaCungCap(maNCC, tenNCC, SDT, nhanVienLienHe, diaChiNCCNo,SoNha_TenDuong)
VALUES
    ('NCC00011', N'Nhà cung cấp 11', '1123456389', N'Phannn Văn A', 'PHUONG01', N'01 đường Đại ca ta'),
    ('NCC00012', N'Nhà cung cấp 12', '9876593210', N'Phannn Văn B', 'PHUONG11', N'02 đường Xã hội đe'),
    ('NCC00013', N'Nhà cung cấp 13', '9867393210', N'Phannn Văn C', 'PHUONG12', N'03 đường bố đời ta'),
    ('NCC00014', N'Nhà cung cấp 14', '0147323369', N'Phannn Văn D', 'PHUONG02', N'04 đường Báo hiếuu'),
    ('NCC00015', N'Nhà cung cấp 15', '0133357669', N'Phannn Văn E', 'PHUONG13', N'05 đường chông gai'),
    ('NCC00016', N'Nhà cung cấp 16', '0111357669', N'Nguyễn Văn A', 'PHUONG13', N'06 đường Bất lực 1'),
    ('NCC00017', N'Nhà cung cấp 17', '0122322659', N'Nguyễn Văn B', 'PHUONG04', N'07 đường nhựa name'),
    ('NCC00018', N'Nhà cung cấp 18', '0124722889', N'Nguyễn Văn C', 'PHUONG14', N'08 đường bê tôngCT'),
    ('NCC00019', N'Nhà cung cấp 19', '0412357889', N'Nguyễn Văn D', 'PHUONG15', N'09 đường nhân gian'),
    ('NCC00020', N'Nhà cung cấp 20', '0112357489', N'Nguyễn Văn E', 'PHUONG05', N'10 đường Ô gà TâyB');
GO
----Bảng: Phiếu nhập
INSERT INTO PhieuNhap(maPN,maNCC,ngayNhaphang)
VALUES
    ('PN00001', 'NCC00018', '01-01-2023'),
    ('PN00002', 'NCC00018', '02-01-2023'),
    ('PN00003', 'NCC00011', '03-01-2023'),
    ('PN00014', 'NCC00016', '04-01-2023'),
    ('PN00015', 'NCC00016', '05-01-2023'),
    ('PN00016', 'NCC00011', '06-01-2023'),
    ('PN00017', 'NCC00012', '07-01-2023'),
    ('PN00018', 'NCC00012', '08-01-2023'),
    ('PN00019', 'NCC00011', '09-01-2023'),
    ('PN00011', 'NCC00011', '10-01-2023');
GO
----Bảng: Chi tiết phiếu nhập
INSERT INTO ChiTietPhieuNhap(maPN,maSP,soLuongNhap,giaNhap)
VALUES
    ('PN00011', 'SP000001', 1000, 8000),
    ('PN00012', 'SP000002',  500, 1200),
    ('PN00012', 'SP000003',  200, 2000),
    ('PN00011', 'SP000004',  300, 3000),
    ('PN00016', 'SP000005',  400, 4000),
    ('PN00015', 'SP000006',  500, 5000),
    ('PN00015', 'SP000007',  600, 6000),
    ('PN00011', 'SP000008',  700, 7000),
    ('PN00020', 'SP000009',  800, 8000),
    ('PN00020', 'SP000010',  900, 9000);
GO
-- Bảng: đơn đặt hàng - hóa đơn
INSERT INTO DonDatHang_HoaDon(maDH, maKH, maNV, ngayTaoHoaDon, SDTGiaoHang, nhanVienLienHe,
            maHoaDonDienTu, ngayThanhToan, ngayGiaoHang, trangThaiDonHang, diaChiGiaoHangNo, SoNha_TenDuong)
VALUES
    ('DH000011', 'KH000006', 'NV000015', GETDATE(), '9632497413', N'Trương Văn AWH',
         'HD00011', '2024-01-11', '2024-01-20', default	, 'PHUONG19', N'09 đường Đào Và'),
    ('DH000012', 'KH000007', 'NV000016', GETDATE(), '9632597414', N'Nguyễn Văn AEH',
         'HD00012', '2024-01-12', '2024-01-21', default	, 'PHUONG10', N'10 đường Võ Tật'),
    ('DH000013', 'KH000008', 'NV000017', GETDATE(), '9632587413', N'Trương Văn ARR',
         'HD00013', '2024-01-11', '2024-01-20', default	, 'PHUONG09', N'09 đường Đào Và'),
    ('DH000014', 'KH000009', 'NV000018', GETDATE(), '0113422789', N'Nguyễn Văn AYH',
        'HD00014', '2024-01-01', '2024-01-10', default  , 'PHUONG11', N'01 đường Đại to'),
    ('DH000015', 'KH000003', 'NV000019', GETDATE(), '0917114321', N'Huỳnh Minh YYH',
        'HD00015', '2024-01-02', '2024-01-11', default	, 'PHUONG02', N'02 đường bố đời'),
    ('DH000016', 'KH000010', 'NV000009', GETDATE(), '0123456459', N'Phannn Văn ACH',
        'HD00016', '2024-01-03', '2024-01-12', default	, 'PHUONG01', N'01 đường tình T'),
    ('DH000017', 'KH000012', 'NV000008', GETDATE(), '0987654121', N'Phannn Văn ADH',
        'HD00017', '2024-01-04', '2024-01-13', default	, 'PHUONG02', N'02 đường làm ăn'),
    ('DH000018', 'KH000013', 'NV000007', GETDATE(), '0986753121', N'Phannn Văn AEB',
        'HD00018', '2024-01-05', '2024-01-14', default  , 'PHUONG13', N'03 đường Mai sa'),
    ('DH000019', 'KH000014', 'NV000006', GETDATE(), '0147562369', N'Nguyễn Văn AFB',
        'HD00019', '2024-01-06', '2024-01-15', default	, 'PHUONG14', N'04 đường đời nà'),
    ('DH000020', 'KH000016', 'NV000005', GETDATE(), '0124567689', N'Nguyễn Văn AGB',
        'HD00020', '2024-01-07', '2024-01-16', default	, 'PHUONG15', N'05 đường ga góc'),
    ('DH000021', 'KH000018', 'NV000004', GETDATE(), '9632687410', N'Nguyễn Văn AHB',
        'HD00021', '2024-01-08', '2024-01-17', default	, 'PHUONG16', N'06 đường phèn C'),
    ('DH000022', 'KH000015', 'NV000004', GETDATE(), '9632617411', N'Trương Văn AIB',
        'HD00022', '2024-01-09', '2024-01-18', default	, 'PHUONG16', N'07 đường số 333'),
    ('DH000023', 'KH000014', 'NV000003', GETDATE(), '9632367412', N'Trương Văn AJB',
        'HD00023', '2024-01-10', '2024-01-19', default	, 'PHUONG08', N'08 đường số 5HS'),
    ('DH000024', 'KH000013', 'NV000002', GETDATE(), '9632367414', N'Nguyễn Văn ALB',
        'HD00024', '2024-01-12', '2024-01-21', default  , 'PHUONG10', N'10 đường Võ Tật');
GO
----Bảng: Chi Tiết đơn hàng
INSERT INTO ChiTietDonHang(maDH,maSP, soLuongDat,donGia)
VALUES
	('DH000001', 'SP000014', 2, 1000),
	('DH000012', 'SP000003', 6, 1000),
	('DH000013', 'SP000004', 4, 1000),
    ('DH000004', 'SP000013', 2, 1000),
    ('DH000013', 'SP000007', 2,  1500),
    ('DH000014', 'SP000009', 1,  2225),
    ('DH000005', 'SP000014', 8,  6050),
    ('DH000004', 'SP000014', 3,  566 ),
    ('DH000004', 'SP000006', 2,  650 ),
    ('DH000008', 'SP000017', 9,  870 ),
    ('DH000009', 'SP000019', 1,  700 ),
    ('DH000009', 'SP000013', 2,  200 ),
    ('DH000011', 'SP000010', 2,  400 );
--Cập nhật ngẫu nhiên cho vài DH trạng thái thành công
UPDATE DonDatHang_HoaDon
SET trangThaiDonHang = N'Thành công'
WHERE maDH IN ('DH000001', 'DH000003', 'DH000010', 'DH000008',
                'DH000015', 'DH000012', 'DH000016', 'DH000019',
                'DH000005', 'DH000002', 'DH000014', 'DH000020');
GO
SELECT maDH,maKH,trangThaiDonHang FROM DonDatHang_HoaDon;
GO
--(câu 1)--(câu 1)--(câu 1)--(câu 1)--(câu 1)--(câu 1)--(câu 1)--(câu 1)--(câu 1)--(câu 1)--
--Bổ sung KHTT vào khách hàng:
ALTER TABLE KhachHang
	ADD KHTT NVARCHAR(50) NOT NULL DEFAULT N'không thân thiết'
						CHECK(KHTT in(N'không thân thiết',
									  N'thân thiết'));
GO
--Cập nhật thân thiết với khách hàng
--đã mua hàng và trạng thái là thành công
--Đã mua hàng và trạng thái không thành công
UPDATE KhachHang
SET KHTT = N'thân thiết'
WHERE maKH IN (SELECT maKH FROM DonDatHang_HoaDon
                WHERE trangThaiDonHang = N'Thành công');
GO
---Xuất ra danh sách để kiểm tra.
SELECT maKH,tenKH,KHTT  FROM KhachHang;
GO
--(câu 2)--(câu 2)--(câu 2)--(câu 2)--(câu 2)--(câu 2)--(câu 2)--(câu 2)--(câu 2)--(câu 2)--
--Hãy xóa những nhà cung cấp mà chưa từng cung cấp hàng
IF EXISTS(SELECT maNCC FROM NhaCungCap WHERE maNCC NOT IN
			(SELECT maNCC FROM PhieuNhap))
BEGIN
	DELETE NhaCungCap
	WHERE maNCC NOT IN(SELECT maNCC FROM PhieuNhap)
END;
go
---Xuất ra danh sách để kiểm tra.
SELECT * FROM NhaCungCap;
GO
--(câu 3)--(câu 3)--(câu 3)--(câu 3)--(câu 3)--(câu 3)--(câu 3)--(câu 3)--(câu 3)--(câu 3)--
--Hãy hiển thị thông tin chi tiết của
--những sản phẩm đã từng được khách hàng mua?
SELECT * FROM SanPham
WHERE maSP IN(SELECT maSP FROM ChiTietDonHang
                WHERE maDH IN(SELECT maDH FROM DonDatHang_HoaDon
                                WHERE trangThaiDonHang = N'Thành công'));
GO
--(câu 4)--(câu 4)--(câu 4)--(câu 4)--(câu 4)--(câu 4)--(câu 4)--(câu 4)--(câu 4)--(câu 4)--
--Hãy hiển thị thông tin chi tiết của
--những sản phẩm đã từng được khách hàng mua
--và có tổng số lượng sản phẩm được mua lớn hơn 10?
SELECT * FROM SanPham
WHERE maSP IN(SELECT maSP FROM ChiTietDonHang
                WHERE maDH IN(SELECT maDH FROM DonDatHang_HoaDon
                                WHERE trangThaiDonHang = N'Thành công')
                GROUP BY maSP
                HAVING SUM(soLuongDat) > 10);

--(câu 5)--(câu 5)--(câu 5)--(câu 5)--(câu 5)--(câu 5)--(câu 5)--(câu 5)--(câu 5)--(câu 5)--
--Xóa constraint
ALTER TABLE DonDatHang_HoaDon
    DROP CONSTRAINT CK_trangThaiDonHang;
GO
--(đổi giá trị cột Trạng thái đơn hàng thành 5 trạng thái
--như buổi học online hôm qua yêu cầu)?
ALTER TABLE DonDatHang_HoaDon
    ADD CONSTRAINT CK_trangThaiDonHang_new
    CHECK (trangThaiDonHang IN (N'Chờ xử lý',
                                N'Chờ lấy hàng',
                                N'Chờ giao hàng',
                                N'Thành công',
                                N'Không thành công'));
GO
--Thêm ngẫu nhiên cho vài DH 5 trạng thái
--Thành công
UPDATE DonDatHang_HoaDon
SET trangThaiDonHang = N'Thành công'
WHERE maDH IN ('DH000001', 'DH000003', 'DH000005',
                'DH000007','DH000009', 'DH000011');
GO
--Không thành công
UPDATE DonDatHang_HoaDon
SET trangThaiDonHang = N'Không thành công'
WHERE maDH IN ('DH000002', 'DH000004', 'DH000006',
                'DH000008','DH000010');
GO
--Chờ giao hàng
UPDATE DonDatHang_HoaDon
SET trangThaiDonHang = N'Chờ giao hàng'
WHERE maDH IN ('DH000012', 'DH000014', 'DH000016',
                'DH000018');
GO
--Chờ lấy hàng
UPDATE DonDatHang_HoaDon
SET trangThaiDonHang = N'Chờ lấy hàng'
WHERE maDH IN ('DH000013', 'DH0000015');
GO
--Chờ xử lý
UPDATE DonDatHang_HoaDon
SET trangThaiDonHang = N'Chờ xử lý'
WHERE maDH IN ('DH000017', 'DH000019', 'DH000020');
GO
--Hiển thi thông tin của đơn hàng có trạng thái 'Chờ xử lý'
SELECT DISTINCT maDH,maKH,maNV,trangThaiDonHang,diaChiGiaoHangNo,SoNha_TenDuong
FROM DonDatHang_HoaDon WHERE trangThaiDonHang = N'Chờ xử lý';
GO
--(câu 6)--(câu 6)--(câu 6)--(câu 6)--(câu 6)--(câu 6)--(câu 6)--(câu 6)--(câu 6)--(câu 6)--
--Hãy đếm số đơn hàng theo mỗi trạng thái?
SELECT trangThaiDonHang, COUNT(maDH) AS soLuong
FROM DonDatHang_HoaDon GROUP BY trangThaiDonHang;
GO

--(câu a)--(câu a)--(câu a)--(câu a)--(câu a)--(câu a)--(câu a)--(câu a)--(câu a)--(câu a)--
/*
	Hãy hiển thị thông tin sản phẩm có số lần nhập hàng về nhiều nhất
	[B1]: insert thêm dòng dữ liệu để kết quả hiện lên rõ ràng hơn
	B2: Viết code hiển thị
*/
--B1
INSERT INTO ChiTietPhieuNhap(maPN,maSP,soLuongNhap,giaNhap)
VALUES
    ('PN00011', 'SP000020', 1000, 8000),
    ('PN00012', 'SP000020',  500, 1200),
    ('PN00012', 'SP000012',  200, 2000),
    ('PN00011', 'SP000009',  300, 3000),
    ('PN00016', 'SP000015',  400, 4000),
    ('PN00015', 'SP000018',  500, 5000),
    ('PN00015', 'SP000015',  600, 6000),
    ('PN00011', 'SP000011',  700, 7000),
    ('PN00020', 'SP000019',  800, 8000),
    ('PN00020', 'SP000020',  900, 9000);
GO
--B2
SELECT maSP, tenSP, SoLanNhapHang
FROM (
		SELECT s.maSP, s.tenSP,
			COUNT(cn.soLuongNhap) as SoLanNhapHang,
			RANK() OVER (ORDER BY COUNT(cn.soLuongNhap) DESC) as RankOrder
		FROM SanPham s, ChiTietPhieuNhap cn
		Where s.maSP = cn.maSP
		GROUP BY s.maSP, s.tenSP
	) AS LuotNhapvao
Where RankOrder = 1;
GO

--(câu b)--(câu b)--(câu b)--(câu b)--(câu b)--(câu b)--(câu b)--(câu b)--(câu b)--(câu b)--
/*
	thống kê những sản phẩm thuộc top 3 bán chạy nhất  
	->(lưu ý không phải 3 dòng – có thể nhiều dòng
		miễn là đảm bảo nằm trong top 3) -> subquery 
*/
SELECT s.maSP, s.tenSP, SUM(ch.soLuongDat) as SoLuongBan
FROM SanPham s, ChiTietDonHang ch, DonDatHang_HoaDon dh
WHERE s.maSP = ch.maSP
AND ch.maDH = dh.maDH
AND dh.trangThaiDonHang = N'Thành công'
GROUP BY s.maSP, s.tenSP
Having SUM(ch.soLuongDat) in (
			Select distinct TOP 3 SUM(ch.soLuongDat) as SoLuongBan
			From ChiTietDonHang ch, DonDatHang_HoaDon dh
			WHERE ch.maDH = dh.maDH
			AND dh.trangThaiDonHang = N'Thành công'
			group by maSP
			ORDER BY SUM(ch.soLuongDat) DESC)
ORDER BY SUM(ch.soLuongDat) DESC
--Kiem tra qua cac gia tri 
Select * from DonDatHang_HoaDon
Select * from ChiTietDonHang
GO
--(câu c)--(câu c)--(câu c)--(câu c)--(câu c)--(câu c)--(câu c)--(câu c)--(câu c)--(câu c)--
/*
	thống kê những sản phẩm chưa bán được cái nào  
		->(not in)
	Xài Except(Minus) thay cho not in
*/
Select *
From SanPham
Where maSP in(
		Select s.maSP
		From SanPham s
		except
		Select ch.maSP
		From ChiTietDonHang ch
		)
Go
--(câu d)--(câu d)--(câu d)--(câu d)--(câu d)--(câu d)--(câu d)--(câu d)--(câu d)--(câu d)--
/*
	hiển thị những đơn hàng giao thành công
		và thông tin cụ thể của người giao hàng (position) 
*/
Select *
from NhanVien
Where maNV in ( select maNV
				from DonDatHang_HoaDon
				Where trangThaiDonHang = N'Thành công')
Go
--(câu e)--(câu e)--(câu e)--(câu e)--(câu e)--(câu e)--(câu e)--(câu e)--(câu e)--(câu e)--
/*
Select * from KhachHang
SELECT dh.*
FROM KhachHang k, DonDatHang_HoaDon dh, PhuongXa p, QuanHuyen q, TinhThanh t
WHERE k.maKH = dh.maKH
AND dh.diaChiGiaoHangNo = p.maPhuongXa
AND k.diaChiKHNo = p.maPhuongXa
AND p.QuanHuyen_No = q.maQuanHuyen
AND q.TinhThanh_No = t.maTinhThanh
AND (t.tenTinhthanh like N'%Đà Nẵng'
	or t.tenTinhthanh like N'%Quảng Nam')
*/
Select * from KhachHang
SELECT dh.*
FROM KhachHang k, DonDatHang_HoaDon dh
WHERE k.maKH = dh.maKH
AND k.diaChiKHNo in (
	Select k.diaChiKHNo
	from KhachHang k, PhuongXa p, QuanHuyen q, TinhThanh t
	Where k.diaChiKHNo = p.maPhuongXa
	AND p.QuanHuyen_No = q.maQuanHuyen
	AND q.TinhThanh_No = t.maTinhThanh
	AND (t.tenTinhthanh like N'%Đà Nẵng'
		or t.tenTinhthanh like N'%Quảng Nam')
	)
Go
--(câu f)--(câu f)--(câu f)--(câu f)--(câu f)--(câu f)--(câu f)--(câu f)--(câu f)--(câu f)--

/*
	hiển thị những sản phẩm có giá từ 500k – 2.000k
	[B1]: cập nhật để ra 1 vài giá trị phù hợp để dùng
	B2: hiển thị(tạo format cho tiền)
*/
--B1
UPDATE SanPham
SET donGiaBan = 
    CASE
        WHEN donGiaBan < 20000 THEN donGiaBan + 1200000
        WHEN donGiaBan > 50000 THEN donGiaBan + 1400000
        ELSE donGiaBan
    END;
Go
--B2
Select s.maSP, s.tenSP, FORMAT(s.donGiaBan, 'C0', 'vi-VN') as donGiaBan, s.soLuongCanDuoi, s.soLuongHienCon
from SanPham s
Where donGiaBan >= 500000
AND donGiaBan <=2000000
Go
--(câu g)--(câu g)--(câu g)--(câu g)--(câu g)--(câu g)--(câu g)--(câu g)--(câu g)--(câu g)--
/*
	những tháng có doanh thu trên 2000000 (có tham số là định mức tiền)
*/
UPDATE ChiTietPhieuNhap
SET giaNhap = 
    CASE
        WHEN giaNhap < 20000 THEN giaNhap + 800000
        WHEN giaNhap > 50000 THEN giaNhap + 600000
        ELSE giaNhap
    END;
Go
Update DonDatHang_HoaDon
Set ngayTaoHoaDon = case maDH
		WHEN 'DH000001' THEN DATEADD(MONTH, -16, GETDATE())
		WHEN 'DH000002' THEN DATEADD(MONTH, -12, GETDATE())
		WHEN 'DH000003' THEN DATEADD(MONTH, -21, GETDATE())  
		WHEN 'DH000004' THEN DATEADD(MONTH, -13, GETDATE())
		WHEN 'DH000005' THEN DATEADD(MONTH, -10, GETDATE())
		WHEN 'DH000006' THEN DATEADD(MONTH, -10, GETDATE())
		WHEN 'DH000007' THEN DATEADD(MONTH, -23, GETDATE())
		WHEN 'DH000008' THEN DATEADD(MONTH, -12, GETDATE())
		WHEN 'DH000009' THEN DATEADD(MONTH, -11, GETDATE())  
		WHEN 'DH000010' THEN DATEADD(MONTH, -13, GETDATE())
		WHEN 'DH000011' THEN DATEADD(MONTH, -11, GETDATE())
		WHEN 'DH000012' THEN DATEADD(MONTH, -18, GETDATE())
		WHEN 'DH000013' THEN DATEADD(MONTH, -23, GETDATE())
		WHEN 'DH000014' THEN DATEADD(MONTH, -14, GETDATE())
		WHEN 'DH000015' THEN DATEADD(MONTH, -24, GETDATE())  
		WHEN 'DH000016' THEN DATEADD(MONTH, -23, GETDATE())
		WHEN 'DH000017' THEN DATEADD(MONTH, -21, GETDATE())
		WHEN 'DH000018' THEN DATEADD(MONTH, -21, GETDATE())
		WHEN 'DH000019' THEN DATEADD(MONTH, -13, GETDATE())
		WHEN 'DH000020' THEN DATEADD(MONTH, -15, GETDATE())
		WHEN 'DH000021' THEN DATEADD(MONTH, -55, GETDATE())  
		WHEN 'DH000022' THEN DATEADD(MONTH, -13, GETDATE())
		WHEN 'DH000023' THEN DATEADD(MONTH, -26, GETDATE())
		WHEN 'DH000024' THEN DATEADD(MONTH, -16, GETDATE())
END,
	ngayGiaoHang = case maDH
    	WHEN 'DH000001' THEN DATEADD(MONTH, -2, GETDATE())
    	WHEN 'DH000002' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000003' THEN DATEADD(MONTH, -2, GETDATE())
    	WHEN 'DH000004' THEN DATEADD(MONTH, -4, GETDATE())
    	WHEN 'DH000005' THEN DATEADD(MONTH, -2, GETDATE())
    	WHEN 'DH000006' THEN DATEADD(MONTH, -4, GETDATE())
		WHEN 'DH000007' THEN DATEADD(MONTH, -1, GETDATE())
    	WHEN 'DH000008' THEN DATEADD(MONTH, -2, GETDATE())
    	WHEN 'DH000009' THEN DATEADD(MONTH, -6, GETDATE())
    	WHEN 'DH000010' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000011' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000012' THEN DATEADD(MONTH, -8, GETDATE())
    	WHEN 'DH000013' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000014' THEN DATEADD(MONTH, -4, GETDATE())
    	WHEN 'DH000015' THEN DATEADD(MONTH, -4, GETDATE())
    	WHEN 'DH000016' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000017' THEN DATEADD(MONTH, -1, GETDATE())
    	WHEN 'DH000018' THEN DATEADD(MONTH, -1, GETDATE())
        WHEN 'DH000019' THEN DATEADD(MONTH, -6, GETDATE())
    	WHEN 'DH000020' THEN DATEADD(MONTH, -5, GETDATE())
    	WHEN 'DH000021' THEN DATEADD(MONTH, -5, GETDATE())  
    	WHEN 'DH000022' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000023' THEN DATEADD(MONTH, -1, GETDATE())
    	WHEN 'DH000024' THEN DATEADD(MONTH, -1, GETDATE())
END,
	ngayThanhToan = case maDH
    	WHEN 'DH000001' THEN DATEADD(MONTH, -14, GETDATE())
    	WHEN 'DH000002' THEN DATEADD(MONTH, -1, GETDATE())
    	WHEN 'DH000003' THEN DATEADD(MONTH, -14, GETDATE())  
    	WHEN 'DH000004' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000005' THEN DATEADD(MONTH, -2, GETDATE())
    	WHEN 'DH000006' THEN DATEADD(MONTH, -4, GETDATE())
		WHEN 'DH000007' THEN DATEADD(MONTH, -2, GETDATE())
    	WHEN 'DH000008' THEN DATEADD(MONTH, -10, GETDATE())
    	WHEN 'DH000009' THEN DATEADD(MONTH, -10, GETDATE())  
    	WHEN 'DH000010' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000011' THEN DATEADD(MONTH, -12, GETDATE())
    	WHEN 'DH000012' THEN DATEADD(MONTH, -8, GETDATE())
    	WHEN 'DH000013' THEN DATEADD(MONTH, -10, GETDATE())
    	WHEN 'DH000014' THEN DATEADD(MONTH, -4, GETDATE())
    	WHEN 'DH000015' THEN DATEADD(MONTH, -4, GETDATE())  
    	WHEN 'DH000016' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000017' THEN DATEADD(MONTH, -1, GETDATE())
    	WHEN 'DH000018' THEN DATEADD(MONTH, -1, GETDATE())
        WHEN 'DH000019' THEN DATEADD(MONTH, -6, GETDATE())
    	WHEN 'DH000020' THEN DATEADD(MONTH, -5, GETDATE())
    	WHEN 'DH000021' THEN DATEADD(MONTH, -5, GETDATE())  
    	WHEN 'DH000022' THEN DATEADD(MONTH, -3, GETDATE())
    	WHEN 'DH000023' THEN DATEADD(MONTH, -1, GETDATE())
    	WHEN 'DH000024' THEN DATEADD(MONTH, -1, GETDATE())
END
Go
Update ChiTietDonHang
Set donGia = case maDH
		WHEN 'DH000001' THEN 615000
		WHEN 'DH000002' THEN 815000
		WHEN 'DH000003' THEN 1515000
		WHEN 'DH000004' THEN 715000
		WHEN 'DH000005' THEN 315000
		WHEN 'DH000006' THEN 1015000
		WHEN 'DH000007' THEN 615000
		WHEN 'DH000008' THEN 615000
		WHEN 'DH000009' THEN 155000  
		WHEN 'DH000010' THEN 615000
		WHEN 'DH000011' THEN 615000
		WHEN 'DH000012' THEN 615000
		WHEN 'DH000013' THEN 615000
		WHEN 'DH000014' THEN 615000
		WHEN 'DH000015' THEN 615000
		WHEN 'DH000016' THEN 615000
		WHEN 'DH000017' THEN 615000
		WHEN 'DH000018' THEN 615000
		WHEN 'DH000019' THEN 615000
		WHEN 'DH000020' THEN 615000
		WHEN 'DH000021' THEN 615000  
		WHEN 'DH000022' THEN 615000
		WHEN 'DH000023' THEN 615000
		WHEN 'DH000024' THEN 615000
END
Go
/*
Select DATEPART(MONTH, ngayThanhToan) as Thang, 
		SUM((ch.soLuongDat*ch.donGia) - (ch.soLuongDat*cn.giaNhap)) as DoanhThu
From ChiTietPhieuNhap cn, SanPham s, ChiTietDonHang ch, DonDatHang_HoaDon dh
Where cn.maSP = s.maSP
AND s.maSP = ch.maSP
AND ch.maDH = dh.maDH
AND dh.trangThaiDonHang = N'Thành công'
Group by DATEPART(MONTH, ngayThanhToan)
Having SUM((ch.soLuongDat*ch.donGia) - (ch.soLuongDat*cn.giaNhap)) >2000000
*/

Select DATEPART(MONTH, ngayThanhToan) as Thang, 
		FORMAT(SUM(ch.soLuongDat*ch.donGia), 'C0', 'vi-VN') as DoanhThu
From ChiTietPhieuNhap cn, SanPham s, ChiTietDonHang ch, DonDatHang_HoaDon dh
Where cn.maSP = s.maSP
AND s.maSP = ch.maSP
AND ch.maDH = dh.maDH
AND dh.trangThaiDonHang = N'Thành công'
Group by DATEPART(MONTH, ngayThanhToan)
Having SUM(ch.soLuongDat*ch.donGia) >2000000
Go
--(câu h)--(câu h)--(câu h)--(câu h)--(câu h)--(câu h)--(câu h)--(câu h)--(câu h)--(câu h)--
/*
	thống kê số lượng khách theo từng tỉnh/thành phố (sắp xếp giảm dần)
	->(count – group by - order by)
*/
SELECT t.tenTinhThanh AS Tinh_Thanh,
       COUNT(k.maKH) AS N'Số lượng khách hàng'
FROM KhachHang k, PhuongXa p, QuanHuyen q, TinhThanh t
WHERE k.diaChiKHNo = p.maPhuongXa
      AND p.QuanHuyen_No = q.maQuanHuyen
      AND q.TinhThanh_No = t.maTinhThanh
GROUP BY t.tenTinhThanh
ORDER BY COUNT(k.maKH) DESC;
Go
--(câu i)--(câu i)--(câu i)--(câu i)--(câu i)--(câu i)--(câu i)--(câu i)--(câu i)--(câu i)--
/*
	thống kê giá trung bình, giá max, giá min nhập hàng cho mỗi sản phẩm
*/
UPDATE ChiTietPhieuNhap
SET giaNhap = 
    CASE
        WHEN maPN = 'PN00004' THEN giaNhap - 45000
        WHEN maPN = 'PN00005' THEN giaNhap + 55000
        WHEN maPN = 'PN00006' THEN giaNhap - 45000
        WHEN maPN = 'PN00007' THEN giaNhap + 65000
        WHEN maPN = 'PN00008' THEN giaNhap - 30000
        WHEN maPN = 'PN00009' THEN giaNhap + 33000
        WHEN maPN = 'PN00010' THEN giaNhap - 44000
        WHEN maPN = 'PN00011' THEN giaNhap + 77000
        WHEN maPN = 'PN00012' THEN giaNhap - 99000
        WHEN maPN = 'PN00015' THEN giaNhap + 11000
        WHEN maPN = 'PN00016' THEN giaNhap - 22000
        WHEN maPN = 'PN00020' THEN giaNhap + 50000
        ELSE giaNhap
    END;
Go
--
Select s.maSP, s.tenSP, 
		FORMAT(MAX(cn.giaNhap), 'C0', 'vi-VN') as N'Giá nhập trung bình',
		FORMAT(MIN(cn.giaNhap), 'C0', 'vi-VN') as N'Giá nhập thấp nhất',
		FORMAT(AVG(cn.giaNhap), 'C0', 'vi-VN') as N'Giá nhập cao nhất'
From SanPham s, ChiTietPhieuNhap cn
Where s.maSP = cn.maSP
Group by s.maSP, s.tenSP
Go 
--(câu j)--(câu j)--(câu j)--(câu j)--(câu j)--(câu j)--(câu j)--(câu j)--(câu j)--(câu j)--
/*
	hiển thị giá trung bình, giá max, giá min bán ra cho mỗi sản phẩm
	(lưu ý, mỗi mức giá bán ra của sản phẩm chỉ tính 1 lần)  
		->(giá sản phẩm sẽ thay đổi theo thời gian – được lưu lại trong bảng
			ChiTietDonHang – lấy mức giá bán ra khác biệt với từ khóa distinct)
*/

SELECT s.maSP AS MaSanPham,
        FORMAT(MAX(ch.donGia), 'C0', 'vi-VN') as N'Giá nhập trung bình',
		FORMAT(MIN(ch.donGia), 'C0', 'vi-VN') as N'Giá nhập thấp nhất',
		FORMAT(AVG(ch.donGia), 'C0', 'vi-VN') as N'Giá nhập cao nhất'
FROM SanPham s
JOIN ChiTietDonHang ch ON s.maSP = ch.maSP
GROUP BY s.maSP;

--(câu k)--(câu k)--(câu k)--(câu k)--(câu k)--(câu k)--(câu k)--(câu k)--(câu k)--(câu k)--
/*
	thống kê số lần khách hàng mua hàng của từng khách hàng (sắp xếp giảm dần)
		->group by – order by 
*/
Select * from ChiTietDonHang
Select * from DonDatHang_HoaDon
--
SELECT k.maKH, k.tenKH AS N'Tên khách hàng',
       COUNT(dh.maDH) AS N'Số lần mua hàng'
FROM KhachHang k, DonDatHang_HoaDon dh
WHERE k.maKH = dh.maKH
GROUP BY k.maKH, k.tenKH
ORDER BY COUNT(dh.maDH) DESC;
--(câu l)--(câu l)--(câu l)--(câu l)--(câu l)--(câu l)--(câu l)--(câu l)--(câu l)--(câu l)--
/*
	hiển thị thông tin chi tiết của các sản phẩm mà có số lần nhập hàng nhiều nhất  
		->(lưu ý trường hợp những sản phẩm cùng giá trị) 
			->with ties, hoặc có thể dùng subquery
			Select top 1 with ties …. 
*/
Select TOP 1 with ties s.maSP, s.tenSP, COUNT(cn.maSP) AS SoLanNhapHang
FROM SanPham s, ChiTietPhieuNhap cn
Where s.maSP = cn.maSP
GROUP BY s.maSP, s.tenSP
Order by COUNT(cn.maSP) DESC
--(câu m)--(câu m)--(câu m)--(câu m)--(câu m)--(câu m)--(câu m)--(câu m)--(câu m)--(câu m)--
/*
	hiển thị thông tin chi tiết của các nhà cung cấp mà có số lần nhập hàng lớn hơn 3 
		->count – group - having 
*/
SELECT   ncc.maNCC, ncc.tenNCC, COUNT(cn.soLuongNhap) AS SoLanNhapHang
FROM NhaCungCap ncc, ChiTietPhieuNhap cn, PhieuNhap pn
Where ncc.maNCC = pn.maNCC
AND pn.maPN = cn.maPN
GROUP BY ncc.maNCC, ncc.tenNCC
HAVING COUNT(cn.soLuongNhap) > 3
Order by COUNT(cn.soLuongNhap) DESC
--Câu hỏi thêm--Câu hỏi thêm--Câu hỏi thêm--Câu hỏi thêm--Câu hỏi thêm--Câu hỏi thêm--
/*
	Tạo view chứa thông tin khách hàng thường xuyên mua hàng
	(trong vòng 1 năm)
*/

Go
create view [BT THEM] as
	Select k.*
	From KhachHang k, DonDatHang_HoaDon dh
	Where k.maKH = dh.maKH
	AND YEAR(dh.ngayTaoHoaDon) = YEAR(getdate())
	AND dh.trangThaiDonHang = N'Thành công'
Go

Select * from [BT THEM]
Select * from SanPham

--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--
/*
	Câu 1: Hiển thị thông tin đầy đủ về tất cả sản phẩm, và cột
		được đặt tên là 'Tình trạng' nhận 1 trong các giá trị sau:
		+ 'Hết' nếu soLuongHienCon = 0
		+ 'Gần hết' nếu soLuongHienCon < 10
		+ 'Còn vô tư' nếu soLuongHienCon >=10
*/
Update SanPham
set soLuongHienCon = case maSP
	When 'SP000001' then 0
	When 'SP000003' then 8
	When 'SP000013' then 0
	When 'SP000011' then 9
	When 'SP000010' then 0
	When 'SP000017' then 8
	When 'SP000006' then 0
	When 'SP000016' then 7
	When 'SP000009' then 9
	else soLuongHienCon
End
go
Select *,
	case
		when soLuongHienCon = 0 then N'Hết'
		when soLuongHienCon < 10 then N'Gần hết'
		else N'Còn vô tư'
	End as N'Tình trạng'
from SanPham
Go

/*
	Câu 2: Thống kê() tìm kiếm những sản phẩm có @ten và giá bán ra < @gia
		(với @ten và &gia là tham số vào)
*/
CREATE PROCEDURE pr_TimKiemSanPham
    @ten NVARCHAR(50),
    @gia MONEY
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM SanPham
    WHERE tenSP LIKE '%' + @ten + '%'
    AND donGiaBan < @gia;
END
Go
execute pr_TimKiemSanPham N'Sản phẩm', 1200000
Go
/*
	Câu 3: Thống kê những giá đã từng bán ra của 1 sản phẩm
		(với @maSP là tham số vào)
*/
create procedure pr_ThongKeGiaBan
		@maSP char(8)
as
Begin
	Select s.maSP, ct.donGia
	From SanPham s, ChiTietDonHang ct, DonDatHang_HoaDon dh
	Where s.maSP = ct.maSP
	AND ct.maDH = dh.maDH
	AND s.maSP = @maSP
	AND dh.trangThaiDonHang = N'Thành công'
End
Go
execute pr_ThongKeGiaBan 'SP000001'
Go
execute pr_ThongKeGiaBan 'SP000004'
Go
/*
	Câu 4: Thống kê những sản phẩm có giá bán trong đoạn [@min,@max]
		với @min và @max là hai tham số vào (sắp xếp giảm dần theo giá,
		tăng dần theo mã sản phẩm)
*/
create procedure pr_ThongKeGiaBanInMaxMin
		@max money,
		@min money
as
Begin
	Select s.maSP, ct.donGia
	From SanPham s, ChiTietDonHang ct, DonDatHang_HoaDon dh
	Where s.maSP = ct.maSP
	AND ct.maDH = dh.maDH
	AND ct.donGia < @max
	AND ct.donGia > @min
	AND dh.trangThaiDonHang = N'Thành công'
	Order by s.maSP ASC, ct.donGia DESC
End
Go
execute pr_ThongKeGiaBanInMaxMin 1200000, 500000
Go
execute pr_ThongKeGiaBanInMaxMin 2000000, 1200001
Go
/*
	Câu 5: Tăng tự động các column ID cho tất cả các table
		được sinh từ thực thể mạnh(giải thích ở slide sau)
*/
--Theo thủ tục
--drop PROCEDURE pr_TaoDongMoi
create PROCEDURE pr_TaoDongMoi
    @TableName NVARCHAR(50)
AS
BEGIN
    DECLARE @NewIDtable CHAR(8)
    DECLARE @RandomNumber INT

	DECLARE @HasForeignKey INT
    SELECT @HasForeignKey = COUNT(*)
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc ON tc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
    WHERE tc.TABLE_SCHEMA = 'dbo' AND tc.TABLE_NAME = @TableName

    IF @HasForeignKey > 0
    BEGIN
        PRINT N'Bảng này có khóa ngoại, không áp dụng thủ tục tạo dữ liệu ngẫu nhiên.'
    END
    ELSE
	IF @TableName = N'KhachHang'
	BEGIN
		-- Tạo dữ liệu ngẫu nhiên cho các tham số
		SET @RandomNumber
		= ABS(CHECKSUM(NEWID())) % 1000  -- Số ngẫu nhiên từ 0 đến 999
		DECLARE @tenValues5 NVARCHAR(50)
		= 'Customer' + CAST(@RandomNumber AS NVARCHAR)
		DECLARE @SDT5 VARCHAR(20)
		= CAST(ABS(CHECKSUM(NEWID())) % 9000000000 + 1000000000 AS VARCHAR(20))
		DECLARE @Email5 NVARCHAR(50)
		= 'customer' + CAST(@RandomNumber AS NVARCHAR) + '@example.com'
		DECLARE @soDuTaiKhoan5 money
		= CAST(ROUND(RAND() * 100000, 2) AS money)
		DECLARE @diaChiKHNo5 char(8)
		= 'PHUONG' + RIGHT('0' + CAST(CAST(ROUND(RAND() * 21, 0) AS int) AS varchar(2)), 2)
		DECLARE @SoNha_TenDuong5 NVARCHAR(100)
		= '123 Street' + CAST(@RandomNumber AS NVARCHAR)

		DECLARE @TotalRows5 INT
		SELECT @TotalRows5 = COUNT(*) FROM KhachHang
		SET @NewIDtable
		= 'KH000' + RIGHT('000' + CAST(@TotalRows5 + 1 AS VARCHAR), 3)
    
		INSERT INTO KhachHang (maKH, tenKH, SDT, Email,
						soDuTaiKhoan, diaChiKHNo, SoNha_TenDuong)
		VALUES (@NewIDtable, @tenValues5, @SDT5, @Email5,
					@soDuTaiKhoan5, @diaChiKHNo5, @SoNha_TenDuong5)
	END
	ELSE
	IF @TableName = N'QuocGia'
	BEGIN
		-- Tạo dữ liệu ngẫu nhiên cho các tham số
		SET @RandomNumber
		= ABS(CHECKSUM(NEWID())) % 1000
		DECLARE @tenValues1 NVARCHAR(50)
		= N'Quốc gia' + CAST(@RandomNumber AS NVARCHAR)

		DECLARE @TotalRows1 INT
		SELECT @TotalRows1 = COUNT(*) FROM QuocGia
		SET @NewIDtable
		= 'QG000' + RIGHT('000' + CAST(@TotalRows1 + 2 AS VARCHAR), 3)
    
		INSERT INTO QuocGia (maQuocGia, tenQuocGia)
		VALUES (@NewIDtable, @tenValues1)
	END
	ELSE
	IF @TableName = N'NhanVien'
	BEGIN
		-- Tạo dữ liệu ngẫu nhiên cho các tham số
		SET @RandomNumber
		= ABS(CHECKSUM(NEWID())) % 1000  -- Số ngẫu nhiên từ 0 đến 999
		DECLARE @tenValues2 NVARCHAR(50)
		= N'Cu li số ' + CAST(@RandomNumber AS NVARCHAR)
		DECLARE @SDT2 VARCHAR(20)
		= CAST(ABS(CHECKSUM(NEWID()))%9000000000+1000000000 AS VARCHAR(20))
		DECLARE @Email2 NVARCHAR(50)
		= 'customer' + CAST(@RandomNumber AS NVARCHAR) + '@gmail.com'
		DECLARE @gioiTinh2 bit = ROUND(RAND(), 0)
		DECLARE @RandomDays INT
		= ROUND(RAND() * DATEDIFF(day, '1995-01-01', '2005-12-31'), 0)
		DECLARE @DoB2 DATE
		= DATEADD(day, @RandomDays, '1995-01-01')
		DECLARE @Salary2 MONEY
		= CAST(5000000 + (RAND() * 1000000) AS MONEY)

		DECLARE @TotalRows2 INT
		SELECT @TotalRows2 = COUNT(*) FROM NhanVien
		SET @NewIDtable
		='NV000'+RIGHT('000'+CAST(@TotalRows2 + 2 AS VARCHAR), 3)
    
		INSERT INTO NhanVien(maNV, tenNV, SDT, Email,
									gioiTinh,DoB,Salary)
		VALUES (@NewIDtable, @tenValues2, @SDT2,
					@Email2, @gioiTinh2, @DoB2, @Salary2)
	END
	ELSE
	IF @TableName = N'SanPham'
	BEGIN
		-- Tạo dữ liệu ngẫu nhiên cho các tham số
		SET @RandomNumber
		= ABS(CHECKSUM(NEWID())) % 1000
		DECLARE @tenValues3 NVARCHAR(50)
		=N'Sản phẩm '+CAST(@RandomNumber AS NVARCHAR)
		DECLARE @donGiaBan3 MONEY
		=CAST(5000000+(RAND()*1000000) AS MONEY)
		DECLARE @soLuongHienCon3 INT
		= ROUND(RAND()*(1000 - 500)+500,0)
		DECLARE @soLuongCanDuoi3 INT = 5

		DECLARE @TotalRows3 INT
		SELECT @TotalRows3 = COUNT(*) FROM SanPham
		SET @NewIDtable 
		='SP000'+RIGHT('000'+CAST(@TotalRows3+2 AS VARCHAR),3)
    
		INSERT INTO SanPham(maSP,tenSP,donGiaBan,
						soLuongHienCon,soLuongCanDuoi)
		VALUES (@NewIDtable, @tenValues3, @donGiaBan3,
						@soLuongHienCon3, @soLuongCanDuoi3)
	END
END


Go
/*
Execute pr_TaoDongMoi KhachHang
Execute pr_TaoDongMoi NhanVien
Execute pr_TaoDongMoi QuanHuyen
Execute pr_TaoDongMoi QuocGia
Execute pr_TaoDongMoi TinhThanh
Execute pr_TaoDongMoi PhuongXa
Execute pr_TaoDongMoi SanPham
Execute pr_TaoDongMoi DonDatHang_HoaDon
Execute pr_TaoDongMoi ChiTietDonHang
Execute pr_TaoDongMoi ChiTietPhieuNhap
Execute pr_TaoDongMoi PhieuNhap
Go
select * from QuocGia
select * from KhachHang
select * from NhanVien
select * from SanPham
select * from PhieuNhap
*/
Go
--Theo function
/*
	Câu 6: Thống kê các sản phẩm bán chạy
		(có tham số vào là số các sản phẩm cần thống kê)
*/
--drop PROCEDURE pr_ThongKeSanPhamBanChay
CREATE PROCEDURE pr_ThongKeSanPhamBanChay
    @soLuong INT 
AS 
BEGIN
    SELECT TOP (@soLuong) 
        sp.maSP, 
        sp.tenSP, 
        SUM(ch.soLuongDat) AS soLuongBan 
    FROM SanPham sp
    JOIN ChiTietPhieuNhap pn ON sp.maSP = pn.maSP
    JOIN ChiTietDonHang ch ON sp.maSP = ch.maSP
    JOIN DonDatHang_HoaDon dh ON ch.maDH = dh.maDH
    WHERE ch.soLuongDat > pn.soLuongNhap/2
    GROUP BY sp.maSP, sp.tenSP
    ORDER BY soLuongBan DESC;
END;
Go
update ChiTietDonHang
set soLuongDat = case
	When soLuongDat > 1 AND soLuongDat <=5
		then soLuongDat + 600
	When soLuongDat > 5 AND soLuongDat <=10
		then soLuongDat + 300
	else
		soLuongDat + 200
End
Go
execute pr_ThongKeSanPhamBanChay 1
execute pr_ThongKeSanPhamBanChay 5
execute pr_ThongKeSanPhamBanChay 13
GO
/*
	Câu 7: Thống kê những tháng có doanh thu trên một giá trị 
		định mức nào đó(định mức là tham số vào)
*/
--drop function ft_TinhDoanhThuLonHonDinhMuc
create function ft_TinhDoanhThuLonHonDinhMuc
		(@Dinhmuc MONEY)
RETURNS TABLE
AS
RETURN 
(
    SELECT
        MONTH(dh.ngayTaoHoaDon) AS Thang,
        YEAR(dh.ngayTaoHoaDon) AS Nam,
        FORMAT(SUM(ch.donGia*ch.soLuongDat), 'C0', 'vi-VN') AS DoanhThu
    FROM DonDatHang_HoaDon dh, ChiTietDonHang ch
	Where dh.maDH = ch.maDH
    AND dh.trangThaiDonHang = N'Thành Công'
    GROUP BY MONTH(dh.ngayTaoHoaDon), YEAR(dh.ngayTaoHoaDon)
    HAVING SUM(ch.donGia) > @Dinhmuc
);

Go
SELECT Thang, Nam, DoanhThu
FROM ft_TinhDoanhThuLonHonDinhMuc(1000000)
ORDER BY Thang, Nam;
Go
/*
	Câu 8: Thống kê giá trung bình, giá max, giá min
		ở các phiếu nhập hàng cho mỗi sản phẩm
*/
--drop procedure pr_ThongKeAvgMaxMin
create procedure pr_ThongKeAvgMaxMin
	@maSP char(8)
as
Begin
	Select s.maSP,
	    FORMAT(MAX(cn.giaNhap), 'C0', 'vi-VN') as N'Giá nhập cao nhất',
		FORMAT(MIN(cn.giaNhap), 'C0', 'vi-VN') as N'Giá nhập thấp nhất',
		FORMAT(AVG(cn.giaNhap), 'C0', 'vi-VN') as N'Giá nhập trung bình'
	From SanPham s, PhieuNhap pn, ChiTietPhieuNhap cn
	Where s.maSP = cn.maSP
	AND cn.maPN = pn.maPN
	AND s.maSP = @maSP
	Group by s.maSP
End
Go
execute pr_ThongKeAvgMaxMin 'SP000001'
execute pr_ThongKeAvgMaxMin 'SP000014'
execute pr_ThongKeAvgMaxMin 'SP000019'
Go
/*
	Câu 9: Thống kê số lần khách hàng mua hàng (sắp xếp giảm dần)
*/
create procedure pr_ThongKeSoLanMuaHang
AS
BEGIN
    SELECT k.tenKH AS N'Tên khách hàng',
           COUNT(dh.maDH) AS N'Số lần mua hàng'
    FROM KhachHang k, DonDatHang_HoaDon dh
    WHERE k.maKH = dh.maKH
	AND dh.trangThaiDonHang = N'Thành Công'
    GROUP BY k.tenKH
    ORDER BY COUNT(dh.maDH) DESC;
END
Go
execute pr_ThongKeSoLanMuaHang
Go
/*
	Câu 10: Thống kê số lượng khách mua hàng theo từng tỉnh/thành phố
		(sắp xếp giảm dần theo số lượng, tăng dần theo mã khách hàng)
*/
--drop procedure pr_ThongKeKHTheoTinhThanh
create procedure pr_ThongKeKHTheoTinhThanh
AS
BEGIN
    SELECT t.tenTinhthanh AS N'Tỉnh/Thành phố',
			kh.maKH,
			COUNT(kh.maKH) AS N'Số lượng khách mua hàng'
    FROM KhachHang kh, DonDatHang_HoaDon dh,
		PhuongXa p, QuanHuyen q, TinhThanh t
	Where kh.maKH = dh.maKH
	--AND kh.diaChiKHNo = p.maPhuongXa
	AND dh.diaChiGiaoHangNo = p.maPhuongXa
	AND p.QuanHuyen_No = q.maQuanHuyen
	AND q.TinhThanh_No = t.maTinhThanh
    GROUP BY t.tenTinhthanh, kh.maKH
    ORDER BY COUNT(kh.maKH) DESC, kh.maKH ASC;
END
Go
execute pr_ThongKeKHTheoTinhThanh
Go
/*
	câu 11: viết hàm tính tổng tiền khi biết mã đơn hàng
*/

create function ft_TinhTongTien(@maDH CHAR(8))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @tongTien MONEY;

    SELECT @tongTien = SUM(soLuongDat * donGia)
    FROM ChiTietDonHang
    WHERE maDH = @maDH;

    RETURN FORMAT(ISNULL(@tongTien, 0), 'C', 'vi-VN');
END;

Go
SELECT dbo.ft_TinhTongTien('DH000010') AS TongTien
SELECT dbo.ft_TinhTongTien('DH000011') AS TongTien
SELECT dbo.ft_TinhTongTien('DH000012') AS TongTien
Go

/*
	câu 12: viết hàm tính thành tiền biết đơn giá, số lượng
*/

--drop function ft_TinhThanhTien
create function ft_TinhThanhTien
	(@donGia MONEY, @soLuong INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @thanhTien MONEY;
    SET @thanhTien = @donGia * @soLuong;
    RETURN FORMAT(ISNULL(@thanhTien, 0), 'C', 'vi-VN');
END;
go
SELECT dbo.ft_TinhThanhTien(100000, 51) AS ThanhTien
SELECT dbo.ft_TinhThanhTien(250000, 15) AS ThanhTien
SELECT dbo.ft_TinhThanhTien(300000, 23) AS ThanhTien

--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--Tuần 14--
/*
	Câu 1: Hãy cập nhật cột đơn giá ở bảng ChiTietDonHang sau sự kiện insert
			+ soLuongHienCon ở bảng SanPham (update/delete)
	Lưu ý: Lưu ý kiểm tra soLuongDat > soLuongHienCon hay không?
*/

--drop trigger tg_Inserted
Go
create trigger trg_ChiTietDonHang
On ChiTietDonHang
after insert, update, delete
as
BEGIN
	if not exists(select * from deleted) -- sau khi insrert dòng mới
	begin
		if exists(Select * 
				from SanPham s, inserted i
				Where s.maSP = i.maSP
				AND s.soLuongHienCon < i.soLuongDat)
		begin
			DECLARE @thongBao NVARCHAR(MAX);
    
			SELECT @thongBao = STRING_AGG(CONCAT(s.maSP, N' (Hiện có: ', s.soLuongHienCon, N', Đặt: ', i.soLuongDat, ')'), ', ')
			FROM SanPham s
			JOIN inserted i ON s.maSP = i.maSP
			WHERE s.soLuongHienCon < i.soLuongDat;

			PRINT N'Số lượng hiện còn không đủ cho các sản phẩm: ' + @thongBao;
			ROLLBACK;
		end
		else
		begin
			update SanPham
			set soLuongHienCon = soLuongHienCon - ch.soLuongDat
			from inserted i, ChiTietDonHang ch
			Where i.maSP = SanPham.maSP
			AND i.maDH = ch.maDH
			AND ch.maSP = SanPham.maSP
			AND SanPham.maSP in (Select maSP from inserted)
			--Cập nhật giá
			update ChiTietDonHang
			set donGia = donGiaBan
			from inserted i, SanPham s
			Where i.maSP = s.maSP
			AND i.maDH = ChiTietDonHang.maDH
			AND ChiTietDonHang.maSP = s.maSP
			AND s.maSP in (Select maSP from ChiTietDonHang)

			if exists(Select * 
						from SanPham s, inserted i 
						Where i.maSP = s.maSP 
						AND soLuongHienCon <= soLuongCanDuoi)
			begin
			DECLARE @maSP1 NVARCHAR(MAX);

			SELECT @maSP1 = STRING_AGG(s.maSP, ', ')
			FROM SanPham s
			JOIN inserted i ON i.maSP = s.maSP
			WHERE s.soLuongHienCon <= s.soLuongCanDuoi;

			PRINT N'Cần nhập thêm hàng cho: ' + @maSP1;
			end
		end
	end
	else if not exists(select * from inserted) -- Sau khi xóa 
	begin
		update SanPham
		set soLuongHienCon = soLuongHienCon + d.soLuongDat
		from deleted d
		Where d.maSP = SanPham.maSP
		AND SanPham.maSP in (Select maSP from deleted)

	end
	else -- Sau Cập nhật
	begin
		if exists(Select * 
			from SanPham s, inserted i, deleted d
			Where s.maSP = i.maSP
			AND d.maSP = s.maSP
			AND (s.soLuongHienCon + d.soLuongDat) < i.soLuongDat)
		begin
			DECLARE @thongBao2 NVARCHAR(MAX);
    
			SELECT @thongBao2 = STRING_AGG(CONCAT(s.maSP, N' (Hiện có: ', s.soLuongHienCon, N', Đặt: ', i.soLuongDat, ')'), ', ')
			FROM SanPham s
			JOIN inserted i ON s.maSP = i.maSP
			WHERE s.soLuongHienCon < i.soLuongDat;

			PRINT N'Số lượng hiện còn không đủ cho các sản phẩm: ' + @thongBao2;
			ROLLBACK;
		end
		else
		begin
			update SanPham
			set soLuongHienCon = soLuongHienCon + d.soLuongDat - i.soLuongDat
			from inserted i, ChiTietDonHang ch, deleted d
			Where i.maSP = SanPham.maSP
			AND i.maDH = ch.maDH
			AND ch.maSP = SanPham.maSP
			AND d.maSP = ch.maSP
			AND d.maDH = ch.maDH
			AND SanPham.maSP in (Select maSP from inserted)
			AND SanPham.maSP in (Select maSP from deleted)

			if exists(Select * 
						from SanPham s, inserted i 
						Where i.maSP = s.maSP 
						AND soLuongHienCon <= soLuongCanDuoi)
			begin
				DECLARE @maSP2 NVARCHAR(MAX);

				SELECT @maSP2 = STRING_AGG(s.maSP, ', ')
				FROM SanPham s
				JOIN inserted i ON i.maSP = s.maSP
				WHERE s.soLuongHienCon <= s.soLuongCanDuoi;

				PRINT N'Cần nhập thêm hàng cho: ' + @maSP2;
			end
		end
	end
END
/*
select * from SanPham
insert into ChiTietDonHang
values
	('DH000018','SP000007', 100000, NULL),
	('DH000018','SP000008', 100000, NULL);
Go
insert into ChiTietDonHang
values
	('DH000018','SP000007', 100, NULL),
	('DH000018','SP000008', 100, NULL);
Go
insert into ChiTietDonHang
values
	('DH000018','SP000007', 50768, NULL),
	('DH000018','SP000008', 45768, NULL);

Update ChiTietDonHang
Set soLuongDat = 1500
where maDH = 'DH000018'
AND maSP = 'SP000007' OR maSP = 'SP000008';

Update ChiTietDonHang
Set soLuongDat = 457680
where maDH = 'DH000018'
AND maSP = 'SP000007' OR maSP = 'SP000008';

Update ChiTietDonHang
Set soLuongDat = 45768
where maDH = 'DH000018'
AND maSP = 'SP000007' OR maSP = 'SP000008';

Delete ChiTietDonHang
where maDH = 'DH000018'
AND maSP = 'SP000007' OR maSP = 'SP000008';

select * from SanPham
select * from ChiTietDonHang
*/
Go
-- drop trigger trg_Nhaphang
create trigger trg_Nhaphang
On ChiTietPhieuNhap
after insert, update, delete
AS
BEGIN
	if not exists (select * from deleted) -- Sau khi insert
	begin
		-- Cập nhật số lượng hiện có và giá cao nhất cho sản phẩm
		UPDATE s
		SET 
            s.soLuongHienCon = s.soLuongHienCon + (
                SELECT SUM(i.soLuongNhap)
                FROM inserted i
                WHERE i.maSP = s.maSP
            ),
			s.donGiaBan = (
				SELECT MAX(c.giaNhap)
				FROM ChiTietPhieuNhap c
				WHERE c.maSP = i.maSP
			) * 1.5
		FROM SanPham s
		JOIN inserted i ON s.maSP = i.maSP;
	end
	Else
	if not exists (select * from inserted) -- Sau khi xóa
	begin
        UPDATE s
        SET 
            s.soLuongHienCon = s.soLuongHienCon - (
                SELECT SUM(d.soLuongNhap)
                FROM deleted d
                WHERE d.maSP = s.maSP
            ),
            s.donGiaBan = (
                SELECT MIN(c.giaNhap)
                FROM ChiTietPhieuNhap c
                WHERE c.maSP = d.maSP
            ) * 1.5
        FROM SanPham s
        JOIN deleted d ON s.maSP = d.maSP;
	end
	else -- Sau khi cập nhật
	Begin
        UPDATE s
        SET 
            s.soLuongHienCon = s.soLuongHienCon + (
                SELECT SUM(i.soLuongNhap)
                FROM inserted i
                WHERE i.maSP = s.maSP
            ) - (
                SELECT SUM(d.soLuongNhap)
                FROM deleted d
                WHERE d.maSP = s.maSP
            ),
            s.donGiaBan = (
                SELECT MAX(c.giaNhap)
                FROM ChiTietPhieuNhap c
                WHERE c.maSP = s.maSP
            ) * 1.5
        FROM SanPham s
        WHERE EXISTS (
            SELECT 1
            FROM inserted i
            WHERE i.maSP = s.maSP
        );
	End
END

/*
Insert ChiTietPhieuNhap
Values
	('PN00017', 'SP000018', 777, 500000),
	('PN00017', 'SP000019', 888, 800000),
	('PN00018', 'SP000018', 999, 1200000),
	('PN00018', 'SP000019', 666, 1400000)

Update ChiTietPhieuNhap
Set soLuongNhap = 50000
where maPN = 'PN00018'
AND maSP = 'SP000018'
Update ChiTietPhieuNhap
Set soLuongNhap = 50000
where maPN = 'PN00018'
AND maSP = 'SP000019'

Update ChiTietPhieuNhap
Set soLuongNhap = 50000
where (maPN = 'PN00017' OR maPN = 'PN00018')
AND (maSP = 'SP000018' OR maSP = 'SP000019')

DELETE ChiTietPhieuNhap
WHERE maPN = 'PN00017' 
  AND (maSP = 'SP000018' OR maSP = 'SP000019');
DELETE ChiTietPhieuNhap
WHERE maPN = 'PN00018' 
  AND (maSP = 'SP000018' OR maSP = 'SP000019');

Select * from SanPham
Select * from ChiTietPhieuNhap
*/
