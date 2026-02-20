<%@page import="java.util.List"%>
<%@page import="com.workflowx.dao.UserDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.workflowx.util.DatabaseConnection" %>

<%
User user = (User) session.getAttribute("user");
if (user == null || !user.isAdmin()) {
    response.sendRedirect("login.jsp");
    return;
}
String role = user.getRole();
String primaryColor = role.equals("ADMIN") ? "#f5576c" : "#667eea";
/* ===== THEME ===== */
String theme = "LIGHT";
if (user.getThemePreference() != null) {
    theme = user.getThemePreference();
}

String status = request.getParameter("status");
String source = request.getParameter("source");
UserDAO userDAO = new UserDAO();

List<User> activeEmployers = userDAO.getUsersByRoleAndStatus("EMPLOYER" ,true);
List<User> inactiveEmployers = userDAO.getUsersByRoleAndStatus("EMPLOYER" ,false);
List<User> adminUsers = userDAO.getUsersByRoleAndStatus("ADMIN", true);

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
<title>Manage Employers</title>

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
.header {
    background: linear-gradient(135deg,#f093fb,#f5576c);
    padding: 15px 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: white;
}

.dark-mode .header {
    background: linear-gradient(135deg,#232526,#414345);
}

.header .dashboard-btn{
    color: white;
    text-decoration: none;
    padding: 8px 15px;
    background: rgba(255,255,255,0.2);
    border-radius: 5px;
}

/* MINI TOGGLE */
/* MINI ICON TOGGLE */
        .mini-toggle {
            width: 60px;
            height: 28px;
            background: #ddd;
            border-radius: 20px;
            padding: 3px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .mini-slider {
            width: 100%;
            height: 100%;
            border-radius: 20px;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 6px;
            font-size: 12px;
        }

        .mini-slider::before {
            content: "";
            position: absolute;
            width: 22px;
            height: 22px;
            background: #667eea;
            border-radius: 50%;
            left: 3px;
            transition: all 0.3s ease;
        }

        .mini-slider.active::before {
            left: 35px;
            background: #2b2b3d;
        }

        .mini-slider span {
            z-index: 1;
            }
             /* Dark mode adjustments */
        .dark-mode .mini-toggle {
            background: #444;
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

    <h2>WorkFlowX - <%= role %></h2>

    <div style="display:flex; align-items:center; gap:15px;">

        <!-- THEME TOGGLE -->
        <form action="ThemeServlet" method="post">
            <div class="mini-toggle" onclick="this.closest('form').submit();">
                <div class="mini-slider <%= theme.equals("DARK") ? "active" : "" %>">
                    <span>☀</span>
                    <span>🌙</span>
                </div>
            </div>

            <input type="hidden" name="currentTheme" value="<%= theme %>">
            <input type="hidden" name="redirectPage" value="manageEmployers.jsp">
            <input type="hidden" name="status" value="<%= status %>">
            <input type="hidden" name="source" value="<%= source %>">
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

          <% if ("globalReports".equals(source)) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
         <% } else { %>
          <a href="adminDashboard.jsp" class="dashboard-btn">← Back to Dashboard</a>
          <% } %>
    </div>
</div>

<div class="container">

<h2>All Employers</h2>

<div class="tabs">
    <div class="tab active" onclick="switchTab(event,'active')">
        Active (<%= activeEmployers.size() %>)
    </div>
    <div class="tab" onclick="switchTab(event,'inactive')">
        Inactive (<%= inactiveEmployers.size() %>)
    </div>
    <div class="tab" onclick="switchTab(event,'admin')">
        Admin (<%= adminUsers.size() %>)
    </div>
</div>
<div id="active" class="tab-content active">
<table>
<tr>
<th>Name</th>
<th>Email</th>
<th>Role</th>
<th>Department</th>
<th>Action</th>
</tr>

<% for(User emp : activeEmployers){ %>
<tr>
<td><%= emp.getFullName() %></td>
<td><%= emp.getEmail() %></td>
<td><%= emp.getRole() %></td>
<td><%= emp.getDepartment() %></td>
<td>
<form action="ToggleUserStatusServlet" method="post">
<input type="hidden" name="userId" value="<%= emp.getUserId() %>">
<input type="hidden" name="currentStatus" value="true">
<button type="submit" class="deactivate-btn">Deactivate</button>
</form>
</td>
</tr>
<% } %>
</table>
</div>
<div id="inactive" class="tab-content" style="display:none;">
<table>
<tr>
<th>Name</th>
<th>Email</th>
<th>Role</th>
<th>Department</th>
<th>Action</th>
</tr>

<% for(User emp : inactiveEmployers){ %>
<tr>
<td><%= emp.getFullName() %></td>
<td><%= emp.getEmail() %></td>
<td><%= emp.getRole() %></td>
<td><%= emp.getDepartment() %></td>
<td>
<form action="ToggleUserStatusServlet" method="post">
<input type="hidden" name="userId" value="<%= emp.getUserId() %>">
<input type="hidden" name="currentStatus" value="false">
<button type="submit" class="activate-btn">Activate</button>
</form>
</td>
</tr>
<% } %>
</table>
</div>
<div id="admin" class="tab-content" style="display:none;">
<table>
<tr>
<th>Name</th>
<th>Email</th>
<th>Role</th>
<th>Department</th>
<th>Status</th>
</tr>

<% for(User admin : adminUsers){ %>
<tr>
<td><%= admin.getFullName() %></td>
<td><%= admin.getEmail() %></td>
<td><%= admin.getRole() %></td>
<td><%= admin.getDepartment() %></td>
<td>Protected</td>
</tr>
<% } %>
</table>
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
