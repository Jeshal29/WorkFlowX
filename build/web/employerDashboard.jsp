<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%@ include file="/common/employerOnly.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employer Dashboard - WorkFlowX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/chatbot.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
    font-family: 'Segoe UI', sans-serif;
    background: #f4f6f9;
    color: #333;
    transition: all 0.3s ease;
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
        <div id="chatbot-widget">
    <div id="chat-button" style="cursor: pointer; font-size: 28px; display: flex; align-items: center; justify-content: center;">
        🤖
        <div id="unread-badge" style="display: none;">1</div>
    </div>

    <div id="chat-window" style="display: none;">
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

        <div id="chat-messages">
            <div class="bot-message">
                <div class="message-bubble bot">
                    👋 Hi! I'm your WorkFlowX assistant. How can I help you today?
                    <div class="message-time">Just now</div>
                </div>
            </div>
            <div class="quick-suggestions" id="main-menu"></div>
        </div>

        <div id="chat-input-area"></div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const options = menuOptions[userRole] || menuOptions['EMPLOYEE'];
        const menu = document.getElementById('main-menu');
        options.forEach(function(option) {
            const btn = document.createElement('div');
            btn.className = 'suggestion';
            btn.textContent = option.label;
            btn.onclick = function() { handleSelection(option); };
            menu.appendChild(btn);
        });
    });
</script>
<script>
const userRole = '${sessionScope.user.role}';

const menuOptions = {
    EMPLOYEE: [
        { label: '📨 Send a Message',   answer: 'Go to the Messages section, select a recipient from the list, type your message in the text box, and click the Send button.' },
        { label: '🏖️ Apply for Leave',  answer: 'Go to the Leave section, click Apply Leave, select the leave type, enter start and end dates, provide a reason, and submit the application.' },
        { label: '✅ View My Tasks',     answer: 'Go to the Tasks section to see all tasks assigned to you. You can filter by status — Pending, In Progress, or Completed — and update the status of each task.' },
        { label: '📝 View My Notes',    answer: 'Go to the Notes section to see all your personal notes. You can create new notes, edit existing ones, and delete notes you no longer need.' }
    ],
    EMPLOYER: [
        { label: '📋 Assign a Task',        answer: 'Go to the Tasks section and click Assign Task. Select the employee, enter a title, description, priority level, deadline, and optionally attach a file. Then click Submit.' },
        { label: '👥 Check Employee Details', answer: 'Go to the Employees section to view a list of all employees in your department along with their details such as name, email, and current status.' },
        { label: '🏖️ Check Leave Requests',  answer: 'Go to the Leave section to see all pending leave requests from your department. You can approve or reject each request and add remarks.' },
        { label: '📊 View Reports',          answer: 'Go to the Reports section to view your department\'s activity — including task completion rates, leave statistics, and communication violation summaries.' }
    ]
};

function toggleChat() {
    const chatWindow = document.getElementById('chat-window');
    const chatButton = document.getElementById('chat-button');
    const unreadBadge = document.getElementById('unread-badge');

    if (chatWindow.style.display === 'none') {
        chatWindow.style.display = 'flex';
        chatButton.style.display = 'none';
        unreadBadge.style.display = 'none';
    } else {
        chatWindow.style.display = 'none';
        chatButton.style.display = 'flex';
    }
}

function showMenu() {
    const messagesContainer = document.getElementById('chat-messages');

    const botMsg = document.createElement('div');
    botMsg.className = 'bot-message';
    botMsg.innerHTML = '<div class="message-bubble bot">How can I help you today?<div class="message-time">Just now</div></div>';
    messagesContainer.appendChild(botMsg);

    const suggestionsDiv = document.createElement('div');
    suggestionsDiv.className = 'quick-suggestions';
    suggestionsDiv.id = 'main-menu';

    const options = menuOptions[userRole] || menuOptions['EMPLOYEE'];
    options.forEach(function(option) {
        const btn = document.createElement('div');
        btn.className = 'suggestion';
        btn.textContent = option.label;
        btn.onclick = function() { handleSelection(option); };
        suggestionsDiv.appendChild(btn);
    });

    messagesContainer.appendChild(suggestionsDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

function handleSelection(option) {
    const messagesContainer = document.getElementById('chat-messages');

    // Remove menu
    const menu = document.getElementById('main-menu');
    if (menu) menu.remove();

    // Show user selection as bubble
    const userMsg = document.createElement('div');
    userMsg.className = 'user-message';
    const now = new Date();
    const timeStr = now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');
    userMsg.innerHTML = '<div class="message-bubble user">' + option.label + '<div class="message-time">' + timeStr + '</div></div>';
    messagesContainer.appendChild(userMsg);

    // Show typing indicator
    const typingDiv = document.createElement('div');
    typingDiv.className = 'bot-message';
    typingDiv.id = 'typing-indicator';
    typingDiv.innerHTML = '<div class="typing-indicator"><span></span><span></span><span></span></div>';
    messagesContainer.appendChild(typingDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;

    // Show answer after short delay
    setTimeout(function() {
        const typing = document.getElementById('typing-indicator');
        if (typing) typing.remove();

        const botMsg = document.createElement('div');
        botMsg.className = 'bot-message';
        botMsg.innerHTML = '<div class="message-bubble bot">' + option.answer + '<div class="message-time">' + timeStr + '</div></div>';
        messagesContainer.appendChild(botMsg);

        // Show Back to Menu button
        const backDiv = document.createElement('div');
        backDiv.className = 'quick-suggestions';
        const backBtn = document.createElement('div');
        backBtn.className = 'suggestion';
        backBtn.textContent = '⬅️ Back to Menu';
        backBtn.onclick = function() {
            backDiv.remove();
            showMenu();
        };
        backDiv.appendChild(backBtn);
        messagesContainer.appendChild(backDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }, 800);
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