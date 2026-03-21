/*
-- =============================================
-- Ten du an: WEBPC_API
-- Mo ta: Tao cau truc bang cho CSDL SQL Server
-- Tac gia: Gemini
-- Ngay tao: 29/10/2025
-- Ghi chu: Thiet ke dua tren tai lieu tham khao ve quan ly ban linh kien may tinh.
-- =============================================
*/

--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'QLBANLINHKIENPC')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''QLBANLINHKIENPC'' 
    BEGIN
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE QLBANLINHKIENPC;
END
go
--tạo database tên "QLBH" - Quản lý bán hàng
create database QLBANLINHKIENPC;
go
--Sử dụng database "QLBH" -- Quản lý bán hàng
USE QLBANLINHKIENPC;



-- 1. VaiTro (Roles)
CREATE TABLE VaiTro (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tenVaiTro NVARCHAR(50) NOT NULL UNIQUE
);

-- 2. NguoiDung (Users)
CREATE TABLE NguoiDung (
    id NVARCHAR(450) PRIMARY KEY DEFAULT NEWID(),
    idVaiTro INT NOT NULL,
    hoTen NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    matKhau NVARCHAR(255) NOT NULL, -- Se luu hash
    soDienThoai VARCHAR(15) UNIQUE,
    ngayTao DATETIME DEFAULT GETDATE(),
    emailConfirmed BIT DEFAULT 0,
    CONSTRAINT FK_NguoiDung_VaiTro FOREIGN KEY (idVaiTro) REFERENCES VaiTro(id)
);

-- 3. DanhMuc (Categories)
CREATE TABLE DanhMuc (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tenDanhMuc NVARCHAR(100) NOT NULL,
    idCha INT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT FK_DanhMuc_Cha FOREIGN KEY (idCha) REFERENCES DanhMuc(id)
);

-- 4. NhaCungCap (Suppliers)
CREATE TABLE NhaCungCap (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tenNhaCungCap NVARCHAR(255) NOT NULL,
    diaChi NVARCHAR(500),
    soDienThoai VARCHAR(15),
    email NVARCHAR(100)
);

-- 5. SanPham (Products)
CREATE TABLE SanPham (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idDanhMuc INT NOT NULL,
    idNhaCungCap INT NOT NULL,
    tenSanPham NVARCHAR(500) NOT NULL,
    moTaNgan NVARCHAR(1000),
    moTaChiTiet NTEXT,
    giaBan DECIMAL(18, 2) NOT NULL CHECK (giaBan >= 0),
    giaNhap DECIMAL(18, 2) NOT NULL CHECK (giaNhap >= 0),
    hinhAnh VARCHAR(500),
    danhSachAnh NTEXT, -- Luu dang JSON ['url1', 'url2']
    thoiGianBaoHanh INT DEFAULT 12, -- Tinh bang thang
    slug VARCHAR(500) NOT NULL UNIQUE,
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (idDanhMuc) REFERENCES DanhMuc(id),
    CONSTRAINT FK_SanPham_NhaCungCap FOREIGN KEY (idNhaCungCap) REFERENCES NhaCungCap(id)
);

-- 6. Kho (Warehouse/Stock)
CREATE TABLE Kho (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idSanPham INT NOT NULL UNIQUE,
    soLuongTon INT NOT NULL DEFAULT 0 CHECK (soLuongTon >= 0),
    CONSTRAINT FK_Kho_SanPham FOREIGN KEY (idSanPham) REFERENCES SanPham(id) ON DELETE CASCADE
);

-- 7. GioHang (Carts)
CREATE TABLE GioHang (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idNguoiDung NVARCHAR(450) NOT NULL UNIQUE,
    tongTien DECIMAL(18, 2) DEFAULT 0,
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_GioHang_NguoiDung FOREIGN KEY (idNguoiDung) REFERENCES NguoiDung(id) ON DELETE CASCADE
);

-- 8. GioHangChiTiet (Cart Details)
CREATE TABLE GioHangChiTiet (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idGioHang INT NOT NULL,
    idSanPham INT NOT NULL,
    soLuong INT NOT NULL CHECK (soLuong > 0),
    donGia DECIMAL(18, 2) NOT NULL, -- Gia tai thoi diem them vao gio
    CONSTRAINT FK_GioHangChiTiet_GioHang FOREIGN KEY (idGioHang) REFERENCES GioHang(id) ON DELETE CASCADE,
    CONSTRAINT FK_GioHangChiTiet_SanPham FOREIGN KEY (idSanPham) REFERENCES SanPham(id)
);

-- 9. DiaChi (Addresses)
CREATE TABLE DiaChi (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idNguoiDung NVARCHAR(450) NOT NULL,
    diaChiChiTiet NVARCHAR(500) NOT NULL,
    phuongXa NVARCHAR(100) NOT NULL,
    quanHuyen NVARCHAR(100) NOT NULL,
    tinhThanh NVARCHAR(100) NOT NULL DEFAULT N'Đà Nẵng',
    soDienThoaiNhan VARCHAR(15) NOT NULL,
    tenNguoiNhan NVARCHAR(100) NOT NULL,
    laMacDinh BIT DEFAULT 0,
    kinhDo FLOAT NULL,
    viDo FLOAT NULL,
    CONSTRAINT FK_DiaChi_NguoiDung FOREIGN KEY (idNguoiDung) REFERENCES NguoiDung(id)
);

-- 10. ThanhToan (Payment Methods)
CREATE TABLE ThanhToan (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tenPhuongThuc NVARCHAR(100) NOT NULL,
    maPhuongThuc VARCHAR(50) NOT NULL UNIQUE,
    hinhAnh VARCHAR(500)
);

-- 11. KhuyenMai (Promotions)
CREATE TABLE KhuyenMai (
    id INT IDENTITY(1,1) PRIMARY KEY,
    maGiamGia VARCHAR(50) NOT NULL UNIQUE,
    tenKhuyenMai NVARCHAR(255) NOT NULL,
    phanTramGiam INT DEFAULT 0 CHECK (phanTramGiam >= 0 AND phanTramGiam <= 100),
    soTienGiamToiDa DECIMAL(18, 2) DEFAULT 0,
    dieuKienDonHangToiThieu DECIMAL(18, 2) DEFAULT 0,
    ngayBatDau DATETIME NOT NULL,
    ngayKetThuc DATETIME NOT NULL,
    soLuong INT NOT NULL CHECK (soLuong > 0),
    daSuDung INT DEFAULT 0
);

-- 12. HoaDon (Orders)
CREATE TABLE HoaDon (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idNguoiDung NVARCHAR(450) NOT NULL,
    idDiaChi INT NOT NULL,
    idThanhToan INT NOT NULL,
    idKhuyenMai INT NULL,
    tongTienGoc DECIMAL(18, 2) NOT NULL,
    soTienGiam DECIMAL(18, 2) DEFAULT 0,
    tongTienCuoiCung DECIMAL(18, 2) NOT NULL,
    trangThai NVARCHAR(50) NOT NULL DEFAULT N'Chờ thanh toán',
    ghiChu NVARCHAR(500),
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_HoaDon_NguoiDung FOREIGN KEY (idNguoiDung) REFERENCES NguoiDung(id),
    CONSTRAINT FK_HoaDon_DiaChi FOREIGN KEY (idDiaChi) REFERENCES DiaChi(id),
    CONSTRAINT FK_HoaDon_ThanhToan FOREIGN KEY (idThanhToan) REFERENCES ThanhToan(id),
    CONSTRAINT FK_HoaDon_KhuyenMai FOREIGN KEY (idKhuyenMai) REFERENCES KhuyenMai(id)
);

-- 13. HoaDonChiTiet (Order Details)
CREATE TABLE HoaDonChiTiet (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idHoaDon INT NOT NULL,
    idSanPham INT NOT NULL,
    soLuong INT NOT NULL CHECK (soLuong > 0),
    donGia DECIMAL(18, 2) NOT NULL, -- Gia tai thoi diem chot don
    CONSTRAINT FK_HoaDonChiTiet_HoaDon FOREIGN KEY (idHoaDon) REFERENCES HoaDon(id) ON DELETE CASCADE,
    CONSTRAINT FK_HoaDonChiTiet_SanPham FOREIGN KEY (idSanPham) REFERENCES SanPham(id)
);

-- 14. OTP_Log (OTP Logs)
CREATE TABLE OTP_Log (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idNguoiDung NVARCHAR(450) NOT NULL,
    maOTP VARCHAR(10) NOT NULL,
    thoiGianTao DATETIME DEFAULT GETDATE(),
    thoiGianHetHan DATETIME NOT NULL,
    daSuDung BIT DEFAULT 0,
    loaiOTP NVARCHAR(50) NOT NULL, -- 'REGISTER', 'FORGOT_PASSWORD'
    CONSTRAINT FK_OTP_Log_NguoiDung FOREIGN KEY (idNguoiDung) REFERENCES NguoiDung(id)
);

-- 15. Payment_Log (Payment Logs)
CREATE TABLE Payment_Log (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idHoaDon INT NOT NULL,
    maGiaoDich NVARCHAR(100) NOT NULL,
    maDonHangDoiTac NVARCHAR(100) NOT NULL,
    soTien DECIMAL(18, 2) NOT NULL,
    noiDungThanhToan NVARCHAR(500),
    thoiGianGiaoDich DATETIME,
    trangThai NVARCHAR(50) NOT NULL, -- 'Success', 'Failed', 'Pending'
    maLoi VARCHAR(50) NULL,
    message NVARCHAR(500) NULL,
    CONSTRAINT FK_Payment_Log_HoaDon FOREIGN KEY (idHoaDon) REFERENCES HoaDon(id)
);

-- 16. LichSuGiaoHang (Shipping History)
CREATE TABLE LichSuGiaoHang (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idHoaDon INT NOT NULL,
    trangThai NVARCHAR(100) NOT NULL,
    thoiGian DATETIME DEFAULT GETDATE(),
    nguoiCapNhat NVARCHAR(450) NOT NULL, -- idNguoiDung (Staff/Admin)
    CONSTRAINT FK_LichSuGiaoHang_HoaDon FOREIGN KEY (idHoaDon) REFERENCES HoaDon(id),
    CONSTRAINT FK_LichSuGiaoHang_NguoiDung FOREIGN KEY (nguoiCapNhat) REFERENCES NguoiDung(id)
);

-- 17. PhieuNhap (Goods Receipt)
CREATE TABLE PhieuNhap (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idNhaCungCap INT NOT NULL,
    idNguoiTao NVARCHAR(450) NOT NULL,
    ngayNhap DATETIME DEFAULT GETDATE(),
    tongTien DECIMAL(18, 2) NOT NULL DEFAULT 0,
    ghiChu NVARCHAR(500),
    CONSTRAINT FK_PhieuNhap_NhaCungCap FOREIGN KEY (idNhaCungCap) REFERENCES NhaCungCap(id),
    CONSTRAINT FK_PhieuNhap_NguoiDung FOREIGN KEY (idNguoiTao) REFERENCES NguoiDung(id)
);

-- 18. ChiTietPhieuNhap (Goods Receipt Details)
CREATE TABLE ChiTietPhieuNhap (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idPhieuNhap INT NOT NULL,
    idSanPham INT NOT NULL,
    soLuongNhap INT NOT NULL CHECK (soLuongNhap > 0),
    donGiaNhap DECIMAL(18, 2) NOT NULL CHECK (donGiaNhap >= 0),
    CONSTRAINT FK_ChiTietPhieuNhap_PhieuNhap FOREIGN KEY (idPhieuNhap) REFERENCES PhieuNhap(id) ON DELETE CASCADE,
    CONSTRAINT FK_ChiTietPhieuNhap_SanPham FOREIGN KEY (idSanPham) REFERENCES SanPham(id)
);

-- 19. CauHinhMayTinh (PC Builds)
CREATE TABLE CauHinhMayTinh (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idNguoiDung NVARCHAR(450) NOT NULL,
    tenCauHinh NVARCHAR(100) NOT NULL,
    tongGia DECIMAL(18, 2) DEFAULT 0,
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CauHinhMayTinh_NguoiDung FOREIGN KEY (idNguoiDung) REFERENCES NguoiDung(id)
);

-- 20. ChiTietCauHinh (PC Build Details)
CREATE TABLE ChiTietCauHinh (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idCauHinh INT NOT NULL,
    idSanPham INT NOT NULL,
    idDanhMuc INT NOT NULL,
    soLuong INT DEFAULT 1,
    CONSTRAINT FK_ChiTietCauHinh_CauHinh FOREIGN KEY (idCauHinh) REFERENCES CauHinhMayTinh(id) ON DELETE CASCADE,
    CONSTRAINT FK_ChiTietCauHinh_SanPham FOREIGN KEY (idSanPham) REFERENCES SanPham(id),
    CONSTRAINT FK_ChiTietCauHinh_DanhMuc FOREIGN KEY (idDanhMuc) REFERENCES DanhMuc(id)
);
GO

-- Them du lieu co ban
INSERT INTO VaiTro (tenVaiTro) VALUES (N'Admin'), (N'Staff'), (N'User');
INSERT INTO ThanhToan (tenPhuongThuc, maPhuongThuc) VALUES (N'Thanh toán khi nhận hàng', 'COD'), (N'Thanh toán qua MoMo', 'MOMO');
GO

/*
-- =============================================
-- Ten du an: WEBPC_API
-- Mo ta: Tao Stored Procedures (CRUD) cho tat ca cac bang
-- Tac gia: Gemini
-- Ngay tao: 29/10/2025
-- =============================================
*/

-- 1. VaiTro
GO
CREATE PROCEDURE ps_LietKeVaiTro
AS
BEGIN
    SELECT * FROM VaiTro;
END
GO
CREATE PROCEDURE ps_ThemVaiTro
    @tenVaiTro NVARCHAR(50)
AS
BEGIN
    INSERT INTO VaiTro (tenVaiTro) VALUES (@tenVaiTro);
END
GO
CREATE PROCEDURE ps_SuaVaiTro
    @id INT,
    @tenVaiTro NVARCHAR(50)
AS
BEGIN
    UPDATE VaiTro SET tenVaiTro = @tenVaiTro WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaVaiTro
    @id INT
AS
BEGIN
    DELETE FROM VaiTro WHERE id = @id;
END
GO

-- 2. NguoiDung (Mau: Se khong them matKhau o day, logic hash se o API)
GO
CREATE PROCEDURE ps_LietKeNguoiDung
AS
BEGIN
    SELECT id, idVaiTro, hoTen, email, soDienThoai, ngayTao, emailConfirmed FROM NguoiDung;
END
GO
CREATE PROCEDURE ps_ThemNguoiDung
    @id NVARCHAR(450),
    @idVaiTro INT,
    @hoTen NVARCHAR(100),
    @email NVARCHAR(100),
    @matKhau NVARCHAR(255),
    @soDienThoai VARCHAR(15)
AS
BEGIN
    INSERT INTO NguoiDung (id, idVaiTro, hoTen, email, matKhau, soDienThoai)
    VALUES (@id, @idVaiTro, @hoTen, @email, @matKhau, @soDienThoai);
END
GO
CREATE PROCEDURE ps_SuaNguoiDung
    @id NVARCHAR(450),
    @idVaiTro INT,
    @hoTen NVARCHAR(100),
    @soDienThoai VARCHAR(15)
AS
BEGIN
    UPDATE NguoiDung
    SET idVaiTro = @idVaiTro, hoTen = @hoTen, soDienThoai = @soDienThoai
    WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaNguoiDung
    @id NVARCHAR(450)
AS
BEGIN
    -- Can than khi xoa nguoi dung, co the set trang thai 'IsDeleted' thay vi xoa cung
    DELETE FROM NguoiDung WHERE id = @id;
END
GO

-- 3. DanhMuc
GO
CREATE PROCEDURE ps_LietKeDanhMuc
AS
BEGIN
    SELECT * FROM DanhMuc;
END
GO
CREATE PROCEDURE ps_ThemDanhMuc
    @tenDanhMuc NVARCHAR(100),
    @idCha INT,
    @slug VARCHAR(100)
AS
BEGIN
    INSERT INTO DanhMuc (tenDanhMuc, idCha, slug) VALUES (@tenDanhMuc, @idCha, @slug);
END
GO
CREATE PROCEDURE ps_SuaDanhMuc
    @id INT,
    @tenDanhMuc NVARCHAR(100),
    @idCha INT,
    @slug VARCHAR(100)
AS
BEGIN
    UPDATE DanhMuc SET tenDanhMuc = @tenDanhMuc, idCha = @idCha, slug = @slug WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaDanhMuc
    @id INT
AS
BEGIN
    -- Can kiem tra rang buoc khoa ngoai truoc khi xoa
    DELETE FROM DanhMuc WHERE id = @id;
END
GO

-- 4. NhaCungCap
GO
CREATE PROCEDURE ps_LietKeNhaCungCap
AS
BEGIN
    SELECT * FROM NhaCungCap;
END
GO
CREATE PROCEDURE ps_ThemNhaCungCap
    @tenNhaCungCap NVARCHAR(255),
    @diaChi NVARCHAR(500),
    @soDienThoai VARCHAR(15),
    @email NVARCHAR(100)
AS
BEGIN
    INSERT INTO NhaCungCap (tenNhaCungCap, diaChi, soDienThoai, email)
    VALUES (@tenNhaCungCap, @diaChi, @soDienThoai, @email);
END
GO
CREATE PROCEDURE ps_SuaNhaCungCap
    @id INT,
    @tenNhaCungCap NVARCHAR(255),
    @diaChi NVARCHAR(500),
    @soDienThoai VARCHAR(15),
    @email NVARCHAR(100)
AS
BEGIN
    UPDATE NhaCungCap
    SET tenNhaCungCap = @tenNhaCungCap, diaChi = @diaChi, soDienThoai = @soDienThoai, email = @email
    WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaNhaCungCap
    @id INT
AS
BEGIN
    DELETE FROM NhaCungCap WHERE id = @id;
END
GO

-- 5. SanPham
GO
CREATE PROCEDURE ps_LietKeSanPham
AS
BEGIN
    SELECT * FROM SanPham;
END
GO
CREATE PROCEDURE ps_ThemSanPham
    @idDanhMuc INT,
    @idNhaCungCap INT,
    @tenSanPham NVARCHAR(500),
    @moTaNgan NVARCHAR(1000),
    @moTaChiTiet NTEXT,
    @giaBan DECIMAL(18, 2),
    @giaNhap DECIMAL(18, 2),
    @hinhAnh VARCHAR(500),
    @danhSachAnh NTEXT,
    @thoiGianBaoHanh INT,
    @slug VARCHAR(500)
AS
BEGIN
    INSERT INTO SanPham (idDanhMuc, idNhaCungCap, tenSanPham, moTaNgan, moTaChiTiet, giaBan, giaNhap, hinhAnh, danhSachAnh, thoiGianBaoHanh, slug)
    VALUES (@idDanhMuc, @idNhaCungCap, @tenSanPham, @moTaNgan, @moTaChiTiet, @giaBan, @giaNhap, @hinhAnh, @danhSachAnh, @thoiGianBaoHanh, @slug);
END
GO
CREATE PROCEDURE ps_SuaSanPham
    @id INT,
    @idDanhMuc INT,
    @idNhaCungCap INT,
    @tenSanPham NVARCHAR(500),
    @moTaNgan NVARCHAR(1000),
    @moTaChiTiet NTEXT,
    @giaBan DECIMAL(18, 2),
    @giaNhap DECIMAL(18, 2),
    @hinhAnh VARCHAR(500),
    @danhSachAnh NTEXT,
    @thoiGianBaoHanh INT,
    @slug VARCHAR(500)
AS
BEGIN
    UPDATE SanPham
    SET idDanhMuc = @idDanhMuc, idNhaCungCap = @idNhaCungCap, tenSanPham = @tenSanPham, moTaNgan = @moTaNgan, moTaChiTiet = @moTaChiTiet,
        giaBan = @giaBan, giaNhap = @giaNhap, hinhAnh = @hinhAnh, danhSachAnh = @danhSachAnh, thoiGianBaoHanh = @thoiGianBaoHanh, slug = @slug
    WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaSanPham
    @id INT
AS
BEGIN
    DELETE FROM SanPham WHERE id = @id;
END
GO

-- 6. Kho
GO
CREATE PROCEDURE ps_LietKeKho
AS
BEGIN
    SELECT K.*, S.tenSanPham FROM Kho K JOIN SanPham S ON K.idSanPham = S.id;
END
GO
CREATE PROCEDURE ps_ThemKho
    @idSanPham INT,
    @soLuongTon INT
AS
BEGIN
    INSERT INTO Kho (idSanPham, soLuongTon) VALUES (@idSanPham, @soLuongTon);
END
GO
CREATE PROCEDURE ps_SuaKho
    @id INT,
    @idSanPham INT,
    @soLuongTon INT
AS
BEGIN
    UPDATE Kho SET idSanPham = @idSanPham, soLuongTon = @soLuongTon WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaKho
    @id INT
AS
BEGIN
    DELETE FROM Kho WHERE id = @id;
END
GO

-- 7. GioHang
GO
CREATE PROCEDURE ps_LietKeGioHang
AS
BEGIN
    SELECT * FROM GioHang;
END
GO
CREATE PROCEDURE ps_ThemGioHang
    @idNguoiDung NVARCHAR(450)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM GioHang WHERE idNguoiDung = @idNguoiDung)
    BEGIN
        INSERT INTO GioHang (idNguoiDung) VALUES (@idNguoiDung);
    END
END
GO
CREATE PROCEDURE ps_SuaGioHang
    @id INT,
    @idNguoiDung NVARCHAR(450),
    @tongTien DECIMAL(18, 2)
AS
BEGIN
    UPDATE GioHang SET idNguoiDung = @idNguoiDung, tongTien = @tongTien WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaGioHang
    @id INT
AS
BEGIN
    DELETE FROM GioHang WHERE id = @id;
END
GO

-- 8. GioHangChiTiet
GO
CREATE PROCEDURE ps_LietKeGioHangChiTiet
    @idGioHang INT
AS
BEGIN
    SELECT * FROM GioHangChiTiet WHERE idGioHang = @idGioHang;
END
GO
CREATE PROCEDURE ps_ThemGioHangChiTiet
    @idGioHang INT,
    @idSanPham INT,
    @soLuong INT,
    @donGia DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO GioHangChiTiet (idGioHang, idSanPham, soLuong, donGia)
    VALUES (@idGioHang, @idSanPham, @soLuong, @donGia);
END
GO
CREATE PROCEDURE ps_SuaGioHangChiTiet
    @id INT,
    @soLuong INT
AS
BEGIN
    UPDATE GioHangChiTiet SET soLuong = @soLuong WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaGioHangChiTiet
    @id INT
AS
BEGIN
    DELETE FROM GioHangChiTiet WHERE id = @id;
END
GO

-- 9. DiaChi
GO
CREATE PROCEDURE ps_LietKeDiaChi
    @idNguoiDung NVARCHAR(450)
AS
BEGIN
    SELECT * FROM DiaChi WHERE idNguoiDung = @idNguoiDung;
END
GO
CREATE PROCEDURE ps_ThemDiaChi
    @idNguoiDung NVARCHAR(450),
    @diaChiChiTiet NVARCHAR(500),
    @phuongXa NVARCHAR(100),
    @quanHuyen NVARCHAR(100),
    @tinhThanh NVARCHAR(100),
    @soDienThoaiNhan VARCHAR(15),
    @tenNguoiNhan NVARCHAR(100),
    @laMacDinh BIT,
    @kinhDo FLOAT,
    @viDo FLOAT
AS
BEGIN
    IF @laMacDinh = 1
    BEGIN
        UPDATE DiaChi SET laMacDinh = 0 WHERE idNguoiDung = @idNguoiDung;
    END
    INSERT INTO DiaChi (idNguoiDung, diaChiChiTiet, phuongXa, quanHuyen, tinhThanh, soDienThoaiNhan, tenNguoiNhan, laMacDinh, kinhDo, viDo)
    VALUES (@idNguoiDung, @diaChiChiTiet, @phuongXa, @quanHuyen, @tinhThanh, @soDienThoaiNhan, @tenNguoiNhan, @laMacDinh, @kinhDo, @viDo);
END
GO
CREATE PROCEDURE ps_SuaDiaChi
    @id INT,
    @diaChiChiTiet NVARCHAR(500),
    @phuongXa NVARCHAR(100),
    @quanHuyen NVARCHAR(100),
    @tinhThanh NVARCHAR(100),
    @soDienThoaiNhan VARCHAR(15),
    @tenNguoiNhan NVARCHAR(100),
    @laMacDinh BIT,
    @kinhDo FLOAT,
    @viDo FLOAT
AS
BEGIN
    IF @laMacDinh = 1
    BEGIN
        DECLARE @idNguoiDung NVARCHAR(450);
        SELECT @idNguoiDung = idNguoiDung FROM DiaChi WHERE id = @id;
        UPDATE DiaChi SET laMacDinh = 0 WHERE idNguoiDung = @idNguoiDung AND id != @id;
    END
    UPDATE DiaChi
    SET diaChiChiTiet = @diaChiChiTiet, phuongXa = @phuongXa, quanHuyen = @quanHuyen, tinhThanh = @tinhThanh,
        soDienThoaiNhan = @soDienThoaiNhan, tenNguoiNhan = @tenNguoiNhan, laMacDinh = @laMacDinh, kinhDo = @kinhDo, viDo = @viDo
    WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaDiaChi
    @id INT
AS
BEGIN
    DELETE FROM DiaChi WHERE id = @id;
END
GO

-- 10. ThanhToan
GO
CREATE PROCEDURE ps_LietKeThanhToan
AS
BEGIN
    SELECT * FROM ThanhToan;
END
GO
CREATE PROCEDURE ps_ThemThanhToan
    @tenPhuongThuc NVARCHAR(100),
    @maPhuongThuc VARCHAR(50),
    @hinhAnh VARCHAR(500)
AS
BEGIN
    INSERT INTO ThanhToan (tenPhuongThuc, maPhuongThuc, hinhAnh) VALUES (@tenPhuongThuc, @maPhuongThuc, @hinhAnh);
END
GO
CREATE PROCEDURE ps_SuaThanhToan
    @id INT,
    @tenPhuongThuc NVARCHAR(100),
    @maPhuongThuc VARCHAR(50),
    @hinhAnh VARCHAR(500)
AS
BEGIN
    UPDATE ThanhToan SET tenPhuongThuc = @tenPhuongThuc, maPhuongThuc = @maPhuongThuc, hinhAnh = @hinhAnh WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaThanhToan
    @id INT
AS
BEGIN
    DELETE FROM ThanhToan WHERE id = @id;
END
GO

-- 11. KhuyenMai
GO
CREATE PROCEDURE ps_LietKeKhuyenMai
AS
BEGIN
    SELECT * FROM KhuyenMai;
END
GO
CREATE PROCEDURE ps_ThemKhuyenMai
    @maGiamGia VARCHAR(50),
    @tenKhuyenMai NVARCHAR(255),
    @phanTramGiam INT,
    @soTienGiamToiDa DECIMAL(18, 2),
    @dieuKienDonHangToiThieu DECIMAL(18, 2),
    @ngayBatDau DATETIME,
    @ngayKetThuc DATETIME,
    @soLuong INT
AS
BEGIN
    INSERT INTO KhuyenMai (maGiamGia, tenKhuyenMai, phanTramGiam, soTienGiamToiDa, dieuKienDonHangToiThieu, ngayBatDau, ngayKetThuc, soLuong)
    VALUES (@maGiamGia, @tenKhuyenMai, @phanTramGiam, @soTienGiamToiDa, @dieuKienDonHangToiThieu, @ngayBatDau, @ngayKetThuc, @soLuong);
END
GO
CREATE PROCEDURE ps_SuaKhuyenMai
    @id INT,
    @maGiamGia VARCHAR(50),
    @tenKhuyenMai NVARCHAR(255),
    @phanTramGiam INT,
    @soTienGiamToiDa DECIMAL(18, 2),
    @dieuKienDonHangToiThieu DECIMAL(18, 2),
    @ngayBatDau DATETIME,
    @ngayKetThuc DATETIME,
    @soLuong INT
AS
BEGIN
    UPDATE KhuyenMai
    SET maGiamGia = @maGiamGia, tenKhuyenMai = @tenKhuyenMai, phanTramGiam = @phanTramGiam, soTienGiamToiDa = @soTienGiamToiDa,
        dieuKienDonHangToiThieu = @dieuKienDonHangToiThieu, ngayBatDau = @ngayBatDau, ngayKetThuc = @ngayKetThuc, soLuong = @soLuong
    WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaKhuyenMai
    @id INT
AS
BEGIN
    DELETE FROM KhuyenMai WHERE id = @id;
END
GO

-- 12. HoaDon
GO
CREATE PROCEDURE ps_LietKeHoaDon
AS
BEGIN
    SELECT * FROM HoaDon;
END
GO
CREATE PROCEDURE ps_ThemHoaDon
    @idNguoiDung NVARCHAR(450),
    @idDiaChi INT,
    @idThanhToan INT,
    @idKhuyenMai INT,
    @tongTienGoc DECIMAL(18, 2),
    @soTienGiam DECIMAL(18, 2),
    @tongTienCuoiCung DECIMAL(18, 2),
    @trangThai NVARCHAR(50),
    @ghiChu NVARCHAR(500)
AS
BEGIN
    INSERT INTO HoaDon (idNguoiDung, idDiaChi, idThanhToan, idKhuyenMai, tongTienGoc, soTienGiam, tongTienCuoiCung, trangThai, ghiChu)
    VALUES (@idNguoiDung, @idDiaChi, @idThanhToan, @idKhuyenMai, @tongTienGoc, @soTienGiam, @tongTienCuoiCung, @trangThai, @ghiChu);
    SELECT SCOPE_IDENTITY() AS idHoaDonMoi; -- Tra ve ID hoa don vua tao
END
GO
CREATE PROCEDURE ps_SuaTrangThaiHoaDon
    @id INT,
    @trangThai NVARCHAR(50)
AS
BEGIN
    UPDATE HoaDon SET trangThai = @trangThai WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaHoaDon
    @id INT
AS
BEGIN
    -- Xoa hoa don cung se xoa chi tiet (ON DELETE CASCADE)
    DELETE FROM HoaDon WHERE id = @id;
END
GO

-- 13. HoaDonChiTiet
GO
CREATE PROCEDURE ps_LietKeHoaDonChiTiet
    @idHoaDon INT
AS
BEGIN
    SELECT * FROM HoaDonChiTiet WHERE idHoaDon = @idHoaDon;
END
GO
CREATE PROCEDURE ps_ThemHoaDonChiTiet
    @idHoaDon INT,
    @idSanPham INT,
    @soLuong INT,
    @donGia DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO HoaDonChiTiet (idHoaDon, idSanPham, soLuong, donGia)
    VALUES (@idHoaDon, @idSanPham, @soLuong, @donGia);
END
GO
-- Sua/Xoa HoaDonChiTiet thuong khong duoc khuyen khich sau khi don da chot.

-- 14. OTP_Log
GO
CREATE PROCEDURE ps_LietKeOTP_Log
    @idNguoiDung NVARCHAR(450)
AS
BEGIN
    SELECT * FROM OTP_Log WHERE idNguoiDung = @idNguoiDung;
END
GO
CREATE PROCEDURE ps_ThemOTP_Log
    @idNguoiDung NVARCHAR(450),
    @maOTP VARCHAR(10),
    @thoiGianHetHan DATETIME,
    @loaiOTP NVARCHAR(50)
AS
BEGIN
    INSERT INTO OTP_Log (idNguoiDung, maOTP, thoiGianHetHan, loaiOTP)
    VALUES (@idNguoiDung, @maOTP, @thoiGianHetHan, @loaiOTP);
END
GO
CREATE PROCEDURE ps_SuaOTP_Log
    @id INT
AS
BEGIN
    UPDATE OTP_Log SET daSuDung = 1 WHERE id = @id;
END
GO
-- Xoa OTP Log (co the tao job de xoa dinh ky)
CREATE PROCEDURE ps_XoaOTP_Log
    @id INT
AS
BEGIN
    DELETE FROM OTP_Log WHERE id = @id;
END
GO

-- 15. Payment_Log
GO
CREATE PROCEDURE ps_LietKePayment_Log
    @idHoaDon INT
AS
BEGIN
    SELECT * FROM Payment_Log WHERE idHoaDon = @idHoaDon;
END
GO
CREATE PROCEDURE ps_ThemPayment_Log
    @idHoaDon INT,
    @maGiaoDich NVARCHAR(100),
    @maDonHangDoiTac NVARCHAR(100),
    @soTien DECIMAL(18, 2),
    @noiDungThanhToan NVARCHAR(500),
    @thoiGianGiaoDich DATETIME,
    @trangThai NVARCHAR(50),
    @maLoi VARCHAR(50),
    @message NVARCHAR(500)
AS
BEGIN
    INSERT INTO Payment_Log (idHoaDon, maGiaoDich, maDonHangDoiTac, soTien, noiDungThanhToan, thoiGianGiaoDich, trangThai, maLoi, message)
    VALUES (@idHoaDon, @maGiaoDich, @maDonHangDoiTac, @soTien, @noiDungThanhToan, @thoiGianGiaoDich, @trangThai, @maLoi, @message);
END
GO
-- Sua/Xoa Payment_Log thuong khong can thiet

-- 16. LichSuGiaoHang
GO
CREATE PROCEDURE ps_LietKeLichSuGiaoHang
    @idHoaDon INT
AS
BEGIN
    SELECT * FROM LichSuGiaoHang WHERE idHoaDon = @idHoaDon ORDER BY thoiGian DESC;
END
GO
CREATE PROCEDURE ps_ThemLichSuGiaoHang
    @idHoaDon INT,
    @trangThai NVARCHAR(100),
    @nguoiCapNhat NVARCHAR(450)
AS
BEGIN
    INSERT INTO LichSuGiaoHang (idHoaDon, trangThai, nguoiCapNhat)
    VALUES (@idHoaDon, @trangThai, @nguoiCapNhat);
    
    -- Dong thoi cap nhat trang thai chinh cua HoaDon
    UPDATE HoaDon SET trangThai = @trangThai WHERE id = @idHoaDon;
END
GO
-- Sua/Xoa LichSuGiaoHang thuong khong can thiet

-- 17. PhieuNhap
GO
CREATE PROCEDURE ps_LietKePhieuNhap
AS
BEGIN
    SELECT * FROM PhieuNhap;
END
GO
CREATE PROCEDURE ps_ThemPhieuNhap
    @idNhaCungCap INT,
    @idNguoiTao NVARCHAR(450),
    @ghiChu NVARCHAR(500)
AS
BEGIN
    INSERT INTO PhieuNhap (idNhaCungCap, idNguoiTao, ghiChu, tongTien)
    VALUES (@idNhaCungCap, @idNguoiTao, @ghiChu, 0);
    SELECT SCOPE_IDENTITY() AS idPhieuNhapMoi;
END
GO
CREATE PROCEDURE ps_SuaPhieuNhap
    @id INT,
    @idNhaCungCap INT,
    @ghiChu NVARCHAR(500)
AS
BEGIN
    UPDATE PhieuNhap SET idNhaCungCap = @idNhaCungCap, ghiChu = @ghiChu WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaPhieuNhap
    @id INT
AS
BEGIN
    DELETE FROM PhieuNhap WHERE id = @id;
END
GO

-- 18. ChiTietPhieuNhap
GO
CREATE PROCEDURE ps_LietKeChiTietPhieuNhap
    @idPhieuNhap INT
AS
BEGIN
    SELECT * FROM ChiTietPhieuNhap WHERE idPhieuNhap = @idPhieuNhap;
END
GO
CREATE PROCEDURE ps_ThemChiTietPhieuNhap
    @idPhieuNhap INT,
    @idSanPham INT,
    @soLuongNhap INT,
    @donGiaNhap DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO ChiTietPhieuNhap (idPhieuNhap, idSanPham, soLuongNhap, donGiaNhap)
    VALUES (@idPhieuNhap, @idSanPham, @soLuongNhap, @donGiaNhap);
END
GO
CREATE PROCEDURE ps_SuaChiTietPhieuNhap
    @id INT,
    @soLuongNhap INT,
    @donGiaNhap DECIMAL(18, 2)
AS
BEGIN
    UPDATE ChiTietPhieuNhap SET soLuongNhap = @soLuongNhap, donGiaNhap = @donGiaNhap WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaChiTietPhieuNhap
    @id INT
AS
BEGIN
    DELETE FROM ChiTietPhieuNhap WHERE id = @id;
END
GO


-- 19. CauHinhMayTinh
GO
CREATE PROCEDURE ps_LietKeCauHinhMayTinh
    @idNguoiDung NVARCHAR(450)
AS
BEGIN
    SELECT * FROM CauHinhMayTinh WHERE idNguoiDung = @idNguoiDung;
END
GO
CREATE PROCEDURE ps_ThemCauHinhMayTinh
    @idNguoiDung NVARCHAR(450),
    @tenCauHinh NVARCHAR(100)
AS
BEGIN
    -- Kiem tra gioi han 3 cau hinh
    DECLARE @soLuong INT;
    SELECT @soLuong = COUNT(*) FROM CauHinhMayTinh WHERE idNguoiDung = @idNguoiDung;
    
    IF @soLuong < 3
    BEGIN
        INSERT INTO CauHinhMayTinh (idNguoiDung, tenCauHinh)
        VALUES (@idNguoiDung, @tenCauHinh);
        SELECT SCOPE_IDENTITY() AS idCauHinhMoi;
    END
    ELSE
    BEGIN
        RAISERROR (N'Mỗi người dùng chỉ được lưu tối đa 3 cấu hình.', 16, 1);
    END
END
GO
CREATE PROCEDURE ps_SuaCauHinhMayTinh
    @id INT,
    @tenCauHinh NVARCHAR(100)
AS
BEGIN
    UPDATE CauHinhMayTinh SET tenCauHinh = @tenCauHinh WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaCauHinhMayTinh
    @id INT
AS
BEGIN
    DELETE FROM CauHinhMayTinh WHERE id = @id;
END
GO

-- 20. ChiTietCauHinh
GO
CREATE PROCEDURE ps_LietKeChiTietCauHinh
    @idCauHinh INT
AS
BEGIN
    SELECT * FROM ChiTietCauHinh WHERE idCauHinh = @idCauHinh;
END
GO
CREATE PROCEDURE ps_ThemChiTietCauHinh
    @idCauHinh INT,
    @idSanPham INT,
    @idDanhMuc INT,
    @soLuong INT
AS
BEGIN
    -- Kiem tra xem linh kien loai nay (VD: CPU) da co trong cau hinh chua
    -- Neu co thi thay the (UPDATE), neu chua thi them moi (INSERT)
    IF EXISTS (SELECT 1 FROM ChiTietCauHinh WHERE idCauHinh = @idCauHinh AND idDanhMuc = @idDanhMuc)
    BEGIN
        UPDATE ChiTietCauHinh
        SET idSanPham = @idSanPham, soLuong = @soLuong
        WHERE idCauHinh = @idCauHinh AND idDanhMuc = @idDanhMuc;
    END
    ELSE
    BEGIN
        INSERT INTO ChiTietCauHinh (idCauHinh, idSanPham, idDanhMuc, soLuong)
        VALUES (@idCauHinh, @idSanPham, @idDanhMuc, @soLuong);
    END
END
GO
CREATE PROCEDURE ps_SuaChiTietCauHinh
    @id INT,
    @soLuong INT
AS
BEGIN
    UPDATE ChiTietCauHinh SET soLuong = @soLuong WHERE id = @id;
END
GO
CREATE PROCEDURE ps_XoaChiTietCauHinh
    @id INT
AS
BEGIN
    DELETE FROM ChiTietCauHinh WHERE id = @id;
END
GO

/*
-- =============================================
-- Ten du an: WEBPC_API
-- Mo ta: Tao Triggers cho cac nghiep vu tu dong
-- Tac gia: Gemini
-- Ngay tao: 29/10/2025
-- =============================================
*/

GO
-- 1. Trigger tu dong cap nhat tong tien GioHang khi GioHangChiTiet thay doi
CREATE TRIGGER trg_CapNhatTongTienGioHang
ON GioHangChiTiet
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update cho cac GioHang co ban ghi duoc INSERT hoac UPDATE
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE gh
        SET gh.tongTien = ISNULL((SELECT SUM(ct.soLuong * ct.donGia)
                             FROM GioHangChiTiet ct
                             WHERE ct.idGioHang = gh.id), 0)
        FROM GioHang gh
        JOIN (SELECT DISTINCT idGioHang FROM inserted) i ON gh.id = i.idGioHang;
    END

    -- Update cho cac GioHang co ban ghi bi DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE gh
        SET gh.tongTien = ISNULL((SELECT SUM(ct.soLuong * ct.donGia)
                             FROM GioHangChiTiet ct
                             WHERE ct.idGioHang = gh.id), 0)
        FROM GioHang gh
        JOIN (SELECT DISTINCT idGioHang FROM deleted) d ON gh.id = d.idGioHang;
    END
END
GO

-- 2. Trigger tu dong tru so luong ton trong Kho khi them HoaDonChiTiet
CREATE TRIGGER trg_TruSoLuongKho
ON HoaDonChiTiet
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idSanPham INT, @soLuongMua INT, @soLuongTon INT;

    SELECT @idSanPham = i.idSanPham, @soLuongMua = i.soLuong
    FROM inserted i;

    SELECT @soLuongTon = k.soLuongTon
    FROM Kho k
    WHERE k.idSanPham = @idSanPham;

    IF @soLuongTon < @soLuongMua
    BEGIN
        RAISERROR (N'So luong ton kho khong du de thuc hien giao dich.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE Kho
    SET soLuongTon = soLuongTon - @soLuongMua
    WHERE idSanPham = @idSanPham;
END
GO

-- (Tuy chon) Trigger tu dong cong so luong ton khi Huy don hang
-- De don gian, ta gia dinh viec huy don se cap nhat trang thai HoaDon
-- Trigger nay se kich hoat khi HoaDon.trangThai -> 'Da huy'
CREATE TRIGGER trg_HoanTraSoLuongKhoKhiHuyDon
ON HoaDon
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chi kich hoat khi trang thai thay doi thanh 'Da huy'
    IF UPDATE(trangThai)
    BEGIN
        DECLARE @idHoaDon INT, @trangThaiMoi NVARCHAR(50), @trangThaiCu NVARCHAR(50);

        SELECT @idHoaDon = i.id, @trangThaiMoi = i.trangThai, @trangThaiCu = d.trangThai
        FROM inserted i
        JOIN deleted d ON i.id = d.id;

        -- Neu don hang bi huy VA truoc do no KHONG PHAI trang thai 'Da huy'
        IF @trangThaiMoi = N'Đã hủy' AND @trangThaiCu != N'Đã hủy'
        BEGIN
            UPDATE k
            SET k.soLuongTon = k.soLuongTon + hdct.soLuong
            FROM Kho k
            JOIN HoaDonChiTiet hdct ON k.idSanPham = hdct.idSanPham
            WHERE hdct.idHoaDon = @idHoaDon;
        END
    END
END
GO


-- 3. Trigger tu dong cap nhat trang thai HoaDon khi thanh toan hoan tat (qua Payment_Log)
CREATE TRIGGER trg_CapNhatTrangThaiHoaDonThanhToan
ON Payment_Log
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idHoaDon INT, @trangThaiThanhToan NVARCHAR(50);

    SELECT @idHoaDon = i.idHoaDon, @trangThaiThanhToan = i.trangThai
    FROM inserted i;

    IF @trangThaiThanhToan = 'Success'
    BEGIN
        UPDATE HoaDon
        SET trangThai = N'Đã thanh toán' -- Hoac 'Dang xu ly' tuy vao quy trinh
        WHERE id = @idHoaDon AND trangThai = N'Chờ thanh toán';
        
        -- Sau khi thanh toan thanh cong, them lich su giao hang dau tien
        DECLARE @idNguoiDung NVARCHAR(450);
        SELECT @idNguoiDung = idNguoiDung FROM HoaDon WHERE id = @idHoaDon;
        
        INSERT INTO LichSuGiaoHang (idHoaDon, trangThai, nguoiCapNhat)
        VALUES (@idHoaDon, N'Đã xác nhận thanh toán, chờ xử lý', @idNguoiDung); -- Gia su nguoi dung tu cap nhat, hoac 1 ID he thong
    END
END
GO

-- 4. (Bonus) Trigger tu dong cap nhat tong tien PhieuNhap khi ChiTietPhieuNhap thay doi
CREATE TRIGGER trg_CapNhatTongTienPhieuNhap
ON ChiTietPhieuNhap
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update cho PhieuNhap co ban ghi duoc INSERT hoac UPDATE
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE pn
        SET pn.tongTien = ISNULL((SELECT SUM(ct.soLuongNhap * ct.donGiaNhap)
                             FROM ChiTietPhieuNhap ct
                             WHERE ct.idPhieuNhap = pn.id), 0)
        FROM PhieuNhap pn
        JOIN (SELECT DISTINCT idPhieuNhap FROM inserted) i ON pn.id = i.idPhieuNhap;
    END

    -- Update cho PhieuNhap co ban ghi bi DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE pn
        SET pn.tongTien = ISNULL((SELECT SUM(ct.soLuongNhap * ct.donGiaNhap)
                             FROM ChiTietPhieuNhap ct
                             WHERE ct.idPhieuNhap = pn.id), 0)
        FROM PhieuNhap pn
        JOIN (SELECT DISTINCT idPhieuNhap FROM deleted) d ON pn.id = d.idPhieuNhap;
    END
END
GO

-- 5. (Bonus) Trigger tu dong cap nhat so luong Kho khi them ChiTietPhieuNhap
CREATE TRIGGER trg_CongSoLuongKho
ON ChiTietPhieuNhap
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @idSanPham INT, @soLuongNhap INT;
    
    SELECT @idSanPham = i.idSanPham, @soLuongNhap = i.soLuongNhap
    FROM inserted i;

    -- Kiem tra xem SanPham da co trong Kho chua
    IF EXISTS (SELECT 1 FROM Kho WHERE idSanPham = @idSanPham)
    BEGIN
        -- Neu co roi thi cap nhat
        UPDATE Kho
        SET soLuongTon = soLuongTon + @soLuongNhap
        WHERE idSanPham = @idSanPham;
    END
    ELSE
    BEGIN
        -- Neu chua co thi them moi
        INSERT INTO Kho (idSanPham, soLuongTon)
        VALUES (@idSanPham, @soLuongNhap);
    END
END
GO
