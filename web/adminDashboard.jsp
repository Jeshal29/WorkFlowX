<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User" %>
<%@ include file="/common/userSession.jsp" %>
<%@ include file="/common/adminOnly.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - WorkFlowX</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/chatbot.css">
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

        .navbar {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
 
@media (max-width: 768px) {
    .navbar { padding: 10px 15px; flex-wrap: wrap; gap: 10px; }
    .navbar h1 { font-size: 16px; }
    .navbar .user-info { gap: 10px; }
    .navbar .user-info > span { display: none; }
    .navbar .logout-btn { padding: 6px 10px; font-size: 12px; }
    .container { margin: 15px auto; padding: 0 10px; }
    .welcome { padding: 20px; }
    .welcome h2 { font-size: 18px; }
    .card { padding: 20px; }
    .card-icon { font-size: 36px; }
    .card h3 { font-size: 16px; }
    .stats { padding: 20px; }
}

    </style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

    <div class="navbar">
        <h1>WorkFlowX - Admin Portal</h1>
        
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
            <a href="LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome">
            <h2>Administrator Dashboard</h2>
<p>Manage users, moderation, and system reports.</p>
        </div>
        
        <div class="dashboard-grid">

    <a href="employees.jsp" class="card card-employees">
        <div class="card-icon">👥</div>
        <h3>Manage Employees</h3>
        <p>View and control all users</p>
    </a>

    <a href="manageEmployers.jsp" class="card card-employees">
        <div class="card-icon">🏢</div>
        <h3>Manage Employers</h3>
        <p>Control employer accounts</p>
    </a>
            <a href="adminCreateEmployer.jsp" class="card card-employees">
        <div class="card-icon">➕</div>
        <h3>Create Employer</h3>
        <p>Add new employer accounts</p>
    </a>
    <a href="allMessages.jsp" class="card card-messages">
        <div class="card-icon">💬</div>
        <h3>All Messages</h3>
        <p>View all system messages</p>
    </a>

    

    <a href="globalReports.jsp" class="card card-reports">
        <div class="card-icon">📊</div>
        <h3>Global Reports</h3>
        <p>View system-wide analytics</p>
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