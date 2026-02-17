<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.*" %>
<%@ page import="com.workflowx.dao.*" %>
<%@ page import="java.util.*" %>
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
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) { response.sendRedirect("login.jsp"); return; }

UserDAO userDAO = new UserDAO();
MessageDAO messageDAO = new MessageDAO();

// Chat users
List<Integer> chatUserIds = messageDAO.getChatUserIds(currentUser.getUserId());
List<User> chatUsers = new ArrayList<>();
for (Integer id : chatUserIds) {
    User u = userDAO.getUserById(id);
    if (u != null) chatUsers.add(u);
}

// All active users for search
List<User> allEmployees = userDAO.getAllActiveUsers();

// Selected chat
String chatUserIdStr = request.getParameter("chatUserId");
User selectedUser = null;
List<Message> conversation = new ArrayList<>();
if (chatUserIdStr != null) {
    try {
        int chatUserId = Integer.parseInt(chatUserIdStr);
        selectedUser = userDAO.getUserById(chatUserId);
        conversation = messageDAO.getConversation(currentUser.getUserId(), chatUserId);
    } catch (NumberFormatException e) {}
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Chats - WorkFlowX</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: 'Segoe UI', sans-serif;
    background: linear-gradient(135deg, #667eea, #764ba2);
}

.dark-mode { background: #1e1e2f; color: #f1f1f1; }

.navbar {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 15px 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: white;
}

.dark-mode .navbar { background: linear-gradient(135deg, #232526 0%, #414345 100%); }

.navbar .dashboard-btn { 
    color: white; 
    text-decoration: none;
    padding: 8px 15px; 
    background: rgba(255,255,255,0.2);
    border-radius: 5px;
}

.mini-toggle {
    width: 60px; height: 28px; background: #ddd; border-radius: 20px;
    padding: 3px; cursor: pointer; transition: 0.3s;
}

.mini-slider {
    width: 100%; height: 100%; border-radius: 20px; position: relative;
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 6px; font-size: 12px;
}

.mini-slider::before {
    content: ""; position: absolute; width: 22px; height: 22px;
    background: #667eea; border-radius: 50%; left: 3px; transition: 0.3s;
}

.mini-slider.active::before { left: 35px; background: #2b2b3d; }
.mini-slider span { z-index: 1; }
.dark-mode .mini-toggle { background: #444; }

.main-container { display: flex; height: calc(100vh - 60px); }

.left { 
    width: 30%; 
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
    overflow-y: auto; 
    padding: 15px;
    color: white;
}

.dark-mode .left { background: linear-gradient(135deg, #232526 0%, #414345 100%); }

.right { 
    width: 70%; 
    display: flex; 
    flex-direction: column; 
    background: #f9f9fb;
}

.dark-mode .right { background: darkslateblue; }

.search-box { margin-bottom: 15px; position: relative; }

.search-box input {
    width: 100%; padding: 10px; border-radius: 8px;
    border: 1px solid rgba(255,255,255,0.3);
    background: rgba(255,255,255,0.9);
    font-size: 14px;
}

.dark-mode .search-box input {
    background: rgba(0,0,0,0.3);
    color: white;
    border-color: rgba(255,255,255,0.2);
}

.dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    margin-top: 5px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    max-height: 250px;
    overflow-y: auto;
    z-index: 1000;
}

.dark-mode .dropdown { background: #2b2b3d; color: white; }

.dropdown-item {
    padding: 12px;
    cursor: pointer;
    border-bottom: 1px solid #f0f0f0;
    color: #333;
}

.dark-mode .dropdown-item { border-bottom-color: #444; color: white; }

.dropdown-item:hover { background: #f5f5f5; }
.dark-mode .dropdown-item:hover { background: #3a3a50; }

.dropdown-item strong { display: block; margin-bottom: 3px; color: #000; }
.dark-mode .dropdown-item strong { color: white; }

.dropdown-item small { color: #666; font-size: 12px; }
.dark-mode .dropdown-item small { color: #aaa; }

.user { 
    padding: 12px; 
    border-radius: 10px; 
    margin-bottom: 8px; 
    transition: 0.3s;
}

.user:hover { background: rgba(255,255,255,0.1); }
.user a { text-decoration: none; color: white; font-weight: 500; }

.unread-dot {
    display: inline-block;
    width: 8px; height: 8px;
    background: red;
    border-radius: 50%;
    margin-right: 5px;
}

.header { 
    padding: 15px; 
    font-weight: bold; 
    background: white; 
    border-bottom: 1px solid #ddd;
}

.dark-mode .header { background: black; color: white; }

.messages { flex: 1; overflow-y: auto; padding: 20px; }
.message-row { margin: 10px 0; }
.sent { text-align: right; }
.received { text-align: left; }

.bubble { 
    display: inline-block; 
    padding: 10px 15px; 
    border-radius: 20px; 
    max-width: 60%;
}

.sent .bubble { background: #4cafef; color: white; }
.received .bubble { background: black; color:white; }
.time { font-size: 11px; opacity: 0.7; margin-top: 5px; }

.actions { font-size: 12px; margin-top: 5px; }
.actions span { cursor: pointer; margin-right: 8px; }

.send-box { 
    display: flex; 
    padding: 15px; 
    background: white; 
    border-top: 1px solid #ddd;
    align-items: center;
    gap: 10px;
}

.dark-mode .send-box { background: black; }

.send-box input[type=text] { 
    flex: 1; 
    padding: 10px; 
    border-radius: 20px; 
    border: 1px solid #ccc;
}

.send-box input[type=file] { 
    padding: 5px;
    font-size: 13px;
}

.send-box button { 
    border: none; 
    background: #667eea; 
    color: white; 
    padding: 8px 20px; 
    border-radius: 20px; 
    cursor: pointer;
    font-weight: 600;
}

.send-box button:hover { background: #5a67d8; }

.profile-pic-btn {
    width: 24px; height: 24px; border-radius: 50%;
    background: rgba(255,255,255,0.15); border: 1px solid white;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; text-decoration: none; transition: 0.3s;
    overflow: hidden; padding: 0; margin: 0;
}

.profile-pic-btn:hover { background: rgba(255,255,255,0.3); transform: scale(1.2); }
.profile-pic-btn img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
.profile-icon-svg { width: 12px; height: 12px; fill: white; }
</style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="navbar">
    <h2>💬 Chats</h2>
    <div style="display:flex; align-items:center; gap:15px;">
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
        
        <a href="<%= currentUser.isEmployer() ? "employerDashboard.jsp" : "employeeDashboard.jsp" %>" class="dashboard-btn">← Dashboard</a>
    </div>
</div>

<div class="main-container">
    <!-- LEFT SIDEBAR -->
    <div class="left">
        <h3 style="margin-bottom: 15px;">Your Chats</h3>

        <div class="search-box">
            <input type="text" id="searchInput" placeholder="🔍 Search employees..." autocomplete="off">
            <div id="searchDropdown" class="dropdown" style="display: none;"></div>
        </div>

        <% for (User u : chatUsers) { 
            boolean hasUnread = messageDAO.hasUnreadMessages(currentUser.getUserId(), u.getUserId());
        %>
            <div class="user">
                <a href="messages.jsp?chatUserId=<%= u.getUserId() %>">
                    <% if(hasUnread) { %><span class="unread-dot"></span><% } %>
                    <%= u.getFullName() %>
                </a>
            </div>
        <% } %>
    </div>

    <!-- RIGHT CONVERSATION -->
    <div class="right">
        <% if (selectedUser == null) { %>
            <div style="padding:30px; text-align:center; color:#999;">
                <h2>💬</h2>
                <p>Select a chat to start messaging</p>
            </div>
        <% } else { %>
            <div class="header">Chat with <%= selectedUser.getFullName() %></div>

            <div class="messages" id="messages">
                <% for (Message msg : conversation) { %>
                    <div class="message-row <%= (msg.getSenderId()==currentUser.getUserId())?"sent":"received" %>">
                        <div class="bubble">
                            <% if(msg.getReceiverId() == currentUser.getUserId() && !msg.isRead()) { %>
                                <span class="unread-dot"></span>
                            <% } %>

                            <div id="text-<%=msg.getMessageId()%>">
                                <%= msg.getMessageContent()!=null ? msg.getMessageContent() : "" %>
                                <% if(msg.getAttachmentPath()!=null && !msg.getAttachmentPath().isEmpty()) { %>
                                    <br><a href="<%=msg.getAttachmentPath()%>" target="_blank" style="color: inherit;">📎 Attachment</a>
                                <% } %>
                            </div>

                            <div id="edit-<%=msg.getMessageId()%>" style="display:none;">
                                <input type="text" id="editInput-<%=msg.getMessageId()%>" value="<%=msg.getMessageContent()%>" style="width:70%; padding:5px; border-radius:5px;">
                                <button onclick="saveEdit(<%=msg.getMessageId()%>)">Save</button>
                                <button onclick="cancelEdit(<%=msg.getMessageId()%>)">Cancel</button>
                            </div>

                            <% if(msg.getSenderId()==currentUser.getUserId()){ %>
                                <div class="actions">
                                    <span style="color:blue;" onclick="showEdit(<%=msg.getMessageId()%>)">✏ Edit</span>
                                    <span style="color:red;" onclick="deleteMessage(<%=msg.getMessageId()%>)">❌ Delete</span>
                                </div>
                            <% } %>
                        </div>
                        <div class="time"><%= msg.getSentAt() %></div>
                    </div>
                <% } %>
            </div>

            <form id="sendForm" class="send-box" enctype="multipart/form-data" onsubmit="return sendMessage();">
                <input type="hidden" name="receiverId" value="<%= selectedUser.getUserId() %>">
                <input type="text" name="messageText" placeholder="Type a message...">
                <input type="file" name="attachment">
                <button type="submit">Send</button>
            </form>
        <% } %>
    </div>
</div>

<script>
// Scroll to bottom
const messagesDiv = document.getElementById("messages");
if (messagesDiv) messagesDiv.scrollTop = messagesDiv.scrollHeight;

// Send message (text OR file)
function sendMessage(){
    const form = document.getElementById("sendForm");
    const formData = new FormData(form);
    
    // Allow sending if either message OR file is present
    if(!formData.get("messageText").trim() && !formData.get("attachment").name) {
        alert('Please type a message or attach a file');
        return false;
    }

    fetch("SendMessageServlet", { method:'POST', body:formData })
        .then(() => location.reload());
    return false;
}

// Edit/Delete functions
function showEdit(id){ 
    document.getElementById("text-"+id).style.display="none"; 
    document.getElementById("edit-"+id).style.display="block"; 
}

function cancelEdit(id){ 
    document.getElementById("text-"+id).style.display="block"; 
    document.getElementById("edit-"+id).style.display="none"; 
}

function saveEdit(id){
    var newText = document.getElementById("editInput-" + id).value;
    fetch('EditMessageServlet', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: "messageId=" + id + "&newContent=" + encodeURIComponent(newText)
    }).then(() => location.reload());
}

function deleteMessage(id){
    if(confirm("Delete this message?")){
        fetch('DeleteMessageServlet', {
            method:'POST',
            headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:`messageId=${id}`
        }).then(() => location.reload());
    }
}

// Mark as read
<% if (selectedUser != null) { %>
fetch('MarkAsReadServlet', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'senderId=<%= selectedUser.getUserId() %>'
}).then(() => {
    const chatLink = document.querySelector(`.user a[href*="chatUserId=<%= selectedUser.getUserId() %>"]`);
    if (chatLink) {
        const dot = chatLink.querySelector('.unread-dot');
        if (dot) dot.remove();
    }
    document.querySelectorAll('.message-row.received .unread-dot').forEach(dot => dot.remove());
});
<% } %>

// SEARCH FUNCTIONALITY
console.log('Loading users...');

const users = [
    <% for (int i = 0; i < allEmployees.size(); i++) { User emp = allEmployees.get(i); %>
    {id: <%= emp.getUserId() %>, name: "<%= emp.getFullName() %>", dept: "<%= emp.getDepartment() != null ? emp.getDepartment() : "" %>", role: "<%= emp.getRole() %>"}<%= i < allEmployees.size()-1 ? "," : "" %>
    <% } %>
];

console.log('Users loaded:', users.length);
console.log('Users:', users);

const searchInput = document.getElementById('searchInput');
const dropdown = document.getElementById('searchDropdown');

console.log('Search input:', searchInput);
console.log('Dropdown:', dropdown);

searchInput.addEventListener('input', function() {
    const query = this.value.trim().toLowerCase();
    
    console.log('Search query:', query);
    
    if (!query) {
        dropdown.style.display = 'none';
        return;
    }
    
    const matches = users.filter(u => 
        u.name.toLowerCase().includes(query) || 
        u.dept.toLowerCase().includes(query)
    );
    
    console.log('Matches found:', matches.length);
    console.log('Matches:', matches);
    
    if (matches.length === 0) {
        dropdown.innerHTML = '<div style="padding:12px; color:#333; background:white;">No results found</div>';
    } else {
        dropdown.innerHTML = matches.map(u => 
            '<div style="padding:12px; cursor:pointer; background:white; color:#333; border-bottom:1px solid #ddd;" onclick="openChat(' + u.id + ')">' +
                '<strong style="display:block; color:#000; font-size:14px;">' + u.name + '</strong>' +
                '<small style="color:#666; font-size:12px;">' + u.dept + ' • ' + u.role + '</small>' +
            '</div>'
        ).join('');
    }
    
    dropdown.style.display = 'block';
    console.log('Dropdown HTML:', dropdown.innerHTML);
});

// Close dropdown when clicking outside
document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) {
        dropdown.style.display = 'none';
    }
});

function openChat(userId) {
    console.log('Opening chat:', userId);
    window.location.href = 'messages.jsp?chatUserId=' + userId;
}
</script>

</body>
</html>
