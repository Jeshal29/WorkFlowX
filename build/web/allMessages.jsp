<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.workflowx.model.User, com.workflowx.dao.ReportDAO, java.util.*, java.text.SimpleDateFormat, java.sql.Timestamp, java.util.Calendar" %>

<%
User currentUser = (User) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
String role = currentUser.getRole();
String primaryColor = role.equals("ADMIN") ? "#f5576c" : "#667eea";
// Only Admin can access full messages, Employer can access department messages
if (!currentUser.isAdmin() && !currentUser.isEmployer()) {
    response.sendRedirect("employeeDashboard.jsp");
    return;
}
String theme = "LIGHT";
if (currentUser.getThemePreference() != null) {
    theme = currentUser.getThemePreference();
}

ReportDAO dao = new ReportDAO();
String source = request.getParameter("source");
// Month & Year filter for Admin
Calendar cal = Calendar.getInstance();
String yearParam = request.getParameter("year");
String monthParam = request.getParameter("month");

int selectedYear = yearParam != null ? Integer.parseInt(yearParam) : cal.get(Calendar.YEAR);
int selectedMonth = monthParam != null ? Integer.parseInt(monthParam) : cal.get(Calendar.MONTH) + 1;

String[] monthNames = {"January","February","March","April","May","June",
                       "July","August","September","October","November","December"};

// Messages and violations
List<Map<String,Object>> employerMessages = currentUser.isAdmin() ? dao.getMessagesBySenderRole("EMPLOYER")
                                                                  : dao.getMessagesBySenderRoleByDepartment("EMPLOYER", currentUser.getDepartment());
List<Map<String,Object>> employeeMessages = currentUser.isAdmin() ? dao.getMessagesBySenderRole("EMPLOYEE")
                                                                  : dao.getMessagesBySenderRoleByDepartment("EMPLOYEE", currentUser.getDepartment());

List<Map<String,Object>> censoredMessages = currentUser.isAdmin()
        ? (yearParam != null && monthParam != null ? dao.getCensoredMessagesByMonth(selectedYear, selectedMonth)
                                                   : dao.getCensoredMessages())
        : dao.getCensoredMessagesByDepartment(currentUser.getDepartment());

List<Map<String,Object>> topViolators = currentUser.isAdmin() ? dao.getTopViolators()
                                                              : dao.getTopViolatorsByDepartment(currentUser.getDepartment());

Map<String,Integer> stats = dao.getBadWordStats();
SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
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
<title>WorkFlowX Admin / Employer Messages & Violations</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
body {
    margin:0;
    font-family:Segoe UI;
    background:#f5f5f5;
    color:#333;
}



.navbar{padding:20px 30px;
    background:linear-gradient(135deg,#f093fb,#f5576c);
    display:flex;
    justify-content:space-between;
    align-items:center;
    color:white;
}


.navbar .dashboard-btn { color:white; text-decoration:none; padding:8px 15px; background:rgba(255,255,255,0.2); border-radius:5px; margin-left:10px; }
.container { max-width:1400px; margin:30px auto; padding:0 20px; }
.section { background:white; padding:25px; border-radius:10px; margin-bottom:30px; box-shadow:0 2px 5px rgba(0,0,0,0.1); }
.section h2 { margin-bottom:20px; border-bottom:2px solid #f0f0f0; padding-bottom:10px; }
.message-card, .violation-card { border:1px solid #e0e0e0; border-radius:8px; padding:15px; margin-bottom:15px; background:#fafafa; }
.message-header, .violation-card .header { display:flex; justify-content:space-between; margin-bottom:10px; }
.sender { font-weight:600; }
.date { font-size:13px; color:#666; }
.no-data { text-align:center; padding:20px; color:#999; }
button.toggle-btn { padding:10px 20px; border:none; border-radius:5px; margin-right:10px; cursor:pointer; font-weight:600; background:#667eea; color:white; }
button.toggle-btn.active { background:#764ba2; }
input.search { width:100%; padding:10px; border:1px solid #ddd; border-radius:5px; margin-bottom:20px; }
.stats-row { display:flex; gap:20px; margin-bottom:30px; }
.stat-card { background:white; padding:25px; border-radius:10px; box-shadow:0 2px 5px rgba(0,0,0,0.1); border-left:4px solid #ff6b6b; }
.stat-card h3 { font-size:14px; color:#666; margin-bottom:10px; text-transform:uppercase; }
.stat-card .number { font-size:36px; font-weight:700; color:#ff6b6b; }
.violation-card .content, .violation-card .original { background:#fff5f5; padding:10px; border-radius:5px; border-left:4px solid #ff6b6b; margin-bottom:10px; }
/* GENERAL BACKGROUND & TEXT */
.dark-mode {
    background:#0f172a;
    color:#f0f0f0;
}

/* NAVBAR */
.dark-mode .navbar {
    background:#111827 !important;
    color:white;
}
.dark-mode .navbar a {
    color:white !important;
    background:rgba(255,255,255,0.1);
}

/* CONTAINERS AND SECTIONS */
.dark-mode .section {
    background:#1e293b;
    color:white;
    box-shadow:0 2px 5px rgba(0,0,0,0.5);
}

/* MESSAGE / VIOLATION CARDS */
.dark-mode .message-card,
.dark-mode .violation-card {
    background:#1e293b;
    border:1px solid #334155;
    color:white;
}
.dark-mode .violation-card .content,
.dark-mode .violation-card .original {
    background:#2c3e50;
    border-left:4px solid #ff6b6b;
    color:#f0f0f0;
}

/* STAT CARDS */
.dark-mode .stat-card {
    background:#1e293b;
    border-left:4px solid #ff6b6b;
    color:white;
}

/* SEARCH INPUTS */
.dark-mode input.search {
    background:#334155;
    color:white;
    border:1px solid #555;
}

/* BUTTONS */
.dark-mode button.toggle-btn {
    background:#4f46e5;
    color:white;
}
.dark-mode button.toggle-btn.active {
    background:#6366f1;
}



.mini-toggle {
    width:60px;
    height:28px;
    background:#ddd;
    border-radius:20px;
    padding:3px;
    cursor:pointer;
}

.mini-slider {
    width:100%;
    height:100%;
    border-radius:20px;
    position:relative;
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 6px;
    font-size:12px;
}

.mini-slider::before {
    content:"";
    position:absolute;
    width:22px;
    height:22px;
    background:<%= primaryColor %>;
    border-radius:50%;
    left:3px;
    transition:all 0.3s ease;
}

.mini-slider.active::before {
    left:35px;
    background:#2b2b3d;
}

.mini-slider span { z-index:1; }

.dark-mode .mini-toggle {
    background:#444;
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
    <h2>📂 WorkFlowX Messages & Violations</h2>
    <div style="display:flex; align-items:center; gap:15px;">

        <!-- Theme Toggle -->
        <form action="ThemeServlet" method="post">
            <div class="mini-toggle" onclick="this.closest('form').submit();">
                <div class="mini-slider <%= theme.equals("DARK") ? "active" : "" %>">
                    <span>☀</span>
                    <span>🌙</span>
                </div>
            </div>
            <input type="hidden" name="currentTheme" value="<%= theme %>">
            <input type="hidden" name="redirectPage" value="globalReports.jsp">
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

        <% if ("globalReports".equals(source)) { %>
    <a href="globalReports.jsp" class="dashboard-btn">
        ← Back
    </a>
<% } %>

          <% if ("globalReports".equals(source)) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
         <% } else { %>
          <a href="adminDashboard.jsp" class="dashboard-btn">← Back to Dashboard</a>
          <% } %>
    </div>
</div>

<div class="container">

<!-- Stats -->
<div class="stats-row">
    <div class="stat-card">
        <h3>Total Violations</h3>
        <div class="number"><%= stats.getOrDefault("totalCensored",0) %></div>
    </div>
    <div class="stat-card">
        <h3>Users with Violations</h3>
        <div class="number"><%= stats.getOrDefault("usersWithViolations",0) %></div>
    </div>
</div>

<!-- Toggle Buttons -->
<div style="margin-bottom:20px;">
    <button class="toggle-btn active" onclick="showSection('employer')">👨‍💼 Employer Messages (<%= employerMessages.size() %>)</button>
    <button class="toggle-btn" onclick="showSection('employee')">👩‍💻 Employee Messages (<%= employeeMessages.size() %>)</button>
    <button class="toggle-btn" onclick="showSection('censored')">⚠️ Filtered Messages (<%= censoredMessages.size() %>)</button>
</div>

<!-- EMPLOYER MESSAGES -->
<div id="employer" class="section">
    <% if (employerMessages.isEmpty()) { %>
        <div class="no-data">No employer messages found</div>
    <% } else { %>
        <input type="text" class="search" placeholder="🔍 Search employer messages..." onkeyup="filterMessages('employer')">
        <% for (Map<String,Object> msg : employerMessages) { %>
            <div class="message-card" data-sender="<%= msg.get("senderName").toString().toLowerCase() %>"
                 data-receiver="<%= msg.get("receiverName").toString().toLowerCase() %>"
                 data-content="<%= msg.get("messageContent").toString().toLowerCase() %>">
                <div class="message-header">
                    <div class="sender"><%= msg.get("senderName") %> → <%= msg.get("receiverName") %></div>
                    <div class="date"><%= sdf.format((Timestamp)msg.get("sentAt")) %></div>
                </div>
                <% if (msg.get("subject") != null) { %>
                    <div><strong>Subject:</strong> <%= msg.get("subject") %></div>
                <% } %>

                <div style="margin-top:10px;"><%= msg.get("messageContent") %></div>

                <% if (msg.get("attachmentPath") != null && 
       !msg.get("attachmentPath").toString().isEmpty()) { %>
    <div style="margin-top:8px;">
        <a href="<%= request.getContextPath() %>/uploads/attachments/<%= msg.get("attachmentPath") %>" 
           target="_blank">
            📎 View Attachment
        </a>
    </div>
<% } %>

            </div>
        <% } %>
    <% } %>
</div>

<!-- EMPLOYEE MESSAGES -->
<div id="employee" class="section" style="display:none;">
    <% if (employeeMessages.isEmpty()) { %>
        <div class="no-data">No employee messages found</div>
    <% } else { %>
        <input type="text" class="search" placeholder="🔍 Search employee messages..." onkeyup="filterMessages('employee')">
        <% for (Map<String,Object> msg : employeeMessages) { %>
            <div class="message-card" data-sender="<%= msg.get("senderName").toString().toLowerCase() %>"
                 data-receiver="<%= msg.get("receiverName").toString().toLowerCase() %>"
                 data-content="<%= msg.get("messageContent").toString().toLowerCase() %>">
                <div class="message-header">
                    <div class="sender"><%= msg.get("senderName") %> → <%= msg.get("receiverName") %></div>
                    <div class="date"><%= sdf.format((Timestamp)msg.get("sentAt")) %></div>
                </div>
                <% if (msg.get("subject") != null) { %>
                    <div><strong>Subject:</strong> <%= msg.get("subject") %></div>
                <% } %>

                <div style="margin-top:10px;"><%= msg.get("messageContent") %></div>

                <% if (msg.get("attachmentPath") != null && 
       !msg.get("attachmentPath").toString().isEmpty()) { %>
    <div style="margin-top:8px;">
        <a href="<%= request.getContextPath() %>/uploads/attachments/<%= msg.get("attachmentPath") %>" 
           target="_blank">
            📎 View Attachment
        </a>
    </div>
<% } %>

            </div>
        <% } %>
    <% } %>
</div>


<!-- CENSORED MESSAGES -->
<div id="censored" class="section" style="display:none;">
    <% if (censoredMessages.isEmpty()) { %>
        <div class="no-data">No filtered messages</div>
    <% } else { %>

        <input type="text" class="search" placeholder="🔍 Search filtered messages..." onkeyup="filterMessages('censored')">

        <%
            Set<Integer> shownMessageIds = new HashSet<>();
            for (Map<String,Object> msg : censoredMessages) {

                Integer msgId = (Integer) msg.get("messageId");
                if (msgId == null || shownMessageIds.contains(msgId)) {
                    continue;   // Skip duplicate
                }
                shownMessageIds.add(msgId);
        %>

            <div class="violation-card"
                 data-sender="<%= msg.get("senderName").toString().toLowerCase() %>"
                 data-receiver="<%= msg.get("receiverName").toString().toLowerCase() %>"
                 data-content="<%= msg.get("messageContent").toString().toLowerCase() %>">

                <div class="header">
                    <div class="sender">
                        From:
                        <a href="reportUserDetail.jsp?userId=<%= msg.get("senderId") %>" class="user-link">
                            <%= msg.get("senderName") %>
                        </a>
                        → <%= msg.get("receiverName") %>
                    </div>
                    <div class="date">
                        <%= sdf.format((Timestamp)msg.get("sentAt")) %>
                    </div>
                </div>

                <% if (msg.get("subject") != null) { %>
                    <div class="subject">Subject: <%= msg.get("subject") %></div>
                <% } %>

                <div class="label">Filtered Content:</div>
                <div class="content"><%= msg.get("messageContent") %></div>

                <div class="label">Original Content:</div>
                <div class="original"><%= msg.get("originalContent") %></div>

            </div>

        <% } %>
    <% } %>
</div>


</div>

<script>
function showSection(sectionId) {
    document.querySelectorAll('.section').forEach(s => s.style.display='none');
    document.getElementById(sectionId).style.display='block';
    
    document.querySelectorAll('.toggle-btn').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
}

function filterMessages(sectionId) {
    const container = document.getElementById(sectionId);
    const input = container.querySelector('.search');
    const filter = input.value.toLowerCase();
    container.querySelectorAll('.message-card, .violation-card').forEach(card => {
        const sender = card.getAttribute('data-sender');
        const receiver = card.getAttribute('data-receiver');
        const content = card.getAttribute('data-content');
        card.style.display = (sender.includes(filter) || receiver.includes(filter) || content.includes(filter)) ? 'block' : 'none';
    });
}
</script>
</body>
</html>
