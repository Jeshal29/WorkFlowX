<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String theme = user.getThemePreference() != null ? user.getThemePreference() : "LIGHT";
    
    // Get profile picture with proper fallback
    String profilePic = user.getProfilePicture();
    String profilePicPath = "";
    
    if (profilePic == null || profilePic.isEmpty() || profilePic.equals("default.jpg")) {
        // Use a data URL for default avatar (no external file needed)
        profilePicPath = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' r='50' fill='%23667eea'/%3E%3Ctext x='50' y='50' text-anchor='middle' dy='0.35em' font-family='Arial' font-size='40' fill='white'%3E" + user.getFullName().charAt(0) + "%3C/text%3E%3C/svg%3E";
    } else {
        profilePicPath = "uploads/profiles/" + profilePic;
    }
    
    // Determine navbar gradient based on role (match dashboard)
    String navbarGradient = "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"; // Employee blue
    String headerGradient = "linear-gradient(135deg, #667eea 0%, #764ba2 100%)"; // Employee blue
    if (user.isAdmin()) {
        navbarGradient = "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"; // Admin pink
        headerGradient = "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"; // Admin pink
    } else if (user.isEmployer()) {
        navbarGradient = "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"; // Employer pink
        headerGradient = "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"; // Employer pink
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - WorkFlowX</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            transition: all 0.3s ease;
        }
        
        .dark-mode {
            background: #1e1e2f;
            color: #f1f1f1;
        }
        
        .navbar {
            background: <%= navbarGradient %>;
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
        
        .navbar a {
            color: white;
            text-decoration: none;
            padding: 8px 20px;
            background: rgba(255,255,255,0.2);
            border-radius: 5px;
        }
        
        .container {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .profile-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: 0.3s ease;
        }
        
        .dark-mode .profile-card {
            background: #2b2b3d;
            color: #f1f1f1;
        }
        
        .profile-header {
            background: <%= headerGradient %>;
            padding: 40px;
            text-align: center;
            position: relative;
        }
        
        .profile-picture-container {
            position: relative;
            display: inline-block;
        }
        
        .profile-picture {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    border: 5px solid white;
    object-fit: cover;
    background: white;
    box-shadow: 0 5px 20px rgba(0,0,0,0.2);
}

        
        .upload-overlay {
            position: absolute;
            bottom: 10px;
            right: 10px;
            width: 40px;
            height: 40px;
            background: #667eea;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 3px 10px rgba(0,0,0,0.3);
            transition: 0.3s;
        }
        
        .upload-overlay:hover {
            background: #764ba2;
            transform: scale(1.1);
        }
        
        .upload-overlay input[type="file"] {
            display: none;
        }
        
        .user-name {
            color: white;
            font-size: 28px;
            font-weight: 700;
            margin-top: 20px;
        }
        
        .user-role {
            color: rgba(255,255,255,0.9);
            font-size: 16px;
            margin-top: 5px;
        }
        
        .profile-body {
            padding: 40px;
        }
        
        .message {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 500;
        }
        
        .success {
            background: #e6ffed;
            color: #2e7d32;
            border: 1px solid #2e7d32;
        }
        
        .error {
            background: #ffe6e6;
            color: #c62828;
            border: 1px solid #c62828;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        
        .dark-mode .form-group label {
            color: #f1f1f1;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border-radius: 8px;
            border: 2px solid #e0e0e0;
            font-size: 15px;
            transition: 0.3s;
        }
        
        .dark-mode .form-group input {
            background: #1e1e2f;
            border-color: #444;
            color: #f1f1f1;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .form-group input:disabled {
            background: #f5f5f5;
            cursor: not-allowed;
        }
        
        .dark-mode .form-group input:disabled {
            background: #1a1a2e;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn {
            flex: 1;
            padding: 14px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }
        
        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }
        
        .btn-secondary:hover {
            background: #667eea;
            color: white;
        }
        
        .info-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-top: 30px;
        }
        
        .dark-mode .info-section {
            background: #1e1e2f;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .dark-mode .info-row {
            border-bottom-color: #444;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            font-weight: 600;
            color: #666;
        }
        
        .dark-mode .info-label {
            color: #aaa;
        }
        
        .info-value {
            color: #333;
        }
        
        .dark-mode .info-value {
            color: #f1f1f1;
        }
        
        #imagePreview {
            display: none;
            margin-top: 15px;
            text-align: center;
        }
        
        #imagePreview img {
            max-width: 200px;
            border-radius: 8px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
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
    .remove-btn {
    width: 35px;
    height: 35px;
    border-radius: 50%;
    border: none;
    background: #ff4d4d;
    color: white;
    cursor: pointer;
    font-weight: bold;
    box-shadow: 0 3px 10px rgba(0,0,0,0.3);
    transition: 0.3s;
}

.remove-btn:hover {
    background: #cc0000;
    transform: scale(1.1);
}

</style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">
    <div class="navbar">
        <h2>👤 My Profile</h2>
        <% if (user.isAdmin()) { %>
            <a href="adminDashboard.jsp">← Back to Dashboard</a>
        <% } else if (user.isEmployer()) { %>
            <a href="employerDashboard.jsp">← Back to Dashboard</a>
        <% } else { %>
            <a href="employeeDashboard.jsp">← Back to Dashboard</a>
        <% } %>
    </div>
    
    <div class="container">
        <div class="profile-card">
            <!-- Profile Header with Picture -->
            <div class="profile-header">
                <div class="profile-picture-container">

    <%
    String finalPath;
    if (profilePic == null || profilePic.isEmpty() || profilePic.equals("default.jpg")) {
        finalPath = profilePicPath;
    } else {
        finalPath = request.getContextPath() + "/uploads/profiles/" + profilePic;
    }
    %>

    <img src="<%= finalPath %>" 
         alt="<%= user.getFullName() %>" 
         class="profile-picture"
         id="profileImg">

    <!-- Upload Form -->
    <form id="profilePicForm" action="UploadProfilePicServlet" 
          method="post" enctype="multipart/form-data">

        <label class="upload-overlay" title="Change Profile Picture">
            📷
            <input type="file" 
                   name="profilePicture" 
                   accept="image/*"
                   onchange="previewAndUpload(this)">
        </label>

    </form>

    <% if (profilePic != null && !profilePic.isEmpty() && !profilePic.equals("default.jpg")) { %>
        <form action="RemoveProfilePicServlet" method="post"
              style="position:absolute; top:10px; right:10px;">
            <button type="submit" class="remove-btn" title="Remove Picture">
                ✕
            </button>
        </form>
    <% } %>

</div>



            
            <!-- Profile Body -->
            <div class="profile-body">
                <% if (request.getAttribute("success") != null) { %>
                    <div class="message success">
                        <%= request.getAttribute("success") %>
                    </div>
                <% } %>
                
                <% if (request.getAttribute("error") != null) { %>
                    <div class="message error">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <div id="imagePreview">
                    <p>Preview:</p>
                    <img id="preview" src="" alt="Preview">
                </div>
                
                <form action="ProfileServlet" method="post">
                    <div class="form-grid">
                        <div class="form-group">
                            <label>Username</label>
                            <input type="text" value="<%= user.getUsername() %>" disabled>
                        </div>
                        
                        <div class="form-group">
                            <label>Email Address</label>
                            <input type="email" name="email" value="<%= user.getEmail() %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" name="fullName" value="<%= user.getFullName() %>" required>
                        </div>
                        
                        <div class="form-group">
    <label>Department</label>
    <select name="department">
        <option value="">-- Select Department --</option>
        <% String[] depts = {"HR","IT","Finance","Sales","Marketing","Development","Support"};
           String userDept = user.getDepartment() != null ? user.getDepartment() : "";
           for (String d : depts) { %>
            <option value="<%= d %>" <%= d.equals(userDept) ? "selected" : "" %>><%= d %></option>
        <% } %>
    </select>
</div>
                    </div>
                    
                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">💾 Update Profile</button>
                        <button type="button" class="btn btn-secondary" onclick="location.href='changePassword.jsp'">🔒 Change Password</button>
                    </div>
                </form>
                
                <!-- Account Information -->
                <div class="info-section">
                    <h3 style="margin-bottom: 15px;">Account Information</h3>
                    <div class="info-row">
                        <span class="info-label">User ID:</span>
                        <span class="info-value">#<%= user.getUserId() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Account Status:</span>
                        <span class="info-value"><%= user.isActive() ? "✅ Active" : "❌ Inactive" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Member Since:</span>
                        <span class="info-value"><%= user.getCreatedAt() != null ? user.getCreatedAt().toString().substring(0, 10) : "N/A" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Last Login:</span>
                        <span class="info-value"><%= user.getLastLogin() != null ? user.getLastLogin() : "Never" %></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
    function previewAndUpload(input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            
            // Validate file type
            if (!file.type.startsWith('image/')) {
                alert('Please select an image file');
                return;
            }
            
            // Validate file size (max 5MB)
            if (file.size > 5 * 1024 * 1024) {
                alert('File size must be less than 5MB');
                return;
            }
            
            // Show preview
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('preview').src = e.target.result;
                document.getElementById('imagePreview').style.display = 'block';
            };
            reader.readAsDataURL(file);
            
            // Auto-submit form
            if (confirm('Upload this profile picture?')) {
                document.getElementById('profilePicForm').submit();
            }
        }
    }
    </script>
</body>
</html>
