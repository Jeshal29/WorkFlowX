<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.workflowx.dao.UserDAO" %>
<%@ page import="com.workflowx.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.workflowx.util.DatabaseConnection" %>
<%@ include file="/common/userSession.jsp" %>
<%
String role = user.getRole();
UserDAO userDAO = new UserDAO();
List<User> activeEmployees;
List<User> inactiveEmployees;
if (role.equals("ADMIN")) {
    activeEmployees = userDAO.getUsersByStatus(true);
    inactiveEmployees = userDAO.getUsersByStatus(false);
} else {
    // Employer sees only their department
    activeEmployees = userDAO.getEmployeesByDepartmentAndStatus(user.getDepartment(), true);
    inactiveEmployees = userDAO.getEmployeesByDepartmentAndStatus(user.getDepartment(), false);
}
String source = request.getParameter("source");

Connection conn = DatabaseConnection.getConnection();
PreparedStatement stmt;
/* COLOR BASED ON ROLE */
String primaryColor = role.equals("ADMIN") ? "#f5576c" : "#667eea";
String gradientColor = role.equals("ADMIN") 
        ? "linear-gradient(135deg,#f093fb,#f5576c)"
        : "linear-gradient(135deg,#667eea,#764ba2)";

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Employees - WorkFlowX</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
<style>

body {
    margin: 0;
    padding: 0;
    font-family: 'Segoe UI', sans-serif;
    background: #f4f6f9;
    color: #333;
}

/* DARK MODE */
body.dark-mode {
    background: #1e1e2f;
}

.dark-mode table { color: white; }
.dark-mode h2 { color: white; }

.dark-mode th {
    background: #333;
    color: white;
}

.dark-mode td {
    border-bottom: 1px solid #444;
}

.dark-mode tbody tr:nth-child(odd) {
    background: #2b2b3d;
    color:white;
}

.dark-mode tbody tr:nth-child(even) {
    background: #242434;
    color:white;
}

.dark-mode .container {
    background: #252538;
}

/* NAVBAR */
.navbar {
    background: <%= gradientColor %>;
    padding: 15px 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: white;
}

.dark-mode .navbar {
    background: linear-gradient(135deg,#232526,#414345);
}

.navbar .dashboard-btn{
    color: white;
    text-decoration: none;
    padding: 8px 15px;
    background: rgba(255,255,255,0.2);
    border-radius: 5px;
}


/* CONTAINER */
.container {
    width: 80%;
    margin: 40px auto;
    padding: 30px;
    border-radius: 12px;
    background: white;
    box-shadow: 0 8px 20px rgba(0,0,0,0.08);
}

/* TABS */
.tabs {
    display:flex;
    gap:10px;
    margin-bottom:20px;
}

.tab {
    padding:10px 20px;
    background:white;
    border-radius:20px;
    font-weight:600;
    cursor:pointer;
}

.tab.active {
    background:<%= primaryColor %>;
    color:white;
}

.dark-mode .tab {
    background:#333;
    color:white;
}

/* TABLE */
table {
    width:100%;
    border-collapse:collapse;
}

th {
    background:<%= primaryColor %>;
    color:white;
    padding:14px;
}

td {
    padding:14px;
}

tr:nth-child(even) {
    background:#f2f2f2;
}

.dark-mode tr:nth-child(even) {
    background:#2b2b3d;
}

/* BUTTONS */
.activate-btn {
    background:#27ae60;
    color:white;
    border:none;
    padding:6px 14px;
    border-radius:20px;
    cursor:pointer;
}

.deactivate-btn {
    background:#c0392b;
    color:white;
    border:none;
    padding:6px 14px;
    border-radius:20px;
    cursor:pointer;
}

</style>
</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="navbar">
    <h2>WorkFlowX - <%= role %></h2>

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

       <% if ("globalReports".equals(source)) { %>
    <a href="globalReports.jsp" class="dashboard-btn">
        ← Back
    </a>
<% } %>

    <!-- Dashboard Button -->
    <% if (user.isAdmin()) { %>
    <% if ("globalReports".equals(source)) { %>
        <!-- Admin coming from Global Reports -->
        <a href="globalReports.jsp" class="dashboard-btn">Dashboard</a>
    <% } else { %>
        <!-- Admin coming from anywhere else -->
        <a href="adminDashboard.jsp" class="dashboard-btn">← Back to Dashboard</a>
    <% } %>
<% } else { %>
    <!-- Employer -->
    <a href="employerDashboard.jsp" class="dashboard-btn">← Back to Dashboard</a>
<% } %>
    </div>
    </div>


<div class="container">

<h2>All Employees</h2>

<div class="tabs">
    <div class="tab active" onclick="switchTab(event,'active')">
        Active (<%= activeEmployees.size() %>)
    </div>
    <div class="tab" onclick="switchTab(event,'inactive')">
        Inactive (<%= inactiveEmployees.size() %>)
    </div>
</div>

<!-- ACTIVE -->
<div id="active" class="tab-content active">
<table>
<tr>
<th>Name</th>
<th>Email</th>
<th>Role</th>
<th>Department</th>
<th>Action</th>
</tr>

<% for(User emp : activeEmployees){ 
       if("EMPLOYEE".equals(emp.getRole())) { %>
<tr>
<td><%= emp.getFullName() %></td>
<td><%= emp.getEmail() %></td>
<td><%= emp.getRole() %></td>
<td><%= emp.getDepartment() %></td>
<td>
<form action="ToggleUserStatusServlet" method="post">
    <input type="hidden" name="userId" value="<%= emp.getUserId() %>">
    <input type="hidden" name="currentStatus" value="true">
    <input type="hidden" name="returnPage" value="employees.jsp">
    <button type="submit" class="deactivate-btn">Deactivate</button>
</form>
</td>
</tr>
<%  } } %>
</table>
</div>

<!-- INACTIVE -->
<div id="inactive" class="tab-content" style="display:none;">
<table>
<tr>
<th>Name</th>
<th>Email</th>
<th>Role</th>
<th>Department</th>
<th>Action</th>
</tr>

<% for(User emp : inactiveEmployees){ 
if("EMPLOYEE".equals(emp.getRole())) { %>
<tr>
<td><%= emp.getFullName() %></td>
<td><%= emp.getEmail() %></td>
<td><%= emp.getRole() %></td>
<td><%= emp.getDepartment() %></td>
<td>
<form action="ToggleUserStatusServlet" method="post">
    <input type="hidden" name="userId" value="<%= emp.getUserId() %>">
    <input type="hidden" name="currentStatus" value="false">
    <input type="hidden" name="returnPage" value="employees.jsp">
    <button type="submit" class="activate-btn">Activate</button>
</form>
</td>
</tr>
<%  } } %>
</table>
</div>

</div>

<script>
function switchTab(event, tabName) {
    document.querySelectorAll('.tab-content').forEach(content => {
        content.style.display = 'none';
    });

    document.querySelectorAll('.tab').forEach(tab => {
        tab.classList.remove('active');
    });

    document.getElementById(tabName).style.display = 'block';
    event.target.classList.add('active');
}
</script>

</body>
</html>
