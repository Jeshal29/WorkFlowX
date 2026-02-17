<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.UserDAO, java.util.List" %>
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
    if (currentUser == null || !currentUser.isEmployer()) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    UserDAO userDAO = new UserDAO();
   List<User> employees = userDAO.getActiveEmployees();

%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assign Task - WorkFlowX</title>
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
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color:white;
}

.navbar .dashboard-btn { 
    color: white; 
               text-decoration: none;
               padding: 8px 15px; 
               background: rgba(255,255,255,0.2);
               border-radius: 5px; }

        .navbar h2 { font-size: 20px; }
      
        .container { max-width: 800px; margin: 30px auto; padding: 0 20px; }
        .form-container { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 5px; color: #555; font-weight: 500; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .btn { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; border: none; padding: 12px 30px; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 600; }
        .btn:hover { opacity: 0.9; }
        .success { background: #efe; color: #3c3; padding: 10px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #3c3; }
        .error { background: #fee; color: #c33; padding: 10px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #c33; }
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
        <h2>Assign New Task</h2>
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
        <div class="form-container">
            <h3 style="margin-bottom: 20px; color: #333;">Create Task Assignment</h3>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="error"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <form action="AssignTaskServlet" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label>Assign To: *</label>
                    <select name="employeeId" required>
                        <option value="">Select Employee...</option>
                        <% for (User emp : employees) { %>
                            <option value="<%= emp.getUserId() %>"><%= emp.getFullName() %> (<%= emp.getDepartment() %>)</option>
                        <% } %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Task Title: *</label>
                    <input type="text" name="taskTitle" required placeholder="Enter task title">
                </div>
                
                <div class="form-group">
                    <label>Description:</label>
                    <textarea name="taskDescription" placeholder="Enter task details..."></textarea>
                </div>
                <div class="form-group">
    <label>Attach File (Optional):</label>
    <input type="file" name="taskFile" 
           accept=".pdf,.doc,.docx,.txt,.jpg,.jpeg,.png,.zip" 
           style="padding: 8px; border: 2px dashed #ddd; background: #f9f9f9;">
    <small style="display: block; margin-top: 5px; color: #666;">
        Supported: PDF, Word, Images, ZIP (Max 10MB)
    </small>
</div>
                <div class="form-group">
                    <label>Priority: *</label>
                    <select name="priority" required>
                        <option value="LOW">Low</option>
                        <option value="MEDIUM" selected>Medium</option>
                        <option value="HIGH">High</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Deadline: *</label>
                    <input type="date" name="deadline" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                </div>
                
                <button type="submit" class="btn">Assign Task</button>
            </form>
        </div>
    </div>
</body>
</html>