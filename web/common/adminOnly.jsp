<%
if (!user.isAdmin()) {
    response.sendRedirect("login.jsp");
    return;
}
%>