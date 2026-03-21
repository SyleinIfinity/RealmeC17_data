IF EXISTS (SELECT * FROM sys.databases WHERE name = N'Đặt vé xem phim')
	BEGIN
		USE master
		ALTER database [Đặt vé xem phim] set single_user with rollback immediate
		DROP DATABASE [Đặt vé xem phim];
	END

create database [Đặt vé xem phim]
go 
use [Đặt vé xem phim]
go

-- Tạo bảng: Phim
CREATE TABLE Phim (
  idPhim CHAR(10) not null,
  tenPhim NVARCHAR(50) not null,
  theLoai NVARCHAR(50) not null,
  [2D3D] char(2) not null,
  totalTime FLOAT not null,
  agedLabel int not null,
  constraint PK_idPhim_Phim primary key(idPhim)
);

CREATE TABLE SuatChieu (
  idSC CHAR(10) not null,
  startTime TIME not null,
  constraint PK_idSC_SuatChieu primary key(idSC)
);

CREATE TABLE Ve (
  idVe  int identity(1,1) not null,
  PhimNo CHAR(10) not null,
  SCNo CHAR(10) not null,
  PhongNo CHAR(10) not null,
  GheNo CHAR(10) not null,
  ngayMuaVe DATE not null,
  ngayChieuPhim DATE not null,
  ageLevel int not null, -- Lưu trữ nhãn tuổi, ví dụ: "G", "PG", "R",
  giaVe money not null,
  constraint PK_idVe_Ve primary key(idVe)
);

CREATE TABLE Phong (
  idPhong CHAR(10) not null,
  tenPhong NVARCHAR(50) not null,
  constraint PK_idPhong_Phong primary key(idPhong)
);

CREATE TABLE Ghe (
  idGhe CHAR(10) not null,
  maHangGhe CHAR(7) not null,
  gheNumber VARCHAR(100) not null,
  constraint PK_idGhe_Ghe primary key(idGhe)
);

-- Câu 1b.
ALTER TABLE Phim 
	add constraint CK_2D3D_Phim CHECK ([2D3D] IN ('2D', '3D')),
		constraint DF_2D3D_Phim default '2D' for [2D3D];

-- Câu 1c.
ALTER TABLE VE 
	ADD CONSTRAINT FK_PhimNo FOREIGN KEY (PhimNo) REFERENCES Phim(idPhim)
			on update 
				cascade
			on delete
				cascade;
-- ALTER TABLE VE 
-- 	ADD FOREIGN KEY (SCNo) REFERENCES SuatChieu(idSC)
-- 		on update 
-- 			cascade
-- 		on delete
-- 			cascade;
-- ALTER TABLE VE 
-- 	ADD FOREIGN KEY (PhongNo) REFERENCES Phong(idPhong)
-- 		on update 
-- 			cascade
-- 		on delete
-- 			cascade;
-- ALTER TABLE VE 
-- 	ADD FOREIGN KEY (GheNo) REFERENCES Ghe(idGhe)
-- 		on update 
-- 			cascade
-- 		on delete
-- 			cascade;

-- Câu 1d.
ALTER TABLE Phim
	add HangSanXuat nvarchar(100) not null;

-- Câu 1e.
update Phim
set HangSanXuat = null
where HangSanXuat is not null

INSERT INTO Phim (idPhim, tenPhim, theLoai, [2D3D], totalTime, agedLabel, HangSanXuat)
VALUES ('P001', N'Avengers: Endgame'		,N'Hành động'		, '3D', 180.5, 16, N'Marvel Studios'),
       ('P002', N'The Shawshank Redemption', N'Tâm lý, Tội phạm', '2D', 142	 , 16, N'Castle Rock Entertainment');

INSERT INTO Ve (PhimNo, SCNo, PhongNo, GheNo, ngayMuaVe, ngayChieuPhim, ageLevel, giaVe)
VALUES ('P001', 'SC001', 'Phong01', 'G01', '2022-08-15', '2022-08-16', '18', 150000),
       ('P002', 'SC002', 'Phong02', 'G02', '2022-08-16', '2022-08-17', '17', 120000);

SELECT * FROM Phim

DELETE Ve
WHERE PhimNo = 'P001'

SELECT * FROM Ve

CREATE TABLE LoaiPhong
(
	idLPhong char(5),
	tenLPhong NVARCHAR(50) not null,
	CONSTRAINT PK_IDLPhong PRIMARY KEY(idLPhong)
)

CREATE TABLE LoaiKhu
(
	idLKhu char(5),
	tenLKhu NVARCHAR(50) not null,
	CONSTRAINT PK_IDLPhong PRIMARY KEY(idLKhu)
)

CREATE TABLE Khu
(
	idKhu char(5),
	LKhuNo CHAR(5) NOT NULL,
	tenKhu NVARCHAR(50) not null,
	CONSTRAINT PK_IDLPhong PRIMARY KEY(idKhu),
	FOREIGN KEY(LKhuNo) REFERENCES LoaiKhu(idLKhu)
)

ALTER TABLE PHONG
	ADD LPhongNo CHAR(5) not NULL FOREIGN KEY(LPhongNo) REFERENCES LoaiPhong(idLPhong),
		KhuNo CHAR(5) not NULL FOREIGN KEY(KhuNo) REFERENCES Khu(idKhu)

SELECT	v.*
FROM	Phim p, Ve v, Phong ph
WHERE	p.idPhim = v.idVe
AND 	v.PhongNo = ph.idPhong
AND v.PhongNo = 'P001' or v.PhongNo = 'P002'