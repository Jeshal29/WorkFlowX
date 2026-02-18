<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.ReportDAO, java.util.*, java.text.SimpleDateFormat" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || (!currentUser.isEmployer() && !currentUser.isAdmin())) {
    response.sendRedirect("login.jsp");
    return;
}

ReportDAO dao = new ReportDAO();
 List<Map<String, Object>> messageActivity;
    List<Map<String, Object>> topSenders;
    Map<String, Integer> msgStats;

    if (currentUser.isAdmin()) {
        messageActivity = dao.getMessageActivity();
        topSenders = dao.getTopMessageSenders();
        msgStats = dao.getMessageStats();
    } else {
        // Employer sees only their department employees' messages
        messageActivity = dao.getMessageActivityByDepartment(currentUser.getDepartment());
        topSenders = dao.getTopMessageSendersByDepartment(currentUser.getDepartment());
        msgStats = dao.getMessageStatsByDepartment(currentUser.getDepartment());
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
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
    <title>Message Analytics - WorkFlowX</title>
    <style>
        *{
    margin:0;
    padding:0;
    box-sizing:border-box;
}

body{
    font-family:'Segoe UI',sans-serif;
    background:#f5f5f5;
    color:#333;
    transition:0.3s;
}

/* ===== NAVBAR ===== */
.navbar{
    background:linear-gradient(135deg,#764ba2 0%,#667eea 100%);
    color:white;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.navbar .dashboard-btn{
    color:white;
    text-decoration:none;
    padding:8px 15px;
    background:rgba(255,255,255,0.2);
    border-radius:5px;
    margin-left:10px;
}

/* ===== LAYOUT ===== */
.container{
    max-width:1400px;
    margin:30px auto;
    padding:0 20px;
}

.page-header,
.section,
.stat-card{
    background:white;
    border-radius:10px;
    padding:30px;
    margin-bottom:30px;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

.page-header h1{
    margin-bottom:10px;
}

/* ===== STATS ===== */
.stats-grid{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
    gap:20px;
    margin-bottom:30px;
}

.stat-card{
    border-left:4px solid #667eea;
}

.stat-card .number{
    font-size:36px;
    font-weight:700;
    margin-top:5px;
}

.stat-card.total .number{color:#667eea;}
.stat-card.read .number{color:#43e97b;}
.stat-card.unread .number{color:#fa709a;}
.stat-card.filtered .number{color:#ff6b6b;}

/* ===== TOP SENDERS ===== */
.top-senders{
    display:grid;
    gap:15px;
}

.sender-row{
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:15px;
    border-radius:8px;
    background:#f9f9f9;
}

.sender-row:hover{
    background:#f3f0ff;
}

.sender-info{
    display:flex;
    align-items:center;
    gap:15px;
}

.rank{
    width:30px;
    height:30px;
    border-radius:50%;
    background:linear-gradient(135deg,#764ba2 0%,#667eea 100%);
    color:white;
    display:flex;
    align-items:center;
    justify-content:center;
    font-weight:700;
}

.sender-name{
    font-weight:600;
    color:#333;
}

.sender-dept{
    font-size:13px;
    color:#666;
}

.message-count{
    background:#eef2ff;
    color:#667eea;
    padding:8px 16px;
    border-radius:20px;
    font-weight:600;
    font-size:14px;
}

/* ===== CHART ===== */
.chart-container{
    margin-top:20px;
}

.chart-bar{
    display:flex;
    align-items:center;
    margin-bottom:12px;
}

.chart-label{
    min-width:110px;
    font-size:14px;
    color:#666;
}

.chart-bar-wrapper{
    flex:1;
    background:#f0f0f0;
    border-radius:5px;
    height:28px;
    overflow:hidden;
}

.chart-bar-fill{
    height:100%;
    background:linear-gradient(90deg,#764ba2 0%,#667eea 100%);
    display:flex;
    align-items:center;
    padding-left:10px;
    color:white;
    font-weight:600;
    font-size:12px;
    transition:width 0.3s ease;
}

/* ===== TOGGLE ===== */
.mini-toggle{
    width:60px;
    height:28px;
    background:#ddd;
    border-radius:20px;
    padding:3px;
    cursor:pointer;
}

.mini-slider{
    width:100%;
    height:100%;
    position:relative;
}

.mini-slider::before{
    content:"";
    position:absolute;
    width:22px;
    height:22px;
    background:#667eea;
    border-radius:50%;
    left:3px;
    transition:0.3s;
}

.mini-slider.active::before{
    left:35px;
    background:#1e1e2f;
}

/* ===== DARK MODE ===== */
body.dark-mode{
    background:#1e1e2f;
    color:#f1f1f1;
}

.dark-mode .navbar{
    background:#1e1e2f;
}

.dark-mode .page-header,
.dark-mode .section,
.dark-mode .stat-card{
    background:#252538;
    color:#f1f1f1;
}

.dark-mode .sender-row{
    background:#2b2b3d;
}

.dark-mode .sender-row:hover{
    background:#353552;
}

.dark-mode .chart-bar-wrapper{
    background:#353552;
}

.dark-mode .mini-toggle{
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
        <h2>💬 Message Analytics</h2>
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
            <h1>Communication Analytics</h1>
            <p>Message statistics and usage patterns</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card blue">
                <h3>Total Messages</h3>
                <div class="number"><%= msgStats.getOrDefault("total", 0) %></div>
            </div>
            
            <div class="stat-card green">
                <h3>Read Messages</h3>
                <div class="number"><%= msgStats.getOrDefault("read", 0) %></div>
            </div>
            
            <div class="stat-card orange">
                <h3>Unread Messages</h3>
                <div class="number"><%= msgStats.getOrDefault("unread", 0) %></div>
            </div>
            
            <div class="stat-card red">
                <h3>Filtered</h3>
                <div class="number"><%= msgStats.getOrDefault("censored", 0) %></div>
            </div>
        </div>
        
        <!-- Top Message Senders -->
        <div class="section">
            <h2>Top 10 Message Senders</h2>
            
            <div class="top-senders">
                <% int rank = 1; %>
                <% for (Map<String, Object> sender : topSenders) { %>
                    <div class="sender-row">
                        <div class="sender-info">
                            <div class="rank"><%= rank++ %></div>
                            <div>
                                <a href="reportUserDetail.jsp?userId=<%= sender.get("userId") %>" style="text-decoration: none;">
                                    <div class="sender-name"><%= sender.get("fullName") %></div>
                                </a>
                                <div class="sender-dept"><%= sender.get("department") %></div>
                            </div>
                        </div>
                        <div class="message-count"><%= sender.get("messageCount") %> messages</div>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Daily Activity -->
        <div class="section">
            <h2>Message Activity (Last 30 Days)</h2>
            <div class="chart-container">
                <% 
                int maxCount = 0;
                for (Map<String, Object> day : messageActivity) {
                    int count = (Integer)day.get("count");
                    if (count > maxCount) maxCount = count;
                }
                %>
                
                <% for (Map<String, Object> day : messageActivity) { %>
                    <% 
                    int count = (Integer)day.get("count");
                    double percentage = maxCount > 0 ? (count * 100.0 / maxCount) : 0;
                    %>
                    <div class="chart-bar">
                        <div class="chart-label"><%= sdf.format((java.sql.Date)day.get("date")) %></div>
                        <div class="chart-bar-wrapper">
                            <div class="chart-bar-fill" style="width: <%= percentage %>%;">
                                <%= count %> messages
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
