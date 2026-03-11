<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.workflowx.dao.ReportDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%
boolean isAdmin = user.isAdmin();
/* ===== Task Data ===== */
ReportDAO dao = new ReportDAO();
String selectedStatus = request.getParameter("status");
    if (selectedStatus == null) selectedStatus = "PENDING";
    List<Map<String, Object>> tasks;
    Map<String, Integer> taskStats;

    if (user.isAdmin()) {
        tasks = dao.getTasksByStatus(selectedStatus);
        taskStats = dao.getTaskStatsByStatus();
    } else {
        // Employer sees only tasks THEY assigned
        tasks = dao.getTasksByStatusAndEmployer(selectedStatus, user.getUserId());
        taskStats = dao.getTaskStatsByStatusAndEmployer(user.getUserId());
    }
SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
String source = request.getParameter("source");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Task Reports - WorkFlowX</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
<style>

* { margin:0; padding:0; box-sizing:border-box; }

body {
    font-family:'Segoe UI',sans-serif;
    background:#f5f5f5;
    color:#333;
}

/* ===== NAVBAR THEME BASED ON ROLE ===== */
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

.dark-mode .navbar {
    background:#0f172a;
}

.navbar .dashboard-btn {
    color:white;
    text-decoration:none;
    padding:8px 15px;
    background:rgba(255,255,255,0.2);
    border-radius:5px;
}

/* ===== CONTAINER ===== */
.container {
    max-width:1400px;
    margin:30px auto;
    padding:0 20px;
}

/* ===== CARDS ===== */
.page-header,
.stat-card,
.filter-tabs,
.task-card {
    background:white;
    border-radius:10px;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

.dark-mode {
    background:#0f172a;
    color:white;
}

.dark-mode .page-header,
.dark-mode .stat-card,
.dark-mode .filter-tabs,
.dark-mode .task-card {
    background:#1e293b;
    color:white;
}

.page-header {
    padding:30px;
    margin-bottom:30px;
}

.stats-row {
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(200px,1fr));
    gap:15px;
    margin-bottom:30px;
}

.stat-card {
    padding:20px;
    text-align:center;
}

.stat-card .number {
    font-size:30px;
    font-weight:700;
}

.stat-card .label {
    font-size:13px;
    color:#666;
}

.dark-mode .stat-card .label {
    color:#bbb;
}

/* ===== FILTER TABS ===== */
.filter-tabs {
    display:flex;
    gap:10px;
    padding:15px;
    margin-bottom:20px;
}

.filter-tabs a {
    padding:10px 20px;
    border-radius:8px;
    text-decoration:none;
    font-weight:600;
    color:#666;
}

.filter-tabs a.active {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    color:white;
}

.dark-mode .filter-tabs a {
    color:white;
}

/* ===== TASK CARD ===== */
.task-card {
    padding:20px;
    margin-bottom:15px;
    border-left:4px solid <%= isAdmin ? "#fa709a" : "#4facfe" %>;
}

.task-header {
    display:flex;
    justify-content:space-between;
    align-items:start;
    margin-bottom:15px;
}

.task-title {
    font-size:18px;
    font-weight:600;
}

.task-meta {
    font-size:13px;
    color:#666;
}

.dark-mode .task-meta {
    color:#bbb;
}

/* ===== BADGES ===== */
.badge {
    padding:5px 12px;
    border-radius:15px;
    font-size:12px;
    font-weight:600;
}

.badge.high { background:#ffebee; color:#d32f2f; }
.badge.medium { background:#fff3e0; color:#f57c00; }
.badge.low { background:#e8f5e9; color:#388e3c; }
.badge.pending { background:#fff3e0; color:#f57c00; }
.badge.in-progress { background:#e3f2fd; color:#1976d2; }
.badge.completed { background:#e8f5e9; color:#388e3c; }
.badge.overdue { background:#ffebee; color:#d32f2f; }

.no-data {
    text-align:center;
    padding:40px;
    color:#999;
}
</style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">
<!-- NAVBAR -->
<div class="navbar">
    <h2>Task Reports</h2>

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


      <%
String backHref = "reports.jsp"; // default

if ("globalReports".equals(request.getParameter("source"))) {
    backHref = "globalReports.jsp";
} else if ("reports".equals(request.getParameter("source"))) {
    backHref = "reports.jsp";
}
%>

<a href="<%= backHref %>" class="dashboard-btn">← Back</a>

    <!-- Dashboard Button -->
    <% if (user.isAdmin()) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } else { %>
        <a href="employerDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } %>

    </div>
</div>

<div class="container">

    <div class="page-header">
        <h1>Task Management</h1>
        <p>View and analyze tasks by status</p>
    </div>

    <div class="stats-row">
        <div class="stat-card">
            <div class="number" style="color:#feca57;">
                <%= taskStats.getOrDefault("PENDING",0) %>
            </div>
            <div class="label">Pending</div>
        </div>

        <div class="stat-card">
            <div class="number" style="color:#4facfe;">
                <%= taskStats.getOrDefault("IN_PROGRESS",0) %>
            </div>
            <div class="label">In Progress</div>
        </div>

        <div class="stat-card">
            <div class="number" style="color:#43e97b;">
                <%= taskStats.getOrDefault("COMPLETED",0) %>
            </div>
            <div class="label">Completed</div>
        </div>

        <div class="stat-card">
            <div class="number" style="color:#ff6b6b;">
                <%= taskStats.getOrDefault("OVERDUE",0) %>
            </div>
            <div class="label">Overdue</div>
        </div>
    </div>

    <div class="filter-tabs">
    <a href="reportTasks.jsp?status=PENDING<%= source!=null ? "&source="+source : "" %>"
       class="<%= "PENDING".equals(selectedStatus)?"active":"" %>">
       Pending
    </a>

    <a href="reportTasks.jsp?status=IN_PROGRESS<%= source!=null ? "&source="+source : "" %>"
       class="<%= "IN_PROGRESS".equals(selectedStatus)?"active":"" %>">
       In Progress
    </a>

    <a href="reportTasks.jsp?status=COMPLETED<%= source!=null ? "&source="+source : "" %>"
       class="<%= "COMPLETED".equals(selectedStatus)?"active":"" %>">
       Completed
    </a>

    <a href="reportTasks.jsp?status=OVERDUE<%= source!=null ? "&source="+source : "" %>"
       class="<%= "OVERDUE".equals(selectedStatus)?"active":"" %>">
       Overdue
    </a>
</div>


    <% if (tasks.isEmpty()) { %>
        <div class="no-data">
            No <%= selectedStatus.toLowerCase().replace("_"," ") %> tasks found
        </div>
    <% } else { 
        for (Map<String,Object> task : tasks) { %>

        <div class="task-card">
            <div class="task-header">
                <div>
                    <div class="task-title"><%= task.get("taskTitle") %></div>
                    <div class="task-meta">
                        Assigned by: <strong><%= task.get("assignedBy") %></strong> →
                        Assigned to: <strong><%= task.get("assignedTo") %></strong>
                    </div>
                </div>

                <div style="display:flex; gap:10px;">
                    <span class="badge <%= task.get("priority").toString().toLowerCase() %>">
                        <%= task.get("priority") %>
                    </span>
                    <span class="badge <%= task.get("status").toString().toLowerCase().replace("_","-") %>">
                        <%= task.get("status").toString().replace("_"," ") %>
                    </span>
                </div>
            </div>

            <div>
                <% if (task.get("deadline") != null) { %>
                    Deadline:
                    <strong><%= sdf.format((Date)task.get("deadline")) %></strong>
                <% } else { %>
                    No deadline set
                <% } %>
            </div>
        </div>

    <% } } %>

</div>

</body>
</html>
