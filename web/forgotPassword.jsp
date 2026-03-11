<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - WorkFlowX</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        }
        
        .back-btn {
            position: absolute;
            top: 15px;
            left: 15px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .back-btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            width: 450px;
            max-width: 90%;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .header .icon {
            font-size: 64px;
            margin-bottom: 15px;
        }
        
        .header h1 {
            color: #667eea;
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .header p {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .progress {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            position: relative;
        }
        
        .progress::before {
            content: '';
            position: absolute;
            top: 15px;
            left: 0;
            right: 0;
            height: 2px;
            background: #e0e0e0;
            z-index: 0;
        }
        
        .progress-step {
            flex: 1;
            text-align: center;
            position: relative;
            z-index: 1;
        }
        
        .progress-step .circle {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: #e0e0e0;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 8px;
            font-weight: 600;
            font-size: 14px;
        }
        
        .progress-step.active .circle {
            background: #667eea;
        }
        
        .progress-step.completed .circle {
            background: #00cc44;
        }
        
        .progress-step .label {
            font-size: 12px;
            color: #999;
        }
        
        .progress-step.active .label {
            color: #667eea;
            font-weight: 600;
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
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .otp-inputs {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        
        .otp-inputs input {
            width: 50px;
            height: 50px;
            text-align: center;
            font-size: 24px;
            font-weight: 600;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
        }
        
        .otp-inputs input:focus {
            border-color: #667eea;
        }
        
        .password-wrapper {
            position: relative;
        }
        
        .password-wrapper input {
            padding-right: 45px;
        }
        
        .toggle-password {
            position: absolute;
            right: 12px;
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
        
        .toggle-password:hover {
            color: #667eea;
        }
        
        .toggle-password svg {
            width: 20px;
            height: 20px;
        }
        
        .submit-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
            margin-top: 10px;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
        }
        
        .submit-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .message {
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }
        
        .success {
            background: #e6ffed;
            color: #2e7d32;
            border: 1px solid #2e7d32;
        }
        
        .error {
            background: #ffebee;
            color: #c62828;
            border: 1px solid #c62828;
        }
        
        .info {
            background: #e3f2fd;
            color: #1976d2;
            border: 1px solid #1976d2;
        }
        
        .resend-otp {
            text-align: center;
            margin-top: 15px;
            font-size: 13px;
            color: #666;
        }
        
        .resend-otp button {
            background: none;
            border: none;
            color: #667eea;
            font-weight: 600;
            cursor: pointer;
            text-decoration: underline;
        }
        
        .resend-otp button:disabled {
            color: #999;
            cursor: not-allowed;
            text-decoration: none;
        }
        
        .timer {
            color: #f57c00;
            font-weight: 600;
        }
        
        .step {
            display: none;
        }
        
        .step.active {
            display: block;
        }
        .strength-bar { height: 4px; border-radius: 2px; background: #eee; margin-top: 8px; }
.strength-bar-fill { height: 100%; border-radius: 2px; width: 0%; transition: all 0.3s; }
.strength-text { font-size: 11px; margin-top: 4px; font-weight: 600; }
.password-rules { margin-top: 8px; }
.rule { font-size: 12px; padding: 2px 0; color: #bbb; }
.rule.valid { color: #28a745; }
.rule.invalid { color: #dc3545; }
.password-indicator { position: absolute; right: 40px; top: 50%; transform: translateY(-50%); font-size: 20px; font-weight: bold; display: none; }
.password-indicator.match { color: #28a745; display: inline; }
.password-indicator.mismatch { color: #dc3545; display: inline; }
    </style>
</head>
<body>
    <a href="login.jsp" class="back-btn">← Back to Login</a>

    <div class="container">
        <div class="header">
            <div class="icon">🔐</div>
            <h1>Reset Password</h1>
            <p id="headerText">Enter your email to receive OTP</p>
        </div>
        
        <div class="progress">
            <div class="progress-step active" id="progress1">
                <div class="circle">1</div>
                <div class="label">Email</div>
            </div>
            <div class="progress-step" id="progress2">
                <div class="circle">2</div>
                <div class="label">Verify OTP</div>
            </div>
            <div class="progress-step" id="progress3">
                <div class="circle">3</div>
                <div class="label">New Password</div>
            </div>
        </div>
        
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
        
        <% if (request.getAttribute("info") != null) { %>
            <div class="message info">
                <%= request.getAttribute("info") %>
            </div>
        <% } %>
        
        <!-- STEP 1: Enter Email -->
        <% if (request.getAttribute("step") == null || "email".equals(request.getAttribute("step"))) { %>
            <div class="step active" id="step1">
                <form action="ForgotPasswordServlet" method="post">
                    <input type="hidden" name="action" value="sendOTP">
                    
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               required 
                               placeholder="Enter your registered email"
                               value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>">
                    </div>
                    
                    <button type="submit" class="submit-btn">
                        📧 Send OTP
                    </button>
                </form>
            </div>
        <% } %>
        
        <!-- STEP 2: Verify OTP -->
        <% if ("verifyOTP".equals(request.getAttribute("step"))) { %>
            <script>
                document.getElementById('headerText').textContent = 'Enter the 6-digit OTP sent to your email';
                document.getElementById('progress1').classList.add('completed');
                document.getElementById('progress1').classList.remove('active');
                document.getElementById('progress2').classList.add('active');
            </script>
            
            <div class="step active" id="step2">
                <div class="message info">
                    📧 OTP sent to: <%= request.getAttribute("maskedEmail") %>
                    <br><small>Check your inbox and spam folder</small>
                </div>
                
                <form action="ForgotPasswordServlet" method="post" onsubmit="return submitOTP()">
                    <input type="hidden" name="action" value="verifyOTP">
                    <input type="hidden" name="email" value="<%= request.getAttribute("email") %>">
                    <input type="hidden" name="otp" id="otpValue">
                    
                    <div class="form-group">
                        <label>Enter 6-Digit OTP</label>
                        <div class="otp-inputs">
                            <input type="text" maxlength="1" class="otp-input" id="otp1" autofocus>
                            <input type="text" maxlength="1" class="otp-input" id="otp2">
                            <input type="text" maxlength="1" class="otp-input" id="otp3">
                            <input type="text" maxlength="1" class="otp-input" id="otp4">
                            <input type="text" maxlength="1" class="otp-input" id="otp5">
                            <input type="text" maxlength="1" class="otp-input" id="otp6">
                        </div>
                    </div>
                    
                    <button type="submit" class="submit-btn">
                        ✓ Verify OTP
                    </button>
                </form>
                
                <div class="resend-otp">
                    Didn't receive OTP? 
                    <button id="resendBtn" onclick="resendOTP()" disabled>
                        Resend in <span class="timer" id="timer">60</span>s
                    </button>
                </div>
            </div>
            
            <script>
                // OTP Input Auto-focus
                const otpInputs = document.querySelectorAll('.otp-input');
                otpInputs.forEach((input, index) => {
                    input.addEventListener('input', (e) => {
                        if (e.target.value.length === 1 && index < 5) {
                            otpInputs[index + 1].focus();
                        }
                    });
                    
                    input.addEventListener('keydown', (e) => {
                        if (e.key === 'Backspace' && !e.target.value && index > 0) {
                            otpInputs[index - 1].focus();
                        }
                    });
                });
                
                // Submit OTP
                function submitOTP() {
                    let otp = '';
                    otpInputs.forEach(input => otp += input.value);
                    
                    if (otp.length !== 6) {
                        alert('Please enter all 6 digits');
                        return false;
                    }
                    
                    document.getElementById('otpValue').value = otp;
                    return true;
                }
                
                // Resend Timer
                let timeLeft = 60;
                const timer = setInterval(() => {
                    timeLeft--;
                    document.getElementById('timer').textContent = timeLeft;
                    
                    if (timeLeft <= 0) {
                        clearInterval(timer);
                        const resendBtn = document.getElementById('resendBtn');
                        resendBtn.disabled = false;
                        resendBtn.innerHTML = 'Resend OTP';
                    }
                }, 1000);
                
                // Resend OTP Function
                function resendOTP() {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'ForgotPasswordServlet';
                    
                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'sendOTP';
                    
                    const emailInput = document.createElement('input');
                    emailInput.type = 'hidden';
                    emailInput.name = 'email';
                    emailInput.value = '<%= request.getAttribute("email") %>';
                    
                    form.appendChild(actionInput);
                    form.appendChild(emailInput);
                    document.body.appendChild(form);
                    form.submit();
                }
            </script>
        <% } %>
        
        <!-- STEP 3: Reset Password -->
        <% if ("resetPassword".equals(request.getAttribute("step"))) { %>
            <script>
                document.getElementById('headerText').textContent = 'Create your new password';
                document.getElementById('progress1').classList.add('completed');
                document.getElementById('progress2').classList.add('completed');
                document.getElementById('progress2').classList.remove('active');
                document.getElementById('progress3').classList.add('active');
            </script>
            
            <div class="step active" id="step3">
                <form action="ForgotPasswordServlet" method="post" onsubmit="return validatePassword()">
                    <input type="hidden" name="action" value="resetPassword">
                    <input type="hidden" name="email" value="<%= request.getAttribute("email") %>">
                    
                    <div class="form-group">
                        <label for="newPassword">New Password</label>
                        <input type="password" 
       id="newPassword" 
       name="newPassword" 
       required
       minlength="6"
       placeholder="Enter new password"
       oninput="checkStrength(this.value)">
                            <button type="button" class="toggle-password" onclick="togglePwd('newPassword', this)">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                                </svg>
                            </button>
                        </div>
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
                        <label for="confirmPassword">Confirm Password</label>
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
                    
                    <button type="submit" class="submit-btn">
                        🔒 Reset Password
                    </button>
                </form>
            </div>
            
            <script>
               function validatePassword() {
    const newPwd = document.getElementById('newPassword').value;
    const confirmPwd = document.getElementById('confirmPassword').value;

    const hasLength  = newPwd.length >= 8;
    const hasUpper   = /[A-Z]/.test(newPwd);
    const hasLower   = /[a-z]/.test(newPwd);
    const hasNumber  = /[0-9]/.test(newPwd);
    const hasSpecial = /[!@#$%^&*()\-_=+\[\]{};:'",.<>?\/\\|`~]/.test(newPwd);

    if (!hasLength || !hasUpper || !hasLower || !hasNumber || !hasSpecial) {
        alert('Password must meet all the requirements shown!');
        return false;
    }
    if (newPwd !== confirmPwd) {
        alert('Passwords do not match!');
        return false;
    }
    return true;
}
            </script>
        <% } %>
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
    const pwd = document.getElementById('newPassword').value;  // ← fix this line
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

    </script>
</body>
</html>
