<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String theme = "LIGHT";
    if (currentUser != null && currentUser.getThemePreference() != null) {
        theme = currentUser.getThemePreference();
    }
    
    String navProfilePic = null;
    if (currentUser != null) {
        String pic = currentUser.getProfilePicture();
        if (pic != null && !pic.isEmpty() && !pic.equals("default.jpg")) {
            navProfilePic = pic;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Employer Account - WorkFlowX</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
        }
        
        .dark-mode {
            background: #1e1e2f;
            color: #f1f1f1;
        }
        
        .navbar {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .dark-mode .navbar {
            background: linear-gradient(135deg, #232526 0%, #414345 100%);
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
        
        .container {
            max-width: 600px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .form-card {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .dark-mode .form-card {
            background: #2b2b3d;
        }
        
        .form-card h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }
        
        .dark-mode .form-card h1 {
            color: #ffffff;
        }
        
        .form-card p {
            color: #666;
            margin-bottom: 30px;
        }
        
        .dark-mode .form-card p {
            color: #bbbbbb;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }
        
        .dark-mode .form-group label {
            color: #ffffff;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
        }
        
        .dark-mode .form-group input,
        .dark-mode .form-group select {
            background: #1e1e2f;
            border-color: #444;
            color: #ffffff;
        }
        
        .required { color: #f5576c; }
        
        .password-wrapper {
            position: relative;
        }
        
        .password-wrapper { 
    position: relative; 
}
.password-wrapper input { 
    padding-right: 70px !important;  /* Changed from 40px to make room for indicator */
}

/* Password match/mismatch indicator */
.password-indicator {
    position: absolute;
    right: 40px;  /* Positioned between input and toggle button */
    top: 50%;
    transform: translateY(-50%);
    font-size: 20px;
    font-weight: bold;
    display: none;  /* Hidden by default */
}

/* Green tick when passwords match */
.password-indicator.match { 
    color: #28a745; 
    display: inline; 
}

/* Red cross when passwords don't match */
.password-indicator.mismatch { 
    color: #dc3545; 
    display: inline; 
}
        
        .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #999;
            padding: 0;
            display: flex;
            align-items: center;
        }
        
        .toggle-password:hover { color: #f5576c; }
        .toggle-password svg { width: 18px; height: 18px; }
        
        .btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .error {
            background: #fee;
            color: #c33;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #c33;
        }
        
        .success {
            background: #efe;
            color: #3c3;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #3c3;
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
        
        .mini-toggle {
            width: 60px;
            height: 28px;
            background: #ddd;
            border-radius: 20px;
            padding: 3px;
            cursor: pointer;
        }
        
        .mini-slider {
            width: 100%;
            height: 100%;
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
            background: #f5576c;
            border-radius: 50%;
            left: 3px;
            transition: all 0.3s ease;
        }
        
        .mini-slider.active::before {
            left: 35px;
            background: #2b2b3d;
        }
        
        .dark-mode .mini-toggle {
            background: #444;
        }
        
        @media (max-width: 768px) {
            .container {
                margin: 20px auto;
                padding: 0 15px;
            }
            
            .form-card {
                padding: 25px;
            }
            
            .navbar {
                padding: 10px 15px;
                flex-wrap: wrap;
                gap: 10px;
            }
            
            .navbar h2 {
                font-size: 16px;
            }
        }
    </style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

    <div class="navbar">
        <h2>➕ Create Employer Account</h2>
        <div class="nav-right">
            <form action="ThemeServlet" method="post">
                <div class="mini-toggle" onclick="this.closest('form').submit();">
                    <div class="mini-slider <%= theme.equals("DARK") ? "active" : "" %>">
                        <span>☀</span>
                        <span>🌙</span>
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
            
            <a href="adminDashboard.jsp" class="dashboard-btn">← Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-card">
            <h1>Create Employer Account</h1>
            <p>Create a new employer/manager account with elevated privileges</p>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="success"><%= request.getAttribute("success") %></div>
            <% } %>
            
            <form action="AdminCreateEmployerServlet" method="post">
                <div class="form-group">
                    <label>Full Name <span class="required">*</span></label>
                    <input type="text" name="fullName" required placeholder="Enter employer's full name">
                </div>
                
                <div class="form-group">
                    <label>Username <span class="required">*</span></label>
                    <input type="text" name="username" required placeholder="Choose a username">
                </div>
                
                <div class="form-group">
                    <label>Email <span class="required">*</span></label>
                    <input type="email" name="email" required placeholder="employer@company.com">
                </div>
                
                <div class="form-group">
                    <label>Department <span class="required">*</span></label>
                    <select name="department" required>
                        <option value="">-- Select Department --</option>
                        <option value="HR">HR</option>
                        <option value="IT">IT</option>
                        <option value="Finance">Finance</option>
                        <option value="Sales">Sales</option>
                        <option value="Marketing">Marketing</option>
                        <option value="Operations">Operations</option>
                        <option value="Support">Support</option>
                    </select>
                </div>
                
                <div class="form-group">
            <label>Password <span class="required">*</span></label>
            <div class="password-wrapper">
                <input type="password" id="password" name="password" required
                       placeholder="Minimum 8 characters" oninput="checkStrength(this.value)">
                <button type="button" class="toggle-password" onclick="togglePwd('password', this)">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                    </svg>
                </button>
            </div>
            <!-- Strength bar -->
            <div class="strength-bar"><div class="strength-bar-fill" id="strengthBar"></div></div>
            <div class="strength-text" id="strengthText"></div>
            <!-- Rules -->
            <div class="password-rules">
                <div class="rule" id="rule-length">○ &nbsp;At least 8 characters</div>
                <div class="rule" id="rule-upper">○ &nbsp;At least one uppercase letter (A-Z)</div>
                <div class="rule" id="rule-lower">○ &nbsp;At least one lowercase letter (a-z)</div>
                <div class="rule" id="rule-number">○ &nbsp;At least one number (0-9)</div>
                <div class="rule" id="rule-special">○ &nbsp;At least one special character (!@#$%^&*)</div>
            </div>
        </div>

        <div class="form-group">
    <label>Confirm Password <span class="required">*</span></label>
    <div class="password-wrapper">
        <input type="password" id="confirmPassword" name="confirmPassword" required 
               placeholder="Re-enter password" oninput="checkMatch();">
        <span class="password-indicator" id="matchIndicator"></span>
        <button type="button" class="toggle-password" onclick="togglePwd('confirmPassword', this)">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                    </svg>
                </button>
            </div>
                </div>
                
                <button type="submit" class="btn">Create Employer Account</button>
            </form>
        </div>
    </div>
    
    <script>
    function togglePwd(fieldId, btn) {
        const input = document.getElementById(fieldId);
        const svg = btn.querySelector('svg');
        if (input.type === 'password') {
            input.type = 'text';
            svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>';
        } else {
            input.type = 'password';
            svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>';
        }
    }
    function checkMatch() {
    const pwd = document.getElementById('password').value;
    const confirm = document.getElementById('confirmPassword').value;
    const indicator = document.getElementById('matchIndicator');
    
    if (confirm.length === 0) {
        indicator.className = 'password-indicator';
        indicator.innerHTML = '';
        return;
    }
    
    if (pwd === confirm) {
        indicator.className = 'password-indicator match';
        indicator.innerHTML = '✓';
    } else {
        indicator.className = 'password-indicator mismatch';
        indicator.innerHTML = '✗';
    }
}
function setRule(id, valid) {
    const el = document.getElementById(id);
    if (valid) {
        el.className = 'rule valid';
        el.innerHTML = el.innerHTML.replace('○', '✓');
    } else {
        el.className = 'rule invalid';
        el.innerHTML = el.innerHTML.replace('✓', '○');
    }
}

function checkStrength(val) {
    const hasLength  = val.length >= 8;
    const hasUpper   = /[A-Z]/.test(val);
    const hasLower   = /[a-z]/.test(val);
    const hasNumber  = /[0-9]/.test(val);
    const hasSpecial = /[!@#$%^&*()\-_=+\[\]{};:'",.<>?\/\\|`~]/.test(val);

    // Update rule icons
    document.getElementById('rule-length').innerHTML  = (hasLength  ? '✓' : '○') + ' &nbsp;At least 8 characters';
    document.getElementById('rule-upper').innerHTML   = (hasUpper   ? '✓' : '○') + ' &nbsp;At least one uppercase letter (A-Z)';
    document.getElementById('rule-lower').innerHTML   = (hasLower   ? '✓' : '○') + ' &nbsp;At least one lowercase letter (a-z)';
    document.getElementById('rule-number').innerHTML  = (hasNumber  ? '✓' : '○') + ' &nbsp;At least one number (0-9)';
    document.getElementById('rule-special').innerHTML = (hasSpecial ? '✓' : '○') + ' &nbsp;At least one special character (!@#$%^&*)';

    document.getElementById('rule-length').className  = 'rule ' + (hasLength  ? 'valid' : (val.length > 0 ? 'invalid' : ''));
    document.getElementById('rule-upper').className   = 'rule ' + (hasUpper   ? 'valid' : (val.length > 0 ? 'invalid' : ''));
    document.getElementById('rule-lower').className   = 'rule ' + (hasLower   ? 'valid' : (val.length > 0 ? 'invalid' : ''));
    document.getElementById('rule-number').className  = 'rule ' + (hasNumber  ? 'valid' : (val.length > 0 ? 'invalid' : ''));
    document.getElementById('rule-special').className = 'rule ' + (hasSpecial ? 'valid' : (val.length > 0 ? 'invalid' : ''));

    const score = [hasLength, hasUpper, hasLower, hasNumber, hasSpecial].filter(Boolean).length;
    const bar   = document.getElementById('strengthBar');
    const text  = document.getElementById('strengthText');

    const levels = [
        { pct: '0%',   color: '#eee',    label: '' },
        { pct: '20%',  color: '#dc3545', label: 'Very Weak' },
        { pct: '40%',  color: '#fd7e14', label: 'Weak' },
        { pct: '60%',  color: '#ffc107', label: 'Fair' },
        { pct: '80%',  color: '#20c997', label: 'Strong' },
        { pct: '100%', color: '#28a745', label: 'Very Strong' },
    ];

    bar.style.width      = val.length ? levels[score].pct   : '0%';
    bar.style.background = val.length ? levels[score].color : '#eee';
    text.textContent     = val.length ? levels[score].label : '';
    text.style.color     = levels[score].color;
}

function validateForm() {
    const pwd     = document.getElementById('password').value;
    const confirm = document.getElementById('confirmPassword').value;

    const hasLength  = pwd.length >= 8;
    const hasUpper   = /[A-Z]/.test(pwd);
    const hasLower   = /[a-z]/.test(pwd);
    const hasNumber  = /[0-9]/.test(pwd);
    const hasSpecial = /[!@#$%^&*()\-_=+\[\]{};:'",.<>?\/\\|`~]/.test(pwd);

    if (!hasLength || !hasUpper || !hasLower || !hasNumber || !hasSpecial) {
        alert('Password must meet all the requirements shown!');
        return false;
    }
    if (pwd !== confirm) {
        alert('Passwords do not match!');
        return false;
    }
    return true;
}

    </script>
</body>
</html>
