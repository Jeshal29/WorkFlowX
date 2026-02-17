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

Connection conn = DatabaseConnection.getConnection();
PreparedStatement stmt;

if ("ACTIVE".equalsIgnoreCase(status)) {
    stmt = conn.prepareStatement(
        "SELECT user_id,full_name,email,department,is_active FROM users WHERE role='EMPLOYER' AND is_active=1"
    );
} else if ("INACTIVE".equalsIgnoreCase(status)) {
    stmt = conn.prepareStatement(
        "SELECT user_id,full_name,email,department,is_active FROM users WHERE role='EMPLOYER' AND is_active=0"
    );
} else {
    stmt = conn.prepareStatement(
        "SELECT user_id,full_name,email,department,is_active FROM users WHERE role='EMPLOYER'"
    );
}

ResultSet rs = stmt.executeQuery();
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
    display:flex;
    justify-content:space-between;
    align-items:center;
    background:linear-gradient(135deg,#f093fb,#f5576c);
    color:white;
}

.dark-mode .header {
    background:#111827;
}
.header .dashboard-btn { color:white; text-decoration:none; padding:8px 15px; background:rgba(255,255,255,0.2); border-radius:5px; margin-left:10px; }
.dark-mode .header a {
    color:white;
    background:rgba(255,255,255,0.1);
}
.container {
    padding:30px;
}
.container a { color:black; text-decoration:none; padding:8px 15px; background:rgba(210,230,220,0.4); border-radius:5px; margin-left:10px; }
.dark-mode .container a {
    color:white;
    background:rgba(255,255,255,0.1);
}
table {
    width:100%;
    border-collapse:collapse;
    margin-top:20px;
    background:white;
}

.dark-mode table {
    background:#1e293b;
}

th, td {
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

.active {
    color:#22c55e;
    font-weight:bold;
}

.inactive {
    color:#ef4444;
    font-weight:bold;
}

.btn {
    padding:6px 12px;
    border:none;
    border-radius:6px;
    cursor:pointer;
    font-size:13px;
}

.activate {
    background:#22c55e;
    color:white;
}

.deactivate {
    background:#ef4444;
    color:white;
}

.btn:hover {
    opacity:0.8;
}

/* MINI TOGGLE */
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

.header .dashboard-btn {
    color:white;
    text-decoration:none;
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


    /* ===== MOBILE RESPONSIVE ===== */
    @media (max-width: 768px) {

        /* Navbar */
        .navbar, .header {
            padding: 10px 15px;
            flex-wrap: wrap;
            gap: 8px;
        }
        .navbar h1, .navbar h2, .header h2 {
            font-size: 16px;
        }
        .navbar > div[style] {
            gap: 8px !important;
            flex-wrap: wrap;
        }
        .navbar .user-info > span {
            display: none;
        }
        .navbar .dashboard-btn, .header .dashboard-btn {
            padding: 6px 10px;
            font-size: 12px;
        }

        /* Container */
        .container {
            margin: 10px auto;
            padding: 0 10px;
            width: 95% !important;
        }

        /* Welcome / Page Header */
        .welcome, .page-header, .section-header {
            padding: 15px;
        }
        .welcome h2, .page-header h1, .page-header h2 {
            font-size: 18px;
        }

        /* Dashboard cards */
        .card { padding: 15px; }
        .card-icon { font-size: 36px; }
        .card h3 { font-size: 15px; }

        /* Tables - make scrollable on mobile */
        .table-container {
            overflow-x: auto;
            width: 100%;
        }
        table {
            min-width: 600px;
        }

        /* Forms */
        .form-group input,
        .form-group select,
        .form-group textarea,
        .remarks-input {
            font-size: 16px;
        }

        /* Buttons - stack vertically */
        .action-form {
            flex-direction: column;
        }
        .btn-group {
            flex-direction: column;
        }

        /* Grid layouts */
        .dashboard-grid,
        .cards-grid,
        .reports-grid,
        .stats-row,
        .stats-grid,
        .stats-container,
        .grid {
            grid-template-columns: 1fr !important;
        }

        /* Stats */
        .stats { padding: 15px; }

        /* Messages / Chat layout */
        .main-container {
            flex-direction: column;
            height: auto;
        }
        .left, .right {
            width: 100% !important;
        }
        .left {
            max-height: 250px;
            overflow-y: auto;
        }
        .right {
            min-height: 400px;
        }

        /* Task grid */
        .task-grid {
            grid-template-columns: 1fr !important;
        }
        .task-header {
            flex-direction: column;
            gap: 8px;
        }
        .task-meta {
            flex-direction: column;
            gap: 5px;
        }

        /* Leave details */
        .leave-details {
            grid-template-columns: 1fr 1fr !important;
        }
        .leave-header {
            flex-direction: column;
            gap: 10px;
        }

        /* Profile */
        .profile-body { padding: 20px; }
        .form-grid {
            grid-template-columns: 1fr !important;
        }
        .info-row {
            flex-direction: column;
            gap: 4px;
        }

        /* Performance cards */
        .performance-card {
            flex-direction: column;
            align-items: flex-start;
            gap: 15px;
        }
        .stats-row {
            flex-wrap: wrap;
        }

        /* Report cards */
        .report-card { padding: 20px; }
        .report-card .icon { font-size: 36px; }

        /* Tabs */
        .tabs, .filter-tabs {
            flex-wrap: wrap;
        }
        .tab, .filter-tabs a {
            font-size: 13px;
            padding: 8px 12px;
        }

        /* Notes */
        .add-note-btn {
            width: 50px;
            height: 50px;
            font-size: 28px;
        }

        /* Assign task form */
        .form-container {
            padding: 20px;
        }

        /* Violator rows */
        .violator-row {
            flex-direction: column;
            align-items: flex-start;
            gap: 8px;
        }

        /* Charts */
        .chart-bar {
            flex-direction: column;
            align-items: flex-start;
        }
        .chart-label { min-width: unset; }
        .chart-bar-wrapper { width: 100%; }

        /* Messages page send box */
        .send-box { flex-wrap: wrap; }
        .send-box input[type=text] { width: 100%; }
        .send-box input[type=file] { width: 100%; }
    }

    @media (max-width: 480px) {
        .navbar h1, .navbar h2, .header h2 {
            font-size: 14px;
        }
        .stat-card .number {
            font-size: 28px;
        }
        .leave-details {
            grid-template-columns: 1fr !important;
        }
    }

</style>
</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="header">

    <h2>🏢 Manage Employers</h2>

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

      <a href="javascript:history.back();" class="dashboard-btn">
    ← Back
</a>

    <!-- Dashboard Button -->
    <% if (user.isAdmin()) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } else { %>
        <a href="employerDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } %>
    </div>
</div>

<div class="container">

<div style="margin-bottom:20px;">
    <a href="manageEmployers.jsp<%= source!=null ? "?source="+source : "" %>">All</a> |
    <a href="manageEmployers.jsp?status=ACTIVE<%= source!=null ? "&source="+source : "" %>">Active</a> |
    <a href="manageEmployers.jsp?status=INACTIVE<%= source!=null ? "&source="+source : "" %>">Inactive</a>
</div>

<table>
<tr>
<th>Name</th>
<th>Email</th>
<th>Department</th>
<th>Status</th>
<th>Action</th>
</tr>

<% 
boolean hasData = false;
while(rs.next()){ 
    hasData = true;
    int userId = rs.getInt("user_id");
    boolean isActive = rs.getBoolean("is_active");
%>

<tr>
<td><%= rs.getString("full_name") %></td>
<td><%= rs.getString("email") %></td>
<td><%= rs.getString("department") %></td>

<td class="<%= isActive ? "active":"inactive" %>">
    <%= isActive ? "Active":"Inactive" %>
</td>

<td>
<form action="ToggleUserStatusServlet" method="post">
    <input type="hidden" name="userId" value="<%= userId %>">
    <input type="hidden" name="currentStatus" value="<%= isActive %>">
    <input type="hidden" name="status" value="<%= status %>">
    <input type="hidden" name="source" value="<%= source %>">

    <% if(isActive){ %>
        <button type="submit" class="btn deactivate">Deactivate</button>
    <% } else { %>
        <button type="submit" class="btn activate">Activate</button>
    <% } %>
</form>
</td>

</tr>

<% } 

if(!hasData){ %>
<tr>
<td colspan="5">No employers found.</td>
</tr>
<% } %>

</table>

</div>

<%
rs.close();
stmt.close();
conn.close();
%>

</body>
</html>
