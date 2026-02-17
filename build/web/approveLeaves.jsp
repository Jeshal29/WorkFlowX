<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.model.Leave, com.workflowx.dao.LeaveDAO, java.util.List, java.text.SimpleDateFormat" %>
<%
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


<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!currentUser.isEmployer()) {
        response.sendRedirect("employeeDashboard.jsp");
        return;
    }
    
    LeaveDAO leaveDAO = new LeaveDAO();
    List<Leave> pendingLeaves = leaveDAO.getAllPendingLeaves();
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Approve Leaves - WorkFlowX</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        body {
    font-family: 'Segoe UI', sans-serif;
    background: #f4f6f9;
    color: #333;
    transition: all 0.3s ease;
}

 /* DARK MODE FULL OVERRIDE */
       .dark-mode {
            background: #1e1e2f;
            color: #f1f1f1;
        }

        .dark-mode .navbar {
                background: linear-gradient(135deg, #232526 0%, #414345 100%);
        }

        .dark-mode .welcome,
        .dark-mode .card,
        .dark-mode .stats {
            background: #2b2b3d;
            color: #ffffff;
        }

        .dark-mode .card h3,
        .dark-mode .welcome h2,
        .dark-mode .stats h3 {
            color: #ffffff;
        }

        .dark-mode .card p,
        .dark-mode .welcome p,
        .dark-mode .stat-item span:first-child {
            color: #bbbbbb;
        }

        .dark-mode .stat-item {
            border-bottom: 1px solid #444;
        }

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

        /* Dark mode adjustments */
        .dark-mode .mini-toggle {
            background: #444;
        }

        .navbar { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            color: white; 
            padding: 15px 30px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .navbar h2 { font-size: 24px; }
        .navbar .dashboard-btn { 
            color: white; 
            text-decoration: none; 
            padding: 8px 20px; 
            background: rgba(255,255,255,0.2); 
            border-radius: 5px; 
            transition: background 0.3s;
        }
        .navbar a:hover { background: rgba(255,255,255,0.3); }
        
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .success { 
            background: #d4edda; 
            color: #155724; 
            padding: 15px; 
            border-radius: 5px; 
            margin-bottom: 20px; 
            border-left: 4px solid #28a745; 
        }
        
        .error { 
            background: #f8d7da; 
            color: #721c24; 
            padding: 15px; 
            border-radius: 5px; 
            margin-bottom: 20px; 
            border-left: 4px solid #dc3545; 
        }
        
        .leave-cards {
            display: grid;
            gap: 20px;
        }
        
        .leave-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .leave-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.12);
        }
        
        .leave-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .employee-info {
            flex: 1;
        }
        
        .employee-name {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .leave-type {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .leave-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .detail-item {
            display: flex;
            flex-direction: column;
        }
        
        .detail-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 5px;
        }
        
        .detail-value {
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }
        
        .reason-box {
            background: #fff8dc;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            border-left: 4px solid #ffc107;
        }
        
        .reason-box strong {
            display: block;
            margin-bottom: 8px;
            color: #856404;
        }
        
        .action-form {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #f0f0f0;
        }
        
        .remarks-input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-family: inherit;
        }
        
        .btn {
            padding: 10px 25px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 14px;
        }
        
        .btn-approve {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
        }
        
        .btn-approve:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(17, 153, 142, 0.3);
        }
        
        .btn-reject {
            background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%);
            color: white;
        }
        
        .btn-reject:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(238, 9, 121, 0.3);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .empty-state svg {
            width: 120px;
            height: 120px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .empty-state h3 {
            color: #666;
            font-size: 20px;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: #999;
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
        <h2>📋 Leave Approval Center</h2>
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
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-label">Pending Approvals</div>
                <div class="stat-number"><%= pendingLeaves.size() %></div>
            </div>
        </div>
            
        
        <% if (request.getAttribute("success") != null) { %>
            <div class="success">✓ <%= request.getAttribute("success") %></div>
        <% } %>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error">✗ <%= request.getAttribute("error") %></div>
        <% } %>
        
        <div class="leave-cards">
            <% if (pendingLeaves.isEmpty()) { %>
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/>
                    </svg>
                    <h3>No Pending Approvals</h3>
                    <p>All leave requests have been processed</p>
                </div>
            <% } else {
                for (Leave leave : pendingLeaves) {
            %>
                <div class="leave-card">
                    <div class="leave-header">
                        <div class="employee-info">
                            <div class="employee-name"><%= leave.getEmployeeName() %></div>
                            <span class="leave-type"><%= leave.getLeaveType().replace("_", " ") %></span>
                        </div>
                    </div>
                    
                    <div class="leave-details">
                        <div class="detail-item">
                            <span class="detail-label">Start Date</span>
                            <span class="detail-value"><%= dateFormat.format(leave.getStartDate()) %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">End Date</span>
                            <span class="detail-value"><%= dateFormat.format(leave.getEndDate()) %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Duration</span>
                            <span class="detail-value"><%= leave.getTotalDays() %> <%= leave.getTotalDays() == 1 ? "day" : "days" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Applied On</span>
                            <span class="detail-value"><%= dateFormat.format(leave.getAppliedAt()) %></span>
                        </div>
                    </div>
                    
                    <% if (leave.getReason() != null && !leave.getReason().trim().isEmpty()) { %>
                        <div class="reason-box">
                            <strong>📝 Reason:</strong>
                            <%= leave.getReason() %>
                        </div>
                    <% } %>
                    
                    <form action="ApproveLeaveServlet" method="post" class="action-form">
                        <input type="hidden" name="leaveId" value="<%= leave.getLeaveId() %>">
                        <input type="text" name="remarks" class="remarks-input" 
                               placeholder="Add remarks (optional)">
                        <button type="submit" name="action" value="approve" class="btn btn-approve">
                            ✓ Approve
                        </button>
                        <button type="submit" name="action" value="reject" class="btn btn-reject">
                            ✗ Reject
                        </button>
                    </form>
                </div>
            <% 
                }
            } 
            %>
        </div>
    </div>
</body>
</html>
