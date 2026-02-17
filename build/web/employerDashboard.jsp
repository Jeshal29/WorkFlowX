<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
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
    // Check if user is logged in
   
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check if user is employer
    if (!user.isEmployer()) {
        response.sendRedirect("employeeDashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employer Dashboard - WorkFlowX</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
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
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .navbar h1 {
            font-size: 24px;
        }
        
        .navbar .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .navbar .user-info span {
            font-size: 14px;
        }
        
        .navbar .logout-btn,
        .navbar .profile-btn{
            background: rgba(255,255,255,0.2);
            color: white;
            border: 1px solid white;
            padding: 8px 20px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }
        
        .navbar .logout-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        .navbar .profile-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .welcome {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .welcome h2 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .welcome p {
            color: #666;
        }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .card-icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        
        .card h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 20px;
        }
        
        .card p {
            color: #666;
            font-size: 14px;
        }
        
        .card-messages { border-top: 4px solid #667eea; }
        .card-tasks { border-top: 4px solid #f093fb; }
        .card-employees { border-top: 4px solid #4facfe; }
        .card-leaves { border-top: 4px solid #43e97b; }
        .card-reports { border-top: 4px solid #fa709a; }
        .card-chatbot { border-top: 4px solid #feca57; }
        
        .stats {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .stats h3 {
            color: #333;
            margin-bottom: 20px;
        }
        
        .stat-item {
            display: flex;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #eee;
        }
        
        .stat-item:last-child {
            border-bottom: none;
        }
        
        .stat-item span:first-child {
            color: #666;
        }
        
        .stat-item span:last-child {
            font-weight: 600;
            color: #f5576c;
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
        <h1>WorkFlowX - Employer Portal</h1>
        <div class="user-info">
            <span>Welcome, <%= user.getFullName() %>!</span>
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
            <a href="LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome">
            <h2>Employer Dashboard</h2>
            <p>Manage employees, assign tasks, approve leaves, and view reports.</p>
        </div>
        
        <div class="dashboard-grid">
            <a href="messages.jsp" class="card card-messages">
                <div class="card-icon">💬</div>
                <h3>Messages</h3>
                <p>Communicate with employees</p>
            </a>
            
            <a href="assignTask.jsp" class="card card-tasks">
                <div class="card-icon">✓</div>
                <h3>Assign Tasks</h3>
                <p>Create and manage tasks</p>
            </a>
            
            <a href="employees.jsp" class="card card-employees">
                <div class="card-icon">👥</div>
                <h3>Employees</h3>
                <p>View employee details</p>
            </a>
            
            <a href="approveLeaves.jsp" class="card card-leaves">
                <div class="card-icon">🏖️</div>
                <h3>Leave Requests</h3>
                <p>Approve or reject leaves</p>
            </a>
            
            <a href="reports.jsp" class="card card-reports">
                <div class="card-icon">📊</div>
                <h3>Reports</h3>
                <p>View activity reports</p>
            </a>
            
           
        </div>
        <!-- Chatbot Widget -->
<div id="chatbot-widget">
    <!-- Chat Button -->
    <div id="chat-button" style="cursor: pointer; font-size: 28px; display: flex; align-items: center; justify-content: center;">
    🤖
    <div id="unread-badge" style="display: none;">1</div>
</div>


    
    <!-- Chat Window -->
    <div id="chat-window" style="display: none;">
        <!-- Header -->
        <div id="chat-header">
            <div style="display: flex; align-items: center; gap: 10px;">
                <div class="bot-avatar">🤖</div>
                <div>
                    <div style="font-weight: 600; font-size: 15px;">WorkFlowX Assistant</div>
                    <div style="font-size: 12px; opacity: 0.8;">Online</div>
                </div>
            </div>
            <button onclick="toggleChat()" style="background: none; border: none; color: white; font-size: 24px; cursor: pointer; padding: 0; width: 30px; height: 30px;">&times;</button>
        </div>
        
        <!-- Messages Container -->
        <div id="chat-messages">
            <div class="bot-message">
                <div class="message-bubble bot">
                    👋 Hi! I'm your WorkFlowX assistant. How can I help you today?
                    <div class="message-time">Just now</div>
                </div>
            </div>
            
            <!-- Quick Suggestions -->
            <div class="quick-suggestions">
                <div class="suggestion" onclick="sendQuickMessage('How do I send a message?')">📨 Send Messages</div>
                <div class="suggestion" onclick="sendQuickMessage('How do I apply for leave?')">🏖️ Apply Leave</div>
                <div class="suggestion" onclick="sendQuickMessage('How do I upload a file?')">📁 Upload Files</div>
                <div class="suggestion" onclick="sendQuickMessage('How do I view my tasks?')">✓ View Tasks</div>
            </div>
        </div>
        
        <!-- Input Area -->
        <div id="chat-input-area">
            <input type="text" id="chat-input" placeholder="Type your message..." onkeypress="handleKeyPress(event)">
            <button id="send-btn" onclick="sendMessage()">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                    <path d="M2 10L18 2L10 18L8 11L2 10Z" fill="white"/>
                </svg>
            </button>
        </div>
    </div>
</div>
        
        </div>
    <style>
#chatbot-widget {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 9999;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

#chat-button {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: linear-gradient(135deg, #25D366 0%, #128C7E 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(37, 211, 102, 0.4);
    transition: all 0.3s ease;
    position: relative;
}

#chat-button:hover {
    transform: scale(1.1);
    box-shadow: 0 6px 20px rgba(37, 211, 102, 0.6);
}

#unread-badge {
    position: absolute;
    top: -5px;
    right: -5px;
    background: #ff3b30;
    color: white;
    border-radius: 50%;
    width: 22px;
    height: 22px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 600;
    border: 2px solid white;
}

#chat-window {
    position: absolute;
    bottom: 80px;
    right: 0;
    width: 380px;
    height: 550px;
    background: white;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    animation: slideUp 0.3s ease;
}

@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

#chat-header {
    background: linear-gradient(135deg, #25D366 0%, #128C7E 100%);
    color: white;
    padding: 15px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.bot-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
}

#chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
    background: #f0f0f5;
    display: flex;
    flex-direction: column;
    gap: 15px;
}

#chat-messages::-webkit-scrollbar {
    width: 6px;
}

#chat-messages::-webkit-scrollbar-thumb {
    background: #ccc;
    border-radius: 3px;
    
}

.bot-message, .user-message {
    display: flex;
    gap: 8px;
    animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.user-message {
    justify-content: flex-end;
}

.message-bubble {
    max-width: 75%;
    padding: 12px 16px;
    border-radius: 18px;
    font-size: 14px;
    line-height: 1.4;
    position: relative;
    
}

.message-bubble.bot {
    background: white;
    color: black;
    border-bottom-left-radius: 4px;
    box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

.message-bubble.user {
    background: linear-gradient(135deg, #25D366 0%, #128C7E 100%);
    color: black;
    border-bottom-right-radius: 4px;
}

.message-time {
    font-size: 11px;
    opacity: 0.6;
    margin-top: 4px;
    text-align: right;
}

.typing-indicator {
    display: flex;
    gap: 4px;
    padding: 12px 16px;
    background: white;
    border-radius: 18px;
    width: fit-content;
    box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

.typing-indicator span {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #999;
    animation: typing 1.4s infinite;
}

.typing-indicator span:nth-child(2) {
    animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
    animation-delay: 0.4s;
}

@keyframes typing {
    0%, 60%, 100% {
        transform: translateY(0);
    }
    30% {
        transform: translateY(-10px);
    }
}

.quick-suggestions {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: 10px;
}

.suggestion {
    background: white;
    padding: 10px 14px;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 13px;
    box-shadow: 0 1px 2px rgba(0,0,0,0.1);
    color: black;
}

.suggestion:hover {
    background: #25D366;
    color: black;
    transform: translateX(5px);
}

#chat-input-area {
    padding: 15px 20px;
    background: white;
    display: flex;
    gap: 10px;
    border-top: 1px solid #e0e0e0;
}

#chat-input {
    flex: 1;
    padding: 12px 16px;
    border: 1px solid #e0e0e0;
    border-radius: 25px;
    font-size: 14px;
    outline: none;
    font-family: inherit;
}

#chat-input:focus {
    border-color: #25D366;
}

#send-btn {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    background: linear-gradient(135deg, #25D366 0%, #128C7E 100%);
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s;
}

#send-btn:hover {
    transform: scale(1.1);
}

#send-btn:active {
    transform: scale(0.95);
}

@media (max-width: 500px) {
    #chat-window {
        width: calc(100vw - 40px);
        height: calc(100vh - 100px);
        bottom: 80px;
        right: 20px;
    }
}
</style>

<script>
function toggleChat() {
    const chatWindow = document.getElementById('chat-window');
    const chatButton = document.getElementById('chat-button');
    const unreadBadge = document.getElementById('unread-badge');
    
    if (chatWindow.style.display === 'none') {
        chatWindow.style.display = 'flex';
        chatButton.style.display = 'none';
        unreadBadge.style.display = 'none';
        
        setTimeout(function() {
            document.getElementById('chat-input').focus();
        }, 300);
    } else {
        chatWindow.style.display = 'none';
        chatButton.style.display = 'flex';
    }
}

function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

function sendQuickMessage(message) {
    document.getElementById('chat-input').value = message;
    sendMessage();
}

function sendMessage() {
    const input = document.getElementById('chat-input');
    const message = input.value.trim();
    
    if (message === '') return;
    
    addMessage(message, 'user');
    input.value = '';
    
    showTyping();
    
    fetch('ChatbotServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'message=' + encodeURIComponent(message)
    })
    .then(function(response) { return response.json(); })
    .then(function(data) {
        hideTyping();
        if (data.success) {
            addMessage(data.message, 'bot');
        } else {
            addMessage('Sorry, something went wrong. Please try again.', 'bot');
        }
    })
    .catch(function(error) {
        hideTyping();
        addMessage('Sorry, I am having trouble connecting. Please try again later.', 'bot');
    });
}

function addMessage(text, sender) {
    const messagesContainer = document.getElementById('chat-messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = sender + '-message';
    
    const now = new Date();
    const timeStr = now.getHours().toString().padStart(2, '0') + ':' + 
                   now.getMinutes().toString().padStart(2, '0');
    
    const bubble = document.createElement('div');
    bubble.className = 'message-bubble ' + sender;
    
    const textNode = document.createTextNode(text);
    bubble.appendChild(textNode);
    
    const timeDiv = document.createElement('div');
    timeDiv.className = 'message-time';
    timeDiv.textContent = timeStr;
    bubble.appendChild(timeDiv);
    
    messageDiv.appendChild(bubble);
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

function showTyping() {
    const messagesContainer = document.getElementById('chat-messages');
    const typingDiv = document.createElement('div');
    typingDiv.className = 'bot-message';
    typingDiv.id = 'typing-indicator';
    typingDiv.innerHTML = '<div class="typing-indicator"><span></span><span></span><span></span></div>';
    messagesContainer.appendChild(typingDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

function hideTyping() {
    const typingIndicator = document.getElementById('typing-indicator');
    if (typingIndicator) {
        typingIndicator.remove();
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const chatButton = document.getElementById('chat-button');
    if (chatButton) {
        chatButton.addEventListener('click', function() {
            toggleChat();
        });
    }
});
</script>
</body>
</html>