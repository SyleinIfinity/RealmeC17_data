IF EXISTS (SELECT name
FROM sys.databases
WHERE name = N'QUANLYBANVE')
BEGIN
    EXEC sp_MSforeachdb 'IF ''?'' = ''QUANLYBANVE''
    BEGIN
        ALTER DATABASE [QUANLYBANVE] SET SINGLE_USER WITH ROLLBACK IMMEDIATE 
    END'
    USE master
    DROP DATABASE [QUANLYBANVE]
END
CREATE DATABASE [QUANLYBANVE]
USE QUANLYBANVE
CREATE TABLE [CUSTOMER]
(
    CustomerID VARCHAR(15) PRIMARY KEY NOT NULL,
    NameCust NVARCHAR(50) NOT NULL,
    C_Password VARCHAR(16) NOT NULL,
    Email VARCHAR(50) UNIQUE CHECK (Email LIKE '%_@__%.__%'),
    Phone VARCHAR(11) UNIQUE CHECK(Phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            or Phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    DateOfBirth DATE
)
CREATE TABLE [ADMIN]
(
    AdminID VARCHAR(5) PRIMARY KEY,
    nameAdmin NVARCHAR(50) NOT NULL,
    Email VARCHAR(50) UNIQUE CHECK (Email LIKE '%_@__%.__%'),
    Phone VARCHAR(11) UNIQUE CHECK(Phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            or Phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    A_Password VARCHAR(16) NOT NULL,
)
CREATE TABLE [FLIGHT]
(
    FlightID VARCHAR(7) PRIMARY KEY NOT NULL,
    FlightNumber VARCHAR(5) NOT NULL,
    DepartureAirport NVARCHAR(30) NOT NULL,
    ArrivalAirport NVARCHAR(30) NOT NULL,
    DepartureTime VARCHAR(16),
    ArrivalTime VARCHAR(16),
    Price MONEY
)
CREATE TABLE [AIRPORT]
(
    AirportID VARCHAR(15) PRIMARY KEY NOT NULL,
    AirportName NVARCHAR(30) NOT NULL,
    City NVARCHAR(30)
)
CREATE TABLE [AIRLINE]
(
    AirlineID VARCHAR(15) PRIMARY KEY NOT NULL,
    AirlineName NVARCHAR(30),
    IATA_Code VARCHAR(5),
)
CREATE TABLE [TICKET]
(
    TicketID VARCHAR(7) PRIMARY KEY NOT NULL,
    FlightID VARCHAR(7) NOT NULL,
    CustomerID VARCHAR(15) NOT NULL,
    SeatNumber VARCHAR(3) NOT NULL,
    BookingDate VARCHAR(19) NOT NULL,
    StatusTicket VARCHAR(15) CHECK(StatusTicket IN ('Confirmed', 'Cancelled', 'Pending', 'Checked In', 'No Show', 'Refunded')),
    FOREIGN KEY(FlightID) REFERENCES FLIGHT(FlightID),
    FOREIGN KEY(CustomerID) REFERENCES CUSTOMER(CustomerID)
)
INSERT INTO CUSTOMER
    (CustomerID, NameCust, Email, Phone, DateOfBirth, C_Password)
VALUES
    ('C001', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '0123456789', '1990-01-01', '123456789'),
    ('C004', N'Nguyễn Văn A', 'a@gmail.com', '0123456780', '1990-01-01', '123456789'),
    ('C002', N'Trần Thị B', 'tranthib@example.com', '0987654321', '1985-05-15', '123456789'),
    ('C003', N'Lê Văn C', 'levanc@example.com', '0135792468', '1992-10-20', '123456789')
INSERT INTO ADMIN
    (AdminID, nameAdmin, Email, Phone, A_Password)
VALUES
    ('A001', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '0123456789', '123456789'),
    ('A004', N'Nguyễn Văn D', 'b@gmail.com', '0123456780', '123456789'),
    ('A002', N'Trần Thị C', 'tranthib@example.com', '0987654321', '123456789'),
    ('A003', N'Lê Văn A', 'levanc@example.com', '0135792468', '123456789')
INSERT INTO FLIGHT
    (FlightID, FlightNumber, DepartureAirport, ArrivalAirport, DepartureTime, ArrivalTime, Price)
VALUES
    ('F000001', 'VN001', N'Sân Bay Nội Bài', N'Sân Bay Tân Sơn Nhất', '2024-11-20 08:00', '2024-11-20 10:00', 1500000),
    ('F000002', 'VN002', N'Sân Bay Đà Nẵng', N'Sân Bay Cam Ranh', '2024-11-21 12:00', '2024-11-21 13:30', 1200000),
    ('F000003', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-11-22 16:00', '2024-11-22 17:30', 2000000),
    ('F000004', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-11-24 16:00', '2024-11-24 17:30', 2000000),
    ('F000005', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-11-26 16:00', '2024-11-26 17:30', 2000000),
    ('F000006', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-11-28 16:00', '2024-11-28 17:30', 2000000),
    ('F000007', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-11-30 16:00', '2024-11-30 17:30', 2000000),
    ('F000008', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-12-01 16:00', '2024-12-01 17:30', 2000000),
    ('F000009', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-12-03 16:00', '2024-12-03 17:30', 2000000),
    ('F000010', 'VN003', N'Sân Bay Tân Sơn Nhất', N'Sân Bay Phú Quốc', '2024-12-05 16:00', '2024-12-05 17:30', 2000000)
INSERT INTO AIRPORT
    (AirportID, AirportName, City)
VALUES
    ('A001', N'Sân Bay Nội Bài', N'Hà Nội'),
    ('A002', N'Sân Bay Tân Sơn Nhất', N'TP. Hồ Chí Minh'),
    ('A003', N'Sân Bay Đà Nẵng', N'Đà Nẵng'),
    ('A004', N'Sân Bay Cam Ranh', N'Khánh Hòa'),
    ('A005', N'Sân Bay Phú Quốc', N'Kiên Giang'),
    ('A006', N'Sân Bay Tuy Hòa', N'Phú Yên'),
    ('A007', N'Sân Bay Đồng Hới', N'Quảng Bình'),
    ('A008', N'Sân Bay Cát Bi', N'Hải Phòng'),
    ('A009', N'Sân Bay Vinh', N'Nghệ An'),
    ('A010', N'Sân Bay Phú Bài', N'Thừa Thiên-Huế')
INSERT INTO AIRLINE
    (AirlineID, AirlineName, IATA_Code)
VALUES
    ('AL001', N'Vietnam Airlines', 'VN'),
    ('AL002', N'Bamboo Airways', 'QH'),
    ('AL003', N'VietJet Air', 'VJ')
INSERT INTO TICKET
    (TicketID, FlightID, CustomerID, SeatNumber, BookingDate, StatusTicket)
VALUES
    ('T000001', 'F000001', 'C001', 'A01', '2024-11-01', 'Confirmed'),
    ('T000002', 'F000001', 'C002', 'A02', '2024-11-02', 'Pending'),
    ('T000003', 'F000002', 'C003', 'A03', '2024-11-03', 'Confirmed'),
    ('T000004', 'F000002', 'C001', 'A04', '2024-11-02', 'Confirmed'),
    ('T000005', 'F000003', 'C003', 'A01', '2024-11-10', 'Confirmed'),
    ('T000006', 'F000003', 'C002', 'A03', '2024-11-11', 'Confirmed'),
    ('T000007', 'F000004', 'C003', 'A07', '2024-11-11', 'No Show'),
    ('T000008', 'F000004', 'C001', 'A06', '2024-11-12', 'Confirmed'),
    ('T000009', 'F000005', 'C001', 'A04', '2024-11-12', 'Cancelled'),
    ('T000010', 'F000005', 'C002', 'A02', '2024-11-13', 'Refunded'),
    ('T000011', 'F000006', 'C002', 'A05', '2024-11-13', 'No Show'),
    ('T000012', 'F000006', 'C003', 'A09', '2024-11-14', 'Confirmed'),
    ('T000013', 'F000007', 'C001', 'A10', '2024-11-15', 'Cancelled'),
    ('T000014', 'F000007', 'C003', 'A06', '2024-11-15', 'Checked In'),
    ('T000015', 'F000008', 'C002', 'A02', '2024-11-16', 'Confirmed'),
    ('T000016', 'F000008', 'C003', 'A01', '2024-11-17', 'Confirmed'),
    ('T000017', 'F000009', 'C001', 'A08', '2024-11-18', 'Refunded'),
    ('T000018', 'F000009', 'C003', 'A06', '2024-11-18', 'Cancelled'),
    ('T000019', 'F000010', 'C001', 'A03', '2024-11-16', 'No Show'),
    ('T000020', 'F000010', 'C003', 'A01', '2024-11-26', 'Confirmed')