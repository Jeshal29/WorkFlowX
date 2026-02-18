<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.sql.Timestamp" %>
<%@ page import="com.workflowx.model.User" %>
<%@ page import="com.workflowx.dao.ReportDAO" %>

<%
User currentUser = (User) session.getAttribute("user");

if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String role = currentUser.getRole();

if (!role.equals("ADMIN") && !role.equals("EMPLOYER")) {
    response.sendRedirect("employeeDashboard.jsp");
    return;
}

String userIdParam = request.getParameter("userId");
if (userIdParam == null) {
    response.sendRedirect("reportBadWords.jsp");
    return;
}

boolean isAdmin = currentUser.isAdmin();
ReportDAO dao = new ReportDAO();

int userId;
    try {
        userId = Integer.parseInt(request.getParameter("userId"));
    } catch (Exception e) {
        response.sendRedirect("reports.jsp");
        return;
    }

    // SECURITY: Employer can only view employees from their own department
    if (!currentUser.isAdmin()) {
        boolean allowed = dao.isUserInDepartment(userId, currentUser.getDepartment());
        if (!allowed) {
            response.sendRedirect("reports.jsp");
            return;
        }
    }

    Map<String, Object> userDetails = dao.getUserDetails(userId);

    if (userDetails.isEmpty()) {
        response.sendRedirect("reports.jsp");
        return;
    }

List<Map<String, Object>> allCensored = dao.getCensoredMessages();

List<Map<String, Object>> userViolations = new ArrayList<>();

for (Map<String, Object> msg : allCensored) {
    if ((int)msg.get("senderId") == userId) {
        userViolations.add(msg);
    }
}

SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

String theme = currentUser.getThemePreference() != null 
        ? currentUser.getThemePreference() 
        : "LIGHT";

boolean isDark = theme.equals("DARK");
String navProfilePic = null;
    if (currentUser != null) {
        String pic = currentUser.getProfilePicture();
        if (pic != null && !pic.isEmpty() && !pic.equals("default.jpg")) {
            navProfilePic = pic;
        }
    }

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Violation Details</title>

<style>
body {
    margin:0;
    font-family:'Segoe UI',sans-serif;
    background:#f4f6f9;
    transition:0.3s;
}

body.dark-mode {
    background:#1e1e2f;
    color:white;
}

/* NAVBAR */
.navbar {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    color:white;
}

body.dark-mode .navbar {
    background: linear-gradient(135deg,#232526,#414345);
}

.navbar-left {
    display:flex;
    align-items:center;
    gap:15px;
}

.navbar-right {
    display:flex;
    align-items:center;
    gap:10px;
}

.navbar .dashboard-btn {
    color:white;
    text-decoration:none;
    background:rgba(255,255,255,0.2);
    padding:8px 15px;
    border-radius:5px;
}

/* TOGGLE */
.toggle-btn {
    cursor:pointer;
    background:white;
    color:#f5576c;
    border:none;
    padding:8px 15px;
    border-radius:20px;
    font-weight:600;
}

body.dark-mode .toggle-btn {
    background:#333;
    color:white;
}

/* CONTAINER */
.container {
    width:80%;
    margin:40px auto;
}

/* CARD */
.card {
    background:white;
    padding:25px;
    border-radius:10px;
    margin-bottom:25px;
    box-shadow:0 4px 15px rgba(0,0,0,0.08);
}

body.dark-mode .card {
    background:#252538;
}

/* VIOLATION BOX */
.violation {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    border-left:4px solid #f5576c;
    padding:15px;
    margin-bottom:15px;
    border-radius:8px;
}

body.dark-mode .violation {
    background:#2b2b3d;
}

.label {
    font-weight:600;
    margin-top:8px;
}
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
            background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
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

<script>
function toggleTheme() {
    document.body.classList.toggle("dark-mode");
}
</script>

</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="navbar">
    <h2>👥 User Details</h2>
    
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

    <!-- USER INFO -->
    <div class="card">
        <h2><%= userDetails.get("fullName") %></h2>
        <p><strong>Email:</strong> <%= userDetails.get("email") %></p>
        <p><strong>Department:</strong> <%= userDetails.get("department") %></p>
        <p><strong>Total Violations:</strong> <%= userViolations.size() %></p>
        <p><strong>Total Messages Sent:</strong> <%= userDetails.get("messagesSent") %></p>
        <p><strong>Censored Messages:</strong> <%= userDetails.get("censoredMessages") %></p>
    </div>

    <!-- VIOLATION LIST -->
    <div class="card">
        <h2>Filtered Messages</h2>

        <% if (userViolations.isEmpty()) { %>
            <p>No violations found for this user.</p>
        <% } else { 
            for (Map<String, Object> msg : userViolations) { %>

            <div class="violation">
                <div><strong>To:</strong> <%= msg.get("receiverName") %></div>
                <div><strong>Date:</strong> <%= sdf.format((Timestamp)msg.get("sentAt")) %></div>

                <% if (msg.get("subject") != null && !msg.get("subject").toString().isEmpty()) { %>
                    <div><strong>Subject:</strong> <%= msg.get("subject") %></div>
                <% } %>

                <div class="label">Filtered Content:</div>
                <div><%= msg.get("messageContent") %></div>

                <div class="label">Original Content:</div>
                <div><%= msg.get("originalContent") %></div>
            </div>

        <% } } %>

    </div>

</div>

</body>
</html>
