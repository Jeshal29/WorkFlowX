<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String theme = user.getThemePreference() != null ? user.getThemePreference() : "LIGHT";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - WorkFlowX</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            max-width: 500px;
            margin: 60px auto;
            padding: 0 20px;
        }
        
        .card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            padding: 40px;
            transition: 0.3s ease;
        }
        
        .dark-mode .card {
            background: #2b2b3d;
            color: #f1f1f1;
        }
        
        h1 {
            text-align: center;
            margin-bottom: 10px;
            color: #333;
        }
        
        .dark-mode h1 {
            color: #f1f1f1;
        }
        
        .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        
        .dark-mode .subtitle {
            color: #aaa;
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
        
        .form-group {
            margin-bottom: 25px;
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
        
        .password-input-wrapper {
            position: relative;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 40px 12px 15px;
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
        
        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            font-size: 20px;
            user-select: none;
        }
        
        .password-strength {
            height: 4px;
            background: #e0e0e0;
            border-radius: 2px;
            margin-top: 8px;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0;
            transition: all 0.3s;
        }
        
        .strength-weak {
            width: 33%;
            background: #ff4444;
        }
        
        .strength-medium {
            width: 66%;
            background: #ffaa00;
        }
        
        .strength-strong {
            width: 100%;
            background: #00cc44;
        }
        
        .password-requirements {
            margin-top: 10px;
            font-size: 13px;
            color: #666;
        }
        
        .dark-mode .password-requirements {
            color: #aaa;
        }
        
        .requirement {
            margin: 5px 0;
            padding-left: 20px;
            position: relative;
        }
        
        .requirement::before {
            content: '✗';
            position: absolute;
            left: 0;
            color: #ff4444;
        }
        
        .requirement.met::before {
            content: '✓';
            color: #00cc44;
        }
        
        .btn {
            width: 100%;
            padding: 14px;
            border-radius: 8px;
            border: none;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }
        
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .security-tips {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-top: 30px;
        }
        
        .dark-mode .security-tips {
            background: #1e1e2f;
        }
        
        .security-tips h3 {
            font-size: 16px;
            margin-bottom: 10px;
            color: #667eea;
        }
        
        .security-tips ul {
            margin-left: 20px;
            font-size: 13px;
            line-height: 1.8;
            color: #666;
        }
        
        .dark-mode .security-tips ul {
            color: #aaa;
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
        <h2>🔒 Change Password</h2>
        <a href="profile.jsp">← Back to Profile</a>
    </div>
    
    <div class="container">
        <div class="card">
            <h1>Change Your Password</h1>
            <p class="subtitle">Keep your account secure with a strong password</p>
            
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
            
            <form action="ChangePasswordServlet" method="post" onsubmit="return validateForm()">
                <div class="form-group">
                    <label>Current Password</label>
                    <div class="password-input-wrapper">
                        <input type="password" 
                               id="currentPassword" 
                               name="currentPassword" 
                               required
                               placeholder="Enter current password">
                        <span class="toggle-password" onclick="togglePassword('currentPassword')">👁️</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>New Password</label>
                    <div class="password-input-wrapper">
                        <input type="password" 
                               id="newPassword" 
                               name="newPassword" 
                               required
                               minlength="6"
                               placeholder="Enter new password"
                               oninput="checkPasswordStrength()">
                        <span class="toggle-password" onclick="togglePassword('newPassword')">👁️</span>
                    </div>
                    <div class="password-strength">
                        <div class="password-strength-bar" id="strengthBar"></div>
                    </div>
                    <div class="password-requirements">
                        <div class="requirement" id="req-length">At least 6 characters</div>
                        <div class="requirement" id="req-upper">At least one uppercase letter</div>
                        <div class="requirement" id="req-lower">At least one lowercase letter</div>
                        <div class="requirement" id="req-number">At least one number</div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Confirm New Password</label>
                    <div class="password-input-wrapper">
                        <input type="password" 
                               id="confirmPassword" 
                               name="confirmPassword" 
                               required
                               placeholder="Re-enter new password"
                               oninput="checkMatch()">
                        <span class="toggle-password" onclick="togglePassword('confirmPassword')">👁️</span>
                    </div>
                    <div id="matchMessage" style="margin-top: 8px; font-size: 13px;"></div>
                </div>
                
                <button type="submit" class="btn" id="submitBtn">🔐 Update Password</button>
            </form>
            
            <div class="security-tips">
                <h3>🛡️ Security Tips</h3>
                <ul>
                    <li>Use a unique password that you don't use elsewhere</li>
                    <li>Mix uppercase, lowercase, numbers, and symbols</li>
                    <li>Avoid personal information like names or birthdays</li>
                    <li>Change your password regularly</li>
                    <li>Never share your password with anyone</li>
                </ul>
            </div>
        </div>
    </div>
    
    <script>
    function togglePassword(fieldId) {
        const field = document.getElementById(fieldId);
        const type = field.type === 'password' ? 'text' : 'password';
        field.type = type;
    }
    
    function checkPasswordStrength() {
        const password = document.getElementById('newPassword').value;
        const strengthBar = document.getElementById('strengthBar');
        
        let strength = 0;
        
        // Check requirements
        const hasLength = password.length >= 6;
        const hasUpper = /[A-Z]/.test(password);
        const hasLower = /[a-z]/.test(password);
        const hasNumber = /[0-9]/.test(password);
        
        // Update requirement indicators
        document.getElementById('req-length').classList.toggle('met', hasLength);
        document.getElementById('req-upper').classList.toggle('met', hasUpper);
        document.getElementById('req-lower').classList.toggle('met', hasLower);
        document.getElementById('req-number').classList.toggle('met', hasNumber);
        
        // Calculate strength
        if (hasLength) strength++;
        if (hasUpper) strength++;
        if (hasLower) strength++;
        if (hasNumber) strength++;
        
        // Update strength bar
        strengthBar.className = 'password-strength-bar';
        if (strength <= 1) {
            strengthBar.classList.add('strength-weak');
        } else if (strength <= 3) {
            strengthBar.classList.add('strength-medium');
        } else {
            strengthBar.classList.add('strength-strong');
        }
        
        checkMatch();
    }
    
    function checkMatch() {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const matchMessage = document.getElementById('matchMessage');
        
        if (confirmPassword.length === 0) {
            matchMessage.textContent = '';
            return;
        }
        
        if (newPassword === confirmPassword) {
            matchMessage.textContent = '✓ Passwords match';
            matchMessage.style.color = '#00cc44';
        } else {
            matchMessage.textContent = '✗ Passwords do not match';
            matchMessage.style.color = '#ff4444';
        }
    }
    
    function validateForm() {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        
        if (newPassword !== confirmPassword) {
            alert('Passwords do not match!');
            return false;
        }
        
        if (newPassword.length < 6) {
            alert('Password must be at least 6 characters long!');
            return false;
        }
        
        return true;
    }
    </script>
</body>
</html>
