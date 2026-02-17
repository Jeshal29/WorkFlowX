<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - WorkFlowX</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
        
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            width: 400px;
            max-width: 90%;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo .icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        
        .logo h1 {
            color: #f5576c;
            font-size: 28px;
            margin-bottom: 5px;
        }
        
        .logo p {
            color: #666;
            font-size: 13px;
        }
        
        .security-badge {
            background: #fff3e0;
            color: #f57c00;
            padding: 10px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 20px;
            font-size: 12px;
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
            border-color: #f5576c;
        }
        
        .login-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .login-btn:hover {
            transform: translateY(-2px);
        }
        
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
            text-align: center;
        }
    </style>
</head>
<body>
    <a href="login.jsp" class="back-btn">← Back to Login</a>

    <div class="login-container">
        <div class="logo">
            <div class="icon">🔐</div>
            <h1>Admin Access</h1>
            <p>WorkFlowX Administration Panel</p>
        </div>
        
        <div class="security-badge">
            ⚠️ Authorized Personnel Only
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <form action="LoginServlet" method="post">
            <input type="hidden" name="role" value="ADMIN">
            
            <div class="form-group">
                <label for="username">Admin Username</label>
                <input type="text" id="username" name="username" required placeholder="Enter admin username">
            </div>
            
            <div class="form-group">
                <label for="password">Admin Password</label>
                <input type="password" id="password" name="password" required placeholder="Enter admin password">
            </div>
            
            <button type="submit" class="login-btn">Access Admin Panel</button>
        </form>
    </div>
</body>
</html>
