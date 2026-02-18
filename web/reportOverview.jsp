<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.ReportDAO, java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || (!currentUser.isEmployer() && !currentUser.isAdmin())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    ReportDAO dao = new ReportDAO();
    
    Map<String, Integer> overallStats;
    Map<String, Integer> taskStats;
    Map<String, Integer> leaveStats;
    Map<String, Integer> deptStats;
    Map<String, Integer> messageStats;
    
    if (currentUser.isAdmin()) {
        overallStats = dao.getOverallStats();
        taskStats = dao.getTaskStatsByStatus();
        leaveStats = dao.getLeaveStatsByStatus();
        deptStats = dao.getDepartmentStats();
        messageStats = dao.getMessageStats();
    } else {
        // Employer sees their department's numbers only
        overallStats = dao.getOverallStatsByDepartment(currentUser.getDepartment(), currentUser.getUserId());
        taskStats = dao.getTaskStatsByStatusAndEmployer(currentUser.getUserId());
        leaveStats = dao.getLeaveStatsByStatusAndDepartment(currentUser.getDepartment());
        deptStats = dao.getDepartmentStats();
        messageStats = dao.getMessageStatsByDepartment(currentUser.getDepartment());
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
    <title>System Overview - WorkFlowX</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background:#f5f5f5;
    color:#333;
    transition: all 0.3s ease;
}

/* ================= NAVBAR ================= */
.navbar {
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
    color:white;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
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

.page-header,
.stat-card,
.section {
    background:white;
    padding:30px;
    border-radius:10px;
    margin-bottom:20px;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

.page-header h1,
.section h2 {
    color:#333;
}

.stats-grid {
    display:grid;
    grid-template-columns:repeat(auto-fit, minmax(250px,1fr));
    gap:20px;
    margin-bottom:30px;
}

.stat-card h3 {
    font-size:14px;
    color:#666;
    margin-bottom:10px;
    text-transform:uppercase;
}

.stat-card .number {
    font-size:36px;
    font-weight:700;
}

.stat-card .label {
    font-size:13px;
    color:#999;
}

/* ================= CARD COLORS (UNCHANGED) ================= */
.stat-card.blue { border-left:4px solid #667eea; }
.stat-card.blue .number { color:#667eea; }

.stat-card.green { border-left:4px solid #43e97b; }
.stat-card.green .number { color:#43e97b; }

.stat-card.orange { border-left:4px solid #fa709a; }
.stat-card.orange .number { color:#fa709a; }

.stat-card.purple { border-left:4px solid #f093fb; }
.stat-card.purple .number { color:#f093fb; }

.stat-card.red { border-left:4px solid #ff6b6b; }
.stat-card.red .number { color:#ff6b6b; }

.stat-card.teal { border-left:4px solid #4facfe; }
.stat-card.teal .number { color:#4facfe; }

/* ================= DATA ROW ================= */
.data-row {
    display:flex;
    justify-content:space-between;
    padding:15px 0;
    border-bottom:1px solid #f0f0f0;
}

.data-row:last-child { border-bottom:none; }

.data-row .label { color:#666; font-weight:500; }
.data-row .value { font-weight:700; font-size:18px; }

/* ================= PROGRESS ================= */
.progress-bar {
    background:#f0f0f0;
    border-radius:10px;
    height:30px;
    overflow:hidden;
    margin-bottom:15px;
}

.progress-fill {
    height:100%;
    display:flex;
    align-items:center;
    padding:0 15px;
    color:white;
    font-size:13px;
    font-weight:600;
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
    background:#667eea;
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
.dark-mode .stat-card,
.dark-mode .section {
    background:#252538;
    color:#f1f1f1;
}

.dark-mode h1,
.dark-mode h2,
.dark-mode h3,
.dark-mode h4 {
    color:#ffffff;
}

.dark-mode .data-row .label { color:#bbbbbb; }
.dark-mode .data-row .value { color:#ffffff; }

.dark-mode .progress-bar { background:#3a3a50; }

.dark-mode .mini-toggle { background:#444; }
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
        <h2>📈 System Overview</h2>
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

            <a href="reports.jsp" class="dashboard-btn"
>← Back</a>
            <a href="employerDashboard.jsp" class="dashboard-btn"
>Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h1>System Overview</h1>
            <p>Complete statistics and analytics for WorkFlowX</p>
        </div>
        
        <!-- Overall Statistics -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <h3>Total Users</h3>
                <div class="number"><%= overallStats.getOrDefault("totalUsers", 0) %></div>
                <div class="label">Active accounts</div>
            </div>
            
            <div class="stat-card green">
                <h3>Employees</h3>
                <div class="number"><%= overallStats.getOrDefault("totalEmployees", 0) %></div>
                <div class="label">Active employees</div>
            </div>
            
            <% if (currentUser.isAdmin()) { %>
    <div class="stat-card orange">
        <h3>Employers</h3>
        <div class="number"><%= overallStats.getOrDefault("totalEmployers", 0) %></div>
        <div class="label">Managers</div>
    </div>
<% } %>
            
            <div class="stat-card purple">
                <h3>Total Messages</h3>
                <div class="number"><%= overallStats.getOrDefault("totalMessages", 0) %></div>
                <div class="label">All communications</div>
            </div>
            
            <div class="stat-card teal">
                <h3>Total Tasks</h3>
                <div class="number"><%= overallStats.getOrDefault("totalTasks", 0) %></div>
                <div class="label">All assignments</div>
            </div>
            
            <div class="stat-card red">
                <h3>Total Leaves</h3>
                <div class="number"><%= overallStats.getOrDefault("totalLeaves", 0) %></div>
                <div class="label">Leave applications</div>
            </div>
        </div>
        
        <!-- Task Statistics -->
        <div class="section">
            <h2>Task Overview</h2>
            <div class="chart-container">
                <div>
                    <h4 style="color: #666; margin-bottom: 15px;">Task Status Distribution</h4>
                    <% 
                    int totalTasks = overallStats.getOrDefault("totalTasks", 1);
                    int pending = taskStats.getOrDefault("PENDING", 0);
                    int inProgress = taskStats.getOrDefault("IN_PROGRESS", 0);
                    int completed = taskStats.getOrDefault("COMPLETED", 0);
                    int overdue = taskStats.getOrDefault("OVERDUE", 0);
                    %>
                    
                    <div style="margin-bottom: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span style="color: #666;">Pending</span>
                            <span style="font-weight: 600;"><%= pending %></span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= (pending * 100.0 / totalTasks) %>%; background: linear-gradient(90deg, #feca57 0%, #ff9ff3 100%);"><%= String.format("%.1f", pending * 100.0 / totalTasks) %>%</div>
                        </div>
                    </div>
                    
                    <div style="margin-bottom: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span style="color: #666;">In Progress</span>
                            <span style="font-weight: 600;"><%= inProgress %></span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= (inProgress * 100.0 / totalTasks) %>%; background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);"><%= String.format("%.1f", inProgress * 100.0 / totalTasks) %>%</div>
                        </div>
                    </div>
                    
                    <div style="margin-bottom: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span style="color: #666;">Completed</span>
                            <span style="font-weight: 600;"><%= completed %></span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= (completed * 100.0 / totalTasks) %>%; background: linear-gradient(90deg, #43e97b 0%, #38f9d7 100%);"><%= String.format("%.1f", completed * 100.0 / totalTasks) %>%</div>
                        </div>
                    </div>
                    
                    <% if (overdue > 0) { %>
                    <div style="margin-bottom: 10px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span style="color: #666;">Overdue</span>
                            <span style="font-weight: 600;"><%= overdue %></span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%= (overdue * 100.0 / totalTasks) %>%; background: linear-gradient(90deg, #ff6b6b 0%, #ff5252 100%);"><%= String.format("%.1f", overdue * 100.0 / totalTasks) %>%</div>
                        </div>
                    </div>
                    <% } %>
                </div>
                
                <div>
                    <h4 style="color: #666; margin-bottom: 15px;">Task Summary</h4>
                    <div class="data-row">
                        <span class="label">Total Tasks</span>
                        <span class="value"><%= totalTasks %></span>
                    </div>
                    <div class="data-row">
                        <span class="label">Completion Rate</span>
                        <span class="value" style="color: #43e97b;"><%= String.format("%.1f", completed * 100.0 / totalTasks) %>%</span>
                    </div>
                    <div class="data-row">
                        <span class="label">Active Tasks</span>
                        <span class="value" style="color: #4facfe;"><%= (pending + inProgress) %></span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Leave Statistics -->
        <div class="section">
            <h2>Leave Management</h2>
            <div class="chart-container">
                <div>
                    <h4 style="color: #666; margin-bottom: 15px;">Leave Status</h4>
                    <% 
                    int totalLeaves = overallStats.getOrDefault("totalLeaves", 1);
                    int leavePending = leaveStats.getOrDefault("PENDING", 0);
                    int leaveApproved = leaveStats.getOrDefault("APPROVED", 0);
                    int leaveRejected = leaveStats.getOrDefault("REJECTED", 0);
                    %>
                    
                    <div class="data-row">
                        <span class="label">Pending</span>
                        <span class="value" style="color: #feca57;"><%= leavePending %></span>
                    </div>
                    <div class="data-row">
                        <span class="label">Approved</span>
                        <span class="value" style="color: #43e97b;"><%= leaveApproved %></span>
                    </div>
                    <div class="data-row">
                        <span class="label">Rejected</span>
                        <span class="value" style="color: #ff6b6b;"><%= leaveRejected %></span>
                    </div>
                    <div class="data-row">
                        <span class="label">Total</span>
                        <span class="value"><%= totalLeaves %></span>
                    </div>
                </div>
                
                <div>
                    <h4 style="color: #666; margin-bottom: 15px;">Leave Metrics</h4>
                    <div class="data-row">
                        <span class="label">Approval Rate</span>
                        <span class="value" style="color: #43e97b;"><%= String.format("%.1f", leaveApproved * 100.0 / totalLeaves) %>%</span>
                    </div>
                    <div class="data-row">
                        <span class="label">Rejection Rate</span>
                        <span class="value" style="color: #ff6b6b;"><%= String.format("%.1f", leaveRejected * 100.0 / totalLeaves) %>%</span>
                    </div>
                    <div class="data-row">
                        <span class="label">Pending Review</span>
                        <span class="value" style="color: #feca57;"><%= leavePending %></span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Department Distribution -->
        <div class="section">
            <h2>Department Distribution</h2>
            <% if (deptStats.isEmpty()) { %>
                <div style="text-align: center; padding: 20px; color: #999;">No department data available</div>
            <% } else { %>
                <div style="max-width: 600px;">
                    <% for (Map.Entry<String, Integer> entry : deptStats.entrySet()) { %>
                        <div style="margin-bottom: 15px;">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                                <span style="color: #666; font-weight: 500;"><%= entry.getKey() %></span>
                                <span style="font-weight: 600;"><%= entry.getValue() %> employees</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: <%= (entry.getValue() * 100.0 / overallStats.getOrDefault("totalEmployees", 1)) %>%; background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);"><%= String.format("%.1f", entry.getValue() * 100.0 / overallStats.getOrDefault("totalEmployees", 1)) %>%</div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
        
        <!-- Message Statistics -->
        <div class="section">
            <h2>Communication Analytics</h2>
            <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
                <div class="stat-card blue">
                    <h3>Total Messages</h3>
                    <div class="number"><%= messageStats.getOrDefault("total", 0) %></div>
                </div>
                <div class="stat-card green">
                    <h3>Read Messages</h3>
                    <div class="number"><%= messageStats.getOrDefault("read", 0) %></div>
                </div>
                <div class="stat-card orange">
                    <h3>Unread Messages</h3>
                    <div class="number"><%= messageStats.getOrDefault("unread", 0) %></div>
                </div>
                <div class="stat-card red">
                    <h3>Filtered Messages</h3>
                    <div class="number"><%= messageStats.getOrDefault("censored", 0) %></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
