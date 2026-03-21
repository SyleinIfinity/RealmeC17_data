<%-- 
    Document   : demosession
    Created on : Mar 27, 2025, 11:16:55 AM
    Author     : Admin
--%>

<%@page import="java.net.HttpRetryException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Session Example</title>
</head>
<body>
    <%
        try{
        // Get the current session, create one if it doesn't exist
        //HttpSession session = request.getSession();

        // Set a session attribute
      
        String username = (String) session.getValue("username");
     
        // Display session information
        out.println("<h1>Session Example</h1>");
        out.println("<p>Session ID: " + session.getId() + "</p>");
        out.println("<p>Username: " + username + "</p>");
         }catch(Exception ex){}
    %>
</body>
</html>
        %>
        <h1>Hello World!</h1>
    </body>
</html>
