<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.ReportDAO, java.util.*, java.text.SimpleDateFormat, java.sql.Timestamp" %>

<%
User currentUser = (User) session.getAttribute("user");

if (currentUser == null || 
   (!currentUser.isEmployer() && !currentUser.isAdmin())) {
    response.sendRedirect("login.jsp");
    return;
}
boolean isAdmin = currentUser.isAdmin();
ReportDAO dao = new ReportDAO();
 List<Map<String, Object>> users;

    if (currentUser.isAdmin()) {
        users = dao.getAllUsersReport();  // Admin sees everyone including employers
    } else {
        // Employer sees only employees in their own department
        users = dao.getUsersReportByDepartment(currentUser.getDepartment());
    }

if (users == null) {
    users = new ArrayList<>();
}

SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
User user = (User) session.getAttribute("user");
    String theme = "LIGHT";

    if (user != null && user.getThemePreference() != null) {
        theme = user.getThemePreference();
    }
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
<meta charset="UTF-8">
<title>User Reports - WorkFlowX</title>

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

/* ================= TOGGLE ================= */
.mini-toggle {
    width:60px;
    height:28px;
    background:#ddd;
    border-radius:20px;
    padding:3px;
    cursor:pointer;
    transition:background 0.3s ease;
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
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    border-radius:50%;
    left:3px;
    transition:all 0.3s ease;
}

.mini-slider.active::before {
    left:35px;
    background:#2b2b3d;
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

.dark-mode .mini-toggle {
    background:#444;
}

.dark-mode .no-data {
    color:#bbb;
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

<div class="navbar">
    <h2>👥 User Reports</h2>
    
    <div style="display:flex; align-items:center; gap:15px;">

        <form action="ThemeServlet" method="post" style="margin-right:15px;">
    
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

        <a href="javascript:history.back();" class="dashboard-btn">
    ← Back
</a>

    <!-- Dashboard Button -->
    <% if (currentUser.isAdmin()) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } else { %>
        <a href="employerDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } %>
    </div>
</div>


<div class="container">

<div class="page-header">
   <% if (!currentUser.isAdmin()) { %>
        <p style="color:#666; margin-top:5px;">Showing employees in: <strong><%= currentUser.getDepartment() %></strong></p>
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
<a href="reportUserDetail.jsp?userId=<%= u.get("userId") %>">
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
