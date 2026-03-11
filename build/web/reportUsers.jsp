<%@page import="java.sql.Timestamp  "%>
<%@page import="java.util.Map"%>
<%@page import="com.workflowx.dao.ReportDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>

<%
boolean isAdmin = user.isAdmin();
String source = request.getParameter("source");
String department = request.getParameter("department");
ReportDAO dao = new ReportDAO();
String selectedDept = request.getParameter("department");
 List<Map<String, Object>> users;

    if (isAdmin) {
    if (selectedDept != null && !selectedDept.isEmpty()) {
        // Admin viewing a specific department
        users = dao.getUsersReportByDepartment(selectedDept);
    } else {
        // Admin viewing all users
        users = dao.getAllUsersReport();
    }
} else {
    // Employer sees only employees in their own department
    users = dao.getUsersReportByDepartment(user.getDepartment());
}
if (users == null) {
    users = new ArrayList<>();
}
SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Reports - WorkFlowX</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
<style>
* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background:#f5f5f5;
    color:#333;
    transition:all 0.3s ease;
}

/* ================= NAVBAR ================= */
.navbar {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    color:white;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.navbar .dashboard-btn {
    color:white;
    text-decoration:none;
    padding:8px 15px;
    background:rgba(255,255,255,0.2);
    border-radius:5px;
    margin-left:10px;
}

/* ================= LAYOUT ================= */
.container {
    max-width:1400px;
    margin:30px auto;
    padding:0 20px;
}

.page-header {
    background:white;
    padding:30px;
    border-radius:10px;
    margin-bottom:30px;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

.table-container {
    background:white;
    border-radius:10px;
    overflow:hidden;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

table {
    width:100%;
    border-collapse:collapse;
}

thead {
   background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    color:white;
}

th, td {
    padding:15px;
    text-align:left;
    
}

tbody tr:hover {
    background:#f9f9f9;
}

td a {
    text-decoration:none;
    color: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    font-weight:600;
}

/* ================= BADGES ================= */
.badge {
    padding:5px 12px;
    border-radius:15px;
    font-size:12px;
    font-weight:600;
    display:inline-block;
}

.employee { background:#e3f2fd; color:#1976d2; }
.employer { background:#fff3e0; color:#f57c00; }
.admin { background:#ede7f6; color:#5e35b1; }

.active { background:#e8f5e9; color:#388e3c; }
.inactive { background:#ffebee; color:#d32f2f; }

.no-data {
    text-align:center;
    padding:40px;
    color:#999;
}
/* ================= DARK MODE ================= */
body.dark-mode {
    background:#1e1e2f;
    color:#f1f1f1;
}

.dark-mode .navbar {
    background:#1e1e2f;
}

.dark-mode .page-header,
.dark-mode .table-container {
    background:#252538;
    color:#f1f1f1;
}

.dark-mode table thead {
    background:#2f2f45;
}

.dark-mode tbody tr:hover {
    background:#303048;
}

.dark-mode th,
.dark-mode td {
    border-color:#3a3a50;
}

.dark-mode td a {
    color:#8ea6ff;
}

.dark-mode .no-data {
    color:#bbb;
}
</style>
</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="navbar">
    <h2>👥 User Reports</h2>
    
    <div style="display:flex; align-items:center; gap:15px;">
        <form action="ThemeServlet" method="post">
            <div class="mini-toggle" onclick="this.closest('form').submit();">
                <div class="mini-slider <%= theme.equals("DARK") ? "active" : "" %>">
                     <span class="icon-left">☀</span>
            <span class="icon-right">🌙</span>
                </div>
            </div>
            <input type="hidden" name="currentTheme" value="<%= theme %>">
        </form>

        <% if (navProfilePic != null) { %>
    <!-- Show uploaded profile picture -->
            <a href="profile.jsp" class="profile-pic-btn" title="My Profile">
            <img src="uploads/profiles/<%= navProfilePic %>" alt="Profile">
            </a>
        <% } else { %>
    <!-- Show default user icon -->
            <a href="profile.jsp" class="profile-pic-btn" title="My Profile">
            <svg class="profile-icon-svg" viewBox="0 0 24 24">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
            </svg>
            </a>
        <% } %>

       <% if ("globalReports".equals(request.getParameter("source"))) { %>
    <a href="globalReports.jsp" class="dashboard-btn">← Back</a>
   
<% } else if ("reports".equals(request.getParameter("source"))) { %>
    <a href="reports.jsp" class="dashboard-btn">← Back</a>
    
<% } %>


    <!-- Dashboard Button -->
    <% if (user.isAdmin()) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } else { %>
        <a href="employerDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } %>
    </div>
</div>


<div class="container">

<div class="page-header">
    <% if (selectedDept != null && !selectedDept.isEmpty()) { %>
        <p style="color:#666; margin-top:5px;">
            Showing employees in: <strong><%= selectedDept %></strong>
        </p>
    <% } else if (!user.isAdmin()) { %>
        <p style="color:#666; margin-top:5px;">
            Showing employees in: <strong><%= user.getDepartment() %></strong>
        </p>
    <% } else { %>
        <p style="color:#666; margin-top:5px;">
            Showing all employees
        </p>
    <% } %>
</div>

<div class="table-container">

<% if (users.isEmpty()) { %>

    <div class="no-data">No users found</div>

<% } else { %>

<table>
<thead>
<tr>
<th>Username</th>
<th>Full Name</th>
<th>Email</th>
<th>Role</th>
<th>Department</th>
<th>Status</th>
<th>Joined</th>
<th>Last Login</th>
</tr>
</thead>

<tbody>

<%
for (Map<String, Object> u : users) {
    String role = u.get("role") != null ? u.get("role").toString() : "-";
    Boolean isActive = u.get("isActive") != null ? (Boolean)u.get("isActive") : false;
    Timestamp createdAt = (Timestamp) u.get("createdAt");
    Timestamp lastLogin = (Timestamp) u.get("lastLogin");
%>

<tr>
<td>
<a href="reportUserDetail.jsp?userId=<%= u.get("userId") %>&source=<%= source %>&department=<%= department %>">
    <%= u.get("username") %>
</a>
</td>

<td><%= u.get("fullName") %></td>
<td><%= u.get("email") %></td>

<td>
<span class="badge <%= role.toLowerCase() %>">
<%= role %>
</span>
</td>

<td><%= u.get("department") != null ? u.get("department") : "-" %></td>

<td>
<span class="badge <%= isActive ? "active" : "inactive" %>">
<%= isActive ? "Active" : "Inactive" %>
</span>
</td>

<td><%= createdAt != null ? sdf.format(createdAt) : "-" %></td>

<td><%= lastLogin != null ? sdf.format(lastLogin) : "Never" %></td>

</tr>

<% } %>

</tbody>
</table>

<% } %>

</div>
</div>

</body>
</html>
