<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.model.Task, com.workflowx.dao.TaskDAO, java.util.List, java.text.SimpleDateFormat" %>
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
    
    TaskDAO taskDAO = new TaskDAO();
    List<Task> tasks;
    
    if (currentUser.isEmployer()) {
        tasks = taskDAO.getTasksByEmployer(currentUser.getUserId());
    } else {
        tasks = taskDAO.getTasksForEmployee(currentUser.getUserId());
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tasks - WorkFlowX</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        
        /* DARK MODE */
        .dark-mode {
            background: #1e1e2f;
            color: #f1f1f1;
        }

        .dark-mode .navbar {
            background: linear-gradient(135deg, #232526 0%, #414345 100%);
        }
        
        .dark-mode .task-card {
            background: #2b2b3d;
            color: white;
        }
        
        .dark-mode .task-title {
            color: white;
        }
        
        .dark-mode .task-desc {
            color: #bbb;
        }
        
        .dark-mode .attachment-link {
            background: #1e1e2f;
            color: #8b9bff;
        }
        
        .dark-mode select {
            background: #1e1e2f;
            color: white;
            border-color: #444;
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
        }
        
        .navbar h2 { font-size: 20px; }
        
        .navbar .nav-right {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .navbar .dashboard-btn { 
            color: white; 
            text-decoration: none; 
            padding: 8px 15px; 
            background: rgba(255,255,255,0.2); 
            border-radius: 5px; 
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
        
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .success { background: #efe; color: #3c3; padding: 10px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #3c3; }
        .error { background: #fee; color: #c33; padding: 10px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #c33; }
        .task-grid { display: grid; gap: 20px; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); }
        .task-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); border-left: 4px solid #667eea; }
        .task-card.high { border-left-color: #f5576c; }
        .task-card.medium { border-left-color: #feca57; }
        .task-card.low { border-left-color: #43e97b; }
        .task-header { display: flex; justify-content: space-between; margin-bottom: 10px; gap: 10px; }
        .task-title { font-size: 18px; font-weight: 600; color: #333; flex: 1; }
        .task-status { padding: 5px 15px; border-radius: 20px; font-size: 12px; font-weight: 600; white-space: nowrap; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-in_progress { background: #d1ecf1; color: #0c5460; }
        .status-completed { background: #d4edda; color: #155724; }
        .status-overdue { background: #f8d7da; color: #721c24; }
        .task-desc { color: #666; margin: 10px 0; line-height: 1.5; }
        .task-meta { display: flex; gap: 20px; margin-top: 15px; font-size: 14px; color: #999; flex-wrap: wrap; }
        
        .attachment-link {
            margin-top: 10px;
            padding: 8px 12px;
            background: #f0f0f0;
            border-radius: 5px;
            display: inline-block;
            text-decoration: none;
            color: #667eea;
            font-size: 13px;
            transition: 0.3s;
        }
        
        .attachment-link:hover {
            background: #e0e0e0;
        }
        
        .btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 8px 20px; border-radius: 5px; cursor: pointer; font-size: 14px; text-decoration: none; display: inline-block; }
        select { padding: 5px 10px; border: 1px solid #ddd; border-radius: 5px; cursor: pointer; }
        .no-tasks { text-align: center; padding: 60px 20px; color: #999; }
    </style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

    <div class="navbar">
        <h2><%= currentUser.isEmployer() ? "Manage Tasks" : "My Tasks" %></h2>
        <div class="nav-right">
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
                <a href="profile.jsp" class="profile-pic-btn" title="My Profile">
                    <img src="uploads/profiles/<%= navProfilePic %>" alt="Profile">
                </a>
            <% } else { %>
                <a href="profile.jsp" class="profile-pic-btn" title="My Profile">
                    <svg class="profile-icon-svg" viewBox="0 0 24 24">
                        <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                    </svg>
                </a>
            <% } %>
            
            <a href="<%= currentUser.isEmployer() ? "employerDashboard.jsp" : "employeeDashboard.jsp" %>" class="dashboard-btn">← Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <% if (request.getAttribute("success") != null) { %>
            <div class="success"><%= request.getAttribute("success") %></div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <% if (tasks.isEmpty()) { %>
            <div class="no-tasks">
                <h3>No tasks <%= currentUser.isEmployer() ? "assigned" : "found" %> yet</h3>
                <% if (currentUser.isEmployer()) { %>
                    <p style="margin-top: 10px;"><a href="assignTask.jsp" class="btn">Assign New Task</a></p>
                <% } %>
            </div>
        <% } else { %>
            <div class="task-grid">
                <% for (Task task : tasks) { %>
                    <div class="task-card <%= task.getPriority().toLowerCase() %>">
                        <div class="task-header">
                            <div class="task-title"><%= task.getTaskTitle() %></div>
                            <span class="task-status status-<%= task.getStatus().toLowerCase() %>">
                                <%= task.getStatus().replace("_", " ") %>
                            </span>
                        </div>
                        
                        <% if (task.getTaskDescription() != null && !task.getTaskDescription().isEmpty()) { %>
                            <div class="task-desc"><%= task.getTaskDescription() %></div>
                        <% } %>
                        
                        <% if (task.getAttachmentPath() != null && !task.getAttachmentPath().isEmpty()) { %>
                            <a href="<%= task.getAttachmentPath() %>" target="_blank" class="attachment-link">
                                📎 View Attachment
                            </a>
                        <% } %>
                        
                        <div class="task-meta">
                            <span>📅 Deadline: <%= dateFormat.format(task.getDeadline()) %></span>
                            <span>⚡ Priority: <%= task.getPriority() %></span>
                            <% if (currentUser.isEmployer()) { %>
                                <span>👤 Assigned to: <%= task.getAssignedToName() %></span>
                            <% } else { %>
                                <span>👤 Assigned by: <%= task.getAssignedByName() %></span>
                            <% } %>
                        </div>
                        
                        <% if (currentUser.isEmployee() && !task.getStatus().equals("COMPLETED")) { %>
                            <form action="UpdateTaskServlet" method="post" style="margin-top: 15px;">
                                <input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
                                <select name="status" onchange="this.form.submit()">
                                    <option value="">Change Status...</option>
                                    <option value="IN_PROGRESS" <%= task.getStatus().equals("IN_PROGRESS") ? "selected" : "" %>>In Progress</option>
                                    <option value="COMPLETED">Completed</option>
                                </select>
                            </form>
                        <% } %>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
