<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.ReportDAO, java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isEmployer()) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    ReportDAO dao = new ReportDAO();
    List<Map<String, Object>> performance;

    if (currentUser.isAdmin()) {
        performance = dao.getEmployeePerformance();
    } else {
        // Employer sees only their department's employees
        performance = dao.getEmployeePerformanceByDepartment(currentUser.getDepartment());
    }
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
    <title>Employee Performance - WorkFlowX</title>
    <style>
       * { 
    margin: 0; 
    padding: 0; 
    box-sizing: border-box; 
}

body { 
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
    background: #f5f5f5; 
}

/* ===== NAVBAR ===== */
.navbar { 
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%); 
    color: white; 
    padding: 15px 30px; 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
}

.navbar h2 { 
    font-size: 24px; 
}

.navbar .dashboard-btn { 
    color: white; 
    text-decoration: none; 
    padding: 8px 15px; 
    background: rgba(255,255,255,0.2); 
    border-radius: 5px; 
    margin-left: 10px; 
}

/* ===== LAYOUT ===== */
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
    box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
}

.page-header h1 { 
    color: #333; 
    margin-bottom: 10px; 
}

/* ===== PERFORMANCE GRID ===== */
.performance-grid { 
    display: grid; 
    gap: 20px; 
}

.performance-card { 
    background: white; 
    padding: 25px; 
    border-radius: 10px; 
    box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
    display: flex; 
    align-items: center; 
    gap: 20px; 
    transition: all 0.3s; 
}

.performance-card:hover { 
    transform: translateY(-3px); 
    box-shadow: 0 5px 15px rgba(0,0,0,0.15); 
}

/* ===== RANK BADGES ===== */
.rank-badge { 
    width: 50px; 
    height: 50px; 
    border-radius: 50%; 
    display: flex; 
    align-items: center; 
    justify-content: center; 
    font-weight: 700; 
    font-size: 20px; 
    color: white; 
    flex-shrink: 0; 
}

.rank-1 { 
    background: linear-gradient(135deg, #ffd700 0%, #ffed4e 100%); 
    box-shadow: 0 4px 12px rgba(255, 215, 0, 0.4); 
}

.rank-2 { 
    background: linear-gradient(135deg, #c0c0c0 0%, #dcdcdc 100%); 
}

.rank-3 { 
    background: linear-gradient(135deg, #cd7f32 0%, #daa520 100%); 
}

.rank-other { 
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
}

/* ===== EMPLOYEE INFO ===== */
.employee-info { 
    flex: 1; 
}

.employee-name { 
    font-size: 18px; 
    font-weight: 600; 
    color: #333; 
    margin-bottom: 5px; 
}

.employee-name a { 
    color: #333; 
    text-decoration: none; 
}

.employee-name a:hover { 
    color: #667eea;
}

.employee-dept { 
    color: #666; 
    font-size: 14px; 
}

/* ===== STATS ===== */
.stats-row { 
    display: flex; 
    gap: 30px; 
    align-items: center; 
}

.stat-item { 
    text-align: center; 
}

.stat-value { 
    font-size: 24px; 
    font-weight: 700; 
    color: #333; 
}

.stat-label { 
    font-size: 12px; 
    color: #666; 
    text-transform: uppercase; 
    margin-top: 2px; 
}

/* ===== PROGRESS CIRCLE ===== */
.progress-circle { 
    position: relative; 
    width: 80px; 
    height: 80px; 
}

.progress-circle svg { 
    transform: rotate(-90deg); 
}

.progress-circle-bg { 
    fill: none; 
    stroke: #f0f0f0; 
    stroke-width: 8; 
}

.progress-circle-fill { 
    fill: none; 
    stroke: #667eea;
    stroke-width: 8; 
    stroke-linecap: round; 
    transition: stroke-dashoffset 0.5s; 
}

.progress-text { 
    position: absolute; 
    top: 50%; 
    left: 50%; 
    transform: translate(-50%, -50%); 
    font-size: 18px; 
    font-weight: 700; 
}

.trophy { 
    font-size: 24px; 
    margin-left: auto; 
}

.no-data { 
    text-align: center; 
    padding: 40px; 
    color: #999; 
}

/* ===== TOGGLE ===== */
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

/* ===== DARK MODE ===== */
.dark-mode {
    background: #121212;
    color: #e0e0e0;
}

.dark-mode .navbar {
    background: #1e1e2f;
}

.dark-mode .navbar a {
    background: rgba(255,255,255,0.1);
}

.dark-mode .page-header,
.dark-mode .performance-card {
    background: #1e1e2f;
    color: #e0e0e0;
    box-shadow: none;
}

.dark-mode .page-header h1 {
    color: #ffffff;
}

.dark-mode .employee-name,
.dark-mode .employee-name a,
.dark-mode .stat-value {
    color: #ffffff;
}

.dark-mode .employee-name a:hover {
    color: #8fa8ff;
}

.dark-mode .employee-dept,
.dark-mode .stat-label,
.dark-mode .no-data {
    color: #bbbbbb;
}

.dark-mode .performance-card:hover {
    box-shadow: 0 5px 15px rgba(0,0,0,0.6);
}

.dark-mode .progress-circle-bg {
    stroke: #333;
}

.dark-mode .mini-toggle {
    background: #444;
}

.dark-mode .mini-slider::before {
    background: #2b2b3d;
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
        <h2>🎯 Employee Performance</h2>
        
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


            <a href="reports.jsp" class="dashboard-btn"
>← Back</a>
            <a href="employerDashboard.jsp" class="dashboard-btn"
>Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h1>Performance Rankings</h1>
            <p>Employees ranked by task completion rate and total completed tasks</p>
        </div>
        
        <div class="performance-grid">
            <% if (performance.isEmpty()) { %>
                <div class="no-data">No performance data available</div>
            <% } else { %>
                <% 
                int rank = 1;
                for (Map<String, Object> emp : performance) {
                    String rankClass = rank == 1 ? "rank-1" : rank == 2 ? "rank-2" : rank == 3 ? "rank-3" : "rank-other";
                    int totalTasks = (Integer)emp.get("totalTasks");
                    int completedTasks = (Integer)emp.get("completedTasks");
                    double completionRate = (Double)emp.get("completionRate");
                    
                    // Calculate circle progress
                    double circumference = 2 * Math.PI * 36; // radius = 36
                    double offset = circumference - (completionRate / 100 * circumference);
                    
                    String strokeColor = completionRate >= 80 ? "#43e97b" : completionRate >= 60 ? "#feca57" : "#ff6b6b";
                %>
                    <div class="performance-card">
                        <div class="rank-badge <%= rankClass %>"><%= rank %></div>
                        
                        <div class="employee-info">
                            <div class="employee-name">
                                <a href="reportUserDetail.jsp?userId=<%= emp.get("userId") %>">
                                    <%= emp.get("fullName") %>
                                </a>
                            </div>
                            <div class="employee-dept"><%= emp.get("department") %></div>
                        </div>
                        
                        <div class="stats-row">
                            <div class="stat-item">
                                <div class="stat-value"><%= totalTasks %></div>
                                <div class="stat-label">Total Tasks</div>
                            </div>
                            
                            <div class="stat-item">
                                <div class="stat-value" style="color: #43e97b;"><%= completedTasks %></div>
                                <div class="stat-label">Completed</div>
                            </div>
                            
                            <div class="progress-circle">
                                <svg width="80" height="80">
                                    <circle class="progress-circle-bg" cx="40" cy="40" r="36"/>
                                    <circle class="progress-circle-fill" cx="40" cy="40" r="36" 
                                            stroke="<%= strokeColor %>"
                                            stroke-dasharray="<%= circumference %>"
                                            stroke-dashoffset="<%= offset %>"/>
                                </svg>
                                <div class="progress-text" style="color: <%= strokeColor %>;"><%= String.format("%.0f", completionRate) %>%</div>
                            </div>
                        </div>
                        
                        <% if (rank <= 3) { %>
                            <div class="trophy">
                                <%= rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉" %>
                            </div>
                        <% } %>
                    </div>
                <% 
                    rank++;
                } 
                %>
            <% } %>
        </div>
    </div>
</body>
</html>
