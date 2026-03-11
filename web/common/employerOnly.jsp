<%@page import="com.workflowx.model.Leave"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="com.workflowx.dao.LeaveDAO"%>
<%
if (!user.isEmployer()) {
    response.sendRedirect("login.jsp");
    return;
}
%>