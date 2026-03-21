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
USE [QUANLYBANVE]


CREATE TABLE CITY
(
	CityID char(5),
	nameCiTy nvarchar(100),
	constraint PK_maTinhThanh PRIMARY KEY(CityID),
);
Go
 --hang hạng ghế
 CREATE TABLE SEATCLASS
 (
     idSeatClass char(4),
     nameSeatClass NVARCHAR(15),
	 Costmultiple AS(CASE when nameSeatClass = N'Phổ Thông' then 1.1 else 2.5 end) PERSISTED,
     constraint PK_idSeatClass PRIMARY KEY(idSeatClass)
     
 );
Go
-- Tạo bảng Loại Ghế
CREATE TABLE SEATTYPE
(
    idSeatType char(3),
    nameSeatType NVARCHAR(15),
    idSeatClass char(4),
    constraint PK_idSeatType PRIMARY KEY(idSeatType),
    constraint FK_idSeatClass FOREIGN KEY(idSeatClass) REFERENCES SEATCLASS(idSeatClass)
                        ON UPDATE CASCADE
                        ON DELETE CASCADE
);
GO
-- Tạo bảng GheNgoi
CREATE TABLE SEATNUMBER
(
    idSeat char(4),
    numberSeat nvarchar(2),
    idSeatType char(3),
	StatusSeat varchar(10) default 'enable',
    constraint PK_idSeat PRIMARY KEY(idSeat),
    constraint FK_idSeatType FOREIGN KEY(idSeatType) REFERENCES SEATTYPE(idSeatType)
                        ON UPDATE CASCADE
                        ON DELETE CASCADE
);
Go
CREATE TABLE [CUSTOMER]
(
    CustomerID VARCHAR(15) PRIMARY KEY,
    NameCust NVARCHAR(50),
    C_Password VARCHAR(16),
    Email VARCHAR(50) CHECK (Email LIKE '%_@__%.__%'),
    Phone VARCHAR(11),
    DateOfBirth varchar(50),
	accountBalance money default 0
);
Go
CREATE TABLE [ADMIN]
(
    AdminID VARCHAR(5) PRIMARY KEY,
    nameAdmin NVARCHAR(50),
    A_Password VARCHAR(16),
    Email VARCHAR(50) CHECK (Email LIKE '%_@__%.__%'),
    Phone VARCHAR(11),
	DateOfBirth varchar(50)
);
Go
CREATE TABLE [AIRPORT]
(
    AirportID VARCHAR(15) PRIMARY KEY,
    AirportName NVARCHAR(30),
    CityID CHAR(5),
	FOREIGN KEY(CityID) REFERENCES CITY(CityID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);
Go
CREATE TABLE [FLIGHT]
(
    FlightID VARCHAR(7) PRIMARY KEY,
    FlightNumber VARCHAR(5),
	AirportID VARCHAR(15),
	CityID CHAR(5),
    DepartureTime VARCHAR(25),
    ArrivalTime VARCHAR(25),
    DefaultPrice MONEY,
	available int default 0,
	Maximum int,
	FOREIGN KEY(AirportID) REFERENCES AIRPORT(AirportID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY(CityID) REFERENCES CITY(CityID)
);
Go

CREATE TABLE [TICKET]
(
    TicketID VARCHAR(7) PRIMARY KEY,
    FlightID VARCHAR(7),
    CustomerID VARCHAR(15),
    idSeat CHAR(4),
    BookingDate VARCHAR(25),
	TypeTicket nvarchar(30),
	Price Money,
    FOREIGN KEY(FlightID) REFERENCES FLIGHT(FlightID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
    FOREIGN KEY(CustomerID) REFERENCES CUSTOMER(CustomerID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
    FOREIGN KEY(idSeat) REFERENCES SEATNUMBER(idSeat)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);
Go
CREATE TABLE [CUSTOMERREQUESTS]
(
    RequestID CHAR(5),
    TicketID VARCHAR(7),
    RequestType NVARCHAR(50),
    RequestDate VARCHAR(19),
    RequestStatus VARCHAR(20),
    Comments NVARCHAR(255),
    FOREIGN KEY (TicketID) REFERENCES TICKET(TicketID)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION
);
GO

CREATE TRIGGER trg_UpdateMaximumSeats
ON FLIGHT
AFTER INSERT,UPDATE
AS
BEGIN
    DECLARE @TotalSeats INT;
    -- Tính tổng số ghế
    SELECT @TotalSeats = COUNT(idSeat) FROM SEATNUMBER;

    -- Cập nhật giá trị Maximum trong bảng FLIGHT cho tất cả các chuyến bay
    UPDATE FLIGHT
    SET Maximum = @TotalSeats;
END;
Go

INSERT INTO CITY(CityID, nameCity)
VALUES
    ('CT001',N'Thành phố Đà Nẵng'),
    ('CT002',N'Thành phố Hà Nội'),
    ('CT003',N'Thành phố Nha Trang'),
    ('CT004',N'Thành phố Sài Gòn'),
    ('CT005',N'Thành phố Hải Phòng'),
    ('CT006',N'Thành phố Kiên Giang'),
    ('CT007',N'Thành phố Phú Yên'),
    ('CT008',N'Thành phố Thừa Thiên Huế'),
    ('CT009',N'Thành phố Nghệ An'),
    ('CT010',N'Thành phố Quảng Bình');
GO
INSERT INTO SEATCLASS (idSeatClass, nameSeatClass)
VALUES
    ('SC01', N'Phổ Thông'),
    ('SC02', N'Thương Gia');
Go
INSERT INTO SEATTYPE (idSeatType, nameSeatType, idSeatClass)
VALUES
    ('ST1', 'A', 'SC02'),
    ('ST2', 'B', 'SC02'),
    ('ST3', 'C', 'SC01'),
    ('ST4', 'D', 'SC01'),
    ('ST5', 'E', 'SC01');
Go
INSERT INTO SEATNUMBER (idSeat, numberSeat, idSeatType, StatusSeat)
VALUES
--ghế A
    ('SN01', 1, 'ST1', 'enable'),
    ('SN02', 2, 'ST1', 'enable'),
    ('SN03', 3, 'ST1', 'enable'),
    ('SN04', 4, 'ST1', 'enable'),
    ('SN05', 5, 'ST1', 'enable'),
    ('SN06', 6, 'ST1', 'enable'),
--ghế B
    ('SN07', 1, 'ST2', 'enable'),
    ('SN08', 2, 'ST2', 'enable'),
    ('SN09', 3, 'ST2', 'enable'),
    ('SN10', 4, 'ST2', 'enable'),
    ('SN11', 5, 'ST2', 'enable'),
    ('SN12', 6, 'ST2', 'enable'),
-- Ghế C
    ('SN13', 1, 'ST3', 'enable'),
    ('SN14', 2, 'ST3', 'enable'),
    ('SN15', 3, 'ST3', 'enable'),
    ('SN16', 4, 'ST3', 'enable'),
    ('SN17', 5, 'ST3', 'enable'),
    ('SN18', 6, 'ST3', 'enable'),

-- Ghế D
    ('SN19', 1, 'ST4', 'enable'),
    ('SN20', 2, 'ST4', 'enable'),
    ('SN21', 3, 'ST4', 'enable'),
    ('SN22', 4, 'ST4', 'enable'),
    ('SN23', 5, 'ST4', 'enable'),
    ('SN24', 6, 'ST4', 'enable'),
--Ghế E
    ('SN25', 1, 'ST5', 'enable'),
    ('SN26', 2, 'ST5', 'enable'),
    ('SN27', 3, 'ST5', 'enable'),
    ('SN28', 4, 'ST5', 'enable'),
    ('SN29', 5, 'ST5', 'enable'),
    ('SN30', 6, 'ST5', 'enable');
Go
INSERT INTO CUSTOMER
    (CustomerID, NameCust, Email, Phone, DateOfBirth, C_Password)
VALUES
    ('C001', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '0123456789', '1990-01-01', '123456789'),
    ('C004', N'Nguyễn Văn A', 'khanhsky2k5nam@gmail.com', '0123456780', '1990-01-01', '123456789'),
    ('C002', N'Trần Thị B'  , 'tranthib@example.com', '0987654321', '1985-05-15', '123456789'),
    ('C003', N'Lê Văn C'    , 'khang0504luvy@gmail.com', '0135792468', '1992-10-20', '123456789');
GO
INSERT INTO ADMIN
    (AdminID, nameAdmin, Email, Phone, A_Password, DateOfBirth)
VALUES
    ('A001', N'Nguyễn Tuấn Anh'		, '23115053122101@sv.ute.udn.vn', '0123456789', '123456789', '2005-02-12'),
    ('A004', N'Huỳnh Minh Dũng'		, '23115053122108@sv.ute.udn.vn', '0123456780', '123456789', '2005-01-31'),
    ('A002', N'Phan Văn Khánh'		, '23115053122114@sv.ute.udn.vn', '0987654321', '123456789', '2005-04-05'),
    ('A003', N'Nguyễn Thành Mạnh'	, '23115053122120@sv.ute.udn.vn', '0135792468', '123456789', '2005-11-18');
GO
INSERT INTO AIRPORT
    (AirportID, AirportName, CityID)
VALUES
    ('AI01', N'Sân Bay Nội Bài'		, 'CT002'),
    ('AI02', N'Sân Bay Tân Sơn Nhất', 'CT004'),
    ('AI03', N'Sân Bay Đà Nẵng'		, 'CT001'),
    ('AI04', N'Sân Bay Cam Ranh'	, 'CT003'),
    ('AI05', N'Sân Bay Phú Quốc'	, 'CT006'),
    ('AI06', N'Sân Bay Tuy Hòa'		, 'CT007'),
    ('AI07', N'Sân Bay Đồng Hới'	, 'CT010'),
    ('AI08', N'Sân Bay Cát Bi'		, 'CT005'),
    ('AI09', N'Sân Bay Vinh'		, 'CT009'),
    ('AI10', N'Sân Bay Phú Bài'		, 'CT008');
GO
INSERT INTO FLIGHT
    (FlightID,FlightNumber,  AirportID, CityID, DepartureTime, ArrivalTime, DefaultPrice)
VALUES
    ('F000001','VN001',  'AI01', 'CT001', '2025-01-01 08:00:45', '2025-01-04 10:00:44', 1500000),
    ('F000002','VN002',  'AI02', 'CT001', '2024-11-21 12:00:10', '2024-11-21 13:30:56', 1200000),
    ('F000003','VN003',  'AI01', 'CT009', '2024-11-22 16:00:47', '2024-11-22 17:30:11', 1780000),
    ('F000004','VN003',  'AI05', 'CT003', '2024-11-24 16:00:08', '2024-11-24 17:30:23', 1560000),
    ('F000005','VN003',  'AI06', 'CT005', '2024-11-26 16:00:07', '2024-11-26 17:30:07', 1750000),
    ('F000006','VN003',  'AI02', 'CT010', '2024-11-28 16:00:04', '2024-11-28 17:30:22', 2000000),
    ('F000007','VN003',  'AI07', 'CT006', '2024-11-30 16:00:05', '2024-11-30 17:30:11', 1350000),
    ('F000008','VN003',  'AI01', 'CT001', '2024-12-01 16:00:45', '2024-12-02 17:30:01', 2000000),
    ('F000009','VN003',  'AI09', 'CT007', '2024-12-03 16:00:13', '2024-12-03 17:30:00', 1490000),
    ('F000010','VN003',  'AI10', 'CT002', '2024-12-05 16:00:12', '2024-12-05 17:30:45', 2100000);
Go
/*
INSERT INTO TICKET
    (TicketID, FlightID, CustomerID, idSeat, BookingDate)
VALUES
    ('T000001', 'F000001', 'C001', 'SN01', '2024-11-01'),
    ('T000002', 'F000001', 'C002', 'SN02', '2024-11-02', 'Pending'),
    ('T000003', 'F000002', 'C003', 'SN01', '2024-11-03', 'Confirmed'),
    ('T000004', 'F000002', 'C001', 'SN07', '2024-11-02', 'Confirmed'),
    ('T000005', 'F000003', 'C003', 'SN01', '2024-11-10', 'Confirmed'),
    ('T000006', 'F000003', 'C002', 'SN08', '2024-11-11', 'Confirmed'),
    ('T000007', 'F000004', 'C003', 'SN01', '2024-11-11', 'No Show'),
    ('T000008', 'F000004', 'C001', 'SN09', '2024-11-12', 'Confirmed'),
    ('T000009', 'F000005', 'C001', 'SN01', '2024-11-12', 'Cancelled'),
    ('T000010', 'F000005', 'C002', 'SN10', '2024-11-13', 'Refunded'),
    ('T000011', 'F000006', 'C002', 'SN21', '2024-11-13', 'No Show'),
    ('T000012', 'F000006', 'C003', 'SN01', '2024-11-14', 'Confirmed'),
    ('T000013', 'F000007', 'C001', 'SN11', '2024-11-15', 'Cancelled'),
    ('T000014', 'F000007', 'C003', 'SN01', '2024-11-15', 'Checked In'),
    ('T000015', 'F000008', 'C002', 'SN17', '2024-11-16', 'Confirmed'),
    ('T000016', 'F000008', 'C003', 'SN26', '2024-11-17', 'Confirmed'),
    ('T000017', 'F000009', 'C001', 'SN02', '2024-11-18', 'Refunded'),
    ('T000018', 'F000009', 'C003', 'SN11', '2024-11-18', 'Cancelled'),
    ('T000019', 'F000010', 'C001', 'SN15', '2024-11-16', 'No Show'),
    ('T000020', 'F000010', 'C003', 'SN25', '2024-11-26', 'Confirmed');
Go
*/
--drop PROCEDURE pr_TaoDongMoi
create PROCEDURE pr_TaoDongMoi
    @TableName NVARCHAR(50),
	@NewIDtable VARCHAR(15) OUTPUT -- Tham số đầu ra
AS
BEGIN
	IF @TableName = N'Customer'
	BEGIN
		-- Tìm CustomerID lớn nhất hiện có
		DECLARE @maxMaLopHocPhan VARCHAR(10);
		SELECT @maxMaLopHocPhan = MAX(CustomerID) FROM CUSTOMER;

		IF @maxMaLopHocPhan IS NULL
		BEGIN
			SET @NewIDtable = 'C00001';  -- Đặt giá trị khởi đầu
		END
		ELSE
		BEGIN
			-- Tăng ID lên 1
			SET @NewIDtable = 'C' + FORMAT(CAST(RIGHT(@maxMaLopHocPhan, 3) AS INT) + 1, 'D3');
		END

		-- Chèn vào bảng
		INSERT INTO CUSTOMER (CustomerID)
		VALUES (@NewIDtable);
	END
	ELSE
	IF @TableName = N'ADMIN'
	BEGIN
		-- Tìm AdminID lớn nhất hiện có
		DECLARE @MaxAdminID VARCHAR(10);
		SELECT @MaxAdminID = MAX(AdminID) FROM ADMIN;

		IF @MaxAdminID IS NULL
		BEGIN
			SET @NewIDtable = 'A00001';  -- Đặt giá trị khởi đầu
		END
		ELSE
		BEGIN
			-- Tăng ID lên 1
			SET @NewIDtable = 'A' + FORMAT(CAST(RIGHT(@MaxAdminID, 3) AS INT) + 1, 'D3');
		END

		-- Chèn vào bảng
		INSERT INTO ADMIN (AdminID)
		VALUES (@NewIDtable);
	END
	ELSE
	IF @TableName = N'AIRPORT'
	BEGIN
		-- Tìm AirportID lớn nhất hiện có
		DECLARE @MaxAirportID VARCHAR(15);
		SELECT @MaxAirportID = MAX(AirportID) FROM AIRPORT;

		IF @MaxAirportID IS NULL
		BEGIN
			SET @NewIDtable = 'AI00001';  -- Đặt giá trị khởi đầu
		END
		ELSE
		BEGIN
			-- Tăng ID lên 1
			SET @NewIDtable = 'AI' + FORMAT(CAST(RIGHT(@MaxAirportID, 2) AS INT) + 1, 'D2');
		END

		-- Chèn vào bảng
		INSERT INTO AIRPORT (AirportID)
		VALUES (@NewIDtable);
	END
	ELSE
	IF @TableName = N'FLIGHT'
	BEGIN
		-- Tìm FlightID lớn nhất hiện có
		DECLARE @MaxFlightID VARCHAR(7);
		SELECT @MaxFlightID = MAX(FlightID) FROM FLIGHT;
		IF @MaxFlightID IS NULL
		BEGIN
			SET @NewIDtable = 'F000001';
		END
		ELSE
		BEGIN
			-- Tăng ID lên 1
			SET @NewIDtable = 'F' + FORMAT(CAST(RIGHT(@MaxFlightID, 6) AS INT) + 1, 'D6');
		END

		-- Chèn vào bảng
		INSERT INTO FLIGHT(FlightID)
		VALUES (@NewIDtable);
	END
	ELSE
	IF @TableName = N'TICKET'
	BEGIN
		-- Tìm TicketID lớn nhất hiện có
		DECLARE @MaxTicketID VARCHAR(7);
		SELECT @MaxTicketID = MAX(TicketID) FROM TICKET;

		-- Nếu không có TicketID nào, khởi tạo giá trị đầu tiên
		IF @MaxTicketID IS NULL
		BEGIN
			SET @NewIDtable = 'T0001';
		END
		ELSE
		BEGIN
			-- Tăng ID lên 1
			SET @NewIDtable = 'T' + FORMAT(CAST(RIGHT(@MaxTicketID, 4) AS INT) + 1, 'D4');
		END

		-- Chèn vào bảng
		INSERT INTO TICKET(TicketID)
		VALUES (@NewIDtable);
	END
	ELSE
	IF @TableName = N'CUSTOMERREQUESTS'
	BEGIN
		-- Tìm RequestID lớn nhất hiện có
		DECLARE @MaxRequestID VARCHAR(7);
		SELECT @MaxRequestID = MAX(RequestID) FROM CUSTOMERREQUESTS;

		-- Nếu không có RequestID nào, khởi tạo giá trị đầu tiên
		IF @MaxRequestID IS NULL
		BEGIN
			SET @NewIDtable = 'RQ001';
		END
		ELSE
		BEGIN
			-- Tăng ID lên 1
			SET @NewIDtable = 'RQ' + FORMAT(CAST(RIGHT(@MaxRequestID, 3) AS INT) + 1, 'D3');
		END

		-- Chèn vào bảng
		INSERT INTO CUSTOMERREQUESTS(RequestID)
		VALUES (@NewIDtable);
	END
END
/*
DECLARE @NewCustomerID VARCHAR(15)
exec pr_TaoDongMoi CUSTOMER, @NewCustomerID output

DECLARE @NewAdminID VARCHAR(15)
exec pr_TaoDongMoi ADMIN, @NewAdminID output

DECLARE @AirportID VARCHAR(15)
exec pr_TaoDongMoi AIRPORT, @AirportID output
select * from AIRPORT

DECLARE @FlightID VARCHAR(15)
exec pr_TaoDongMoi FLIGHT, @FlightID output
select * from FLIGHT

DECLARE @TicketID VARCHAR(15)
exec pr_TaoDongMoi TICKET, @TicketID output
select * from TICKET

DECLARE @RequestID VARCHAR(15)
exec pr_TaoDongMoi CUSTOMERREQUESTS, @RequestID output
select * from CUSTOMERREQUESTS

Update CUSTOMER
set NameCust = N'khánh',
	C_Password = '123lll***',
	Email = 'khanh@gmail.com',
	Phone = 0123456789,
	DateOfBirth = '2005/04/05'
Where CustomerID = @NewCustomerID

Select * from CUSTOMER
*/
Go
CREATE TRIGGER trg_Delete
ON CUSTOMER
AFTER DELETE
AS
BEGIN
    DELETE FROM TICKET
    WHERE CustomerID IN (
        SELECT d.CustomerID
        FROM deleted d, TICKET t, CUSTOMER c  
		Where d.CustomerID = c.CustomerID
		And t.CustomerID = c.CustomerID
    )
END;
Go
-- Trigger để xử lý việc xóa từ CITY
CREATE TRIGGER trg_DeleteCity
ON CITY
INSTEAD OF DELETE
AS
BEGIN
    -- Xóa các bản ghi tương ứng trong bảng FLIGHT
    DELETE FROM FLIGHT
    WHERE CityID IN (SELECT CityID FROM deleted);
    
    -- Sau đó, xóa bản ghi trong CITY
    DELETE FROM CITY
    WHERE CityID IN (SELECT CityID FROM deleted);
END;

GO

CREATE TRIGGER trg_CalculatePrice
ON TICKET
AFTER UPDATE
AS
BEGIN
    -- Cập nhật giá vé
    UPDATE TICKET
    SET Price = F.DefaultPrice * SC.Costmultiple
    FROM FLIGHT F, SEATNUMBER SN, SEATTYPE ST, SEATCLASS SC
    WHERE TICKET.FlightID = F.FlightID
      AND TICKET.idSeat = SN.idSeat
      AND SN.idSeatType = ST.idSeatType
      AND ST.idSeatClass = SC.idSeatClass
      AND TICKET.TicketID IN (SELECT TicketID FROM inserted);

    -- Cập nhật số dư tài khoản khách hàng
    UPDATE CUSTOMER
    SET accountBalance = accountBalance - 
        (SELECT SUM(F.DefaultPrice * SC.Costmultiple)
         FROM inserted I
         JOIN FLIGHT F ON I.FlightID = F.FlightID
         JOIN SEATNUMBER SN ON I.idSeat = SN.idSeat
         JOIN SEATTYPE ST ON SN.idSeatType = ST.idSeatType
         JOIN SEATCLASS SC ON ST.idSeatClass = SC.idSeatClass)
    WHERE CUSTOMER.CustomerID IN (SELECT CustomerID FROM inserted);
    
    -- Cập nhật số ghế có sẵn trong chuyến bay
    UPDATE FLIGHT
    SET available = (
        SELECT COUNT(T.TicketID)
        FROM TICKET T
        WHERE T.FlightID = F.FlightID
    )
    FROM FLIGHT F
    WHERE F.FlightID IN (
        SELECT DISTINCT T.FlightID
        FROM TICKET T 
        WHERE T.TicketID IN (SELECT TicketID FROM inserted)
    );
END;
Go

CREATE TRIGGER trg_RefundAfterDelete
ON TICKET
AFTER DELETE
AS
BEGIN
    -- Hoàn tiền cho khách hàng
    UPDATE CUSTOMER
    SET accountBalance = accountBalance + 
        (SELECT SUM(F.DefaultPrice * SC.Costmultiple)
         FROM DELETED D
         JOIN FLIGHT F ON D.FlightID = F.FlightID
         JOIN SEATNUMBER SN ON D.idSeat = SN.idSeat
         JOIN SEATTYPE ST ON SN.idSeatType = ST.idSeatType
         JOIN SEATCLASS SC ON ST.idSeatClass = SC.idSeatClass)
    WHERE CUSTOMER.CustomerID IN (SELECT CustomerID FROM DELETED);

    -- Cập nhật số ghế có sẵn trong chuyến bay
    UPDATE FLIGHT
    SET available = (
        SELECT COUNT(T.TicketID)
        FROM TICKET T
        WHERE T.FlightID = F.FlightID
    )
    FROM FLIGHT F
    WHERE F.FlightID IN (
        SELECT DISTINCT D.FlightID
        FROM DELETED D
    );
END;


GO
/*
SELECT DISTINCT DepartureTime 
FROM FLIGHT 
WHERE AirportID IN (SELECT AirportID FROM AIRPORT WHERE AirportName = N'Sân Bay Nội Bài');

SELECT DISTINCT ArrivalTime 
FROM FLIGHT 
WHERE AirportID IN (SELECT AirportID FROM AIRPORT WHERE AirportName = N'Sân Bay Nội Bài');

SELECT F.FlightID, F.FlightNumber, A.AirportName, C.nameCiTy,
	F.DepartureTime, F.ArrivalTime, F.DefaultPrice, F.available, F.Maximum
FROM FLIGHT F, AIRPORT A, CITY C
WHERE F.AirportID = A.AirportID
AND F.CityID = C.CityID
AND A.AirportID = 'AI01'
AND C.CityID = 'CT001'
AND F.DepartureTime >= '2024-12-01 15:04:02'
AND F.ArrivalTime <= '2024-12-05 15:04:02';
*/

Select distinct (T.nameSeatType+N.numberSeat)
From SEATTYPE T, SEATNUMBER N, SEATCLASS C
Where N.idSeatType = T.idSeatType
AND T.idSeatClass = C.idSeatClass
AND C.nameSeatClass = N'Thương Gia'
AND N.idSeat not in (select distinct idSeat from TICKET Where FlightID = 'F000002')

Select N.idSeat
From SEATTYPE T, SEATNUMBER N, SEATCLASS C
Where N.idSeatType = T.idSeatType
AND T.idSeatClass = C.idSeatClass
AND (T.nameSeatType+N.numberSeat) = 'A1'

Select T.TicketID, C.NameCust, F.FlightNumber, T.TypeTicket,
		SC.nameSeatClass, (ST.nameSeatType + N.numberSeat),
		T.BookingDate, F.DepartureTime, AR.AirportName,
		(Select AirportName from AIRPORT Where AIRPORT.CityID = F.CityID), T.Price
From TICKET T, FLIGHT F, AIRPORT AR, CUSTOMER C, SEATTYPE ST, SEATNUMBER N, SEATCLASS SC
Where T.FlightID = F.FlightID
AND T.CustomerID = C.CustomerID
AND F.AirportID = AR.AirportID
AND N.idSeatType = ST.idSeatType
AND ST.idSeatClass = SC.idSeatClass
AND T.idSeat = N.idSeat
AND T.CustomerID = 'C002'


Select available, Maximum
From FLIGHT
Where FlightID = 'F000008'