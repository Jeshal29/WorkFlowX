
<%
if (!user.isEmployee()) {
    response.sendRedirect("login.jsp");
    return;
}
%>