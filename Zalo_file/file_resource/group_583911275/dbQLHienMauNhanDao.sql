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

-- ===============================================================
-- CÁC RÀNG BUỘC BỔ SUNG
-- ===============================================================

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

-- ==================================================================================
-- VÙNG NỘI DUNG CHO THỦ TỤC (PROCEDURE)
-- ==================================================================================

-- 1. THỦ TỤC: Đăng ký tài khoản mới cho Người hiến máu (Bao gồm cả Tài khoản & Hồ sơ)
-- Logic: Tạo tài khoản trước -> Lấy ID tài khoản -> Tạo hồ sơ người hiến
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
    BEGIN TRY
        BEGIN TRANSACTION;

            -- Bước 1: Tạo tài khoản
            INSERT INTO TAIKHOAN (tenDangNhap, matKhau, vaiTro, soDienThoai, trangThai)
            VALUES (@tenDangNhap, @matKhau, 'NguoiHien', @soDienThoai, N'Hoạt động');

            -- Lấy mã tài khoản vừa tạo
            DECLARE @newMaTK INT = SCOPE_IDENTITY();

            -- Bước 2: Tạo hồ sơ người hiến
            INSERT INTO NGUOIHIEN (hoTen, soCMND_CCCD, ngaySinh, gioiTinh, diaChi, maTK)
            VALUES (@hoTen, @soCMND_CCCD, @ngaySinh, @gioiTinh, @diaChi, @newMaTK);

        COMMIT TRANSACTION;
        PRINT N'Đăng ký tài khoản người hiến thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 2. THỦ TỤC: Đăng ký lịch hiến máu
-- Logic: Kiểm tra đợt hiến còn mở không, người này đã đăng ký chưa
CREATE OR ALTER PROCEDURE sp_DangKyLichHienMau
    @maDot INT,
    @maNguoiHien INT,
    @khungGioHen DATETIME
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra 1: Đợt hiến máu có tồn tại và chưa kết thúc
        IF NOT EXISTS (SELECT 1 FROM DOTHIENMAU WHERE maDot = @maDot 
													AND ngayKetThuc >= GETDATE())
        BEGIN
            THROW 51000, N'Đợt hiến máu này không tồn tại hoặc đã kết thúc.', 1;
        END

        -- Kiểm tra 2: Người này đã đăng ký trong đợt này chưa
        IF EXISTS (SELECT 1 FROM PHIEUDANGKY 
					WHERE maDot = @maDot 
						AND maNguoiHien = @maNguoiHien 
						AND trangThai != N'Hủy đăng ký')
        BEGIN
            THROW 51000, N'Bạn đã đăng ký tham gia đợt này rồi.', 1;
        END

        -- Thêm phiếu đăng ký
        INSERT INTO PHIEUDANGKY (thoiGianDK, khungGioHen, trangThai, maDot, maNguoiHien)
        VALUES (GETDATE(), @khungGioHen, N'Đã đăng ký', @maDot, @maNguoiHien);

        PRINT N'Đăng ký lịch thành công!';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 3. THỦ TỤC: Hủy đăng ký hiến máu
-- Logic: Chỉ cho phép hủy khi trạng thái là 'Đã đăng ký'. Không xóa dòng, chỉ đổi trạng thái.
CREATE OR ALTER PROCEDURE sp_HuyDangKyHienMau
    @maDangKy INT,
    @maNguoiHien INT -- Truyền thêm để bảo mật, đảm bảo chính chủ hủy
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra trạng thái hợp lệ
        IF NOT EXISTS (SELECT 1 FROM PHIEUDANGKY 
                       WHERE maDangKy = @maDangKy 
					   AND maNguoiHien = @maNguoiHien 
					   AND trangThai = N'Đã đăng ký')
        BEGIN
            THROW 51000, N'Không tìm thấy phiếu đăng ký hoặc phiếu đã được xử lý (không thể hủy).', 1;
        END

        -- Cập nhật trạng thái
        UPDATE PHIEUDANGKY
        SET trangThai = N'Hủy đăng ký'
        WHERE maDangKy = @maDangKy;

        PRINT N'Đã hủy đăng ký thành công.';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 4. THỦ TỤC: Cập nhật hồ sơ cá nhân
-- Logic: Cập nhật cả bảng NGUOIHIEN và số điện thoại trong TAIKHOAN
CREATE OR ALTER PROCEDURE sp_CapNhatHoSoCaNhan
    @maNguoiHien INT,
    @hoTen NVARCHAR(150),
    @diaChi NVARCHAR(255),
    @soDienThoaiMoi VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            
            -- Lấy mã tài khoản liên kết
            DECLARE @maTK INT;
            SELECT @maTK = maTK FROM NGUOIHIEN WHERE maNguoiHien = @maNguoiHien;

            -- Cập nhật thông tin cơ bản
            UPDATE NGUOIHIEN
            SET hoTen = @hoTen, diaChi = @diaChi
            WHERE maNguoiHien = @maNguoiHien;

            -- Cập nhật số điện thoại nếu có tài khoản
            IF @maTK IS NOT NULL AND @soDienThoaiMoi IS NOT NULL
            BEGIN
                UPDATE TAIKHOAN
                SET soDienThoai = @soDienThoaiMoi
                WHERE maTK = @maTK;
            END

        COMMIT TRANSACTION;
        PRINT N'Cập nhật hồ sơ thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 5. THỦ TỤC: Cập nhật kết quả sàng lọc (Khám sức khỏe)
-- Logic: Tạo phiếu sàng lọc. Nếu không đạt, ghi rõ lý do.
CREATE OR ALTER PROCEDURE sp_CapNhatKetQuaSangLoc
    @maDangKy INT,
    @maNhanVienYTe INT,
    @huyetAp VARCHAR(10),
    @canNang FLOAT,
    @nhomMau NVARCHAR(25),
    @ketQuaXN NVARCHAR(500),
    @trangThai NVARCHAR(50), -- 'Đạt' hoặc 'Không đạt'
    @lyDoKhongDat NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        IF @canNang <= 40
        BEGIN
            THROW 51000, N'Cân nặng không đủ điều kiện hiến máu (>40kg).', 1;
        END

        INSERT INTO PHIEUSANGLOC (thoiGianKham, huyetAp, canNang, nhomMau, 
					ketQuaXN, trangThai, lyDoKhongDat, maDangKy, maNhanVienYTe)
        VALUES (GETDATE(), @huyetAp, @canNang, @nhomMau, @ketQuaXN, 
					@trangThai, @lyDoKhongDat, @maDangKy, @maNhanVienYTe);

        -- Cập nhật trạng thái phiếu đăng ký để biết người này đã khám xong
        UPDATE PHIEUDANGKY 
        SET trangThai = N'Đã check-in' 
        WHERE maDangKy = @maDangKy;

        PRINT N'Lưu kết quả sàng lọc thành công.';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 6. THỦ TỤC: Ghi nhận kết quả hiến máu (Lấy máu thành công)
-- Logic: Chỉ cho phép ghi nhận nếu phiếu sàng lọc có trạng thái 'Đạt'
CREATE OR ALTER PROCEDURE sp_GhiNhanKetQuaHienMau
    @maPhieuSangLoc INT,
    @maNV_LayMau INT,
    @theTich INT -- 250, 350, 450
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra kết quả sàng lọc
        DECLARE @trangThaiSangLoc NVARCHAR(50);
        SELECT @trangThaiSangLoc = trangThai 
			FROM PHIEUSANGLOC WHERE maPhieuSangLoc = @maPhieuSangLoc;

        IF @trangThaiSangLoc IS NULL OR @trangThaiSangLoc = N'Không đạt'
        BEGIN
            THROW 51000, N'Phiếu sàng lọc ko hợp lệ hoặc ko đạt yêu cầu sức khỏe.', 1;
        END

        -- Insert kết quả
        INSERT INTO PHIEUHIENMAU (thoiGianHien, theTich, maNV_LayMau, maPhieuSangLoc)
        VALUES (GETDATE(), @theTich, @maNV_LayMau, @maPhieuSangLoc);

        PRINT N'Ghi nhận hiến máu thành công!';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 7. THỦ TỤC: Tạo đợt hiến máu mới
-- Logic: Insert thông tin đợt hiến máu cơ bản
CREATE OR ALTER PROCEDURE sp_TaoDotHienMauMoi
    @tenDot NVARCHAR(200),
    @ngayBatDau DATETIME,
    @ngayKetThuc DATETIME,
    @diaDiem NVARCHAR(200),
    @soLuongDuKien INT,
    @maNPT INT
AS
BEGIN
    BEGIN TRY
        IF @ngayKetThuc < @ngayBatDau
        BEGIN
            THROW 51000, N'Ngày kết thúc phải sau ngày bắt đầu.', 1;
        END

        INSERT INTO DOTHIENMAU (tenDot, ngayBatDau, 
						ngayKetThuc, diaDiem, soLuongDuKien, trangThai, maNPT)
        VALUES (@tenDot, @ngayBatDau, @ngayKetThuc, 
						@diaDiem, @soLuongDuKien, N'Lên kế hoạch', @maNPT);

        PRINT N'Tạo đợt hiến máu thành công.';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 8. THỦ TỤC: Phân công nhân viên tham gia đợt
-- Logic: Kiểm tra xem đã có Danh sách cho đợt này chưa. Nếu chưa -> Tạo danh sách -> Thêm nhân viên vào chi tiết.
CREATE OR ALTER PROCEDURE sp_PhanCongNhanVien
    @maDot INT,
    @maNhanVienYTe INT,
    @nhiemVu NVARCHAR(100),
    @maCodeNhiemVu VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            
            DECLARE @maDS INT;
            
            -- Kiểm tra xem đợt này đã khởi tạo danh sách chưa
            SELECT @maDS = maDS FROM DANHSACHNHANVIENTHAMGIA WHERE maDot = @maDot;

            -- Nếu chưa có danh sách, tạo mới
            IF @maDS IS NULL
            BEGIN
                INSERT INTO DANHSACHNHANVIENTHAMGIA (tenDS, ngayTao, maDot)
                VALUES (N'Danh sách nhân sự đợt ' + CAST(@maDot AS NVARCHAR(10)), GETDATE(), @maDot);
                
                SET @maDS = SCOPE_IDENTITY();
            END

            -- Thêm nhân viên vào danh sách chi tiết
            INSERT INTO CHITIETDANHSACH (maCodeNhiemVu, nhiemVu, maDS, maNhanVienYTe)
            VALUES (@maCodeNhiemVu, @nhiemVu, @maDS, @maNhanVienYTe);

        COMMIT TRANSACTION;
        PRINT N'Phân công nhân viên thành công.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 9. THỦ TỤC: Duyệt yêu cầu điều phối
-- Logic: Người quản lý duyệt hoặc từ chối phiếu điều phối
CREATE OR ALTER PROCEDURE sp_DuyetYeuCauDieuPhoi
    @maPhieuDP INT,
    @maNguoiDuyet INT,
    @trangThaiMoi NVARCHAR(50) -- 'Đã duyệt' hoặc 'Từ chối'
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra đầu vào
        IF @trangThaiMoi NOT IN (N'Đã duyệt', N'Từ chối')
        BEGIN
            THROW 51000, N'Trạng thái duyệt không hợp lệ.', 1;
        END

        UPDATE PHIEUDIEUPHOI
        SET trangThai = @trangThaiMoi,
            ngayDuyet = GETDATE(),
            maNguoiDuyet = @maNguoiDuyet
        WHERE maPhieuDP = @maPhieuDP;

        PRINT N'Đã cập nhật trạng thái phiếu điều phối.';
    END TRY
    BEGIN CATCH
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- ==================================================================================
-- VÙNG NỘI DUNG CHO CHỨC NĂNG (FUNCTION)
-- ==================================================================================

-- 1. HÀM KIỂM TRA ĐIỀU KIỆN HIẾN MÁU (Quan trọng nhất)
-- Mục đích: Kiểm tra xem người hiến đã đủ thời gian chờ (12 tuần = 84 ngày) kể từ lần hiến gần nhất chưa.
-- Trả về: 1 (Được phép hiến), 0 (Chưa đủ ngày)
CREATE OR ALTER FUNCTION fn_KiemTraDieuKienHienMau (@maNguoiHien INT)
RETURNS BIT
AS
BEGIN
    DECLARE @NgayHienGanNhat DATETIME;
    DECLARE @KetQua BIT;

    -- Lấy ngày hiến máu thành công gần nhất của người này
    -- Join từ PhieuHienMau -> PhieuSangLoc -> PhieuDangKy -> NguoiHien
    SELECT TOP 1 @NgayHienGanNhat = ph.thoiGianHien
    FROM PHIEUHIENMAU ph
    JOIN PHIEUSANGLOC ps ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy
    WHERE pdk.maNguoiHien = @maNguoiHien
    ORDER BY ph.thoiGianHien DESC;

    -- Nếu chưa hiến lần nào -> Được phép (1)
    IF @NgayHienGanNhat IS NULL
    BEGIN
        SET @KetQua = 1;
    END
    ELSE
    BEGIN
        -- Kiểm tra khoảng cách >= 84 ngày (12 tuần)
        IF DATEDIFF(DAY, @NgayHienGanNhat, GETDATE()) >= 84
            SET @KetQua = 1;
        ELSE
            SET @KetQua = 0;
    END

    RETURN @KetQua;
END;
GO

-- 2. HÀM LẤY LỊCH SỬ HIẾN MÁU CÁ NHÂN
-- Mục đích: Trả về bảng danh sách các lần hiến để hiển thị lên App/Web cho người dùng xem.
CREATE OR ALTER FUNCTION fn_LayLichSuHienMau (@maNguoiHien INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ph.thoiGianHien,
        ph.theTich AS TheTich_ml,
        ps.nhomMau,
        bv.tenBV AS NoiHien,
        dt.tenDot,
        nv.hoTen AS NguoiLayMau
    FROM PHIEUHIENMAU ph
    JOIN PHIEUSANGLOC ps ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy
    JOIN DOTHIENMAU dt ON pdk.maDot = dt.maDot
    JOIN NGUOIPHUTRACH npt ON dt.maNPT = npt.maNPT
    JOIN BENHVIEN bv ON npt.maBV = bv.maBV
    JOIN NHANVIENYTE nv ON ph.maNV_LayMau = nv.maNhanVienYTe
    WHERE pdk.maNguoiHien = @maNguoiHien
);
GO

-- 3. HÀM THỐNG KÊ MÁU THEO ĐỢT
-- Mục đích: Giúp quản lý biết được đợt này thu được bao nhiêu đơn vị máu của từng nhóm.
CREATE OR ALTER FUNCTION fn_ThongKeMauTheoDot (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ISNULL(ps.nhomMau, N'Chưa xác định') AS NhomMau,
        COUNT(ph.maPhieuHM) AS SoLuongTuiMau,
        SUM(ph.theTich) AS TongTheTich_ml
    FROM DOTHIENMAU dt
    JOIN PHIEUDANGKY pdk ON dt.maDot = pdk.maDot
    JOIN PHIEUSANGLOC ps ON pdk.maDangKy = ps.maDangKy
    JOIN PHIEUHIENMAU ph ON ps.maPhieuSangLoc = ph.maPhieuSangLoc
    WHERE dt.maDot = @maDot
    GROUP BY ps.nhomMau
);
GO

-- 4. HÀM XEM DANH SÁCH NHÂN VIÊN THAM GIA
-- Mục đích: Liệt kê danh sách nhân sự đi làm nhiệm vụ trong một đợt cụ thể.
CREATE OR ALTER FUNCTION fn_XemDanhSachNhanVienThamGia (@maDot INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        nv.hoTen,
        nv.chucDanh,
        ct.nhiemVu,
        ct.maCodeNhiemVu,
        bv.tenBV AS DonViCongTac
    FROM DANHSACHNHANVIENTHAMGIA ds
    JOIN CHITIETDANHSACH ct ON ds.maDS = ct.maDS
    JOIN NHANVIENYTE nv ON ct.maNhanVienYTe = nv.maNhanVienYTe
    JOIN BENHVIEN bv ON nv.maBV = bv.maBV
    WHERE ds.maDot = @maDot
);
GO

-- 5. HÀM LẤY CHỨNG NHẬN ĐIỆN TỬ (Sinh nội dung chữ)
-- Mục đích: Tạo ra một đoạn văn bản tóm tắt thành tích hiến máu để in ra giấy chứng nhận hoặc hiển thị QR Code.
-- Trả về: Chuỗi văn bản (NVARCHAR).
CREATE OR ALTER FUNCTION fn_LayChungNhanDienTu (@maNguoiHien INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @HoTen NVARCHAR(150);
    DECLARE @CMND VARCHAR(20);
    DECLARE @TongSoLan INT;
    DECLARE @TongTheTich INT;
    DECLARE @NgayHienGanNhat DATE;
    DECLARE @KetQua NVARCHAR(MAX);

    -- Lấy thông tin tổng hợp
    SELECT 
        @HoTen = nh.hoTen,
        @CMND = nh.soCMND_CCCD,
        @TongSoLan = COUNT(ph.maPhieuHM),
        @TongTheTich = SUM(ph.theTich),
        @NgayHienGanNhat = CAST(MAX(ph.thoiGianHien) AS DATE)
    FROM NGUOIHIEN nh
    LEFT JOIN PHIEUDANGKY pdk ON nh.maNguoiHien = pdk.maNguoiHien
    LEFT JOIN PHIEUSANGLOC ps ON pdk.maDangKy = ps.maDangKy
    LEFT JOIN PHIEUHIENMAU ph ON ps.maPhieuSangLoc = ph.maPhieuSangLoc
    WHERE nh.maNguoiHien = @maNguoiHien
    GROUP BY nh.hoTen, nh.soCMND_CCCD;

    -- Nếu chưa hiến lần nào
    IF @TongSoLan IS NULL OR @TongSoLan = 0
    BEGIN
        RETURN N'Chứng nhận: Ông/Bà ' + @HoTen + N' chưa có dữ liệu hiến máu thành công.';
    END

    -- Tạo chuỗi chứng nhận
    SET @KetQua = N'CHỨNG NHẬN HIẾN MÁU NHÂN ĐẠO' + CHAR(13) + CHAR(10) +
                  N'Ông/Bà: ' + @HoTen + CHAR(13) + CHAR(10) +
                  N'CMND/CCCD: ' + @CMND + CHAR(13) + CHAR(10) +
                  N'Đã hiến máu tình nguyện: ' + CAST(@TongSoLan AS NVARCHAR(10)) + 
				  N' lần.' + CHAR(13) + CHAR(10) +
                  N'Tổng lượng máu đã hiến: ' + CAST(@TongTheTich AS NVARCHAR(10)) + 
				  N' ml.' + CHAR(13) + CHAR(10) +
                  N'Lần gần nhất: ' + CONVERT(NVARCHAR(20), @NgayHienGanNhat, 103) + N'.';

    RETURN @KetQua;
END;
GO

-- ==================================================================================
-- VÙNG NỘI DUNG CHO TRIGGER
-- ==================================================================================

-- 1. TRIGGER: KIỂM TRA KHOẢNG CÁCH HIẾN MÁU (Quy tắc 84 ngày)
-- Bảng: PHIEUDANGKY
-- Sự kiện: Khi có lệnh INSERT (Thêm phiếu đăng ký mới)
CREATE OR ALTER TRIGGER trg_KiemTraKhoangCachHienMau
ON PHIEUDANGKY
AFTER INSERT
AS
BEGIN
    -- Khai báo biến
    DECLARE @maNguoiHien INT;
    DECLARE @isDuDieuKien BIT;

    -- Lấy thông tin từ dòng vừa insert (giả định insert từng dòng)
    SELECT @maNguoiHien = maNguoiHien FROM inserted;

    -- Gọi hàm kiểm tra điều kiện (đã viết ở bước trước)
    SET @isDuDieuKien = dbo.fn_KiemTraDieuKienHienMau(@maNguoiHien);

    -- Nếu hàm trả về 0 (Không đủ điều kiện) -> Rollback
    IF @isDuDieuKien = 0
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR (N'Lỗi: Người hiến chưa đủ thời gian chờ (12 tuần) kể từ lần hiến gần nhất.', 16, 1);
        RETURN;
    END
END;
GO

-- 2. TRIGGER: TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI (Sau khi Sàng lọc)
-- Bảng: PHIEUSANGLOC
-- Sự kiện: Khi có lệnh INSERT (Có kết quả khám)
-- Logic: Tự động chuyển trạng thái Phiếu Đăng Ký -> "Đã khám" hoặc "Không đạt"
CREATE OR ALTER TRIGGER trg_TuDongCapNhatTrangThai_KhiKham
ON PHIEUSANGLOC
AFTER INSERT
AS
BEGIN
    DECLARE @maDangKy INT;
    DECLARE @trangThaiKham NVARCHAR(50);

    -- Lấy thông tin từ phiếu sàng lọc vừa tạo
    SELECT @maDangKy = maDangKy, @trangThaiKham = trangThai 
    FROM inserted;

    -- Cập nhật ngược lại bảng PHIEUDANGKY
    IF @trangThaiKham = N'Đạt'
    BEGIN
        UPDATE PHIEUDANGKY 
        SET trangThai = N'Đã check-in (Chờ lấy máu)' 
        WHERE maDangKy = @maDangKy;
    END
    ELSE
    BEGIN
        UPDATE PHIEUDANGKY 
        SET trangThai = N'Không đạt sức khỏe' 
        WHERE maDangKy = @maDangKy;
    END
END;
GO

-- 3. TRIGGER: TỰ ĐỘNG CẬP NHẬT QUY TRÌNH & KIỂM TRA CHỈ TIÊU (Sau khi Hiến máu)
-- Bảng: PHIEUHIENMAU
-- Sự kiện: Khi có lệnh INSERT (Lấy máu thành công)
-- Logic 1: Chuyển trạng thái Phiếu Đăng Ký -> "Hoàn thành"
-- Logic 2: Kiểm tra nếu Đợt hiến máu đã đủ chỉ tiêu -> Thông báo hoặc cập nhật trạng thái đợt
CREATE OR ALTER TRIGGER trg_TuDongCapNhatTrangThai_KhiHien
ON PHIEUHIENMAU
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @maPhieuSangLoc INT;
    DECLARE @maDangKy INT;
    DECLARE @maDot INT;
    DECLARE @SoLuongDaHien INT;
    DECLARE @SoLuongDuKien INT;

    -- 1. Lấy thông tin liên kết: Inserted -> PhieuSangLoc -> PhieuDangKy -> DotHienMau
    SELECT 
        @maPhieuSangLoc = i.maPhieuSangLoc,
        @maDangKy = ps.maDangKy,
        @maDot = pdk.maDot
    FROM inserted i
    JOIN PHIEUSANGLOC ps ON i.maPhieuSangLoc = ps.maPhieuSangLoc
    JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy;

    -- 2. Cập nhật trạng thái phiếu đăng ký thành "Hoàn thành"
    UPDATE PHIEUDANGKY
    SET trangThai = N'Hoàn thành'
    WHERE maDangKy = @maDangKy;

    -- 3. Kiểm tra chỉ tiêu của Đợt hiến máu
    -- Đếm tổng số lượng túi máu của đợt này
    SELECT @SoLuongDaHien = COUNT(ph.maPhieuHM)
    FROM PHIEUHIENMAU ph
    JOIN PHIEUSANGLOC ps ON ph.maPhieuSangLoc = ps.maPhieuSangLoc
    JOIN PHIEUDANGKY pdk ON ps.maDangKy = pdk.maDangKy
    WHERE pdk.maDot = @maDot;

    -- Lấy số lượng dự kiến
    SELECT @SoLuongDuKien = soLuongDuKien FROM DOTHIENMAU WHERE maDot = @maDot;

    -- Nếu vượt chỉ tiêu -> Cập nhật trạng thái Đợt thành 'Hoàn thành' (nếu đang diễn ra)
    IF @SoLuongDaHien >= @SoLuongDuKien
    BEGIN
        UPDATE DOTHIENMAU
        SET trangThai = N'Hoàn thành'
        WHERE maDot = @maDot AND trangThai = N'Đang diễn ra';
    END
END;
GO

-- 4. TRIGGER: BẢO VỆ DỮ LIỆU LỊCH SỬ
-- Bảng: DOTHIENMAU
-- Sự kiện: Khi UPDATE hoặc DELETE
-- Logic: Không cho phép sửa/xóa các đợt hiến máu đã 'Hoàn thành' hoặc 'Đã hủy' để bảo toàn lịch sử.
CREATE OR ALTER TRIGGER trg_ChanThayDoiDotHienMauDaKetThuc
ON DOTHIENMAU
FOR UPDATE, DELETE
AS
BEGIN
    DECLARE @TrangThaiCu NVARCHAR(50);
    
    -- Lấy trạng thái từ bảng bị xóa/sửa (deleted table)
    -- Lưu ý: Nếu update nhiều dòng cùng lúc, logic này cần dùng Cursor hoặc Exists. 
    -- Ở đây dùng EXISTS để tối ưu cho set-based.
    
    IF EXISTS (SELECT 1 FROM deleted WHERE trangThai IN (N'Hoàn thành', N'Đã hủy'))
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR (N'Lỗi bảo mật: Không thể chỉnh sửa hoặc xóa Đợt hiến máu đã Kết thúc hoặc Đã hủy. Dữ liệu này cần lưu trữ lịch sử.', 16, 1);
        RETURN;
    END
END;
GO


-- ==================================================================================
-- VÙNG NỘI DUNG CHO Tạo DỮ LIỆU MẪU
-- ==================================================================================
-- Tắt check khóa ngoại tạm thời để xóa dữ liệu dễ dàng
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all';
DISABLE TRIGGER ALL ON PHIEUDANGKY;
DISABLE TRIGGER ALL ON PHIEUSANGLOC;
DISABLE TRIGGER ALL ON PHIEUHIENMAU;
DISABLE TRIGGER ALL ON DOTHIENMAU;

-- Xóa dữ liệu theo thứ tự ngược (Con xóa trước, Cha xóa sau)
DELETE FROM TAIKHOANDOTHIENMAU;
DELETE FROM CHITIETDANHSACH;
DELETE FROM DANHSACHNHANVIENTHAMGIA;
DELETE FROM PHIEUHIENMAU;
DELETE FROM PHIEUSANGLOC;
DELETE FROM PHIEUDANGKY;
DELETE FROM PHIEUDIEUPHOI;
DELETE FROM DOTHIENMAU;
DELETE FROM NHANVIENYTE;
DELETE FROM NGUOIHIEN;
DELETE FROM NGUOIPHUTRACH;
DELETE FROM QUANLYKHOA;
DELETE FROM BENHVIEN;
DELETE FROM TAIKHOAN;

-- Reset ID tự tăng về 0
DBCC CHECKIDENT ('TAIKHOAN', RESEED, 0);
DBCC CHECKIDENT ('BENHVIEN', RESEED, 0);
DBCC CHECKIDENT ('QUANLYKHOA', RESEED, 0);
DBCC CHECKIDENT ('NGUOIPHUTRACH', RESEED, 0);
DBCC CHECKIDENT ('NHANVIENYTE', RESEED, 0);
DBCC CHECKIDENT ('NGUOIHIEN', RESEED, 0);
DBCC CHECKIDENT ('DOTHIENMAU', RESEED, 0);
DBCC CHECKIDENT ('PHIEUDIEUPHOI', RESEED, 0);
DBCC CHECKIDENT ('DANHSACHNHANVIENTHAMGIA', RESEED, 0);
DBCC CHECKIDENT ('CHITIETDANHSACH', RESEED, 0);
DBCC CHECKIDENT ('TAIKHOANDOTHIENMAU', RESEED, 0);
DBCC CHECKIDENT ('PHIEUDANGKY', RESEED, 0);
DBCC CHECKIDENT ('PHIEUSANGLOC', RESEED, 0);
DBCC CHECKIDENT ('PHIEUHIENMAU', RESEED, 0);
GO

-- CHÈN DỮ LIỆU
-- --- 1. TAIKHOAN ---
SET IDENTITY_INSERT TAIKHOAN ON;
INSERT INTO TAIKHOAN (maTK, tenDangNhap, matKhau, vaiTro, soDienThoai, trangThai) VALUES
(1, 'admin', '123456', 'Admin', '0901000001', N'Hoạt động'),
(2, 'quanly1', '123456', 'QuanLy', '0901000002', N'Hoạt động'),
(3, 'phutrach1', '123456', 'NguoiPhuTrach', '0901000003', N'Hoạt động'),
(4, 'phutrach2', '123456', 'NguoiPhuTrach', '0901000004', N'Hoạt động'),
(5, 'nguoihien1', '123456', 'NguoiHien', '0901000005', N'Hoạt động'),
(6, 'nguoihien2', '123456', 'NguoiHien', '0901000006', N'Hoạt động'),
(7, 'nguoihien3', '123456', 'NguoiHien', '0901000007', N'Hoạt động'),
(8, 'nguoihien4', '123456', 'NguoiHien', '0901000008', N'Đã khóa'),
(9, 'nguoihien5', '123456', 'NguoiHien', '0901000009', N'Hoạt động');
SET IDENTITY_INSERT TAIKHOAN OFF;

-- --- 2. BENHVIEN ---
SET IDENTITY_INSERT BENHVIEN ON;
INSERT INTO BENHVIEN (maBV, tenBV, diaChi, loaiBenhVien) VALUES
(1, N'Bệnh viện Chợ Rẫy', N'201B Nguyễn Chí Thanh, Q5, TP.HCM', N'Công lập'),
(2, N'Bệnh viện Huyết học TW', N'Phạm Văn Bạch, Cầu Giấy, Hà Nội', N'Công lập'),
(3, N'Bệnh viện Đại học Y Dược', N'215 Hồng Bàng, Q5, TP.HCM', N'Công lập'),
(4, N'Bệnh viện Đa khoa Quốc tế Vinmec', N'458 Minh Khai, Hà Nội', N'Quốc tế'),
(5, N'Bệnh viện Hoàn Mỹ', N'Phan Xích Long, Phú Nhuận, TP.HCM', N'Tư nhân');
SET IDENTITY_INSERT BENHVIEN OFF;

-- --- 3. QUANLYKHOA & NGUOIPHUTRACH ---
SET IDENTITY_INSERT QUANLYKHOA ON;
INSERT INTO QUANLYKHOA (maQLK, hoTen, maTK) VALUES (1, N'Nguyễn Văn Quản Lý', 2);
SET IDENTITY_INSERT QUANLYKHOA OFF;

SET IDENTITY_INSERT NGUOIPHUTRACH ON;
INSERT INTO NGUOIPHUTRACH (maNPT, hoTen, maBV, maTK) VALUES
(1, N'Trần Thị Phụ Trách A', 1, 3),
(2, N'Lê Văn Phụ Trách B', 2, 4);
SET IDENTITY_INSERT NGUOIPHUTRACH OFF;

-- --- 4. NHANVIENYTE ---
SET IDENTITY_INSERT NHANVIENYTE ON;
INSERT INTO NHANVIENYTE (maNhanVienYTe, hoTen, chucDanh, maBV) VALUES
(1, N'Bác sĩ Phạm Văn A', N'Bác sĩ CK1', 1),
(2, N'Y tá Nguyễn Thị B', N'Điều dưỡng', 1),
(3, N'Bác sĩ Trần Văn C', N'Bác sĩ', 2),
(4, N'Kỹ thuật viên Lê D', N'KTV Xét nghiệm', 2),
(5, N'Tình nguyện viên E', N'Hỗ trợ', 1);
SET IDENTITY_INSERT NHANVIENYTE OFF;

-- --- 5. NGUOIHIEN ---
SET IDENTITY_INSERT NGUOIHIEN ON;
INSERT INTO NGUOIHIEN (maNguoiHien, hoTen, soCMND_CCCD, ngaySinh, gioiTinh, diaChi, maTK) VALUES
(1, N'Nguyễn Văn Hiến Máu 1', '079123456781', '1995-01-01', N'Nam', N'Q1, TP.HCM', 5),
(2, N'Trần Thị Tình Nguyện 2', '079123456782', '2000-05-15', N'Nữ', N'Q3, TP.HCM', 6),
(3, N'Lê Văn Nhiệt Huyết 3', '079123456783', '1990-12-20', N'Nam', N'Q5, TP.HCM', 7),
(4, N'Phạm Thị Nhân Ái 4', '079123456784', '1998-03-10', N'Nữ', N'Cầu Giấy, HN', 8),
(5, N'Hoàng Văn Hùng 5', '079123456785', '2002-07-07', N'Nam', N'Ba Đình, HN', 9),
(6, N'Khách Vãng Lai 6', '079123456786', '1999-09-09', N'Khác', N'Tự do', NULL);
SET IDENTITY_INSERT NGUOIHIEN OFF;

-- --- 6. DOTHIENMAU ---
SET IDENTITY_INSERT DOTHIENMAU ON;
INSERT INTO DOTHIENMAU (maDot, tenDot, ngayBatDau, ngayKetThuc, diaDiem, soLuongDuKien, trangThai, maNPT) VALUES
(1, N'Hiến máu Xuân Hồng 2023', '2023-01-10 07:00', '2023-01-12 17:00', N'Sảnh A, ĐH Bách Khoa', 500, N'Hoàn thành', 1),
(2, N'Giọt hồng yêu thương T10', '2023-10-15 07:00', '2023-10-15 17:00', N'BV Chợ Rẫy', 100, N'Hoàn thành', 1),
(3, N'Chủ nhật Đỏ 2025', '2025-05-20 07:00', '2025-05-25 17:00', N'SVĐ Mỹ Đình', 1000, N'Lên kế hoạch', 2),
(4, N'Hiến máu cứu người T12', '2025-12-24 07:00', '2025-12-24 17:00', N'Trường ĐH Y Dược', 200, N'Đang diễn ra', 1),
(5, N'Sẻ chia sự sống', '2025-12-30 08:00', '2025-12-30 16:00', N'Nhà văn hóa TN', 150, N'Lên kế hoạch', 2);
SET IDENTITY_INSERT DOTHIENMAU OFF;

-- --- 7. PHIEUDIEUPHOI ---
SET IDENTITY_INSERT PHIEUDIEUPHOI ON;
INSERT INTO PHIEUDIEUPHOI (maPhieuDP, ngayYeuCau, lyDo, trangThai, ngayDuyet, maNguoiYeuCau, maNguoiDuyet) VALUES
(1, '2023-01-05', N'Cần thêm túi máu loại 350ml', N'Đã duyệt', '2023-01-06', 1, 1),
(2, '2023-10-10', N'Xin hỗ trợ thêm y tá', N'Đã duyệt', '2023-10-11', 1, 1),
(3, '2025-05-15', N'Điều phối xe vận chuyển', N'Chờ duyệt', NULL, 2, NULL),
(4, '2025-12-20', N'Cần thêm găng tay y tế', N'Từ chối', '2025-12-21', 1, 1),
(5, '2025-12-22', N'Tăng cường bác sĩ khám', N'Chờ duyệt', NULL, 1, NULL);
SET IDENTITY_INSERT PHIEUDIEUPHOI OFF;

-- --- 8. DANHSACHNHANVIENTHAMGIA ---
SET IDENTITY_INSERT DANHSACHNHANVIENTHAMGIA ON;
INSERT INTO DANHSACHNHANVIENTHAMGIA (maDS, tenDS, ngayTao, maDot) VALUES
(1, N'DS Nhân sự Xuân Hồng', '2023-01-05', 1),
(2, N'DS Nhân sự T10', '2023-10-10', 2),
(3, N'DS Nhân sự T12', '2025-12-20', 4);
SET IDENTITY_INSERT DANHSACHNHANVIENTHAMGIA OFF;

-- --- 9. CHITIETDANHSACH ---
SET IDENTITY_INSERT CHITIETDANHSACH ON;
INSERT INTO CHITIETDANHSACH (maCTDS, maCodeNhiemVu, nhiemVu, maDS, maNhanVienYTe) VALUES
(1, 'NV01', N'Khám sàng lọc', 1, 1),
(2, 'NV02', N'Lấy máu', 1, 2),
(3, 'NV03', N'Hỗ trợ', 1, 5),
(4, 'NV04', N'Khám sàng lọc', 2, 1),
(5, 'NV05', N'Xét nghiệm nhanh', 2, 4);
SET IDENTITY_INSERT CHITIETDANHSACH OFF;

-- --- 10. TAIKHOANDOTHIENMAU ---
SET IDENTITY_INSERT TAIKHOANDOTHIENMAU ON;
INSERT INTO TAIKHOANDOTHIENMAU (maTKDot, tenDangNhap, matKhau, vaiTro, maCTDS, maNguoiTao) VALUES
(1, 'tnv_dot1_01', '123123', 'TNV', 1, 1),
(2, 'tnv_dot1_02', '123123', 'TNV', 2, 1),
(3, 'tnv_dot1_03', '123123', 'TNV', 3, 1),
(4, 'tnv_dot2_01', '123123', 'TNV', 4, 1),
(5, 'tnv_dot2_02', '123123', 'TNV', 5, 1);
SET IDENTITY_INSERT TAIKHOANDOTHIENMAU OFF;

-- --- 11. PHIEUDANGKY (Trạng thái đã khớp với Constraint mới) ---
SET IDENTITY_INSERT PHIEUDANGKY ON;
INSERT INTO PHIEUDANGKY (maDangKy, thoiGianDK, khungGioHen, trangThai, maDot, maNguoiHien) VALUES
(1, '2023-01-05', '2023-01-10 08:00', N'Hoàn thành', 1, 1),
(2, '2023-01-05', '2023-01-10 09:00', N'Không đạt sức khỏe', 1, 2),
(3, '2023-01-06', '2023-01-10 10:00', N'Hủy đăng ký', 1, 3),
(4, '2025-12-20', '2025-12-24 08:30', N'Đã check-in (Chờ lấy máu)', 4, 4),
(5, '2025-12-21', '2025-12-24 09:00', N'Đã đăng ký', 4, 5);
SET IDENTITY_INSERT PHIEUDANGKY OFF;

-- --- 12. PHIEUSANGLOC ---
SET IDENTITY_INSERT PHIEUSANGLOC ON;
INSERT INTO PHIEUSANGLOC (maPhieuSangLoc, thoiGianKham, huyetAp, canNang, nhomMau, ketQuaXN, trangThai, lyDoKhongDat, maDangKy, maNhanVienYTe) VALUES
(1, '2023-01-10 08:15', '120/80', 65, N'A', N'Bình thường', N'Đạt', NULL, 1, 1),
(2, '2023-01-10 09:15', '90/60', 45, N'O', N'Huyết áp thấp', N'Không đạt', N'Huyết áp không đủ điều kiện', 2, 1),
(3, '2025-12-24 08:45', '110/70', 55, N'B', N'Bình thường', N'Đạt', NULL, 4, 1);
SET IDENTITY_INSERT PHIEUSANGLOC OFF;

-- --- 13. PHIEUHIENMAU ---
SET IDENTITY_INSERT PHIEUHIENMAU ON;
INSERT INTO PHIEUHIENMAU (maPhieuHM, thoiGianHien, theTich, maNV_LayMau, maPhieuSangLoc) VALUES
(1, '2023-01-10 08:45', 350, 2, 1);
SET IDENTITY_INSERT PHIEUHIENMAU OFF;

GO

-- ==============================================================================
-- BƯỚC 4: BẬT LẠI CÁC CƠ CHẾ BẢO VỆ
-- ==============================================================================
EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all';
ENABLE TRIGGER ALL ON PHIEUDANGKY;
ENABLE TRIGGER ALL ON PHIEUSANGLOC;
ENABLE TRIGGER ALL ON PHIEUHIENMAU;
ENABLE TRIGGER ALL ON DOTHIENMAU;
GO

USE QLHienMauNhanDao;
GO

PRINT N'=== BẮT ĐẦU KỊCH BẢN KIỂM THỬ HỆ THỐNG ===';

-- KHAI BÁO CÁC BIẾN SẼ DÙNG TRONG QUÁ TRÌNH TEST ĐỂ LƯU ID
DECLARE @MaDotMoi INT;
DECLARE @MaTaiKhoanMoi INT;
DECLARE @MaNguoiHienMoi INT;
DECLARE @MaDangKyMoi INT;
DECLARE @MaPhieuSangLocMoi INT;
DECLARE @MaNPT INT = 1; -- Lấy tạm người phụ trách ID 1 có sẵn
DECLARE @MaBacSi INT = 1; -- Lấy tạm bác sĩ ID 1 có sẵn

-- =================================================================================
-- TEST CASE 1: QUẢN LÝ TẠO ĐỢT HIẾN MÁU MỚI (Sử dụng Procedure sp_TaoDotHienMauMoi)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[1] TEST: Quản lý tạo đợt hiến máu mới';

EXEC sp_TaoDotHienMauMoi 
    @tenDot = N'Ngày hội Hiến máu Demo Test', 
    @ngayBatDau = '2025-12-25 07:00', 
    @ngayKetThuc = '2025-12-29 17:00', 
    @diaDiem = N'Trung tâm Testing', 
    @soLuongDuKien = 100, 
    @maNPT = @MaNPT;

-- Lấy ID đợt vừa tạo
SELECT TOP 1 @MaDotMoi = maDot FROM DOTHIENMAU ORDER BY maDot DESC;
PRINT N'=> Đã tạo đợt hiến máu ID: ' + CAST(@MaDotMoi AS NVARCHAR(10));

-- =================================================================================
-- TEST CASE 2: NGƯỜI DÙNG MỚI ĐĂNG KÝ TÀI KHOẢN (Sử dụng sp_DangKyTaiKhoanNguoiHien)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[2] TEST: Người dân đăng ký tài khoản mới';

-- Tạo tên đăng nhập ngẫu nhiên để tránh trùng khi chạy test nhiều lần
DECLARE @RandomUser VARCHAR(20) = 'userTest_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR);

EXEC sp_DangKyTaiKhoanNguoiHien 
    @tenDangNhap = @RandomUser,
    @matKhau = '123456',
    @soDienThoai = '0999888777',
    @hoTen = N'Nguyễn Văn Test',
    @soCMND_CCCD = '001099123456', -- CCCD mẫu
    @ngaySinh = '1995-01-01',
    @gioiTinh = N'Nam',
    @diaChi = N'Hà Nội';

-- Lấy ID người hiến vừa tạo
SELECT TOP 1 @MaNguoiHienMoi = maNguoiHien FROM NGUOIHIEN ORDER BY maNguoiHien DESC;
PRINT N'=> Đã tạo Người hiến ID: ' + CAST(@MaNguoiHienMoi AS NVARCHAR(10)) + N' (Tên đăng nhập: ' + @RandomUser + ')';

-- =================================================================================
-- TEST CASE 3: KIỂM TRA ĐIỀU KIỆN & ĐĂNG KÝ LỊCH (Sử dụng Function & Procedure)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[3] TEST: Kiểm tra điều kiện và Đăng ký lịch';

-- Kiểm tra đủ điều kiện không (Function fn_KiemTraDieuKienHienMau)
DECLARE @DuDieuKien BIT = dbo.fn_KiemTraDieuKienHienMau(@MaNguoiHienMoi);

IF @DuDieuKien = 1
BEGIN
    PRINT N'=> Kiểm tra y tế: ĐỦ ĐIỀU KIỆN hiến máu (Chưa hiến lần nào hoặc đã đủ 12 tuần).';
    
    -- Tiến hành đăng ký (Procedure sp_DangKyLichHienMau)
    EXEC sp_DangKyLichHienMau 
        @maDot = @MaDotMoi, 
        @maNguoiHien = @MaNguoiHienMoi, 
        @khungGioHen = '2025-12-26 08:00';
        
    -- Lấy ID phiếu đăng ký
    SELECT TOP 1 @MaDangKyMoi = maDangKy FROM PHIEUDANGKY WHERE maNguoiHien = @MaNguoiHienMoi ORDER BY maDangKy DESC;
    PRINT N'=> Đăng ký lịch thành công. Mã phiếu ĐK: ' + CAST(@MaDangKyMoi AS NVARCHAR(10));
    
    -- Xem trạng thái hiện tại
    SELECT maDangKy, trangThai AS [TrangThai_LucMoiDangKy] FROM PHIEUDANGKY WHERE maDangKy = @MaDangKyMoi;
END
ELSE
BEGIN
    PRINT N'=> Kiểm tra y tế: KHÔNG ĐỦ ĐIỀU KIỆN.';
END

-- =================================================================================
-- TEST CASE 4: BÁC SĨ KHÁM SÀNG LỌC (Sử dụng sp_CapNhatKetQuaSangLoc + Trigger Tự động)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[4] TEST: Bác sĩ nhập kết quả khám sàng lọc';

EXEC sp_CapNhatKetQuaSangLoc 
    @maDangKy = @MaDangKyMoi,
    @maNhanVienYTe = @MaBacSi,
    @huyetAp = '120/80',
    @canNang = 60,
    @nhomMau = N'O',
    @ketQuaXN = N'Bình thường, đủ điều kiện',
    @trangThai = N'Đạt',
    @lyDoKhongDat = NULL;

-- Lấy ID phiếu sàng lọc
SELECT TOP 1 @MaPhieuSangLocMoi = maPhieuSangLoc FROM PHIEUSANGLOC WHERE maDangKy = @MaDangKyMoi;
PRINT N'=> Đã khám xong. Mã phiếu Sàng lọc: ' + CAST(@MaPhieuSangLocMoi AS NVARCHAR(10));

-- KIỂM TRA TRIGGER: Xem trạng thái trong PHIEUDANGKY đã tự đổi thành "Đã check-in" chưa?
SELECT maDangKy, trangThai AS [TrangThai_SauKhiKham] FROM PHIEUDANGKY WHERE maDangKy = @MaDangKyMoi;

-- =================================================================================
-- TEST CASE 5: LẤY MÁU THÀNH CÔNG (Sử dụng sp_GhiNhanKetQuaHienMau + Trigger Hoàn thành)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[5] TEST: Ghi nhận lấy máu thành công';

EXEC sp_GhiNhanKetQuaHienMau 
    @maPhieuSangLoc = @MaPhieuSangLocMoi,
    @maNV_LayMau = @MaBacSi, -- Giả sử bác sĩ lấy máu luôn
    @theTich = 350;

PRINT N'=> Đã ghi nhận lấy 350ml máu.';

-- KIỂM TRA TRIGGER: Xem trạng thái trong PHIEUDANGKY đã tự đổi thành "Hoàn thành" chưa?
SELECT maDangKy, trangThai AS [TrangThai_KetThucQuyTrinh] FROM PHIEUDANGKY WHERE maDangKy = @MaDangKyMoi;

-- =================================================================================
-- TEST CASE 6: THỬ ĐĂNG KÝ LẠI NGAY LẬP TỨC (Kiểm tra Trigger Chặn 84 ngày)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[6] TEST: Cố tình đăng ký lại ngay sau khi hiến (Mong đợi: Hệ thống BÁO LỖI)';

BEGIN TRY
    -- Thử đăng ký lần nữa vào cùng đợt (hoặc đợt khác)
    -- Insert trực tiếp để test Trigger trg_KiemTraKhoangCachHienMau
    INSERT INTO PHIEUDANGKY (thoiGianDK, trangThai, maDot, maNguoiHien)
    VALUES (GETDATE(), N'Đã đăng ký', @MaDotMoi, @MaNguoiHienMoi);
    
    PRINT N'=> LỖI: Hệ thống không chặn được người vừa hiến máu!';
END TRY
BEGIN CATCH
    PRINT N'=> THÀNH CÔNG: Hệ thống đã chặn đăng ký với thông báo lỗi sau:';
    PRINT N'   Error Message: ' + ERROR_MESSAGE();
END CATCH

-- =================================================================================
-- TEST CASE 7: XEM KẾT QUẢ & BÁO CÁO (Sử dụng các Function)
-- =================================================================================
PRINT N'--------------------------------------------------';
PRINT N'[7] TEST: Xem chứng nhận và Thống kê';

-- 1. Xem lịch sử hiến máu của người này
PRINT N'--- Lịch sử hiến máu ---';
SELECT * FROM dbo.fn_LayLichSuHienMau(@MaNguoiHienMoi);

-- 2. In chứng nhận điện tử
PRINT N'--- Giấy chứng nhận điện tử ---';
PRINT dbo.fn_LayChungNhanDienTu(@MaNguoiHienMoi);

-- 3. Thống kê đợt hiến máu vừa tạo
PRINT N'--- Thống kê đợt hiến máu ID ' + CAST(@MaDotMoi AS NVARCHAR(10)) + N' ---';
SELECT * FROM dbo.fn_ThongKeMauTheoDot(@MaDotMoi);

PRINT N'=== KẾT THÚC KỊCH BẢN KIỂM THỬ ===';
GO