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

    <form action="RegisterServlet" method="post" enctype="multipart/form-data">
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
            <input type="email" name="email" required placeholder="your.email@example.com">
        </div>
        <div class="form-group">
            <label>Password <span class="required">*</span></label>
            <input type="password" name="password" required placeholder="Minimum 6 characters" minlength="6">
        </div>
        <div class="form-group">
            <label>Confirm Password <span class="required">*</span></label>
            <input type="password" name="confirmPassword" required placeholder="Re-enter password">
        </div>
        <div class="form-group">
            <label>Department</label>
            <input type="text" name="department" placeholder="e.g., Development, HR, Sales">
        </div>
        <div class="form-group">
            <label>Register as <span class="required">*</span></label>
            <div class="radio-group">
                <label><input type="radio" name="role" value="EMPLOYEE" checked> Employee</label>
                <label><input type="radio" name="role" value="EMPLOYER"> Employer</label>
            </div>
        </div>
        <button type="submit" class="btn">Register</button>
    </form>

    <div class="login-link">
        Already have an account? <a href="login.jsp">Login here</a>
    </div>
</div>

<script>
function previewImage(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];

        if (!file.type.startsWith('image/')) {
            alert('Please select an image file');
            input.value = '';
            return;
        }

        if (file.size > 5 * 1024 * 1024) { // 5MB
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
</script>

</body>
</html>
