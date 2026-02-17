<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%@ page import="com.workflowx.dao.ReportDAO" %>
<%@ page import="java.util.*" %>

<%
User user = (User) session.getAttribute("user");
if (user == null || !user.isAdmin()) {
    response.sendRedirect("login.jsp");
    return;
}
String role = user.getRole();
String primaryColor = role.equals("ADMIN") ? "#f5576c" : "#667eea";
/* ===== Theme Handling ===== */
String theme = "LIGHT";
if (user.getThemePreference() != null) {
    theme = user.getThemePreference();
}

ReportDAO dao = new ReportDAO();
Map<String,Integer> stats = dao.getOverallStats();
Map<String,Integer> departments = dao.getDepartmentStats();
List<Map<String,Object>> topViolators = dao.getTopViolators();
String navProfilePic = null;
    if (user != null) {
        String pic = user.getProfilePicture();
        if (pic != null && !pic.isEmpty() && !pic.equals("default.jpg")) {
            navProfilePic = pic;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Global Reports - Admin</title>

<style>
body {
    margin:0;
    font-family:Segoe UI;
    background:#f5f5f5;
    color:#333;
}

.dark-mode {
    background:#0f172a;
    color:white;
}

.header {
    padding:20px 30px;
    background:linear-gradient(135deg,#f093fb,#f5576c);
    display:flex;
    justify-content:space-between;
    align-items:center;
    color:white;
}

.dark-mode .header {
    background:#111827;
}
.header .dashboard-btn { color:white; text-decoration:none; padding:8px 15px; background:rgba(255,255,255,0.2); border-radius:5px; margin-left:10px; }
.dark-mode .header .dashboard-btn {
    color:white;
    background:rgba(255,255,255,0.1);
}
.container {
    padding:30px;
}

.grid {
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(250px,1fr));
    gap:20px;
}

.card {
    background:white;
    padding:25px;
    border-radius:12px;
    cursor:pointer;
    transition:0.3s;
    text-decoration:none;
    color:#333;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

.dark-mode .card {
    background:#1e293b;
    color:white;
}

.card:hover {
    transform:translateY(-5px);
}

.section {
    margin-top:50px;
}

table {
    width:100%;
    border-collapse:collapse;
    margin-top:15px;
}

th,td {
    padding:12px;
    border-bottom:1px solid #ddd;
    text-align:left;
}

.dark-mode th,
.dark-mode td {
    border-bottom:1px solid #334155;
}

th {
    background:#eee;
}

.dark-mode th {
    background:#1e293b;
}

.bad { color:#ff6b6b; }

/* ===== MINI TOGGLE ===== */
.mini-toggle {
    width:60px;
    height:28px;
    background:#ddd;
    border-radius:20px;
    padding:3px;
    cursor:pointer;
}

.mini-slider {
    width:100%;
    height:100%;
    border-radius:20px;
    position:relative;
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 6px;
    font-size:12px;
}

.mini-slider::before {
    content:"";
    position:absolute;
    width:22px;
    height:22px;
    background:<%= primaryColor %>;
    border-radius:50%;
    left:3px;
    transition:all 0.3s ease;
}

.mini-slider.active::before {
    left:35px;
    background:#2b2b3d;
}

.mini-slider span { z-index:1; }

.dark-mode .mini-toggle {
    background:#444;
}
.profile-pic-btn {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: rgba(255,255,255,0.15);
    border: 1px solid white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    text-decoration: none;
    transition: all 0.3s;
    overflow: hidden;
    padding: 0;
    margin: 0;
}

.profile-pic-btn:hover {
    background: rgba(255,255,255,0.3);
    transform: scale(1.2);
}

.profile-pic-btn img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 50%;
}

.profile-icon-svg {
    width: 12px;
    height: 12px;
    fill: white;
}

</style>
</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="header">
    <h2>🌍 Global Reports Dashboard</h2>

    <div style="display:flex; align-items:center; gap:15px;">

        <!-- Theme Toggle -->
        <form action="ThemeServlet" method="post">
            <div class="mini-toggle" onclick="this.closest('form').submit();">
                <div class="mini-slider <%= theme.equals("DARK") ? "active" : "" %>">
                    <span>☀</span>
                    <span>🌙</span>
                </div>
            </div>
            <input type="hidden" name="currentTheme" value="<%= theme %>">
            <input type="hidden" name="redirectPage" value="globalReports.jsp">
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

        <a href="adminDashboard.jsp" class="dashboard-btn" style="color:white;">← Back to Dashboard</a>
    </div>
</div>

<div class="container">

<div class="grid">

<a href="employees.jsp?source=reports" class="card">
    <h3>Total Employees</h3>
    <div class="number"><%= stats.get("totalEmployees") %></div>
</a>

<a href="manageEmployers.jsp?source=reports" class="card">
    <h3>Total Employers</h3>
    <div class="number"><%= stats.get("totalEmployers") %></div>
</a>

<a href="allMessages.jsp?source=reports" class="card">
    <h3>Total Messages</h3>
    <div class="number"><%= stats.get("totalMessages") %></div>
</a>

<a href="reportTasks.jsp?status=COMPLETED&source=reports" class="card">
    <h3>Completed Tasks</h3>
    <div class="number"><%= stats.get("completedTasks") %></div>
</a>

<a href="reportTasks.jsp?status=PENDING&source=reports" class="card">
    <h3>Pending Tasks</h3>
    <div class="number"><%= stats.get("pendingTasks") %></div>
</a>

</div>

<div class="section">
<h2>⚠️ Top Content Violators</h2>

<table>
<tr>
<th>Name</th>
<th>Department</th>
<th>Violations</th>
<th>Action</th>
</tr>

<% for(Map<String,Object> v : topViolators){ %>
<tr>
<td><%= v.get("fullName") %></td>
<td><%= v.get("department") %></td>
<td class="bad"><%= v.get("violationCount") %></td>
<td>
<a href="reportBadWords.jsp?userId=<%= v.get("userId") %>" style="color:#60a5fa;">
View Messages
</a>
</td>
</tr>
<% } %>

</table>
</div>

<div class="section">
<h2>🏢 Employees by Department</h2>

<table>
<tr>
<th>Department</th>
<th>Employees</th>
<th>View</th>
</tr>

<% for(String dept : departments.keySet()){ %>
<tr>
<td><%= dept %></td>
<td><%= departments.get(dept) %></td>
<td>
<a href="reportUsers.jsp?department=<%= dept %>" style="color:#60a5fa;">
View Users
</a>
</td>
</tr>
<% } %>

</table>
</div>

</div>

</body>
</html>
