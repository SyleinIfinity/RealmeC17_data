<%-- 
    Document   : pageQUANLYBAN
    Created on : Mar 27, 2025, 9:51:22 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="SCHEMACLASS.KHUVUC" %>
<%@page import="SCHEMAOBJECT.KHUVUCS" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập Liệu</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        form {
            max-width: 400px;
            margin: auto;
        }
        label {
            display: block;
            margin-top: 10px;
        }
        input, textarea, select {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            box-sizing: border-box;
        }
        button {
            margin-top: 15px;
            padding: 10px 15px;
            background-color: #007BFF;
            color: white;
            border: none;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <h1>Nhập Liệu Bàn</h1>
    <form action="doBAN" method="get">
        <label for="MaBan_ID">Mã Bàn (ID):</label>
        <input type="text" id="MaBan_ID" name="MaBan_ID" required>

        <label for="TenBan">Tên Bàn:</label>
        <input type="text" id="TenBan" name="TenBan" required>

        <label for="TrangThai">Trạng Thái:</label>
        <select id="TrangThai" name="TrangThai" required>
            <option value="false">Còn Trống</option>
            <option value="true">Đã Có Người</option>
            <option value="true">Đã Đặt Trước</option>
        </select>

        <label for="MoTa">Mô Tả:</label>
        <textarea id="MoTa" name="MoTa" rows="4"></textarea>

        <label for="MaKhuVuc_ID">Mã Khu Vực (ID):</label>
       
             <select id="MaKhuVuc_ID" name="MaKhuVuc_ID" required>
                 <%
                   KHUVUCS khuvucs=new KHUVUCS();
                   for(KHUVUC khuvuc:khuvucs.getLISTKHUVUC().values())
                   {
                   
                 
                 %>
                 <option value="<%=khuvuc.getMaKhuVuc_ID()%>"><%= khuvuc.getTenKhuVuc()%></option>
           
            <%}%>
        </select>
        <button type="submit">Lưu</button>
    </form>
</body>
</html>
