<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="com.workflowx.dao.ReportDAO"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%
ReportDAO dao = new ReportDAO();
 List<Map<String, Object>> messageActivity;
    List<Map<String, Object>> topSenders;
    Map<String, Integer> msgStats;
    if (user.isAdmin()) {
        messageActivity = dao.getMessageActivity();
        topSenders = dao.getTopMessageSenders();
        msgStats = dao.getMessageStats();
    } else {
        // Employer sees only their department employees' messages
        messageActivity = dao.getMessageActivityByDepartment(user.getDepartment());
        topSenders = dao.getTopMessageSendersByDepartment(user.getDepartment());
        msgStats = dao.getMessageStatsByDepartment(user.getDepartment());
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Message Analytics - WorkFlowX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
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
