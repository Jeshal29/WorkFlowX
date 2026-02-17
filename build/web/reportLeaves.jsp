<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.ReportDAO, java.util.*, java.text.SimpleDateFormat, java.sql.Date" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isEmployer()) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    ReportDAO dao = new ReportDAO();
    
    String statusFilter = request.getParameter("status");
    if (statusFilter == null || statusFilter.isEmpty()) {
        statusFilter = "PENDING";
    }
    
    List<Map<String, Object>> leaves = dao.getLeavesByStatus(statusFilter);
    Map<String, Integer> leaveStats = dao.getLeaveStatsByStatus();
    
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
    <title>Leave Reports - WorkFlowX</title>
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

/* ===== STATS ===== */
.stats-row { 
    display: grid; 
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
    gap: 15px; 
    margin-bottom: 30px; 
}

.stat-card { 
    background: white; 
    padding: 20px; 
    border-radius: 10px; 
    box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
    text-align: center; 
    border-left: 4px solid #667eea;
}

.stat-card .number { 
    font-size: 32px; 
    font-weight: 700; 
    margin-bottom: 5px; 
    color: #667eea;
}

.stat-card .label { 
    font-size: 13px; 
    color: #666; 
}

/* ===== FILTER TABS ===== */
.filter-tabs { 
    display: flex; 
    gap: 10px; 
    margin-bottom: 20px; 
    background: white; 
    padding: 15px; 
    border-radius: 10px; 
    box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
}

.filter-tabs a { 
    padding: 10px 20px; 
    border-radius: 8px; 
    text-decoration: none; 
    color: #666; 
    font-weight: 600; 
    transition: all 0.3s; 
}

.filter-tabs a.active { 
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
    color: white; 
}

.filter-tabs a:hover:not(.active) { 
    background: #f3f0ff; 
}

/* ===== LEAVE CARD ===== */
.leave-card { 
    background: white; 
    padding: 20px; 
    border-radius: 10px; 
    margin-bottom: 15px; 
    box-shadow: 0 2px 5px rgba(0,0,0,0.1); 
    border-left: 4px solid #667eea; 
}

.leave-header { 
    display: flex; 
    justify-content: space-between; 
    align-items: start; 
    margin-bottom: 15px; 
}

.employee-name { 
    font-size: 18px; 
    font-weight: 600; 
    color: #333; 
    margin-bottom: 5px; 
}

.leave-meta { 
    display: flex; 
    gap: 15px; 
    font-size: 13px; 
    color: #666; 
}

/* ===== BADGES (UNCHANGED COLORS) ===== */
.badge { 
    padding: 5px 12px; 
    border-radius: 15px; 
    font-size: 12px; 
    font-weight: 600; 
}

.badge.sick { background: #ffebee; color: #d32f2f; }
.badge.casual { background: #e3f2fd; color: #1976d2; }
.badge.vacation { background: #f3e5f5; color: #7b1fa2; }
.badge.emergency { background: #fff3e0; color: #f57c00; }
.badge.other { background: #f5f5f5; color: #666; }
.badge.pending { background: #fff3e0; color: #f57c00; }
.badge.approved { background: #e8f5e9; color: #388e3c; }
.badge.rejected { background: #ffebee; color: #d32f2f; }

/* ===== REASON ===== */
.leave-reason { 
    background: #f9f9f9; 
    padding: 15px; 
    border-radius: 8px; 
    margin-top: 10px; 
    color: #666; 
    font-size: 14px; 
}

.no-data { 
    text-align: center; 
    padding: 40px; 
    color: #999; 
}

/* ===== TOGGLE ===== */
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
.dark-mode .stat-card,
.dark-mode .filter-tabs,
.dark-mode .leave-card {
    background: #1e1e2f;
    color: #e0e0e0;
    box-shadow: none;
}

.dark-mode .page-header h1,
.dark-mode .employee-name {
    color: #ffffff;
}

.dark-mode .stat-card .label,
.dark-mode .leave-meta,
.dark-mode .leave-reason,
.dark-mode .no-data {
    color: #bbbbbb;
}

.dark-mode .filter-tabs a {
    color: #bbbbbb;
}

.dark-mode .filter-tabs a.active {
    background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
    color: white;
}

.dark-mode .filter-tabs a:hover:not(.active) {
    background: #2b2b3d;
}

.dark-mode .leave-card {
    border-left: 4px solid #667eea;
}

.dark-mode .leave-reason {
    background: #2b2b3d;
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

    </style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">
    <div class="navbar">
        <h2>🏖️ Leave Reports</h2>
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
            <h1>Leave Applications</h1>
            <p>Manage and review employee leave requests</p>
        </div>
        
        <div class="stats-row">
            <div class="stat-card">
                <div class="number" style="color: #feca57;"><%= leaveStats.getOrDefault("PENDING", 0) %></div>
                <div class="label">Pending</div>
            </div>
            <div class="stat-card">
                <div class="number" style="color: #43e97b;"><%= leaveStats.getOrDefault("APPROVED", 0) %></div>
                <div class="label">Approved</div>
            </div>
            <div class="stat-card">
                <div class="number" style="color: #ff6b6b;"><%= leaveStats.getOrDefault("REJECTED", 0) %></div>
                <div class="label">Rejected</div>
            </div>
        </div>
        
        <div class="filter-tabs">
            <a href="reportLeaves.jsp?status=PENDING" class="<%= "PENDING".equals(statusFilter) ? "active" : "" %>">Pending</a>
            <a href="reportLeaves.jsp?status=APPROVED" class="<%= "APPROVED".equals(statusFilter) ? "active" : "" %>">Approved</a>
            <a href="reportLeaves.jsp?status=REJECTED" class="<%= "REJECTED".equals(statusFilter) ? "active" : "" %>">Rejected</a>
        </div>
        
        <% if (leaves.isEmpty()) { %>
            <div class="no-data">No <%= statusFilter.toLowerCase() %> leave applications found</div>
        <% } else { %>
            <% for (Map<String, Object> leave : leaves) { %>
                <div class="leave-card">
                    <div class="leave-header">
                        <div style="flex: 1;">
                            <div class="employee-name"><%= leave.get("employeeName") %></div>
                            <div class="leave-meta">
                                <span>Department: <strong><%= leave.get("department") %></strong></span>
                                <span>•</span>
                                <span><%= sdf.format((Date)leave.get("startDate")) %> to <%= sdf.format((Date)leave.get("endDate")) %></span>
                                <span>•</span>
                                <span><strong><%= leave.get("totalDays") %></strong> days</span>
                            </div>
                        </div>
                        <div style="display: flex; gap: 10px; align-items: center;">
                            <span class="badge <%= leave.get("leaveType").toString().toLowerCase() %>">
                                <%= leave.get("leaveType") %>
                            </span>
                            <span class="badge <%= leave.get("status").toString().toLowerCase() %>">
                                <%= leave.get("status") %>
                            </span>
                        </div>
                    </div>
                    
                    <% if (leave.get("reason") != null && !leave.get("reason").toString().isEmpty()) { %>
                        <div class="leave-reason">
                            <strong>Reason:</strong> <%= leave.get("reason") %>
                        </div>
                    <% } %>
                    
                    <% if (leave.get("managerName") != null) { %>
                        <div style="margin-top: 10px; font-size: 13px; color: #666;">
                            Reviewed by: <strong><%= leave.get("managerName") %></strong>
                        </div>
                    <% } %>
                </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>
