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
CREATE TABLE Role
(
    role_id CHAR(5) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL,
    descript NVARCHAR(255)
);
GO
-- Bảng User (Người dùng)
CREATE TABLE [User]
(
    user_id CHAR(5) PRIMARY KEY,
    nameUser NVARCHAR(100) NOT NULL,
	DoB varchar(15) not null,
    phone VARCHAR(10) UNIQUE CHECK (phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    email NVARCHAR(100) UNIQUE CHECK (email LIKE '%@gmail.com'),
    passwordUser NVARCHAR(255) NOT NULL,
    role_id CHAR(5),
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
);
Go
-- Bảng Cơ sở khách sạn
CREATE TABLE Hotel_Branch
(
    branch_id CHAR(5) PRIMARY KEY,
    branch_name NVARCHAR(100) NOT NULL,
    addressH NVARCHAR(255) NOT NULL,
    phone VARCHAR(10) UNIQUE CHECK (phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
Go
-- Bảng Loại phòng
CREATE TABLE Room_Type
(
    room_type_id CHAR(5) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL,
    descript NVARCHAR(255),
    base_price DECIMAL(10,2) NOT NULL
);
Go
-- Bảng Phòng
CREATE TABLE Room
(
    room_id CHAR(5) PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL,
    room_type_id CHAR(5),
    floor INT NOT NULL,
    branch_id CHAR(5),
    price DECIMAL(10,2) NOT NULL,
    status NVARCHAR(20) CHECK (status IN ('Trống', 'Đã đặt', 'Bảo trì')) NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES Room_Type(room_type_id),
    FOREIGN KEY (branch_id) REFERENCES Hotel_Branch(branch_id)
);
Go
-- Bảng Đặt phòng
CREATE TABLE Booking
(
    booking_id CHAR(5) PRIMARY KEY,
    user_id CHAR(5),
    room_id CHAR(5),
    check_in_date varchar(15) NOT NULL,
    check_out_date varchar(15) NOT NULL,
    stat NVARCHAR(20) CHECK (stat IN ('Đã đặt', 'Hoàn thành', 'Hủy')) NOT NULL,
	--check (check_in_date >= getdate()),
	--check (check_out_date <= getdate()),
	check (check_in_date < check_out_date),
    FOREIGN KEY (user_id) REFERENCES [User](user_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
Go
-- Bảng Dịch vụ
CREATE TABLE Servicee
(
    service_id CHAR(5) PRIMARY KEY,
    service_name NVARCHAR(100) NOT NULL,
    price DECIMAL(15,2) NOT NULL
);
Go
-- Bảng Sử dụng dịch vụ
CREATE TABLE Service_Usage
(
    usage_id CHAR(5) PRIMARY KEY,
    booking_id CHAR(5),
    service_id CHAR(5),
    quantity INT NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (service_id) REFERENCES Servicee(service_id)
);
Go
-- Bảng Ví điện tử
CREATE TABLE Wallet
(
    wallet_id CHAR(5) PRIMARY KEY,
    user_id CHAR(5) UNIQUE,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
Go
-- Bảng Giao dịch ví
CREATE TABLE Wallet_Transaction
(
    transaction_id CHAR(5) PRIMARY KEY,
    wallet_id CHAR(5),
    amount DECIMAL(15,2) NOT NULL,
    transaction_type NVARCHAR(20) CHECK (transaction_type IN ('Nạp tiền', 'Rút tiền')) NOT NULL,
    date_time DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (wallet_id) REFERENCES Wallet(wallet_id)
);
Go
-- Bảng Hóa đơn
CREATE TABLE Invoice
(
    invoice_id CHAR(5) PRIMARY KEY,
    booking_id CHAR(5),
    wallet_id CHAR(5),
    total_amount DECIMAL(15,2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT GETDATE(),
    payment_method NVARCHAR(20) CHECK (payment_method IN ('Ví điện tử', 'Tiền mặt', 'Thẻ')) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (wallet_id) REFERENCES Wallet(wallet_id)
);
