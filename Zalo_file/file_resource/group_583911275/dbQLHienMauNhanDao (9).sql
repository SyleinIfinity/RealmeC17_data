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
    maNhanVienYTe INT NULL, 
    
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
    theTich INT NULL, 
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

-- =======================================================================================================================
-- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION -- FUNCTION --
-- =======================================================================================================================

-- số 1
-- Function: Kiểm tra Điều kiện Hiến máu
CREATE OR ALTER FUNCTION fn_KiemTraDieuKienHienMau (@maNguoiHien INT)
RETURNS BIT
AS
BEGIN
    DECLARE @NgayHienGanNhat DATETIME;
    DECLARE @KetQua BIT;

    -- BƯỚC 1: LẤY NGÀY HIẾN MÁU THÀNH CÔNG GẦN NHẤT
    -- Sử dụng bí danh: ph (PhieuHienMau), ps (PhieuSangLoc), pdk (PhieuDangKy)
    -- Sử dụng cách nối bảng qua WHERE
    SELECT TOP 1 @NgayHienGanNhat = ph.thoiGianHien
    FROM PHIEUHIENMAU ph, PHIEUSANGLOC ps, PHIEUDANGKY pdk
    WHERE ph.maPhieuSangLoc = ps.maPhieuSangLoc
      AND ps.maDangKy = pdk.maDangKy
      AND pdk.maNguoiHien = @maNguoiHien
    ORDER BY ph.thoiGianHien DESC;

    -- BƯỚC 2: SO SÁNH VỚI NGÀY HIỆN TẠI
    -- Nếu chưa hiến lần nào (NULL) HOẶC khoảng cách >= 84 ngày -> Đủ điều kiện (1)
    -- Ngược lại -> Không đủ điều kiện (0)
    IF @NgayHienGanNhat IS NULL OR DATEDIFF(DAY, @NgayHienGanNhat, GETDATE()) >= 84
        SET @KetQua = 1;
    ELSE
        SET @KetQua = 0;

    RETURN @KetQua;
END;
GO
-- số 2
-- 3.2.3. Hàm thống kê máu theo đợt
-- =============================================
-- Chức năng:
--   Thống kê số lượng túi máu và tổng thể tích (ml)
--   theo từng nhóm máu trong một đợt hiến máu xác định
-- Tham số:
--   @maDot: Mã đợt hiến máu cần thống kê
-- =============================================
CREATE OR ALTER FUNCTION fn_ThongKeMauTheoDot (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    -- BƯỚC 1: XÁC ĐỊNH ĐỢT HIẾN MÁU CẦN THỐNG KÊ
    -- Lọc dữ liệu theo mã đợt hiến máu được truyền vào
    SELECT 
        -- BƯỚC 2: XỬ LÝ NHÓM MÁU
        -- Nếu chưa xác định nhóm máu thì gán giá trị mặc định
        ISNULL(ps.nhomMau, N'Chưa xác định') AS NhomMau,

        -- BƯỚC 3: THỐNG KÊ SỐ LƯỢNG TÚI MÁU
        -- Đếm số phiếu hiến máu hợp lệ trong đợt
        COUNT(ph.maPhieuHM) AS SoLuongTuiMau,

        -- BƯỚC 4: THỐNG KÊ TỔNG THỂ TÍCH MÁU
        -- Cộng tổng thể tích các túi máu (đơn vị ml)
        ISNULL(SUM(ph.theTich), 0) AS TongTheTich_ml
    FROM DOTHIENMAU dt

        -- BƯỚC 5: LIÊN KẾT CÁC BẢNG THEO QUY TRÌNH NGHIỆP VỤ
        -- Đợt hiến máu → Phiếu đăng ký → Phiếu sàng lọc → Phiếu hiến máu
        INNER JOIN PHIEUDANGKY pdk ON dt.maDot = pdk.maDot
        INNER JOIN PHIEUSANGLOC ps ON pdk.maDangKy = ps.maDangKy
        INNER JOIN PHIEUHIENMAU ph ON ps.maPhieuSangLoc = ph.maPhieuSangLoc

    -- BƯỚC 6: ĐIỀU KIỆN LỌC THEO ĐỢT
    WHERE dt.maDot = @maDot

    -- BƯỚC 7: NHÓM DỮ LIỆU THEO NHÓM MÁU
    GROUP BY ps.nhomMau
);
GO

-- số 3
-- Hàm lấy lịch sử hiến máu cá nhân
CREATE OR ALTER FUNCTION fn_LayLichSuHienMauCaNhan 
(
    @maNguoiHien INT  -- Mã người hiến cần xem lịch sử
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        -- BƯỚC 1: Lấy thông tin cơ bản về lần hiến
        ph.maPhieuHM AS MaPhieu,
        ph.thoiGianHien AS ThoiGianHien,
        ph.theTich AS TheTich_ml,
        
        -- BƯỚC 2: Lấy thông tin sức khỏe tại thời điểm hiến
        ps.nhomMau AS NhomMau,
        ps.huyetAp AS HuyetAp,
        ps.canNang AS CanNang_kg,
        ps.ketQuaXN AS KetQuaXetNghiem,
        
        -- BƯỚC 3: Lấy thông tin đợt hiến máu
        dt.tenDot AS TenDotHienMau,
        dt.diaDiem AS DiaDiem,
        dt.ngayBatDau AS NgayToChuc,
        
        -- BƯỚC 4: Lấy thông tin bệnh viện tổ chức
        bv.tenBV AS BenhVienToChuc,
        bv.diaChi AS DiaChiBenhVien,
        
        -- BƯỚC 5: Lấy thông tin nhân viên y tế
        nv.hoTen AS NhanVienLayMau,
        nv.chucDanh AS ChucDanh,
        
        -- BƯỚC 6: Tính toán thêm (Computed columns)
        DATEDIFF(DAY, ph.thoiGianHien, GETDATE()) AS SoNgayDaQua,
        
        -- BƯỚC 7: Kiểm tra có đủ điều kiện hiến lần tiếp không (84 ngày = 12 tuần)
        CASE 
            WHEN DATEDIFF(DAY, ph.thoiGianHien, GETDATE()) >= 84 
            THEN N'Đã đủ thời gian chờ'
            ELSE N'Chưa đủ ' + CAST(84 - DATEDIFF(DAY, ph.thoiGianHien, GETDATE()) AS NVARCHAR(10)) + N' ngày'
        END AS TrangThaiChoHienTiep

    FROM PHIEUHIENMAU ph
    
    -- JOIN BƯỚC 1: Liên kết với phiếu sàng lọc (để lấy thông tin sức khỏe)
    INNER JOIN PHIEUSANGLOC ps 
        ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    
    -- JOIN BƯỚC 2: Liên kết với phiếu đăng ký (cầu nối đến người hiến)
    INNER JOIN PHIEUDANGKY pdk 
        ON ps.maDangKy = pdk.maDangKy
    
    -- JOIN BƯỚC 3: Liên kết với đợt hiến máu
    INNER JOIN DOTHIENMAU dt 
        ON pdk.maDot = dt.maDot
    
    -- JOIN BƯỚC 4: Liên kết với người phụ trách đợt (để lấy bệnh viện)
    INNER JOIN NGUOIPHUTRACH npt 
        ON dt.maNPT = npt.maNPT
    
    -- JOIN BƯỚC 5: Liên kết với bệnh viện
    INNER JOIN BENHVIEN bv 
        ON npt.maBV = bv.maBV
    
    -- JOIN BƯỚC 6: Liên kết với nhân viên y tế (người lấy máu)
    INNER JOIN NHANVIENYTE nv 
        ON ph.maNV_LayMau = nv.maNhanVienYTe
    
    -- ĐIỀU KIỆN LỌC: Chỉ lấy dữ liệu của người hiến này
    WHERE pdk.maNguoiHien = @maNguoiHien
);
GO

-- số 4
--Hàm xem danh sách nhân viên tham gia
CREATE FUNCTION fn_XemDanhSachNhanVienThamGia (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        nv.hoTen AS TenNhanVien,      -- Lấy họ tên từ bảng Nhân viên
        nv.chucDanh AS ChucDanh,      -- Lấy chức danh nghề nghiệp
        ct.nhiemVu AS NhiemVuCuThe    -- Lấy nhiệm vụ được phân công trong đợt đó
    FROM 
        DOTHIENMAU dt
    -- Bước 1: Kết nối đợt hiến máu với bảng danh sách tham gia
    JOIN 
        DANHSACHNHANVIENTHAMGIA ds ON dt.maDot = ds.maDot
    
    -- Bước 2: Kết nối với bảng chi tiết để lấy mã từng nhân viên
    JOIN 
        CHITIETDANHSACH ct ON ds.maDS = ct.maDS
    
    -- Bước 3: Kết nối với bảng Nhân viên Y tế để lấy thông tin định danh (Tên, Chức danh)
    JOIN 
        NHANVIENYTE nv ON ct.maNhanVienYTe = nv.maNhanVienYTe
    
    -- Bước 4: Lọc dữ liệu theo mã đợt được truyền vào hàm
    WHERE 
        dt.maDot = @maDot
);
GO
--Xem danh sách nhân viên của đợt hiến máu có mã là 1
SELECT * FROM fn_XemDanhSachNhanVienThamGia(1);
GO

-- ====================================================================================================================
-- PROCEDURE -- PROCEDURE -- PROCEDURE -- PROCEDURE -- PROCEDURE -- PROCEDURE -- PROCEDURE -- PROCEDURE -- PROCEDURE -- 
-- ====================================================================================================================
-- số 1
-- Procedure: Đăng ký Lịch Hiến máu
CREATE OR ALTER PROCEDURE sp_DangKyLichHienMau
    @maDot INT,
    @maNguoiHien INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; -- Bắt đầu giao dịch

            -- BƯỚC 1: KIỂM TRA ĐỢT HIẾN MÁU
            -- d: DotHienMau
            IF NOT EXISTS (
                SELECT 1 
                FROM DOTHIENMAU d 
                WHERE d.maDot = @maDot 
                  AND d.ngayKetThuc >= GETDATE()
            )
            BEGIN
                THROW 51000, N'Đợt hiến máu không tồn tại hoặc đã kết thúc.', 1;
            END

            -- BƯỚC 2: KIỂM TRA TRÙNG LẶP
            -- pdk: PhieuDangKy
            IF EXISTS (
                SELECT 1 
                FROM PHIEUDANGKY pdk 
                WHERE pdk.maDot = @maDot 
                  AND pdk.maNguoiHien = @maNguoiHien
            )
            BEGIN
                THROW 51000, N'Bạn đã đăng ký tham gia đợt này rồi.', 1;
            END

            -- BƯỚC 3: KIỂM TRA ĐIỀU KIỆN SỨC KHỎE (Hàm)
            -- Gọi Function đã viết trước đó
            IF dbo.fn_KiemTraDieuKienHienMau(@maNguoiHien) = 0
            BEGIN
                THROW 51000, N'Chưa đủ 12 tuần kể từ lần hiến máu gần nhất.', 1;
            END

            -- BƯỚC 4: THỰC HIỆN ĐĂNG KÝ
            -- Chỉ chạy lệnh này khi 3 bước trên đã qua
            INSERT INTO PHIEUDANGKY (thoiGianDK, trangThai, maDot, maNguoiHien)
            VALUES (GETDATE(), N'Đã đăng ký', @maDot, @maNguoiHien);

        COMMIT TRANSACTION; -- Thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; -- Thất bại -> Rollback
        THROW;
    END CATCH
END;
GO

-- số 2
-- =============================================
-- 3.3.3. Thủ tục cập nhật kết quả sàng lọc 
-- =============================================
CREATE OR ALTER PROCEDURE sp_CapNhatKetQuaSangLoc
    @maDangKy INT,
    @maNhanVienYTe INT,
    @huyetAp VARCHAR(10), 
    @canNang FLOAT,
    @nhomMau NVARCHAR(5),
    @ketQuaXN NVARCHAR(500),
    @trangThai NVARCHAR(50), 
    @lyDoKhongDat NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- BƯỚC 1: KIỂM TRA SỰ TỒN TẠI
    IF NOT EXISTS (SELECT 1 FROM PHIEUSANGLOC WHERE maDangKy = @maDangKy)
    BEGIN
        PRINT N'Lỗi: Hồ sơ sàng lọc chưa được khởi tạo.';
        RETURN;
    END

    -- BƯỚC 2: PHÂN TÍCH HUYẾT ÁP
    DECLARE @TamThu INT, @TamTruong INT;
    BEGIN TRY
        SET @TamThu = CAST(LEFT(@huyetAp, CHARINDEX('/', @huyetAp) - 1) AS INT);
        SET @TamTruong = CAST(SUBSTRING(@huyetAp, CHARINDEX('/', @huyetAp) + 1, LEN(@huyetAp)) AS INT);
        
        -- Kiểm tra logic y tế (Huyết áp quá cao hoặc quá thấp)
        IF (@TamThu < 100 OR @TamThu > 145) OR (@TamTruong < 60 OR @TamTruong > 95)
        BEGIN
            SET @trangThai = N'Không đạt';
            SET @lyDoKhongDat = ISNULL(@lyDoKhongDat, N'') + N' [Hệ thống]: Huyết áp bất thường (' + @huyetAp + N').';
        END
    END TRY
    BEGIN CATCH
        RAISERROR(N'Lỗi: Định dạng huyết áp không đúng (VD: 120/80).', 16, 1);
        RETURN;
    END CATCH

    -- BƯỚC 3: KIỂM TRA CÂN NẶNG 
    IF @canNang <= 40
    BEGIN
        DECLARE @CanNangStr NVARCHAR(10) = CAST(@canNang AS NVARCHAR(10));
        RAISERROR(N'Lỗi: Cân nặng %s kg không hợp lệ (Phải > 40).', 16, 1, @CanNangStr);
        RETURN;
    END

    IF @canNang < 45
    BEGIN
        SET @trangThai = N'Không đạt';
        SET @lyDoKhongDat = ISNULL(@lyDoKhongDat, N'') + N' [Hệ thống]: Cân nặng thấp (<45kg).';
    END

    -- BƯỚC 4: QUÉT TỪ KHOÁ XÉT NGHIỆM
    IF @ketQuaXN LIKE N'%Dương tính%' OR @ketQuaXN LIKE N'%Positive%'
    BEGIN
        SET @trangThai = N'Không đạt';
        SET @lyDoKhongDat = ISNULL(@lyDoKhongDat, N'') + N' [Hệ thống]: Kết quả XN có bất thường.';
    END

    -- BƯỚC 5: KIỂM TRA LÝ DO KHI KHÔNG ĐẠT
    IF @trangThai = N'Không đạt' AND (ISNULL(@lyDoKhongDat, '') = '')
    BEGIN
        RAISERROR(N'Lỗi: Bắt buộc phải có lý do nếu kết luận Không đạt.', 16, 1);
        RETURN;
    END

    -- BƯỚC 6: CẬP NHẬT
    BEGIN TRY
        UPDATE PHIEUSANGLOC
        SET 
            maNhanVienYTe = @maNhanVienYTe,
            huyetAp = @huyetAp,
            canNang = @canNang,
            nhomMau = @nhomMau,
            ketQuaXN = @ketQuaXN,
            trangThai = @trangThai,
            lyDoKhongDat = @lyDoKhongDat,
            thoiGianKham = GETDATE()
        WHERE maDangKy = @maDangKy;

        PRINT N'Đã cập nhật kết quả sàng lọc thành công cho mã #' + CAST(@maDangKy AS VARCHAR);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH
END;
GO

-- số 3
CREATE OR ALTER PROCEDURE sp_GhiNhanKetQuaHienMau
    @maPhieuHM INT,           
    @maPhieuSangLoc INT,
    @maNV_LayMau INT,
    @theTich INT,
    @ghiChu NVARCHAR(500) = NULL
AS
BEGIN
    -- BƯỚC 0: Thiết lập môi trường an toàn
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    -- Khai báo biến
    DECLARE @trangThaiSangLoc NVARCHAR(50);
    DECLARE @maDangKy INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- ============================================
        -- BƯỚC 1: VALIDATE - Kiểm tra phiếu sàng lọc
        -- ============================================
        SELECT 
            @trangThaiSangLoc = trangThai,
            @maDangKy = maDangKy
        FROM PHIEUSANGLOC 
        WHERE maPhieuSangLoc = @maPhieuSangLoc;
        
        -- Kiểm tra 1.1: Phiếu sàng lọc có tồn tại?
        IF @trangThaiSangLoc IS NULL
        BEGIN
            SET @ErrorMessage = N'Lỗi: Không tìm thấy phiếu sàng lọc #' 
                              + CAST(@maPhieuSangLoc AS NVARCHAR(10));
            THROW 50001, @ErrorMessage, 1;
        END
        
        -- Kiểm tra 1.2: Kết quả sàng lọc ĐẠT?
        IF @trangThaiSangLoc <> N'Đạt'
        BEGIN
            SET @ErrorMessage = N'Lỗi: Phiếu sàng lọc #' + CAST(@maPhieuSangLoc AS NVARCHAR(10)) 
                              + N' có trạng thái "' + @trangThaiSangLoc 
                              + N'". Chỉ chấp nhận trạng thái "Đạt".';
            THROW 50002, @ErrorMessage, 1;
        END
        
        -- ============================================
        -- BƯỚC 2: VALIDATE - Kiểm tra phiếu hiến máu tồn tại
        -- ============================================
        IF NOT EXISTS (
            SELECT 1 
            FROM PHIEUHIENMAU 
            WHERE maPhieuHM = @maPhieuHM
        )
        BEGIN
            SET @ErrorMessage = N'Lỗi: Không tìm thấy phiếu hiến máu #' 
                              + CAST(@maPhieuHM AS NVARCHAR(10));
            THROW 50003, @ErrorMessage, 1;
        END
        
        -- ============================================
        -- BƯỚC 3: VALIDATE - Kiểm tra thể tích hợp lệ
        -- ============================================
        IF @theTich NOT IN (250, 350, 450)
        BEGIN
            SET @ErrorMessage = N'Lỗi: Thể tích máu không hợp lệ. ' 
                              + N'Chỉ chấp nhận: 250ml, 350ml, hoặc 450ml. '
                              + N'Giá trị nhận được: ' + CAST(@theTich AS NVARCHAR(10)) + N'ml';
            THROW 50004, @ErrorMessage, 1;
        END
        

        UPDATE PHIEUHIENMAU
        SET 
            thoiGianHien = GETDATE(),           
            theTich = @theTich,                 
            maNV_LayMau = @maNV_LayMau,         
            maPhieuSangLoc = @maPhieuSangLoc   
        WHERE maPhieuHM = @maPhieuHM;
        
        -- Kiểm tra có cập nhật được không?
        IF @@ROWCOUNT = 0
        BEGIN
            SET @ErrorMessage = N'Lỗi: Không thể cập nhật phiếu hiến máu #' 
                              + CAST(@maPhieuHM AS NVARCHAR(10));
            THROW 50005, @ErrorMessage, 1;
        END
        
        -- ============================================
        -- BƯỚC 6: CẬP NHẬT TRẠNG THÁI - Đánh dấu hoàn thành
        -- ============================================
        UPDATE PHIEUDANGKY
        SET trangThai = N'Hoàn thành'
        WHERE maDangKy = @maDangKy;
        
        -- ============================================
        -- BƯỚC 7:Xác nhận transaction
        -- ============================================
        COMMIT TRANSACTION;
        
        -- Trả về thông tin xác nhận
        SELECT 
            @maPhieuHM AS MaPhieuHienMau,
            @theTich AS TheTich,
            GETDATE() AS ThoiGianCapNhat,
            N'Thành công' AS TrangThai;
        
    END TRY
    BEGIN CATCH
        -- ============================================
        -- XỬ LÝ LỖI: Rollback và log chi tiết
        -- ============================================
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Lấy thông tin lỗi chi tiết
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorMessageCatch NVARCHAR(4000) = ERROR_MESSAGE();
        
        -- Log lỗi
        PRINT N'✗ Lỗi xảy ra trong procedure sp_GhiNhanKetQuaHienMau:';
        PRINT N'  - Error Number: ' + CAST(@ErrorNumber AS NVARCHAR(10));
        PRINT N'  - Line: ' + CAST(@ErrorLine AS NVARCHAR(10));
        PRINT N'  - Message: ' + @ErrorMessageCatch;
        
        -- Re-throw error
        THROW;
    END CATCH
END;
GO

-- số 4
--Thủ tục đăng ký tài khoản người hiến

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
    SET NOCOUNT ON; -- Tắt thông báo số dòng bị ảnh hưởng để tăng hiệu năng

    BEGIN TRY
        -- Bắt đầu giao dịch
        BEGIN TRANSACTION;

        -- 1. Kiểm tra tên đăng nhập đã tồn tại chưa
        IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE tenDangNhap = @tenDangNhap)
        BEGIN
            -- Nếu tồn tại thì ném lỗi và hủy giao dịch ngay lập tức
            THROW 50001, N'Tên đăng nhập đã tồn tại, vui lòng chọn tên khác.', 1;
        END

        -- Kiểm tra thêm: CMND/CCCD đã tồn tại chưa (tránh lỗi constraint sau này)
        IF EXISTS (SELECT 1 FROM NGUOIHIEN WHERE soCMND_CCCD = @soCMND_CCCD)
        BEGIN
            THROW 50002, N'Số CMND/CCCD này đã được đăng ký trong hệ thống.', 1;
        END

        -- 2. Thêm mới vào bảng TAIKHOAN
        DECLARE @NewMaTK INT;
        
        INSERT INTO TAIKHOAN (tenDangNhap, matKhau, vaiTro, soDienThoai, trangThai)
        VALUES (@tenDangNhap, @matKhau, 'NguoiHien', @soDienThoai, N'Hoạt động');

        -- 3. Lấy ID (maTK) vừa sinh ra
        SET @NewMaTK = SCOPE_IDENTITY();

        -- 4. Thêm mới vào bảng NGUOIHIEN với ID tài khoản đó
        INSERT INTO NGUOIHIEN (hoTen, soCMND_CCCD, ngaySinh, gioiTinh, diaChi, maTK)
        VALUES (@hoTen, @soCMND_CCCD, @ngaySinh, @gioiTinh, @diaChi, @NewMaTK);

        -- 5. Nếu mọi thứ ổn -> COMMIT
        COMMIT TRANSACTION;
        PRINT N'Đăng ký tài khoản thành công!';
    END TRY
    BEGIN CATCH
        -- 6. Nếu có lỗi bất kỳ -> ROLLBACK
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Hiển thị thông báo lỗi ra ngoài
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ========================================================================================================================
-- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER -- TRIGGER --
-- ========================================================================================================================
-- số 1
-- =============================================
-- 3.4.2. Trigger tự động tạo phiếu sàng lọc
-- =============================================
-- Chức năng:
--   Tự động khởi tạo phiếu sàng lọc khi trạng thái
--   phiếu đăng ký chuyển từ "Đã đăng ký" sang "Đã check-in"
-- Thời điểm kích hoạt:
--   Sau khi cập nhật (AFTER UPDATE) bảng PHIEUDANGKY
-- Phong A: Kham ; Phong B: Xet nghiem
-- 1: Kham -> cam xet nghiem -> Phong A trả vè trạng thái cần xét nghiệm
-- 2: He thong tao phieu sang loc
-- 3: Phong B load lai du lieu -> hiện lên ds
-- =============================================
CREATE OR ALTER TRIGGER trg_tuDongTaoPhieuSangLoc
ON PHIEUDANGKY
AFTER UPDATE 
AS
BEGIN
    SET NOCOUNT ON;

    -- BƯỚC 1: KIỂM TRA CỘT TRẠNG THÁI CÓ ĐƯỢC CẬP NHẬT HAY KHÔNG
    -- Trigger chỉ xử lý khi có thay đổi ở cột trangThai
    IF UPDATE(trangThai)
    BEGIN

        -- BƯỚC 2: XÁC ĐỊNH CÁC BẢN GHI VỪA ĐƯỢC CẬP NHẬT
        -- So sánh dữ liệu trước (deleted) và sau (inserted)
        INSERT INTO PHIEUSANGLOC 
            (maDangKy, maNhanVienYTe, trangThai, lyDoKhongDat, thoiGianKham)
        SELECT 
            -- BƯỚC 3: LẤY THÔNG TIN PHIẾU ĐĂNG KÝ
            i.maDangKy, 

            -- BƯỚC 4: GÁN NHÂN VIÊN Y TẾ MẶC ĐỊNH
            -- Tạm thời gán mã 1, sẽ được cập nhật khi bác sĩ khám
            1, 

            -- BƯỚC 5: GÁN TRẠNG THÁI BAN ĐẦU CHO PHIẾU SÀNG LỌC
            N'Không đạt', 

            -- BƯỚC 6: THIẾT LẬP LÝ DO MẶC ĐỊNH
            -- Phục vụ kiểm tra logic: Không đạt phải có lý do
            N'Hệ thống: Đang chờ bác sĩ khám và cập nhật chỉ số',

            -- BƯỚC 7: GHI NHẬN THỜI GIAN TẠO PHIẾU SÀNG LỌC
            GETDATE()
        FROM inserted i
        JOIN deleted d ON i.maDangKy = d.maDangKy

        -- BƯỚC 8: ĐIỀU KIỆN KÍCH HOẠT NGHIỆP VỤ
        -- Chỉ tạo phiếu sàng lọc khi:
        --   - Trạng thái mới là "Đã check-in"
        --   - Trạng thái cũ là "Đã đăng ký"
        --   - Chưa tồn tại phiếu sàng lọc cho mã đăng ký này
        WHERE i.trangThai = N'Đã check-in' 
          AND d.trangThai = N'Đã đăng ký'
          AND NOT EXISTS (
                SELECT 1 
                FROM PHIEUSANGLOC 
                WHERE maDangKy = i.maDangKy
          );
    END
END;
GO

-- số 2
-- =============================================
-- 3.4.2. Trigger tự động cập nhật trạng thái phiếu hiến máu
-- =============================================
-- Chức năng:
--   Cập nhật trạng thái phiếu đăng ký hiến máu
--   dựa trên kết quả sàng lọc sức khỏe
-- =============================================
CREATE OR ALTER TRIGGER trg_tuDongTaoPhieuHienMau
ON PHIEUSANGLOC
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- BƯỚC 1: KIỂM TRA CỘT ĐƯỢC CẬP NHẬT
    -- Trigger chỉ xử lý khi trạng thái sàng lọc
    -- hoặc thời gian khám được cập nhật
    IF UPDATE(trangThai) OR UPDATE(thoiGianKham)
    BEGIN

        -- BƯỚC 2: CẬP NHẬT TRẠNG THÁI PHIẾU ĐĂNG KÝ
        -- Dựa trên kết quả sàng lọc sức khỏe
        UPDATE pdk
        SET pdk.trangThai = CASE 
                                WHEN i.trangThai = N'Đạt' 
                                    THEN N'Đã check-in (Chờ lấy máu)'
                                WHEN i.trangThai = N'Không đạt' 
                                    THEN N'Không đạt sức khỏe'
                                ELSE pdk.trangThai
                            END

        -- BƯỚC 3: LIÊN KẾT PHIẾU SÀNG LỌC VÀ PHIẾU ĐĂNG KÝ
        FROM PHIEUDANGKY pdk
        JOIN inserted i ON pdk.maDangKy = i.maDangKy;

        -- BƯỚC 4: GHI CHÚ
        -- Không so sánh trạng thái cũ để đảm bảo
        -- trạng thái luôn được đồng bộ chính xác
    END
END;
GO
-- số 3
CREATE OR ALTER TRIGGER trg_TuDongHoanThanhDot
ON PHIEUHIENMAU
AFTER UPDATE
AS
BEGIN
    -- BƯỚC 0: Thiết lập môi trường
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @maPhieuSangLoc INT;
    DECLARE @maDangKy INT;
    DECLARE @maDot INT;
    DECLARE @TongTheTichDaHien INT;
    DECLARE @TheTichDuKien INT;
    DECLARE @TyLeHoanThanh DECIMAL(5,2);
    DECLARE @TrangThaiDotHienTai NVARCHAR(50);
    DECLARE @TheTichVuaCapNhat INT;
    
    -- ============================================
    -- BƯỚC 1: LẤY THÔNG TIN từ bản ghi vừa UPDATE
    -- ============================================
    SELECT 
        @maPhieuSangLoc = i.maPhieuSangLoc,
        @TheTichVuaCapNhat = i.theTich
    FROM inserted i;
    
    -- Chỉ xử lý khi phiếu VỪA MỚI được cập nhật thông tin lấy máu
    -- (thoiGianHien chuyển từ NULL → có giá trị)
    IF NOT EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN deleted d ON i.maPhieuHM = d.maPhieuHM
        WHERE d.thoiGianHien IS NULL 
          AND i.thoiGianHien IS NOT NULL
    )
    BEGIN
        -- Không phải lần cập nhật đầu tiên, bỏ qua
        RETURN;
    END
    
    -- ============================================
    -- BƯỚC 2: TRUY VẾT ngược lên Đợt Hiến Máu
    -- ============================================
    SELECT 
        @maDangKy = ps.maDangKy,
        @maDot = pdk.maDot,
        @TrangThaiDotHienTai = dt.trangThai
    FROM inserted i
    INNER JOIN PHIEUSANGLOC ps 
        ON i.maPhieuSangLoc = ps.maPhieuSangLoc
    INNER JOIN PHIEUDANGKY pdk 
        ON ps.maDangKy = pdk.maDangKy
    INNER JOIN DOTHIENMAU dt 
        ON pdk.maDot = dt.maDot;
    
    -- Kiểm tra dữ liệu hợp lệ
    IF @maDot IS NULL
    BEGIN
        PRINT N'Cảnh báo: Không tìm thấy đợt hiến máu liên quan. Bỏ qua trigger.';
        RETURN;
    END
    
    -- ============================================
    -- BƯỚC 3: THỐNG KÊ - Tính TỔNG THỂ TÍCH
    -- ============================================
    SELECT @TongTheTichDaHien = ISNULL(SUM(ph.theTich), 0)
    FROM PHIEUHIENMAU ph
    INNER JOIN PHIEUSANGLOC ps 
        ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    INNER JOIN PHIEUDANGKY pdk 
        ON ps.maDangKy = pdk.maDangKy
    WHERE pdk.maDot = @maDot
      AND ph.thoiGianHien IS NOT NULL;
    
    -- Lấy thể tích dự kiến
    SELECT 
        @TheTichDuKien = soLuongDuKien
    FROM DOTHIENMAU 
    WHERE maDot = @maDot;
    
    -- Tính tỷ lệ hoàn thành
    IF @TheTichDuKien > 0
        SET @TyLeHoanThanh = (CAST(@TongTheTichDaHien AS DECIMAL(10,2)) / @TheTichDuKien) * 100;
    ELSE
        SET @TyLeHoanThanh = 0;
   
    
    -- ============================================
    -- BƯỚC 4: KIỂM TRA ĐIỀU KIỆN ĐÓNG ĐỢT
    -- ============================================
    IF @TrangThaiDotHienTai = N'Đang diễn ra' 
       AND @TongTheTichDaHien >= @TheTichDuKien
    BEGIN
        -- ============================================
        -- BƯỚC 5: TỰ ĐỘNG ĐÓNG ĐỢT HIẾN MÁU
        -- ============================================
        UPDATE DOTHIENMAU
        SET trangThai = N'Hoàn thành'
        WHERE maDot = @maDot;
        
        -- Tính số người đã hiến
        DECLARE @SoNguoiDaHien INT;
        SELECT @SoNguoiDaHien = COUNT(DISTINCT ph.maPhieuHM)
        FROM PHIEUHIENMAU ph
        INNER JOIN PHIEUSANGLOC ps ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
        INNER JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy
        WHERE pdk.maDot = @maDot
          AND ph.thoiGianHien IS NOT NULL;
        
        -- Tính thể tích trung bình/người
        DECLARE @TheTichTrungBinh DECIMAL(10,2);
        IF @SoNguoiDaHien > 0
            SET @TheTichTrungBinh = CAST(@TongTheTichDaHien AS DECIMAL(10,2)) / @SoNguoiDaHien;
        ELSE
            SET @TheTichTrungBinh = 0;
    END
    ELSE
    BEGIN
        -- ============================================
        -- BƯỚC 8: LOG TIẾN ĐỘ (Chưa đủ chỉ tiêu)
        -- ============================================
        DECLARE @TheTichConThieu INT = @TheTichDuKien - @TongTheTichDaHien;
        DECLARE @SoNguoiConThieu INT = CEILING(@TheTichConThieu / 350.0);
        
        PRINT N'   ⏳ Đợt hiến máu vẫn đang tiếp tục...';
        PRINT N'   📍 Còn thiếu: ' + CAST(@TheTichConThieu AS NVARCHAR(10)) + N' ml (≈ ' 
              + CAST(@TheTichConThieu / 1000.0 AS NVARCHAR(10)) + N' lít)';
        PRINT N'   📍 Ước tính cần: ' + CAST(@SoNguoiConThieu AS NVARCHAR(10)) + N' người nữa (nếu trung bình 350ml/người)';
        PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    END
    
END;
GO

-- số 4
CREATE OR ALTER TRIGGER trg_ChanThayDoiDotHienMauDaKetThuc
ON DOTHIENMAU
FOR UPDATE, DELETE
AS
BEGIN
    -- Kiểm tra bảng ảo DELETED (chứa dữ liệu cũ trước khi lệnh chạy)
    -- Nếu tồn tại bất kỳ dòng nào có trạng thái là 'Hoàn thành' hoặc 'Đã hủy'
    IF EXISTS (
        SELECT 1 
        FROM DELETED 
        WHERE trangThai IN (N'Hoàn thành', N'Đã hủy')
    )
    BEGIN
        -- Báo lỗi cho người dùng
        RAISERROR (N'Lỗi bảo mật: Không thể sửa đổi hoặc xóa các đợt hiến máu đã kết thúc (Hoàn thành/Đã hủy).', 16, 1);
        
        -- Hủy bỏ toàn bộ giao dịch, khôi phục dữ liệu cũ
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- số 5
CREATE OR ALTER TRIGGER trg_ChanXoaSuaPhieuHienMau
ON PHIEUHIENMAU
FOR DELETE, UPDATE
AS
BEGIN
    IF @@ROWCOUNT = 0 RETURN;

    -- Kiểm tra bảng INSERTED có rỗng không?
    IF NOT EXISTS (SELECT * FROM INSERTED)
    BEGIN
        -- INSERTED rỗng => Đây là hành động DELETE
        RAISERROR (N'LỖI: Cấm tuyệt đối hành vi xóa phiếu hiến máu!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    ELSE
    BEGIN
        -- INSERTED có dữ liệu => Đây là hành động UPDATE
        IF UPDATE(theTich) OR UPDATE(maPhieuSangLoc) OR UPDATE(thoiGianHien)
        BEGIN
            RAISERROR (N'LỖI: Cấm sửa các thông tin nhạy cảm!', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
GO

-- số 6
-- TRIGGER CHẶN SỬA PHIẾU SÀNG LỌC
CREATE OR ALTER TRIGGER trg_ChanSuaSangLocKhiDaHienMau
ON PHIEUSANGLOC
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Biến tạm để kiểm tra
    DECLARE @maPhieuSangLoc INT;
    DECLARE @DaHienMau BIT = 0;

    -- Lấy danh sách các phiếu sàng lọc đang bị sửa
    SELECT @maPhieuSangLoc = maPhieuSangLoc FROM INSERTED;

    -- Kiểm tra xem phiếu sàng lọc này đã được dùng để hiến máu chưa?
    -- (Tức là đã tồn tại bên bảng PHIEUHIENMAU chưa)
    IF EXISTS (SELECT 1 FROM PHIEUHIENMAU WHERE maPhieuSangLoc = @maPhieuSangLoc)
    BEGIN
        SET @DaHienMau = 1;
    END

    -- NẾU ĐÃ HIẾN MÁU RỒI -> THÌ KIỂM TRA CHẶT CHẼ
    IF @DaHienMau = 1
    BEGIN
        -- 1. Cấm sửa trạng thái từ "Đạt" sang "Không đạt" (hoặc ngược lại)
        -- Vì máu đã lấy rồi, sửa trạng thái sẽ làm túi máu trở thành "hàng lậu" không rõ nguồn gốc.
        IF UPDATE(trangThai)
        BEGIN
            RAISERROR (N'LỖI LOGIC: Người này đã thực hiện lấy máu. Không thể thay đổi 
			kết quả sàng lọc (Đạt/Không đạt) vào lúc này. Vui lòng xử lý hủy túi máu trước.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Cấm sửa Nhóm máu
        -- Vì nhãn trên túi máu đã in theo kết quả cũ. Sửa ở đây sẽ lệch với túi máu thực tế.
        IF UPDATE(nhomMau)
        BEGIN
            RAISERROR (N'NGUY HIỂM: Đã thu nhận máu. Không được phép sửa "Nhóm máu" 
			 để tránh nhầm lẫn tai hại khi truyền máu.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- số 7
CREATE OR ALTER TRIGGER trg_KiemTraLichNhanVien
ON CHITIETDANHSACH
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra sự tồn tại của xung đột lịch trình
    IF EXISTS (
        SELECT 1
        FROM inserted i, 
             DANHSACHNHANVIENTHAMGIA ds_new, 
             DOTHIENMAU dot_new,
             CHITIETDANHSACH ct_old, 
             DANHSACHNHANVIENTHAMGIA ds_old, 
             DOTHIENMAU dot_old
        WHERE 
            -- 1. Nối bảng để lấy thông tin đợt HIỆN TẠI (đang insert)
            i.maDS = ds_new.maDS
            AND ds_new.maDot = dot_new.maDot

            -- 2. Nối bảng để lấy thông tin các đợt CŨ (đã phân công trước đó)
            AND i.maNhanVienYTe = ct_old.maNhanVienYTe -- Cùng một nhân viên
            AND ct_old.maDS = ds_old.maDS
            AND ds_old.maDot = dot_old.maDot

            -- 3. Điều kiện xung đột
            AND ds_new.maDS <> ds_old.maDS -- Phải là 2 danh sách khác nhau
            AND (
                -- Kiểm tra khoảng thời gian trùng nhau (Overlap check)
                (dot_new.ngayBatDau BETWEEN dot_old.ngayBatDau AND dot_old.ngayKetThuc)
                OR 
                (dot_new.ngayKetThuc BETWEEN dot_old.ngayBatDau AND dot_old.ngayKetThuc)
                OR
                -- Trường hợp đợt mới bao trùm hoàn toàn đợt cũ
                (dot_new.ngayBatDau <= dot_old.ngayBatDau 
				 AND dot_new.ngayKetThuc >= dot_old.ngayKetThuc)
            )
    )
    BEGIN
         RAISERROR (N'Lỗi nhân sự: Nhân viên này đã bị xếp lịch trùng 
		 ở một đợt hiến máu khác trong cùng khung giờ.', 16, 1);
         ROLLBACK TRANSACTION;
    END
END;
GO