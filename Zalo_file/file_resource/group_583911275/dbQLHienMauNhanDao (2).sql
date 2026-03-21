USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = N'QLHienMauNhanDao')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'';
    SELECT @sql += N'KILL ' + CONVERT(VARCHAR(5), session_id) + N';'
    FROM sys.dm_exec_sessions
    WHERE database_id = DB_ID(N'QLHienMauNhanDao');
    EXEC(@sql);

    DROP DATABASE QLHienMauNhanDao;
    PRINT N'Đã xóa cơ sở dữ liệu cũ.';
END
GO

CREATE DATABASE QLHienMauNhanDao;
GO
USE QLHienMauNhanDao;
GO

-- BẢNG 1: TAIKHOAN
CREATE TABLE TAIKHOAN (
    maTK INT IDENTITY(1,1) NOT NULL,
    tenDangNhap VARCHAR(50) NOT NULL,
    matKhau VARCHAR(255) NOT NULL,
    vaiTro VARCHAR(20) NOT NULL,
    soDienThoai VARCHAR(15) NULL,
    trangThai NVARCHAR(20) DEFAULT N'Hoạt động',
    
    CONSTRAINT PK_TAIKHOAN PRIMARY KEY (maTK),
    CONSTRAINT UQ_TAIKHOAN_TenDangNhap UNIQUE (tenDangNhap),
    CONSTRAINT UQ_TAIKHOAN_SDT UNIQUE (soDienThoai)
);
GO

-- BẢNG 2: BENHVIEN
CREATE TABLE BENHVIEN (
    maBV INT IDENTITY(1,1) NOT NULL,
    tenBV NVARCHAR(255) NOT NULL,
    diaChi NVARCHAR(500) NOT NULL,
    loaiBenhVien NVARCHAR(100) NULL,
    
    CONSTRAINT PK_BENHVIEN PRIMARY KEY (maBV)
);
GO

-- BẢNG 3: QUANLYKHOA
CREATE TABLE QUANLYKHOA (
    maQLK INT IDENTITY(1,1) NOT NULL,
    hoTen NVARCHAR(100) NOT NULL,
    maTK INT NOT NULL,
    
    CONSTRAINT PK_QUANLYKHOA PRIMARY KEY (maQLK),
    CONSTRAINT FK_QUANLYKHOA_TAIKHOAN FOREIGN KEY (maTK) 
        REFERENCES TAIKHOAN(maTK) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE 
);
GO

-- BẢNG 4: NGUOIPHUTRACH
CREATE TABLE NGUOIPHUTRACH (
    maNPT INT IDENTITY(1,1) NOT NULL,
    hoTen NVARCHAR(100) NOT NULL,
    maBV INT NOT NULL,
    maTK INT NOT NULL,
    
    CONSTRAINT PK_NGUOIPHUTRACH PRIMARY KEY (maNPT),
    CONSTRAINT FK_NGUOIPHUTRACH_BENHVIEN FOREIGN KEY (maBV) 
        REFERENCES BENHVIEN(maBV)
        ON UPDATE CASCADE
        ON DELETE NO ACTION, 
    CONSTRAINT FK_NGUOIPHUTRACH_TAIKHOAN FOREIGN KEY (maTK) 
        REFERENCES TAIKHOAN(maTK)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
GO

-- BẢNG 5: NGUOIHIEN
CREATE TABLE NGUOIHIEN (
    maNguoiHien INT IDENTITY(1,1) NOT NULL,
    hoTen NVARCHAR(150) NOT NULL,
    soCMND_CCCD VARCHAR(20) NOT NULL,
    ngaySinh DATE NOT NULL,
    gioiTinh NVARCHAR(10) NOT NULL, 
    diaChi NVARCHAR(255) NULL,
    maTK INT NULL, 
    
    CONSTRAINT PK_NGUOIHIEN PRIMARY KEY (maNguoiHien),
    CONSTRAINT UQ_NGUOIHIEN_CMND UNIQUE (soCMND_CCCD),
    CONSTRAINT FK_NGUOIHIEN_TAIKHOAN FOREIGN KEY (maTK) 
        REFERENCES TAIKHOAN(maTK)
        ON UPDATE CASCADE
        ON DELETE SET NULL 
);
GO

-- BẢNG 6: NHANVIENYTE
CREATE TABLE NHANVIENYTE (
    maNhanVienYTe INT IDENTITY(1,1) NOT NULL,
    hoTen NVARCHAR(100) NOT NULL,
    chucDanh NVARCHAR(50) NULL,
    maBV INT NOT NULL,
    
    CONSTRAINT PK_NHANVIENYTE PRIMARY KEY (maNhanVienYTe),
    CONSTRAINT FK_NHANVIENYTE_BENHVIEN FOREIGN KEY (maBV) 
        REFERENCES BENHVIEN(maBV)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
GO
-- BẢNG 7: DOTHIENMAU
CREATE TABLE DOTHIENMAU (
    maDot INT IDENTITY(1,1) NOT NULL,
    tenDot NVARCHAR(200) NOT NULL,
    ngayBatDau DATETIME NOT NULL,
    ngayKetThuc DATETIME NOT NULL,
    diaDiem NVARCHAR(200) NOT NULL,
    soLuongDuKien INT DEFAULT 0,
    trangThai NVARCHAR(50) DEFAULT N'Lên kế hoạch',
    maNPT INT NOT NULL, 
    
    CONSTRAINT PK_DOTHIENMAU PRIMARY KEY (maDot),
    CONSTRAINT FK_DOTHIENMAU_NGUOIPHUTRACH FOREIGN KEY (maNPT) 
        REFERENCES NGUOIPHUTRACH(maNPT)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT CK_DOTHIENMAU_ThoiGian CHECK (ngayKetThuc >= ngayBatDau)
);
GO

-- BẢNG 8: PHIEUDIEUPHOI
CREATE TABLE PHIEUDIEUPHOI (
    maPhieuDP INT IDENTITY(1,1) NOT NULL,
    ngayYeuCau DATETIME DEFAULT GETDATE(),
    lyDo NVARCHAR(500) NULL,
    trangThai NVARCHAR(50) DEFAULT N'Chờ duyệt',
    ngayDuyet DATETIME NULL,
    maNguoiYeuCau INT NOT NULL,
    maNguoiDuyet INT NULL,
    
    CONSTRAINT PK_PHIEUDIEUPHOI PRIMARY KEY (maPhieuDP),
    CONSTRAINT FK_PHIEUDIEUPHOI_NguoiYeuCau FOREIGN KEY (maNguoiYeuCau) 
        REFERENCES NGUOIPHUTRACH(maNPT) 
        ON UPDATE NO ACTION 
        ON DELETE NO ACTION,
    CONSTRAINT FK_PHIEUDIEUPHOI_NguoiDuyet FOREIGN KEY (maNguoiDuyet) 
        REFERENCES NGUOIPHUTRACH(maNPT)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
GO

-- BẢNG 9: DANHSACHNHANVIENTHAMGIA
CREATE TABLE DANHSACHNHANVIENTHAMGIA (
    maDS INT IDENTITY(1,1) NOT NULL,
    tenDS NVARCHAR(100) NOT NULL,
    ngayTao DATETIME DEFAULT GETDATE(),
    maDot INT NOT NULL,
    
    CONSTRAINT PK_DANHSACHNHANVIENTHAMGIA PRIMARY KEY (maDS),
    CONSTRAINT FK_DSNV_DOTHIENMAU FOREIGN KEY (maDot) 
        REFERENCES DOTHIENMAU(maDot)
        ON UPDATE CASCADE
        ON DELETE CASCADE, 
    CONSTRAINT UQ_DSNV_Dot UNIQUE (maDot)
);
GO

-- BẢNG 10: CHITIETDANHSACH
CREATE TABLE CHITIETDANHSACH (
    maCTDS INT IDENTITY(1,1) NOT NULL,
    maCodeNhiemVu VARCHAR(20) NULL,
    nhiemVu NVARCHAR(100) NULL,
    maDS INT NOT NULL,
    maNhanVienYTe INT NOT NULL,
    
    CONSTRAINT PK_CHITIETDANHSACH PRIMARY KEY (maCTDS),
    CONSTRAINT FK_CTDS_DANHSACH FOREIGN KEY (maDS) 
        REFERENCES DANHSACHNHANVIENTHAMGIA(maDS)
        ON UPDATE CASCADE
        ON DELETE CASCADE, 
    CONSTRAINT FK_CTDS_NHANVIEN FOREIGN KEY (maNhanVienYTe) 
        REFERENCES NHANVIENYTE(maNhanVienYTe)
        ON UPDATE NO ACTION 
        ON DELETE NO ACTION 
);
GO

-- BẢNG 11: TAIKHOANDOTHIENMAU
CREATE TABLE TAIKHOANDOTHIENMAU (
    maTKDot INT IDENTITY(1,1) NOT NULL,
    tenDangNhap VARCHAR(50) NOT NULL,
    matKhau VARCHAR(255) NOT NULL,
    vaiTro VARCHAR(20) NULL,
    trangThai VARCHAR(20) DEFAULT N'Hoạt động',
    maCTDS INT NOT NULL, 
    maNguoiTao INT NULL,
    
    CONSTRAINT PK_TAIKHOANDOTHIENMAU PRIMARY KEY (maTKDot),
    CONSTRAINT FK_TKDOT_CHITIET FOREIGN KEY (maCTDS) 
        REFERENCES CHITIETDANHSACH(maCTDS)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_TKDOT_NGUOITAO FOREIGN KEY (maNguoiTao)
        REFERENCES TAIKHOAN(maTK)
        ON UPDATE NO ACTION
        ON DELETE SET NULL
);
GO

-- BẢNG 12: PHIEUDANGKY
CREATE TABLE PHIEUDANGKY (
    maDangKy INT IDENTITY(1,1) NOT NULL,
    thoiGianDK DATETIME DEFAULT GETDATE(),
    khungGioHen DATETIME NULL,
    trangThai NVARCHAR(50) DEFAULT N'Đã đăng ký',
    maDot INT NOT NULL,
    maNguoiHien INT NOT NULL,
    
    CONSTRAINT PK_PHIEUDANGKY PRIMARY KEY (maDangKy),
    CONSTRAINT FK_PHIEUDANGKY_DOTHIENMAU FOREIGN KEY (maDot) 
        REFERENCES DOTHIENMAU(maDot)
        ON UPDATE CASCADE
        ON DELETE NO ACTION, 
    CONSTRAINT FK_PHIEUDANGKY_NGUOIHIEN FOREIGN KEY (maNguoiHien) 
        REFERENCES NGUOIHIEN(maNguoiHien)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION 
);
GO

-- BẢNG 13: PHIEUSANGLOC
CREATE TABLE PHIEUSANGLOC (
    maPhieuSangLoc INT IDENTITY(1,1) NOT NULL,
    thoiGianKham DATETIME DEFAULT GETDATE(),
    huyetAp VARCHAR(10) NULL,
    canNang FLOAT NULL,
    nhomMau NVARCHAR(25) NULL, 
    ketQuaXN NVARCHAR(500) NULL,
    trangThai NVARCHAR(50) NOT NULL, 
    lyDoKhongDat NVARCHAR(500) NULL,
    maDangKy INT NOT NULL,
    maNhanVienYTe INT NOT NULL, 
    
    CONSTRAINT PK_PHIEUSANGLOC PRIMARY KEY (maPhieuSangLoc),
    CONSTRAINT FK_PHIEUSANGLOC_PHIEUDANGKY FOREIGN KEY (maDangKy) 
        REFERENCES PHIEUDANGKY(maDangKy)
        ON UPDATE CASCADE
        ON DELETE CASCADE, -- Xóa phiếu đăng ký thì xóa phiếu khám
    CONSTRAINT FK_PHIEUSANGLOC_NHANVIEN FOREIGN KEY (maNhanVienYTe) 
        REFERENCES NHANVIENYTE(maNhanVienYTe)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION, -- Tránh lỗi cycle với bảng NHANVIENYTE
    CONSTRAINT UQ_PHIEUSANGLOC_DANGKY UNIQUE (maDangKy) 
);
GO

-- BẢNG 14: PHIEUHIENMAU
CREATE TABLE PHIEUHIENMAU (
    maPhieuHM INT IDENTITY(1,1) NOT NULL,
    thoiGianHien DATETIME DEFAULT GETDATE(),
    theTich INT NOT NULL, 
    maNV_LayMau INT NOT NULL,
    maPhieuSangLoc INT NOT NULL,
    
    CONSTRAINT PK_PHIEUHIENMAU PRIMARY KEY (maPhieuHM),
    CONSTRAINT FK_PHIEUHIENMAU_NHANVIEN FOREIGN KEY (maNV_LayMau) 
        REFERENCES NHANVIENYTE(maNhanVienYTe)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION, -- Tránh lỗi cycle
    CONSTRAINT FK_PHIEUHIENMAU_PHIEUSANGLOC FOREIGN KEY (maPhieuSangLoc) 
        REFERENCES PHIEUSANGLOC(maPhieuSangLoc)
        ON UPDATE CASCADE
        ON DELETE CASCADE, 
    CONSTRAINT UQ_PHIEUHIENMAU_SANGLOC UNIQUE (maPhieuSangLoc), 
    CONSTRAINT CK_PHIEUHIENMAU_TheTich CHECK (theTich > 0)
);
GO

-- =============================================================================================================================================================================================
-- CÁC RÀNG BUỘC BỔ SUNG
-- =============================================================================================================================================================================================

IF OBJECT_ID('CK_PHIEUHIENMAU_TheTich', 'C') IS NOT NULL
BEGIN
    ALTER TABLE PHIEUHIENMAU DROP CONSTRAINT CK_PHIEUHIENMAU_TheTich;
END
GO

-- Bảng TAIKHOAN: Chỉ chấp nhận 'Hoạt động' hoặc 'Đã khóa'
ALTER TABLE TAIKHOAN
ADD CONSTRAINT CK_TAIKHOAN_TrangThai 
CHECK (trangThai IN (N'Hoạt động', N'Đã khóa'));
GO

-- Bảng DOTHIENMAU: Các bước của quy trình tổ chức
ALTER TABLE DOTHIENMAU
ADD CONSTRAINT CK_DOTHIENMAU_TrangThai CHECK (trangThai IN (N'Lên kế hoạch', N'Đang diễn ra', N'Hoàn thành', N'Đã hủy'));
GO
-- Bảng PHIEUDIEUPHOI: Quy trình phê duyệt
ALTER TABLE PHIEUDIEUPHOI
ADD CONSTRAINT CK_PHIEUDIEUPHOI_TrangThai CHECK (trangThai IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối'));

-- Bảng PHIEUDANGKY: Trạng thái người hiến đăng ký
ALTER TABLE PHIEUDANGKY
ADD CONSTRAINT CK_PHIEUDANGKY_TrangThai 
CHECK (trangThai IN (N'Đã đăng ký', N'Đã check-in', N'Hủy đăng ký', N'Hoàn thành', N'Đã check-in (Chờ lấy máu)', N'Không đạt sức khỏe'));
GO

-- Bảng PHIEUSANGLOC: Kết quả khám chỉ có Đạt hoặc Không
ALTER TABLE PHIEUSANGLOC
ADD CONSTRAINT CK_PHIEUSANGLOC_TrangThai CHECK (trangThai IN (N'Đạt', N'Không đạt'));
GO

-- Bảng NGUOIHIEN: Người hiến máu phải đủ 18 tuổi
ALTER TABLE NGUOIHIEN
ADD CONSTRAINT CK_NGUOIHIEN_Tuoi CHECK (DATEDIFF(YEAR, ngaySinh, GETDATE()) >= 18);

-- Bảng PHIEUDIEUPHOI: Ngày duyệt phải sau hoặc bằng ngày yêu cầu
ALTER TABLE PHIEUDIEUPHOI
ADD CONSTRAINT CK_PHIEUDIEUPHOI_NgayDuyet CHECK (ngayDuyet >= ngayYeuCau);

-- Bảng PHIEUDANGKY: Khung giờ hẹn (nếu có) phải sau thời gian đăng ký
ALTER TABLE PHIEUDANGKY
ADD CONSTRAINT CK_PHIEUDANGKY_KhungGio CHECK (khungGioHen IS NULL OR khungGioHen >= thoiGianDK);

GO

-- Bảng PHIEUHIENMAU: Thể tích máu hiến phải thuộc các mức chuẩn (250, 350, 450)
ALTER TABLE PHIEUHIENMAU
ADD CONSTRAINT CK_PHIEUHIENMAU_TheTich CHECK (theTich IN (250, 350, 450));

-- Bảng DOTHIENMAU: Số lượng dự kiến không được âm
-- (Chỉ thêm nếu chưa có, dùng lệnh an toàn)
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_DOTHIENMAU_SoLuong')
BEGIN
    ALTER TABLE DOTHIENMAU
    ADD CONSTRAINT CK_DOTHIENMAU_SoLuong CHECK (soLuongDuKien >= 0);
END

-- Bảng PHIEUSANGLOC: Cân nặng phải > 40kg
ALTER TABLE PHIEUSANGLOC
ADD CONSTRAINT CK_PHIEUSANGLOC_CanNang CHECK (canNang > 40);

-- Bảng NGUOIHIEN: Giới tính
ALTER TABLE NGUOIHIEN
ADD CONSTRAINT CK_NGUOIHIEN_GioiTinh CHECK (gioiTinh IN (N'Nam', N'Nữ', N'Khác'));

-- Bảng BENHVIEN: Loại bệnh viện
ALTER TABLE BENHVIEN
ADD CONSTRAINT CK_BENHVIEN_Loai CHECK (loaiBenhVien IN (N'Công lập', N'Tư nhân', N'Quốc tế', N'Khác'));

-- Bảng PHIEUSANGLOC: Logic bắt buộc nhập lý do nếu "Không đạt"
ALTER TABLE PHIEUSANGLOC
ADD CONSTRAINT CK_PHIEUSANGLOC_LyDo CHECK (
    (trangThai = N'Đạt') OR 
    (trangThai = N'Không đạt' AND lyDoKhongDat IS NOT NULL AND LEN(lyDoKhongDat) > 0)
);

GO
CREATE OR ALTER FUNCTION fn_KiemTraDieuKienHienMau (@maNguoiHien INT)
RETURNS BIT
AS
BEGIN
    DECLARE @NgayHienGanNhat DATETIME;
    DECLARE @KetQua BIT;

    -- Lấy ngày hiến gần nhất
    SELECT TOP 1 @NgayHienGanNhat = ph.thoiGianHien
    FROM PHIEUHIENMAU ph
    JOIN PHIEUSANGLOC ps ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy
    WHERE pdk.maNguoiHien = @maNguoiHien
    ORDER BY ph.thoiGianHien DESC;

    -- Logic: Chưa hiến lần nào HOẶC cách lần gần nhất >= 84 ngày (12 tuần)
    IF @NgayHienGanNhat IS NULL OR DATEDIFF(DAY, @NgayHienGanNhat, GETDATE()) >= 84
        SET @KetQua = 1;
    ELSE
        SET @KetQua = 0;

    RETURN @KetQua;
END;
GO

CREATE OR ALTER FUNCTION fn_XemDanhSachNhanVienThamGia (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        nv.hoTen AS TenNhanVien,
        nv.chucDanh,
        ct.nhiemVu AS NhiemVuDuocPhanCong,
        bv.tenBV AS DonViCongTac
    FROM DANHSACHNHANVIENTHAMGIA ds
    JOIN CHITIETDANHSACH ct ON ds.maDS = ct.maDS
    JOIN NHANVIENYTE nv ON ct.maNhanVienYTe = nv.maNhanVienYTe
    JOIN BENHVIEN bv ON nv.maBV = bv.maBV
    WHERE ds.maDot = @maDot
);
GO

CREATE OR ALTER FUNCTION fn_ThongKeMauTheoDot (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ISNULL(ps.nhomMau, N'Chưa xác định') AS NhomMau,
        COUNT(ph.maPhieuHM) AS SoLuongTuiMau,
        ISNULL(SUM(ph.theTich), 0) AS TongTheTich_ml
    FROM DOTHIENMAU dt
    JOIN PHIEUDANGKY pdk ON dt.maDot = pdk.maDot
    JOIN PHIEUSANGLOC ps ON pdk.maDangKy = ps.maDangKy
    JOIN PHIEUHIENMAU ph ON ps.maPhieuSangLoc = ph.maPhieuSangLoc
    WHERE dt.maDot = @maDot
    GROUP BY ps.nhomMau
);
GO

CREATE OR ALTER FUNCTION fn_LayLichSuHienMau (@maNguoiHien INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ph.thoiGianHien,
        ph.theTich AS TheTich_ml,
        ps.nhomMau,
        bv.tenBV AS DonViTiepNhan,
        dt.tenDot
    FROM PHIEUHIENMAU ph
    JOIN PHIEUSANGLOC ps ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy
    JOIN DOTHIENMAU dt ON pdk.maDot = dt.maDot
    JOIN NGUOIPHUTRACH npt ON dt.maNPT = npt.maNPT
    JOIN BENHVIEN bv ON npt.maBV = bv.maBV
    WHERE pdk.maNguoiHien = @maNguoiHien
);
GO

CREATE OR ALTER PROCEDURE sp_DangKyTaiKhoanNguoiHien
    @tenDangNhap VARCHAR(50),
    @matKhau VARCHAR(255),
    @soDienThoai VARCHAR(15),
    @hoTen NVARCHAR(150),
    @soCMND_CCCD VARCHAR(20),
    @ngaySinh DATE,
    @gioiTinh NVARCHAR(10),
    @diaChi NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE tenDangNhap = @tenDangNhap)
            THROW 51000, N'Tên đăng nhập đã tồn tại.', 1;

        INSERT INTO TAIKHOAN (tenDangNhap, matKhau, vaiTro, soDienThoai, trangThai)
        VALUES (@tenDangNhap, @matKhau, 'NguoiHien', @soDienThoai, N'Hoạt động');

        DECLARE @newMaTK INT = SCOPE_IDENTITY();

        INSERT INTO NGUOIHIEN (hoTen, soCMND_CCCD, ngaySinh, gioiTinh, diaChi, maTK)
        VALUES (@hoTen, @soCMND_CCCD, @ngaySinh, @gioiTinh, @diaChi, @newMaTK);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_DangKyLichHienMau
    @maDot INT,
    @maNguoiHien INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Kiểm tra đợt
    IF NOT EXISTS (SELECT 1 FROM DOTHIENMAU WHERE maDot = @maDot AND ngayKetThuc >= GETDATE())
        THROW 51000, N'Đợt hiến máu không tồn tại hoặc đã kết thúc.', 1;

    -- Kiểm tra trùng
    IF EXISTS (SELECT 1 FROM PHIEUDANGKY WHERE maDot = @maDot AND maNguoiHien = @maNguoiHien)
        THROW 51000, N'Bạn đã đăng ký tham gia đợt này rồi.', 1;

    -- Kiểm tra điều kiện sức khỏe (Gọi Function)
    IF dbo.fn_KiemTraDieuKienHienMau(@maNguoiHien) = 0
        THROW 51000, N'Chưa đủ 12 tuần kể từ lần hiến máu gần nhất.', 1;

    INSERT INTO PHIEUDANGKY (thoiGianDK, trangThai, maDot, maNguoiHien)
    VALUES (GETDATE(), N'Đã đăng ký', @maDot, @maNguoiHien);
END;
GO

CREATE OR ALTER PROCEDURE sp_CapNhatKetQuaSangLoc
    @maDangKy INT,
    @maNhanVienYTe INT,
    @huyetAp VARCHAR(10),
    @canNang FLOAT,
    @nhomMau NVARCHAR(5),
    @ketQuaXN NVARCHAR(500),
    @trangThai NVARCHAR(50),
    @lyDoKhongDat NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    IF @canNang < 45
        THROW 51000, N'Cân nặng không đủ điều kiện (<45kg).', 1;

    INSERT INTO PHIEUSANGLOC (thoiGianKham, huyetAp, canNang, nhomMau, ketQuaXN, trangThai, lyDoKhongDat, maDangKy, maNhanVienYTe)
    VALUES (GETDATE(), @huyetAp, @canNang, @nhomMau, @ketQuaXN, @trangThai, @lyDoKhongDat, @maDangKy, @maNhanVienYTe);
END;
GO

CREATE OR ALTER PROCEDURE sp_GhiNhanKetQuaHienMau
    @maPhieuSangLoc INT,
    @maNV_LayMau INT,
    @theTich INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Kiểm tra logic bắt buộc
    IF NOT EXISTS (SELECT 1 FROM PHIEUSANGLOC WHERE maPhieuSangLoc = @maPhieuSangLoc AND trangThai = N'Đạt')
        THROW 51000, N'Người hiến không đạt yêu cầu sàng lọc. Không thể lấy máu.', 1;

    INSERT INTO PHIEUHIENMAU (thoiGianHien, theTich, maNV_LayMau, maPhieuSangLoc)
    VALUES (GETDATE(), @theTich, @maNV_LayMau, @maPhieuSangLoc);
END;
GO

CREATE OR ALTER TRIGGER trg_KiemTraKhoangCachHienMau
ON PHIEUDANGKY
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @maNguoiHien INT;
    SELECT @maNguoiHien = maNguoiHien FROM inserted;

    -- Gọi Function kiểm tra
    IF dbo.fn_KiemTraDieuKienHienMau(@maNguoiHien) = 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51000, N'Lỗi: Người hiến chưa đủ thời gian chờ (12 tuần) kể từ lần hiến gần nhất.', 1;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_TuDongCapNhatTrangThai_KhiKham
ON PHIEUSANGLOC
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maDangKy INT, @trangThaiKham NVARCHAR(50);
    
    SELECT @maDangKy = maDangKy, @trangThaiKham = trangThai 
    FROM inserted;

    IF @trangThaiKham = N'Đạt'
        UPDATE PHIEUDANGKY SET trangThai = N'Đã check-in (Chờ lấy máu)' WHERE maDangKy = @maDangKy;
    ELSE
        UPDATE PHIEUDANGKY SET trangThai = N'Không đạt sức khỏe' WHERE maDangKy = @maDangKy;
END;
GO

CREATE OR ALTER TRIGGER trg_TuDongCapNhatTrangThai_KhiHien
ON PHIEUHIENMAU
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @maPhieuSangLoc INT, @maDangKy INT;

    -- Truy ngược từ PhieuSangLoc -> PhieuDangKy
    SELECT @maPhieuSangLoc = maPhieuSangLoc FROM inserted;
    SELECT @maDangKy = maDangKy FROM PHIEUSANGLOC WHERE maPhieuSangLoc = @maPhieuSangLoc;

    -- Đóng hồ sơ
    UPDATE PHIEUDANGKY SET trangThai = N'Hoàn thành' WHERE maDangKy = @maDangKy;
    
    -- Tự động kiểm tra nếu Đợt hiến máu đã đủ chỉ tiêu thì đóng đợt (Optional Feature)
    DECLARE @maDot INT, @SoLuongDaHien INT, @SoLuongDuKien INT;
    SELECT @maDot = maDot FROM PHIEUDANGKY WHERE maDangKy = @maDangKy;
    
    SELECT @SoLuongDuKien = soLuongDuKien FROM DOTHIENMAU WHERE maDot = @maDot;
    SELECT @SoLuongDaHien = COUNT(*) 
    FROM PHIEUHIENMAU PH 
    JOIN PHIEUSANGLOC PS ON PH.maPhieuSangLoc = PS.maPhieuSangLoc 
    JOIN PHIEUDANGKY DK ON PS.maDangKy = DK.maDangKy 
    WHERE DK.maDot = @maDot;

    IF @SoLuongDaHien >= @SoLuongDuKien
    BEGIN
        UPDATE DOTHIENMAU SET trangThai = N'Hoàn thành' WHERE maDot = @maDot;
    END
END;
GO

CREATE OR ALTER TRIGGER trg_ChanThayDoiDotHienMauDaKetThuc
ON DOTHIENMAU
FOR UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM deleted WHERE trangThai IN (N'Hoàn thành', N'Đã hủy'))
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51000, N'Lỗi bảo mật: Không thể chỉnh sửa hoặc xóa Đợt hiến máu đã Kết thúc hoặc Đã hủy. Dữ liệu này cần lưu trữ lịch sử.', 1;
    END
END;
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.2.3. Hàm thống kê máu theo đợt
CREATE OR ALTER FUNCTION fn_ThongKeMauTheoDot (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ISNULL(ps.nhomMau, N'Chưa xác định') AS NhomMau,
        COUNT(ph.maPhieuHM) AS SoLuongTuiMau,
        ISNULL(SUM(ph.theTich), 0) AS TongTheTich_ml
    FROM DOTHIENMAU dt
    INNER JOIN PHIEUDANGKY pdk ON dt.maDot = pdk.maDot
    INNER JOIN PHIEUSANGLOC ps ON pdk.maDangKy = ps.maDangKy
    INNER JOIN PHIEUHIENMAU ph ON ps.maPhieuSangLoc = ph.maPhieuSangLoc
    WHERE dt.maDot = @maDot
    GROUP BY ps.nhomMau
);
GO

-- =============================================
-- 3.3.3. Thủ tục cập nhật kết quả sàng lọc
-- =============================================
CREATE OR ALTER PROCEDURE sp_CapNhatKetQuaSangLoc
    @maDangKy INT,
    @maNhanVienYTe INT,
    @huyetAp VARCHAR(10),
    @canNang FLOAT,
    @nhomMau NVARCHAR(25),
    @ketQuaXN NVARCHAR(500),
    @trangThai NVARCHAR(50), 
    @lyDoKhongDat NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Kiểm tra logic cân nặng (Chỉ số sinh tồn)
    IF @canNang < 45
    BEGIN
        SET @trangThai = N'Không đạt';
        SET @lyDoKhongDat = ISNULL(@lyDoKhongDat, N'') + N' - Cân nặng không đủ điều kiện (<45kg).';
    END
    -- 2. Thêm dữ liệu vào bảng PHIEUSANGLOC
    INSERT INTO PHIEUSANGLOC (thoiGianKham, huyetAp, canNang, nhomMau, ketQuaXN, trangThai, lyDoKhongDat, maDangKy, maNhanVienYTe)
    VALUES (GETDATE(), @huyetAp, @canNang, @nhomMau, @ketQuaXN, @trangThai, @lyDoKhongDat, @maDangKy, @maNhanVienYTe);

    PRINT N'Ghi nhận kết quả sàng lọc thành công. Trạng thái phiếu đăng ký đã được hệ thống tự động cập nhật.';
END;
GO

-- =============================================
-- 3.4.2. Trigger tự động cập nhật trạng thái
-- =============================================
CREATE OR ALTER TRIGGER trg_TuDongCapNhatTrangThai_KhiKham
ON PHIEUSANGLOC
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Cập nhật cho trường hợp 'Đạt'
    UPDATE pdk
    SET pdk.trangThai = N'Đã check-in (Chờ lấy máu)'
    FROM PHIEUDANGKY pdk
    JOIN inserted i ON pdk.maDangKy = i.maDangKy
    WHERE i.trangThai = N'Đạt';

    -- Cập nhật cho trường hợp 'Không đạt'
    UPDATE pdk
    SET pdk.trangThai = N'Không đạt sức khỏe'
    FROM PHIEUDANGKY pdk
    JOIN inserted i ON pdk.maDangKy = i.maDangKy
    WHERE i.trangThai = N'Không đạt';
END;
GO