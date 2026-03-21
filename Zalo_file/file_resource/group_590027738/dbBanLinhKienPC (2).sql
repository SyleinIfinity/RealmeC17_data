-----------------------------------------------------------
-- PHẦN 1: KHỞI TẠO CƠ SỞ DỮ LIỆU (RESET MỚI)
-----------------------------------------------------------
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = N'QLBANLINHKIENPC')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'';
    SELECT @sql += N'KILL ' + CONVERT(VARCHAR(5), session_id) + N';'
    FROM sys.dm_exec_sessions
    WHERE database_id = DB_ID(N'QLBANLINHKIENPC');
    EXEC(@sql);

    DROP DATABASE QLBANLINHKIENPC;
    PRINT N'Đã xóa cơ sở dữ liệu cũ.';
END
GO

CREATE DATABASE QLBANLINHKIENPC;
PRINT N'Đã tạo cơ sở dữ liệu QLBANLINHKIENPC thành công.';
GO

USE QLBANLINHKIENPC;
GO

-----------------------------------------------------------
-- PHẦN 2: TẠO BẢNG & RÀNG BUỘC (DDL)
-----------------------------------------------------------

-- 1. Bảng VaiTro OK
CREATE TABLE VaiTro (
    maVaiTro INT IDENTITY(1,1) PRIMARY KEY,
    tenVaiTro NVARCHAR(50) NOT NULL, 
    moTa NVARCHAR(255)
);
GO

-- 2. Bảng DanhMuc OK
CREATE TABLE DanhMuc (
    maDanhMuc INT IDENTITY(1,1) PRIMARY KEY,
    tenDanhMuc NVARCHAR(100) NOT NULL,
    moTa NVARCHAR(255) NULL, 
    maDanhMucCha INT NULL, 
    CONSTRAINT FK_DanhMuc_Cha FOREIGN KEY (maDanhMucCha) REFERENCES DanhMuc(maDanhMuc)
);
GO

-- 3. Bảng TaiKhoan OK
CREATE TABLE TaiKhoan (
    maTaiKhoan INT IDENTITY(1,1) PRIMARY KEY,
    tenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    matKhauHash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    anhDaiDien VARCHAR(MAX) NULL, 
    trangThai NVARCHAR(20) DEFAULT N'Active',
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_TaiKhoan_TrangThai CHECK (trangThai IN (N'Active', N'Banned', N'Locked'))
);
GO

-- 4. Bảng OtpLog OK
CREATE TABLE OtpLog (
    maLog INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(100) NOT NULL, -- Nguồn nhận/gửi
    maOTP VARCHAR(10) NOT NULL,
    thoiGianTao DATETIME DEFAULT GETDATE(),
    thoiGianHetHan DATETIME NOT NULL, -- Thời điểm hết hạn (VD: Tao + 5 phút)
    trangThai NVARCHAR(20) DEFAULT N'ConHan', -- ConHan / HetHan / DaSuDung
    
    CONSTRAINT CK_Otp_TrangThai CHECK (trangThai IN (N'ConHan', N'HetHan', N'DaSuDung'))
);
GO

-- 5. Bảng NhanVien OK
CREATE TABLE NhanVien (
    maNhanVien INT IDENTITY(1,1) PRIMARY KEY,
    maCodeNhanVien VARCHAR(20) NOT NULL UNIQUE,
    hoTen NVARCHAR(100) NOT NULL,
    soDienThoai VARCHAR(15),
    maTaiKhoan INT NOT NULL UNIQUE,
    maVaiTro INT NOT NULL,
    CONSTRAINT FK_NhanVien_TaiKhoan FOREIGN KEY (maTaiKhoan) REFERENCES TaiKhoan(maTaiKhoan),
    CONSTRAINT FK_NhanVien_VaiTro FOREIGN KEY (maVaiTro) REFERENCES VaiTro(maVaiTro)
);
GO

-- 6. Bảng KhachHang OK
CREATE TABLE KhachHang (
    maKhachHang INT IDENTITY(1,1) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    soDienThoai VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    maTaiKhoan INT NULL UNIQUE,
    CONSTRAINT FK_KhachHang_TaiKhoan FOREIGN KEY (maTaiKhoan) REFERENCES TaiKhoan(maTaiKhoan)
);
GO

-- 7. Bảng SoDiaChi OK
CREATE TABLE SoDiaChi (
    maSoDiaChi INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT NOT NULL,
    diaChiCuThe NVARCHAR(255) NOT NULL,
    phuongXaId VARCHAR(20),
    quanHuyenId VARCHAR(20),
    tinhThanhId VARCHAR(20),
    macDinh BIT DEFAULT 0,
    CONSTRAINT FK_SoDiaChi_KhachHang FOREIGN KEY (maKhachHang) REFERENCES KhachHang(maKhachHang) ON DELETE CASCADE
);
GO

ALTER TABLE SoDiaChi
ADD TenNguoiNhan NVARCHAR(100) NOT NULL DEFAULT N'',
    SoDienThoai VARCHAR(15) NOT NULL DEFAULT '';

GO
-- Thêm cột lưu tên để hiển thị nhanh, không cần gọi lại API
ALTER TABLE SoDiaChi ADD tenTinhThanh NVARCHAR(100);
GO
ALTER TABLE SoDiaChi ADD tenQuanHuyen NVARCHAR(100);
GO
ALTER TABLE SoDiaChi ADD tenPhuongXa NVARCHAR(100);
GO
-- 8. Bảng SanPham OK
CREATE TABLE SanPham (
    maSanPham INT IDENTITY(1,1) PRIMARY KEY,
    tenSanPham NVARCHAR(255) NOT NULL,
    giaBan DECIMAL(18, 0) NOT NULL DEFAULT 0,
    giaKhuyenMai DECIMAL(18, 0) DEFAULT 0,
    soLuongTon INT NOT NULL DEFAULT 0,
    moTa NVARCHAR(MAX),
    maDanhMuc INT NOT NULL,
    trangThai BIT DEFAULT 1,
    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (maDanhMuc) REFERENCES DanhMuc(maDanhMuc),
    CONSTRAINT CK_SanPham_GiaBan CHECK (giaBan >= 0),
    CONSTRAINT CK_SanPham_SoLuong CHECK (soLuongTon >= 0)
);
GO

-- 9. Bảng HinhAnhSanPham OK
CREATE TABLE HinhAnhSanPham (
    maHinhAnh INT IDENTITY(1,1) PRIMARY KEY,
    maSanPham INT NOT NULL,
    urlHinhAnh VARCHAR(MAX) NOT NULL,
    publicId VARCHAR(255) NULL, 
    laAnhDaiDien BIT DEFAULT 0,
    CONSTRAINT FK_HinhAnh_SanPham FOREIGN KEY (maSanPham) REFERENCES SanPham(maSanPham) ON DELETE CASCADE
);
GO

-- 10. Bảng ThongSoKyThuat OK
CREATE TABLE ThongSoKyThuat (
    maThongSo INT IDENTITY(1,1) PRIMARY KEY,
    maSanPham INT NOT NULL,
    tenThongSo NVARCHAR(100) NOT NULL,
    giaTri NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_ThongSo_SanPham FOREIGN KEY (maSanPham) REFERENCES SanPham(maSanPham) ON DELETE CASCADE
);
GO

-- 11. Bảng PhieuNhap OK
CREATE TABLE PhieuNhap (
    maPhieuNhap INT IDENTITY(1,1) PRIMARY KEY,
    maCodePhieu VARCHAR(50) UNIQUE NOT NULL,
    ngayNhap DATETIME DEFAULT GETDATE(),
    tongTienNhap DECIMAL(18, 0) DEFAULT 0,
    maNhanVienNhap INT NOT NULL,
    ghiChu NVARCHAR(MAX),
    CONSTRAINT FK_PhieuNhap_NhanVien FOREIGN KEY (maNhanVienNhap) REFERENCES NhanVien(maNhanVien)
);
GO

-- 12. Bảng ChiTietPhieuNhap OK
CREATE TABLE ChiTietPhieuNhap (
    maChiTietPhieuNhap INT IDENTITY(1,1) PRIMARY KEY,
    maPhieuNhap INT NOT NULL,
    maSanPham INT NOT NULL,
    soLuongNhap INT NOT NULL,
    giaNhap DECIMAL(18, 0) NOT NULL,
    CONSTRAINT FK_CTPN_PhieuNhap FOREIGN KEY (maPhieuNhap) REFERENCES PhieuNhap(maPhieuNhap) ON DELETE CASCADE,
    CONSTRAINT FK_CTPN_SanPham FOREIGN KEY (maSanPham) REFERENCES SanPham(maSanPham),
    CONSTRAINT CK_CTPN_SoLuong CHECK (soLuongNhap > 0),
    CONSTRAINT CK_CTPN_GiaNhap CHECK (giaNhap >= 0)
);
GO

-- 13. Bảng KhuyenMai OK
CREATE TABLE KhuyenMai (
    maKhuyenMai INT IDENTITY(1,1) PRIMARY KEY,
    maCodeKM VARCHAR(50) UNIQUE NOT NULL,
    tenChuongTrinh NVARCHAR(255) NOT NULL,
    giaTriGiam DECIMAL(18, 0) NOT NULL,
    loaiGiam VARCHAR(20) NOT NULL, 
    donHangToiThieu DECIMAL(18, 0) DEFAULT 0,
    giamToiDa DECIMAL(18, 0) NULL,
    ngayBatDau DATETIME NOT NULL,
    ngayKetThuc DATETIME NOT NULL,
    soLuongConLai INT DEFAULT 0,
    CONSTRAINT CK_KhuyenMai_Ngay CHECK (ngayKetThuc >= ngayBatDau),
    CONSTRAINT CK_KhuyenMai_Loai CHECK (loaiGiam IN ('DIRECT', 'PERCENT'))
);
GO

-- 14. Bảng KhuyenMaiKhachHang OK
CREATE TABLE KhuyenMaiKhachHang (
    maKMKH INT IDENTITY(1,1) PRIMARY KEY,
    maKhuyenMai INT NOT NULL,
    maKhachHang INT NOT NULL,
    daSuDung BIT DEFAULT 0,
    ngayThuThap DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_KMKH_KhuyenMai FOREIGN KEY (maKhuyenMai) REFERENCES KhuyenMai(maKhuyenMai),
    CONSTRAINT FK_KMKH_KhachHang FOREIGN KEY (maKhachHang) REFERENCES KhachHang(maKhachHang)
);
GO

-- 15. Bảng GioHang OK
CREATE TABLE GioHang (
    maGioHang INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT NOT NULL UNIQUE,
    ngayCapNhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_GioHang_KhachHang FOREIGN KEY (maKhachHang) REFERENCES KhachHang(maKhachHang)
);
GO

-- 16. Bảng ChiTietGioHang OK
CREATE TABLE ChiTietGioHang (
    maChiTietGioHang INT IDENTITY(1,1) PRIMARY KEY,
    maGioHang INT NOT NULL,
    maSanPham INT NOT NULL,
    soLuong INT NOT NULL DEFAULT 1,
    CONSTRAINT FK_CTGH_GioHang FOREIGN KEY (maGioHang) REFERENCES GioHang(maGioHang) ON DELETE CASCADE,
    CONSTRAINT FK_CTGH_SanPham FOREIGN KEY (maSanPham) REFERENCES SanPham(maSanPham),
    CONSTRAINT CK_CTGH_SoLuong CHECK (soLuong > 0)
);
GO

-- 17. Bảng DonHang 
CREATE TABLE DonHang (
    maDonHang INT IDENTITY(1,1) PRIMARY KEY,
    maCodeDonHang VARCHAR(50) UNIQUE NOT NULL,
    maKhachHang INT NOT NULL,
    maNhanVienDuyet INT NULL,
    ngayDat DATETIME DEFAULT GETDATE(),
    tongTien DECIMAL(18, 0) NOT NULL,
    trangThai NVARCHAR(50) DEFAULT N'ChoXacNhan',
    diaChiGiaoHang NVARCHAR(255) NOT NULL,
    soDienThoaiGiao VARCHAR(15) NOT NULL,
    nguoiNhan NVARCHAR(100) NOT NULL,
    phiVanChuyen DECIMAL(18, 0) DEFAULT 0,
    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (maKhachHang) REFERENCES KhachHang(maKhachHang),
    CONSTRAINT FK_DonHang_NhanVien FOREIGN KEY (maNhanVienDuyet) REFERENCES NhanVien(maNhanVien)
);
GO
ALTER TABLE DonHang
ADD phuongThucThanhToan NVARCHAR(50) NOT NULL DEFAULT N'COD';
GO

-- 18. Bảng ChiTietDonHang
CREATE TABLE ChiTietDonHang (
    maChiTietDonHang INT IDENTITY(1,1) PRIMARY KEY,
    maDonHang INT NOT NULL,
    maSanPham INT NOT NULL,
    soLuong INT NOT NULL,
    donGiaLucMua DECIMAL(18, 0) NOT NULL,
    thanhTien DECIMAL(18, 0) NOT NULL,
    CONSTRAINT FK_CTDH_DonHang FOREIGN KEY (maDonHang) REFERENCES DonHang(maDonHang) ON DELETE CASCADE,
    CONSTRAINT FK_CTDH_SanPham FOREIGN KEY (maSanPham) REFERENCES SanPham(maSanPham)
);
GO

-- 19. Bảng GiaoDichThanhToan
CREATE TABLE GiaoDichThanhToan (
    maGiaoDich INT IDENTITY(1,1) PRIMARY KEY,
    maDonHang INT NOT NULL,
    maGiaoDichMomo VARCHAR(100) NULL,
    phuongThuc VARCHAR(20) NOT NULL,
    soTien DECIMAL(18, 0) NOT NULL,
    trangThai NVARCHAR(50) DEFAULT N'Pending',
    noiDungLoi NVARCHAR(255) NULL,
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_GiaoDich_DonHang FOREIGN KEY (maDonHang) REFERENCES DonHang(maDonHang)
);
GO

CREATE TABLE NhatKyHoatDong (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    HanhDong NVARCHAR(50) NOT NULL,       -- Ví dụ: REFUND_CONFIRM
    MoTa NVARCHAR(MAX) NOT NULL,          -- Nội dung chi tiết log
    MaNhanVien INT NULL,                  -- Người thực hiện (cho phép NULL nếu là System)
    ThoiGian DATETIME NOT NULL DEFAULT GETDATE(),
    IPThucHien NVARCHAR(50) NULL,         -- Lưu IP máy trạm (Optional)
    
    -- Tạo khóa ngoại liên kết với bảng NhanVien
    CONSTRAINT FK_NhatKyHoatDong_NhanVien FOREIGN KEY (MaNhanVien) 
    REFERENCES NhanVien(maNhanVien)
    ON DELETE SET NULL -- Nếu nhân viên bị xóa, log vẫn còn (MaNhanVien về NULL)
);
GO

-- 1. Bảng PhienChat (Lưu phiên làm việc của từng khách)
-- Logic: Mỗi khách chỉ có 1 dòng active tại một thời điểm
CREATE TABLE PhienChat (
    maPhien INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT NOT NULL,
    thoiGianCapNhat DATETIME DEFAULT GETDATE(),
    
    -- Khóa ngoại liên kết với bảng KhachHang
    CONSTRAINT FK_PhienChat_KhachHang FOREIGN KEY (maKhachHang) 
    REFERENCES KhachHang(maKhachHang)
    ON DELETE CASCADE -- Nếu xóa user thì xóa luôn lịch sử chat
);
GO

-- 2. Bảng ChiTietPhienChat (Lưu nội dung chat)
CREATE TABLE ChiTietPhienChat (
    id INT IDENTITY(1,1) PRIMARY KEY,
    maPhien INT NOT NULL,
    cauHoi NVARCHAR(MAX) NOT NULL,    -- Câu khách hỏi
    cauTraLoi NVARCHAR(MAX) NOT NULL, -- Bot trả lời
    thoiGian DATETIME DEFAULT GETDATE(),

    -- Khóa ngoại liên kết với PhienChat
    CONSTRAINT FK_ChiTiet_Phien FOREIGN KEY (maPhien) 
    REFERENCES PhienChat(maPhien)
    ON DELETE CASCADE -- Quan trọng: Xóa phiên chat -> Xóa sạch tin nhắn con
);
GO

-- Tạo Index để truy vấn lịch sử cho nhanh
CREATE INDEX IX_PhienChat_MaKhachHang ON PhienChat(maKhachHang);
CREATE INDEX IX_ChiTiet_MaPhien ON ChiTietPhienChat(maPhien);
GO

-----------------------------------------------------------
-- PHẦN 3: TẠO TRIGGER (TỰ ĐỘNG HÓA)
-----------------------------------------------------------

-- [MỚI] 1. Trigger OTP: Tự động vô hiệu hóa các mã OTP cũ khi tạo mã mới
-- Logic: Khi Insert 1 OTP cho email A -> Tất cả OTP cũ của email A chuyển thành 'HetHan'
CREATE TRIGGER trg_TuDongHetHanOTPCu
ON OtpLog
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Cập nhật trạng thái 'HetHan' cho các dòng cũ cùng email
    UPDATE OtpLog
    SET trangThai = N'HetHan'
    FROM OtpLog o
    JOIN Inserted i ON o.email = i.email
    WHERE o.maLog <> i.maLog -- Không update dòng vừa insert
      AND o.trangThai = N'ConHan'; -- Chỉ update những cái đang còn hạn
END;
GO

-- 2. Trigger: Tự động cập nhật Tồn Kho khi NHẬP HÀNG
CREATE TRIGGER trg_CapNhatTonKho_NhapHang
ON ChiTietPhieuNhap
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT * FROM Inserted) AND NOT EXISTS (SELECT * FROM Deleted)
    BEGIN
        UPDATE SanPham
        SET soLuongTon = soLuongTon + i.soLuongNhap,
            giaBan = i.giaNhap * 1.2 
        FROM SanPham sp
        JOIN Inserted i ON sp.maSanPham = i.maSanPham;
    END
    IF EXISTS (SELECT * FROM Deleted) AND NOT EXISTS (SELECT * FROM Inserted)
    BEGIN
        UPDATE SanPham
        SET soLuongTon = soLuongTon - d.soLuongNhap
        FROM SanPham sp
        JOIN Deleted d ON sp.maSanPham = d.maSanPham;
    END
    IF EXISTS (SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted)
    BEGIN
        UPDATE SanPham
        SET soLuongTon = soLuongTon + (i.soLuongNhap - d.soLuongNhap)
        FROM SanPham sp
        JOIN Inserted i ON sp.maSanPham = i.maSanPham
        JOIN Deleted d ON sp.maSanPham = d.maSanPham;
    END
END;
GO
--    SELECT name FROM sys.triggers WHERE parent_id = OBJECT_ID('ChiTietDonHang');
-- 3. Trigger: Tự động trừ Tồn Kho khi CÓ ĐƠN HÀNG
--DROP TRIGGER trg_CapNhatTonKho_BanHang
CREATE TRIGGER trg_CapNhatTonKho_BanHang
ON ChiTietDonHang
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM SanPham sp
        JOIN Inserted i ON sp.maSanPham = i.maSanPham
        WHERE sp.soLuongTon < i.soLuong
    )
    BEGIN
        RAISERROR(N'Lỗi: Sản phẩm trong kho không đủ để thực hiện đơn hàng này!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    UPDATE SanPham
    SET soLuongTon = soLuongTon - i.soLuong
    FROM SanPham sp
    JOIN Inserted i ON sp.maSanPham = i.maSanPham;
END;
GO

-- 4. Trigger: Tự động tính Tổng Tiền Đơn Hàng
-- DROP TRIGGER trg_TinhTongTien_DonHang
CREATE TRIGGER trg_TinhTongTien_DonHang
ON ChiTietDonHang
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DanhSachDonHang TABLE (maDonHang INT);
    INSERT INTO @DanhSachDonHang
    SELECT maDonHang FROM Inserted
    UNION
    SELECT maDonHang FROM Deleted;

    UPDATE DonHang
    SET tongTien = (
        SELECT ISNULL(SUM(thanhTien), 0)
        FROM ChiTietDonHang
        WHERE ChiTietDonHang.maDonHang = DonHang.maDonHang
    ) + ISNULL(phiVanChuyen, 0)
    WHERE maDonHang IN (SELECT maDonHang FROM @DanhSachDonHang);
END;
GO
PRINT N'Đã tạo xong Trigger.';
GO

CREATE TRIGGER trg_XoaSanPham
ON SanPham
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Xóa các Thông số kỹ thuật thuộc sản phẩm bị xóa
    DELETE FROM ThongSoKyThuat 
    WHERE maSanPham IN (SELECT maSanPham FROM Deleted);

    -- 2. Xóa các Hình ảnh sản phẩm (Logic tương tự)
    DELETE FROM HinhAnhSanPham 
    WHERE maSanPham IN (SELECT maSanPham FROM Deleted);

    -- 3. Cuối cùng: Xóa chính sản phẩm đó trong bảng SanPham
    DELETE FROM SanPham 
    WHERE maSanPham IN (SELECT maSanPham FROM Deleted);
END;
GO

-----------------------------------------------------------
-- PHẦN 4: TẠO STORED PROCEDURES (THỦ TỤC NGHIỆP VỤ)
-----------------------------------------------------------

-- 1. SP: Đăng ký thành viên
CREATE PROCEDURE sp_DangKyKhachHang
    @TenDangNhap VARCHAR(50),
    @MatKhauHash VARCHAR(255),
    @Email VARCHAR(100),
    @HoTen NVARCHAR(100),
    @SoDienThoai VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO TaiKhoan (tenDangNhap, matKhauHash, email, trangThai)
            VALUES (@TenDangNhap, @MatKhauHash, @Email, N'Active');
            DECLARE @NewTaiKhoanID INT = SCOPE_IDENTITY();

            INSERT INTO KhachHang (hoTen, soDienThoai, email, maTaiKhoan)
            VALUES (@HoTen, @SoDienThoai, @Email, @NewTaiKhoanID);

            DECLARE @NewKhachHangID INT = SCOPE_IDENTITY();
            INSERT INTO GioHang (maKhachHang) VALUES (@NewKhachHangID);
        COMMIT TRANSACTION;
        PRINT N'Đăng ký thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 2. SP: Thêm vào giỏ hàng
CREATE PROCEDURE sp_ThemVaoGioHang
    @MaKhachHang INT,
    @MaSanPham INT,
    @SoLuong INT
AS
BEGIN
    DECLARE @MaGioHang INT;
    SELECT @MaGioHang = maGioHang FROM GioHang WHERE maKhachHang = @MaKhachHang;

    IF @MaGioHang IS NULL
    BEGIN
        PRINT N'Khách hàng chưa có giỏ hàng!';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ChiTietGioHang WHERE maGioHang = @MaGioHang AND maSanPham = @MaSanPham)
    BEGIN
        UPDATE ChiTietGioHang
        SET soLuong = soLuong + @SoLuong
        WHERE maGioHang = @MaGioHang AND maSanPham = @MaSanPham;
    END
    ELSE
    BEGIN
        INSERT INTO ChiTietGioHang (maGioHang, maSanPham, soLuong)
        VALUES (@MaGioHang, @MaSanPham, @SoLuong);
    END
END;
GO

-- 3. SP: Tạo đơn hàng (Checkout)
CREATE PROCEDURE sp_TaoDonHang
    @MaKhachHang INT,
    @MaCodeDonHang VARCHAR(50),
    @DiaChiGiao NVARCHAR(255),
    @SDTGiao VARCHAR(15),
    @NguoiNhan NVARCHAR(100),
    @PhuongThucThanhToan VARCHAR(20),
    @MaKhuyenMaiID INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO DonHang (maCodeDonHang, maKhachHang, ngayDat, tongTien, trangThai, diaChiGiaoHang, soDienThoaiGiao, nguoiNhan)
            VALUES (@MaCodeDonHang, @MaKhachHang, GETDATE(), 0, N'ChoXacNhan', @DiaChiGiao, @SDTGiao, @NguoiNhan);
            
            DECLARE @MaDonHang INT = SCOPE_IDENTITY();
            DECLARE @MaGioHang INT;
            SELECT @MaGioHang = maGioHang FROM GioHang WHERE maKhachHang = @MaKhachHang;

            INSERT INTO ChiTietDonHang (maDonHang, maSanPham, soLuong, donGiaLucMua, thanhTien)
            SELECT @MaDonHang, ct.maSanPham, ct.soLuong, sp.giaBan, (ct.soLuong * sp.giaBan)
            FROM ChiTietGioHang ct
            JOIN SanPham sp ON ct.maSanPham = sp.maSanPham
            WHERE ct.maGioHang = @MaGioHang;

            INSERT INTO GiaoDichThanhToan (maDonHang, phuongThuc, soTien, trangThai)
            VALUES (@MaDonHang, @PhuongThucThanhToan, 0, N'Pending'); 

            IF @MaKhuyenMaiID IS NOT NULL
            BEGIN
                UPDATE KhuyenMaiKhachHang
                SET daSuDung = 1
                WHERE maKhachHang = @MaKhachHang AND maKhuyenMai = @MaKhuyenMaiID;
            END

            DELETE FROM ChiTietGioHang WHERE maGioHang = @MaGioHang;
        COMMIT TRANSACTION;
        PRINT N'Tạo đơn hàng thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 4. SP: Tính lương nhân viên
CREATE PROCEDURE sp_TinhLuongNhanVien
    @Thang INT,
    @Nam INT
AS
BEGIN
    SELECT 
        nv.maNhanVien,
        nv.hoTen,
        vt.tenVaiTro,
        (SELECT COUNT(*) FROM DonHang dh 
         WHERE dh.maNhanVienDuyet = nv.maNhanVien 
         AND MONTH(dh.ngayDat) = @Thang AND YEAR(dh.ngayDat) = @Nam
         AND dh.trangThai = N'DaGiao') AS SoDonBanDuoc,
        (SELECT COUNT(*) FROM PhieuNhap pn
         WHERE pn.maNhanVienNhap = nv.maNhanVien
         AND MONTH(pn.ngayNhap) = @Thang AND YEAR(pn.ngayNhap) = @Nam) AS SoPhieuNhap,
        CASE 
            WHEN vt.tenVaiTro LIKE '%Sales%' THEN 5000000 + ((SELECT COUNT(*) FROM DonHang dh WHERE dh.maNhanVienDuyet = nv.maNhanVien AND MONTH(dh.ngayDat) = @Thang AND dh.trangThai = N'DaGiao') * 50000)
            WHEN vt.tenVaiTro LIKE '%Kho%' OR vt.tenVaiTro LIKE '%Admin%' THEN 6000000 + ((SELECT COUNT(*) FROM PhieuNhap pn WHERE pn.maNhanVienNhap = nv.maNhanVien AND MONTH(pn.ngayNhap) = @Thang) * 100000)
            ELSE 5000000
        END AS LuongTamTinh
    FROM NhanVien nv
    JOIN VaiTro vt ON nv.maVaiTro = vt.maVaiTro;
END;
GO

PRINT N'Hoàn tất toàn bộ cài đặt CSDL (Bổ sung OTP Log).';
GO