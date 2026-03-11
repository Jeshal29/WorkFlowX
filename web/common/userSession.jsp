<%@ page import="com.workflowx.model.User" %>
<%
User user = (User) session.getAttribute("user");

if (user == null) {
    response.sendRedirect("login.jsp");
    return;
}

String theme = user.getThemePreference() != null 
        ? user.getThemePreference() 
        : "LIGHT";

String navProfilePic = null;
String pic = user.getProfilePicture();

if (pic != null && !pic.isEmpty() && !pic.equals("default.jpg")) {
    navProfilePic = pic;
}
%>