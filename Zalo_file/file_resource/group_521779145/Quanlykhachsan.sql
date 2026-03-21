--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'quanlykhachsan')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''quanlykhachsan'' 
    BEGIN
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;
    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE quanlykhachsan;
END

go
--tạo database tên "QLBH" - Quản lý bán hàng
create database quanlykhachsan;

go
--Sử dụng database "QLBH" -- Quản lý bán hàng
USE quanlykhachsan;

GO
-- Bảng Role (Phân quyền)
CREATE TABLE VaiTro
(
    maVaiTro CHAR(5) PRIMARY KEY,
    tenVaiTro NVARCHAR(50) NOT NULL,
    moTa NVARCHAR(255)
);

GO
-- Bảng User (Người dùng)
CREATE TABLE NguoiDung
(
    maNguoiDung CHAR(5) PRIMARY KEY,
    tenNguoiDung NVARCHAR(100) NOT NULL,
	ngaySinh varchar(15) not null CHECK (ngaySinh LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'),
    SDT VARCHAR(10) UNIQUE CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    email NVARCHAR(100) UNIQUE CHECK (email LIKE '%@gmail.com'),
    matKhau NVARCHAR(255) NOT NULL,
	soDuTaiKhoan decimal(20,2) default 0,
    maVaiTro CHAR(5),
    FOREIGN KEY (maVaiTro) REFERENCES VaiTro(maVaiTro)
);

Go
-- Bảng Cơ sở khách sạn
CREATE TABLE ChiNhanhKhachSan
(
    maChiNhanh CHAR(5) PRIMARY KEY,
    tenChiNhanh NVARCHAR(100) NOT NULL,
    diaChi NVARCHAR(255) NULL,
    SDT VARCHAR(10) UNIQUE CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

Go
-- Bảng Loại phòng
CREATE TABLE LoaiPhong
(
    maLoaiPhong CHAR(5) PRIMARY KEY,
    tenLoaiPhong NVARCHAR(50) NOT NULL,
	soLuongToiDa int,
    moTa NVARCHAR(255),
    giaPhong DECIMAL(15,2)
);

Go
-- Bảng Phòng
CREATE TABLE Phong
(
    maPhong CHAR(5) PRIMARY KEY,
    soPhong VARCHAR(10) NOT NULL,
    maLoaiPhong CHAR(5),
    soTang INT NOT NULL,
    maChiNhanh CHAR(5),
    trangThai NVARCHAR(20) CHECK (trangThai IN ('Trống', 'Có người ở', 'Đã đặt trước', 'Bảo trì')) NOT NULL,
    FOREIGN KEY (maLoaiPhong) REFERENCES LoaiPhong(maLoaiPhong),
    FOREIGN KEY (maChiNhanh) REFERENCES ChiNhanhKhachSan(maChiNhanh)
);

Go
--Bảng Loại Dịch Vụ
CREATE TABLE LoaiDichVu
(
	maLoaiDichVu char(5) PRIMARY KEY,
	tenLoaiDichVu NVARCHAR(255) not null,
	giaDichVu decimal(15,2),
	moTa NVARCHAR(255)
);

Go
--Bảng dịch vụ
CREATE TABLE DichVu
(
	maDichVu char(5) PRIMARY KEY,
	tenDichVu NVARCHAR(255) not null,
	maLoaiDichVu char(5),
	FOREIGN KEY (maLoaiDichVu) REFERENCES LoaiDichVu(maLoaiDichVu)
);

Go
-- Bảng Đặt phòng
CREATE TABLE DatPhong
(
    maDatPhong CHAR(5) PRIMARY KEY,
    maNguoiDung CHAR(5),
    maPhong CHAR(5),
	soNguoi int,
    dichVuSuDung CHAR(5),
    ngayThuePhong varchar(15) NOT NULL CHECK (ngayThuePhong LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'),
    ngayTraPhong varchar(15) NOT NULL CHECK (ngayTraPhong LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'),
    trangThai NVARCHAR(20) CHECK (trangThai IN ('Đã đặt', 'Hoàn thành', 'Hủy')) NOT NULL,
	--check (check_in_date >= getdate()),
	--check (check_out_date <= getdate()),
	check (ngayThuePhong < ngayTraPhong),
    FOREIGN KEY (maNguoiDung) REFERENCES NguoiDung(maNguoiDung),
    FOREIGN KEY (maPhong) REFERENCES Phong(maPhong),
    FOREIGN KEY (dichVuSuDung) REFERENCES DichVu(maDichVu)
);

Go
-- Bảng Hóa đơn
CREATE TABLE HoaDon
(
    maHoaDon CHAR(5) PRIMARY KEY,
    maDatPhong CHAR(5),
    maDichVu CHAR(5),
	nhanVienPhuTrach CHAR(5),
    tongTien DECIMAL(15,2) NOT NULL,
    ngayGiaoDich DATETIME NOT NULL DEFAULT GETDATE(),
    phuongThucThanhToan NVARCHAR(20) CHECK (phuongThucThanhToan IN ('Ví điện tử', 'Tiền mặt', 'Thẻ')) NOT NULL,
    FOREIGN KEY (maDatPhong) REFERENCES DatPhong(maDatPhong),
	FOREIGN KEY (nhanVienPhuTrach) REFERENCES NguoiDung(maNguoiDung),
);
go
insert into VaiTro
values
	('R001',N'Khách hàng', 'Thượng đế tới'),
	('R002',N'Nhân Viên', 'Nô Lệ đồng tiên'),
	('R003',N'Quản lý', 'Mini Boss');

go
insert into NguoiDung
values
	('KH001', N'Khanh', '05/04/2005', '0123456789','a@gmail.com'  ,'khanh123',0,'R003'),
	('KH002', N'Hoang', '05/04/2004', '0123888789','abc@gmail.com','hoang123',0,'R002'),
	('KH003', N'Nom'  , '05/04/2006', '0123456975','ada@gmail.com','Nom123'  ,0,'R001');
go
insert into LoaiDichVu
values
	('LDV01', N'Không', 0, N'Không sử dụng dịch vụ');
go
insert into DichVu
values
	('DV001', N'Bỏ qua', 'LDV01');
