<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.workflowx.dao.ReportDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%
    if (!user.isEmployer() && !user.isAdmin()) {
        response.sendRedirect("employeeDashboard.jsp");
        return;
    }
    ReportDAO dao = new ReportDAO();
    List<Map<String, Object>> censoredMessages = new ArrayList<>();

    if (user.isAdmin()) {
        censoredMessages = dao.getCensoredMessages();
    } else if (user.isEmployer()) {
        censoredMessages = dao.getCensoredMessagesByDepartment(user.getDepartment());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reports Dashboard - WorkFlowX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
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
<% if (!user.isAdmin()) { %>
        <div style="background:#fff3cd; border:1px solid #ffc107; border-radius:8px;
                    padding:12px 20px; margin-bottom:20px; color:#856404;">
            📊 You are viewing reports for your department: <strong><%= user.getDepartment() %></strong>
        </div>
    <% } %>
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

        <a href="reportUsers.jsp?source=reports" class="report-card users">
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

       
        
    </div>
</div>

</body>
</html>
