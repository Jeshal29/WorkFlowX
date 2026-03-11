<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - WorkFlowX</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea, #764ba2);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 450px;
        }
        .logo { text-align: center; margin-bottom: 30px; }
        .logo h1 { color: #667eea; font-size: 32px; margin-bottom: 5px; }
        .logo p { color: #666; font-size: 14px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 5px; color: #333; font-weight: 500; }
        .form-group input,
        .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        .radio-group { display: flex; gap: 20px; margin-top: 8px; }
        .radio-group label { display: flex; align-items: center; cursor: pointer; }
        .radio-group input[type="radio"] { margin-right: 5px; cursor: pointer; }
        .btn { width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: 600; cursor: pointer; }
        .btn:hover { transform: translateY(-2px); }
        .error { background: #fee; color: #c33; padding: 10px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #c33; }
        .success { background: #efe; color: #3c3; padding: 10px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #3c3; }
        .login-link { text-align: center; margin-top: 20px; color: #666; }
        .login-link a { color: #667eea; font-weight: 600; text-decoration: none; }
        .login-link a:hover { text-decoration: underline; }
        .required { color: red; }

        /* PROFILE PIC PREVIEW */
        #imagePreview { display: none; margin-bottom: 15px; text-align: center; }
        #imagePreview img { max-width: 120px; border-radius: 50%; box-shadow: 0 3px 10px rgba(0,0,0,0.2); }
        .profile-upload-label {
            display: inline-block;
            margin-bottom: 10px;
            cursor: pointer;
            background: #667eea;
            color: white;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 14px;
        }
        .profile-upload-label:hover { background: #764ba2; }
        .form-group input[type="file"] { display: none; }

        /* Password toggle */
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
            position: absolute; right: 10px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #999; padding: 0; display: flex; align-items: center;
        }
        .toggle-password:hover { color: #667eea; }
        .toggle-password svg { width: 18px; height: 18px; }

        /* Password strength bar */
        .strength-bar {
            height: 4px; border-radius: 2px;
            background: #eee; margin-top: 8px;
        }
        .strength-bar-fill {
            height: 100%; border-radius: 2px;
            width: 0%; transition: all 0.3s;
        }
        .strength-text {
            font-size: 11px; margin-top: 4px;
            font-weight: 600;
        }

        /* Password rules */
        .password-rules { margin-top: 8px; }
        .rule {
            font-size: 12px; padding: 2px 0;
            display: flex; align-items: center; gap: 6px;
            color: #bbb;
        }
        .rule.valid { color: #28a745; }
        .rule.invalid { color: #dc3545; }
        /* Phone validation */
.input-with-icon { position: relative; }
.input-with-icon .flag { 
    position: absolute; left: 12px; top: 50%; 
    transform: translateY(-50%); font-size: 15px; pointer-events: none; 
}
.input-with-icon input { padding-left: 38px !important; }
.form-group input.valid  { border-color: #28a745 !important; }
.form-group input.invalid { border-color: #dc3545 !important; }

</style>
</head>
<body>

<div class="container">
    <div class="logo">
        <h1>WorkFlowX</h1>
        <p>Employee Communication Portal</p>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="error"><%= request.getAttribute("error") %></div>
    <% } %>
    <% if (request.getAttribute("success") != null) { %>
        <div class="success"><%= request.getAttribute("success") %></div>
    <% } %>

    <form action="RegisterServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
        <!-- Profile Picture Upload -->
        <div class="form-group">
            <label class="profile-upload-label" for="profilePicture">📷 Upload Profile Picture</label>
            <input type="file" name="profilePicture" id="profilePicture" accept="image/*" onchange="previewImage(this)">
        </div>
        <div id="imagePreview">
            <img id="preview" src="#" alt="Preview">
        </div>

        <div class="form-group">
            <label>Full Name <span class="required">*</span></label>
            <input type="text" name="fullName" required placeholder="Enter your full name">
        </div>
        <div class="form-group">
            <label>Username <span class="required">*</span></label>
            <input type="text" name="username" required placeholder="Choose a username">
        </div>
        <div class="form-group">
            <label>Email <span class="required">*</span></label>
            <input type="email" id="emailInput" name="email" required 
       placeholder="your.email@example.com" oninput="validateEmail(this)">
        <div class="field-hint" id="emailHint"></div>
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

       <div class="form-group">
    <label>Department <span class="required">*</span></label>
    <select name="department" required>
        <option value="">-- Select Department --</option>
        <option value="HR">HR</option>
        <option value="IT">IT</option>
        <option value="Finance">Finance</option>
        <option value="Sales">Sales</option>
        <option value="Marketing">Marketing</option>
        <option value="Development">Development</option>
        <option value="Support">Support</option>
    </select>
</div>
        <%-- Role is fixed as EMPLOYEE. Employers are created by Admin only. --%>
        <input type="hidden" name="role" value="EMPLOYEE">
        <button type="submit" class="btn">Register</button>
    </form>

    <div class="login-link">
        Already have an account? <a href="login.jsp">Login here</a>
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
        { pct: '100%', color: '#28a745', label: 'Very Strong' }
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

function previewImage(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        if (!file.type.startsWith('image/')) {
            alert('Please select an image file');
            input.value = '';
            return;
        }
        if (file.size > 5 * 1024 * 1024) {
            alert('File size must be less than 5MB');
            input.value = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('preview').src = e.target.result;
            document.getElementById('imagePreview').style.display = 'block';
        };
        reader.readAsDataURL(file);
    }
}
function validateEmail(inp) {
    var re = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
    var h = document.getElementById('emailHint');
    if (!inp.value) { h.textContent=''; inp.classList.remove('valid','invalid'); return; }
    if (re.test(inp.value.trim())) {
        inp.classList.add('valid'); inp.classList.remove('invalid');
        h.className='field-hint ok'; h.textContent='✓ Valid email address';
    } else {
        inp.classList.add('invalid'); inp.classList.remove('valid');
        h.className='field-hint err'; h.textContent='✗ Enter a valid email (e.g. name@domain.com)';
    }
}

</script>

</body>
</html>
