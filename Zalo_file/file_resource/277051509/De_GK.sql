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
  totalTime decimal(10,2) not null,
  agedLabel date not null,
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
  ageLevel date not null, -- Lưu trữ nhãn tuổi, ví dụ: "G", "PG", "R",
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
	ADD FOREIGN KEY (PhimNo) REFERENCES Phim(idPhim)
		on update 
			cascade
		on delete
			cascade;
ALTER TABLE VE 
	ADD FOREIGN KEY (SCNo) REFERENCES SuatChieu(idSC)
		on update 
			cascade
		on delete
			cascade;
ALTER TABLE VE 
	ADD FOREIGN KEY (PhongNo) REFERENCES Phong(idPhong)
		on update 
			cascade
		on delete
			cascade;
ALTER TABLE VE 
	ADD FOREIGN KEY (GheNo) REFERENCES Ghe(idGhe)
		on update 
			cascade
		on delete
			cascade;

-- Câu 1d.
ALTER TABLE Phim
	add HangSanXuat nvarchar(100) not null;

-- Câu 1e.
update Phim
set HangSanXuat = null
where HangSanXuat is not null