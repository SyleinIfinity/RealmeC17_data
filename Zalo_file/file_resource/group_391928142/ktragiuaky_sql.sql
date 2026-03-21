create database dbSHOPHOA
go
use dbSHOPHOA
go

-- Tạo bảng tbNHOM
CREATE TABLE tbNHOM (
    MALOAI INT PRIMARY KEY,
    TENLOAI NVARCHAR(200) NULL
);

-- Tạo bảng tbHOA
CREATE TABLE tbHOA (
    MAHOA INT PRIMARY KEY,
    TENHOA NVARCHAR(200) NULL,
    DONVITINH NVARCHAR(50) NULL,
    SOLUONG INT NULL,
    DONGIA NUMERIC(18, 0) NULL,
    HINHANH NVARCHAR(100) NULL,
    MOTA NVARCHAR(MAX) NULL,
    MALOAI INT NOT NULL,
    FOREIGN KEY (MALOAI) REFERENCES tbNHOM(MALOAI)
);

INSERT INTO tbNHOM (MALOAI, TENLOAI) VALUES
(1, N'Hoa Hồng'),
(2, N'Hoa Cẩm Chướng'),
(3, N'Hoa Hướng Dương'),
(4, N'Hoa Đồng Tiền'),
(5, N'Hoa Lan');

INSERT INTO tbHOA (MAHOA, TENHOA, DONVITINH, SOLUONG, DONGIA, HINHANH, MOTA, MALOAI) VALUES
(1, N'Hoa Hồng Đỏ', N'Bó', 100, 50000, N'hong_do.jpg', N'Hoa hồng đỏ tươi, tượng trưng cho tình yêu.', 1),
(2, N'Hoa Hồng Trắng', N'Bó', 80, 55000, N'hong_trang.jpg', N'Hoa hồng trắng tinh khôi, biểu tượng của sự thuần khiết.', 1),
(3, N'Hoa Cẩm Chướng Đỏ', N'Bó', 60, 45000, N'camchuong_do.jpg', N'Hoa cẩm chướng đỏ với sắc đỏ đậm đà.', 2),
(4, N'Hoa Cẩm Chướng Hồng', N'Bó', 50, 47000, N'camchuong_hong.jpg', N'Hoa cẩm chướng màu hồng tươi tắn.', 2),
(5, N'Hoa Hướng Dương', N'Bó', 120, 40000, N'huongduong.jpg', N'Hoa hướng dương rực rỡ, luôn hướng về ánh mặt trời.', 3),
(6, N'Hoa Đồng Tiền Đỏ', N'Bó', 90, 30000, N'dongtien_do.jpg', N'Hoa đồng tiền màu đỏ tươi, mang ý nghĩa may mắn.', 4),
(7, N'Hoa Đồng Tiền Cam', N'Bó', 70, 32000, N'dongtien_cam.jpg', N'Hoa đồng tiền màu cam rực rỡ.', 4),
(8, N'Hoa Lan Hồ Điệp Trắng', N'Chậu', 30, 75000, N'lan_hodiep_trang.jpg', N'Hoa lan hồ điệp trắng tinh khôi.', 5),
(9, N'Hoa Lan Hồ Điệp Tím', N'Chậu', 25, 80000, N'lan_hodiep_tim.jpg', N'Hoa lan hồ điệp màu tím quyến rũ.', 5);



