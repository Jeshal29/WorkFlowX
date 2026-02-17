<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%@ page import="com.workflowx.dao.ReportDAO"%>
<%@ page import="java.util.*" %>

<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (!currentUser.isEmployer() && !currentUser.isAdmin()) {
        response.sendRedirect("employeeDashboard.jsp");
        return;
    }

    ReportDAO dao = new ReportDAO();
    List<Map<String, Object>> censoredMessages = new ArrayList<>();

    if (currentUser.isAdmin()) {
        censoredMessages = dao.getCensoredMessages();
    } else if (currentUser.isEmployer()) {
        censoredMessages = dao.getCensoredMessagesByDepartment(currentUser.getDepartment());
    }
     User user = (User) session.getAttribute("user");
    String theme = "LIGHT";

    if (user != null && user.getThemePreference() != null) {
        theme = user.getThemePreference();
    }

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
    <title>Reports Dashboard - WorkFlowX</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }

        .navbar {
             background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h2 { font-size: 24px; }

        .navbar .dashboard-btn {
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            background: rgba(255,255,255,0.2);
            border-radius: 5px;
        }

        .container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .page-header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }

        .page-header h1 { color: #333; margin-bottom: 10px; }
        .page-header p { color: #666; }

        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .report-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            text-decoration: none;
            color: inherit;
            display: block;
            transition: 0.3s;
        }

        .report-card:hover {
            transform: translateY(-5px);
        }

        .report-card .icon {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .report-card h3 { color: #333; margin-bottom: 10px; font-size: 20px; }
        .report-card p { color: #666; font-size: 14px; }

        .report-card.users { border-left: 4px solid #667eea; }
        .report-card.badwords { border-left: 4px solid #ff6b6b; }
        .report-card.messages { border-left: 4px solid #4facfe; }
        .report-card.tasks { border-left: 4px solid #f093fb; }
        .report-card.leaves { border-left: 4px solid #43e97b; }
        .report-card.performance { border-left: 4px solid #fa709a; }
        .report-card.activity { border-left: 4px solid #feca57; }
        .report-card.overview { border-left: 4px solid #764ba2; }
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
.dark-mode .navbar{
    background:#1e1e2f;
    color:white;
}
.dark-mode .page-header {
      background:#1e1e2f;
     
}
.dark-mode .page-header h1 {
     color:white;
}
.dark-mode .page-header p {
     color:white;
}
.dark-mode .container{
      background:#1e1e2f;
      
}
.dark-mode {
            background: #1e1e2f;
            
        }
        .dark-mode .report-card {
            background: #1e1e2f;
            color:white;
}
.dark-mode .report-card p {
     color:white;
}
.dark-mode .report-card h3 {
     color:white;
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
    <h2>📊 Reports Dashboard</h2>
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

    <a href="employerDashboard.jsp" class="dashboard-btn">← Back to Dashboard</a>
</div>
</div>

<div class="container">
    <div class="page-header">
        <h1>Select a Report</h1>
        <p>Choose from the reports below to view detailed analytics</p>
    </div>

    <div class="reports-grid">
        <a href="reportOverview.jsp" class="report-card overview">
            <div class="icon">📈</div>
            <h3>System Overview</h3>
            <p>View overall statistics and metrics</p>
        </a>

        <a href="reportUsers.jsp" class="report-card users">
            <div class="icon">👥</div>
            <h3>User Reports</h3>
            <p>View all users, their details and activity</p>
        </a>

        <a href="reportBadWords.jsp" class="report-card badwords">
            <div class="icon">⚠️</div>
            <h3>Content Violations</h3>
            <p>Messages with filtered content and violators</p>
        </a>

        <a href="reportMessages.jsp" class="report-card messages">
            <div class="icon">💬</div>
            <h3>Message Analytics</h3>
            <p>Communication patterns and top senders</p>
        </a>

        <a href="reportTasks.jsp" class="report-card tasks">
            <div class="icon">✓</div>
            <h3>Task Reports</h3>
            <p>Task status, assignments and deadlines</p>
        </a>

        <a href="reportLeaves.jsp" class="report-card leaves">
            <div class="icon">🏖️</div>
            <h3>Leave Reports</h3>
            <p>Leave applications and approval status</p>
        </a>

        <a href="reportPerformance.jsp" class="report-card performance">
            <div class="icon">🎯</div>
            <h3>Employee Performance</h3>
            <p>Task completion rates and rankings</p>
        </a>

       
        </a>
    </div>
</div>

</body>
</html>
