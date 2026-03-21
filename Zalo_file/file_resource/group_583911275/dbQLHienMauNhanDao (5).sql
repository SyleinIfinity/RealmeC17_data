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
    --UPDATE 

    PRINT N'Ghi nhận kết quả sàng lọc thành công. Trạng thái phiếu đăng ký đã được hệ thống tự động cập nhật.';
END;
GO

-- =============================================
-- 3.4.2. Trigger tự động cập nhật trạng thái
-- =============================================
CREATE OR ALTER TRIGGER trg_tuDongTaoPhieuSangLoc
ON PHIEUDANGKY
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

CREATE OR ALTER TRIGGER trg_tuDongTaoPhieuHienMau
ON PHIEUSANGLOC
AFTER UPDATE
AS
BEGIN
 --...
END
go

--Hàm xem danh sách nhân viên tham gia
CREATE FUNCTION fn_XemDanhSachNhanVienThamGia (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        nv.hoTen AS TenNhanVien,
        nv.chucDanh AS ChucDanh,
        ct.nhiemVu AS NhiemVuCuThe
    FROM 
        DOTHIENMAU dt
    JOIN 
        DANHSACHNHANVIENTHAMGIA ds ON dt.maDot = ds.maDot
    JOIN 
        CHITIETDANHSACH ct ON ds.maDS = ct.maDS
    JOIN 
        NHANVIENYTE nv ON ct.maNhanVienYTe = nv.maNhanVienYTe
    WHERE 
        dt.maDot = @maDot
);
GO
--Xem danh sách nhân viên của đợt hiến máu có mã là 1
SELECT * FROM fn_XemDanhSachNhanVienThamGia(1);
GO
--Thủ tục đăng ký tài khoản người hiến

CREATE PROCEDURE sp_DangKyTaiKhoanNguoiHien
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

--Cách gọi thủ tục
EXEC sp_DangKyTaiKhoanNguoiHien 
    @tenDangNhap = 'nguyenvanan', 
    @matKhau = 'MatKhau123', 
    @soDienThoai = '0905123456', 
    @hoTen = N'Nguyễn Văn An', 
    @soCMND_CCCD = '048090000111', 
    @ngaySinh = '1995-05-20', 
    @gioiTinh = N'Nam', 
    @diaChi = N'Hải Châu, Đà Nẵng';
GO
--Trigger bảo toàn lịch sử
IF OBJECT_ID('trg_ChanThayDoiDotHienMauDaKetThuc') IS NOT NULL
    DROP TRIGGER trg_ChanThayDoiDotHienMauDaKetThuc;
GO

CREATE TRIGGER trg_ChanThayDoiDotHienMauDaKetThuc
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

-- 2 -> phiếu sàng lọc với phiếu hiến máu

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


-- =============================================
-- Procedure: sp_GhiNhanKetQuaHienMau
-- Mục đích: Ghi nhận KẾT QUẢ CUỐI CÙNG sau khi lấy máu thành công
-- Người gọi: Nhân viên y tế (có quyền NV_LAY_MAU)
-- Input: 
--   @maPhieuSangLoc: Phiếu sàng lọc ĐÃ ĐẠT
--   @maNV_LayMau: Nhân viên thực hiện
--   @theTich: 250, 350, hoặc 450 ml
--   @ghiChu: Ghi chú thêm (có thể NULL)
-- Output: 
--   Success: Return 1 + Mã phiếu hiến mới
--   Fail: THROW error
-- =============================================
CREATE OR ALTER PROCEDURE sp_GhiNhanKetQuaHienMau
    @maPhieuHM INT,
	@thoiGian DATETIME,
    @theTich INT
AS
BEGIN
    -- BƯỚC 0: Thiết lập môi trường an toàn
    SET NOCOUNT ON;  -- Tắt thông báo "X rows affected" để tăng hiệu năng
    SET XACT_ABORT ON;  -- Tự động rollback nếu có lỗi runtime
    
    DECLARE @maDangKy INT;
	DECLARE @ErrorMessage NVARCHAR(500);
    
    BEGIN TRY
        BEGIN TRANSACTION;  -- Bắt đầu transaction để đảm bảo tính nguyên tử
        -- ============================================
        -- BƯỚC 3: VALIDATE - Kiểm tra thể tích hợp lệ
        -- ============================================
        IF @theTich NOT IN (250, 350, 450)
        BEGIN
            SET @ErrorMessage = N'Lỗi: Thể tích máu không hợp lệ. Chỉ chấp nhận: 250ml, 350ml, hoặc 450ml. Giá trị nhận được: ' 
                              + CAST(@theTich AS NVARCHAR(10)) + N'ml';
            THROW 50004, @ErrorMessage, 1;
        END
        -- ============================================
        -- BƯỚC 5: THỰC THI - Ghi nhận kết quả hiến máu
        -- ============================================
		-- Cập nhật PHIEUHIENMAU thoiGian, theTich
		-- + Điều kiện maPhieuHM =@maPhieuHM
        -- Lấy ID phiếu hiến máu vừa tạo
        
        -- ============================================
        -- BƯỚC 6: CẬP NHẬT TRẠNG THÁI - Đánh dấu hoàn thành
        -- ============================================
        -- Cập nhật phiếu đăng ký sang trạng thái "Hoàn thành"
        UPDATE PHIEUDANGKY
        SET trangThai = N'Hoàn thành'
        WHERE maDangKy = @maDangKy;
        
        -- ============================================
        -- BƯỚC 7: COMMIT - Xác nhận transaction
        -- ============================================
        COMMIT TRANSACTION;
        
        -- Thông báo thành công
        PRINT N'✓ Ghi nhận hiến máu thành công!';
        PRINT N'  - Mã phiếu hiến máu: ' + CAST(@maPhieuHM AS NVARCHAR(10));
        PRINT N'  - Thể tích: ' + CAST(@theTich AS NVARCHAR(10)) + N' ml';
        PRINT N'  - Thời gian: ' + CONVERT(NVARCHAR(30), GETDATE(), 120);
        
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
        
        -- Log lỗi (trong production nên log vào bảng ErrorLog)
        PRINT N'✗ Lỗi xảy ra trong procedure sp_GhiNhanKetQuaHienMau:';
        PRINT N'  - Error Number: ' + CAST(@ErrorNumber AS NVARCHAR(10));
        PRINT N'  - Line: ' + CAST(@ErrorLine AS NVARCHAR(10));
        PRINT N'  - Message: ' + @ErrorMessageCatch;
        
        -- Re-throw error để application layer xử lý
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER TRIGGER trg_TuDongHoanThanhDot
ON PHIEUHIENMAU
AFTER UPDATE
AS
BEGIN
    -- BƯỚC 0: Thiết lập môi trường
    SET NOCOUNT ON;  -- Tắt thông báo "X rows affected"
    
    -- Khai báo biến
    DECLARE @maPhieuSangLoc INT;
    DECLARE @maDangKy INT;
    DECLARE @maDot INT;
    DECLARE @SoLuongDaHien INT;
    DECLARE @SoLuongDuKien INT;
    DECLARE @TyLeHoanThanh DECIMAL(5,2);
    DECLARE @TrangThaiDotHienTai NVARCHAR(50);
    
    -- ============================================
    -- BƯỚC 1: LẤY THÔNG TIN từ bản ghi vừa INSERT
    -- ============================================
    -- Bảng "inserted" là bảng ảo chứa dữ liệu vừa được thêm vào
    SELECT 
        @maPhieuSangLoc = i.maPhieuSangLoc
    FROM inserted i;
    
    -- ============================================
    -- BƯỚC 2: TRUY VẾT ngược lên Phiếu Đăng Ký và Đợt Hiến Máu
    -- ============================================
    -- Chain: PHIEUHIENMAU -> PHIEUSANGLOC -> PHIEUDANGKY -> DOTHIENMAU
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
        PRINT N'⚠ Cảnh báo: Không tìm thấy đợt hiến máu liên quan. Bỏ qua trigger.';
        RETURN;  -- Thoát trigger nhưng KHÔNG rollback transaction chính
    END
    
    -- ============================================
    -- BƯỚC 4: THỐNG KÊ - Đếm số lượng đã hiến trong đợt này
    -- ============================================
    -- Đếm tổng số túi máu đã thu được (không tính trùng)
    SELECT @SoLuongDaHien = COUNT(DISTINCT ph.maPhieuHM)
    FROM PHIEUHIENMAU ph
    INNER JOIN PHIEUSANGLOC ps 
        ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    INNER JOIN PHIEUDANGKY pdk 
        ON ps.maDangKy = pdk.maDangKy
    WHERE pdk.maDot = @maDot;
    
    -- Lấy chỉ tiêu dự kiến của đợt
    SELECT 
        @SoLuongDuKien = soLuongDuKien
    FROM DOTHIENMAU 
    WHERE maDot = @maDot;
    
    -- Tính tỷ lệ hoàn thành (%)
    IF @SoLuongDuKien > 0
        SET @TyLeHoanThanh = (CAST(@SoLuongDaHien AS DECIMAL(10,2)) / @SoLuongDuKien) * 100;
    ELSE
        SET @TyLeHoanThanh = 0;
    
    -- Log thông tin
    PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    PRINT N'📊 THỐNG KÊ ĐỢT HIẾN MÁU #' + CAST(@maDot AS NVARCHAR(10));
    PRINT N'   - Đã thu: ' + CAST(@SoLuongDaHien AS NVARCHAR(10)) + N' túi máu';
    PRINT N'   - Chỉ tiêu: ' + CAST(@SoLuongDuKien AS NVARCHAR(10)) + N' túi máu';
    PRINT N'   - Hoàn thành: ' + CAST(@TyLeHoanThanh AS NVARCHAR(10)) + N'%';
    PRINT N'   - Trạng thái hiện tại: ' + @TrangThaiDotHienTai;
    
    -- ============================================
    -- BƯỚC 5: KIỂM TRA ĐIỀU KIỆN ĐÓNG ĐỢT
    -- ============================================
    -- Điều kiện 1: Đợt đang ở trạng thái "Đang diễn ra"
    -- Điều kiện 2: Đã đạt hoặc vượt chỉ tiêu
    IF @TrangThaiDotHienTai = N'Đang diễn ra' 
       AND @SoLuongDaHien >= @SoLuongDuKien
    BEGIN
        -- ============================================
        -- BƯỚC 6: TỰ ĐỘNG ĐÓNG ĐỢT HIẾN MÁU
        -- ============================================
        UPDATE DOTHIENMAU
        SET 
            trangThai = N'Hoàn thành'
            -- Có thể thêm: ngayHoanThanh = GETDATE()
        WHERE maDot = @maDot;
        
        -- Log thông báo quan trọng
        PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
        PRINT N'🎉 CHÚC MỪNG! Đợt hiến máu #' + CAST(@maDot AS NVARCHAR(10)) + N' đã HOÀN THÀNH chỉ tiêu!';
        PRINT N'   ✓ Trạng thái: "Đang diễn ra" → "Hoàn thành"';
        PRINT N'   ✓ Đã thu: ' + CAST(@SoLuongDaHien AS NVARCHAR(10)) + N' / ' + CAST(@SoLuongDuKien AS NVARCHAR(10)) + N' túi máu';
        PRINT N'   ✓ Đạt: ' + CAST(@TyLeHoanThanh AS NVARCHAR(10)) + N'%';
        PRINT N'   ✓ Thời gian đóng: ' + CONVERT(NVARCHAR(30), GETDATE(), 120);
        PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
        
        -- ============================================
        -- BƯỚC 7: CÁC HÀNH ĐỘNG KÈM THEO (Tùy chọn)
        -- ============================================
        -- TODO: Trong production, có thể thêm:
        -- 1. Gửi email/SMS thông báo cho quản lý
        -- 2. Trigger workflow tiếp theo (vận chuyển máu về kho)
        -- 3. Cập nhật bảng thống kê tổng hợp
        -- 4. Khóa form đăng ký thêm người hiến
        
        -- Ví dụ: Insert vào bảng log hệ thống
        /*
        INSERT INTO SystemLog (EventType, EventMessage, CreatedAt)
        VALUES (
            'DOT_HOAN_THANH',
            N'Đợt #' + CAST(@maDot AS NVARCHAR(10)) + N' đã hoàn thành tự động',
            GETDATE()
        );
        */
        
    END
    ELSE
    BEGIN
        -- Đợt chưa hoàn thành, hiển thị thông tin theo dõi
        PRINT N'   ⏳ Đợt hiến máu vẫn đang tiếp tục...';
        PRINT N'   📍 Còn thiếu: ' + CAST((@SoLuongDuKien - @SoLuongDaHien) AS NVARCHAR(10)) + N' túi máu';
        PRINT N'━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    END
    
END;
GO

-- =============================================
-- Test Trigger
-- =============================================
/*
-- Giả sử đợt #1 có chỉ tiêu 10 túi máu

-- Test 1: Insert túi máu thứ 9 (chưa đủ)
INSERT INTO PHIEUHIENMAU (thoiGianHien, theTich, maNV_LayMau, maPhieuSangLoc)
VALUES (GETDATE(), 350, 5, 9);
-- Kết quả: Trạng thái đợt vẫn là "Đang diễn ra"

-- Test 2: Insert túi máu thứ 10 (đủ chỉ tiêu)
INSERT INTO PHIEUHIENMAU (thoiGianHien, theTich, maNV_LayMau, maPhieuSangLoc)
VALUES (GETDATE(), 350, 5, 10);
-- Kết quả: Trigger tự động đổi trạng thái đợt → "Hoàn thành"

-- Verify kết quả
SELECT maDot, trangThai, soLuongDuKien 
FROM DOTHIENMAU 
WHERE maDot = 1;
*/
