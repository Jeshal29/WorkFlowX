<%@page import="java.util.Calendar"%>
<%@page import="java.sql.Timestamp  "%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.workflowx.dao.ReportDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%
    String userIdParam = request.getParameter("userId"); // get userId from URL
    List<Map<String, Object>> censoredMessages;
List<Map<String, Object>> topViolators;
     ReportDAO dao = new ReportDAO();
     int selectedYear = -1;
    int selectedMonth = -1;

    String yearParam = request.getParameter("year");
    String monthParam = request.getParameter("month");

    if (yearParam != null && monthParam != null) {
        try {
            selectedYear = Integer.parseInt(yearParam);
            selectedMonth = Integer.parseInt(monthParam);
        } catch (NumberFormatException e) {
            selectedYear = -1;
            selectedMonth = -1;
        }
    }
      boolean isAdmin = user.isAdmin();
    // Check access - only EMPLOYER and ADMIN can view
    if (user.isAdmin()) {

    if (userIdParam != null && !userIdParam.isEmpty()) {

        if (selectedYear != -1 && selectedMonth != -1) {
            censoredMessages = dao.getCensoredMessagesByUserAndMonth(
                    Integer.parseInt(userIdParam), selectedYear, selectedMonth);
        } else {
            censoredMessages = dao.getCensoredMessagesByUser(
                    Integer.parseInt(userIdParam));
        }

        Map<String, Object> singleViolator =
                dao.getViolatorByUserId(Integer.parseInt(userIdParam));

        topViolators = new ArrayList<>();
        if (singleViolator != null) topViolators.add(singleViolator);

    } else {

        if (selectedYear != -1 && selectedMonth != -1) {
            censoredMessages = dao.getCensoredMessagesByMonth(
                    selectedYear, selectedMonth);
        } else {
            censoredMessages = dao.getCensoredMessages();
        }

        topViolators = dao.getTopViolators();
    }

} else { // EMPLOYER

    if (userIdParam != null && !userIdParam.isEmpty()) {

        if (selectedYear != -1 && selectedMonth != -1) {
            censoredMessages = dao.getCensoredMessagesByUserDeptAndMonth(
                    Integer.parseInt(userIdParam),
                    user.getDepartment(),
                    selectedYear,
                    selectedMonth);
        } else {
            censoredMessages = dao.getCensoredMessagesByUserAndDepartment(
                    Integer.parseInt(userIdParam),
                    user.getDepartment());
        }

        Map<String, Object> singleViolator =
                dao.getViolatorByUserIdAndDept(
                        Integer.parseInt(userIdParam),
                        user.getDepartment());

        topViolators = new ArrayList<>();
        if (singleViolator != null) topViolators.add(singleViolator);

    } else {

        if (selectedYear != -1 && selectedMonth != -1) {
            censoredMessages = dao.getCensoredMessagesByDeptAndMonth(
                    user.getDepartment(),
                    selectedYear,
                    selectedMonth);
        } else {
            censoredMessages = dao.getCensoredMessagesByDepartment(
                    user.getDepartment());
        }

        topViolators = dao.getTopViolatorsByDepartment(
                user.getDepartment());
    }
}
if (yearParam != null && monthParam != null) {
    try {
        selectedYear = Integer.parseInt(yearParam);
        selectedMonth = Integer.parseInt(monthParam);
    } catch (Exception e) {
        selectedYear = -1;
        selectedMonth = -1;
    }
}

// Month names
String[] monthNames = {
    "January", "February", "March", "April",
    "May", "June", "July", "August",
    "September", "October", "November", "December"
};

// Date formatter
SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

   Map<String, Integer> stats;
    if (user.isAdmin()) {
        stats = dao.getBadWordStats();
    } else {
        stats = dao.getBadWordStatsByDepartment(user.getDepartment());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Content Violations - WorkFlowX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
    <style>
      * {
    margin:0;
    padding:0;
    box-sizing:border-box;
}

body {
    font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background:#f5f5f5;
    color:#333;
    transition: all 0.3s ease;
}

/* ================= NAVBAR ================= */
.navbar {
     background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    color:white;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

.navbar .dashboard-btn {
    color:white;
    text-decoration:none;
    padding:8px 15px;
    background:rgba(255,255,255,0.2);
    border-radius:5px;
    margin-left:10px;
}

/* ================= LAYOUT ================= */
.container {
    max-width:1400px;
    margin:30px auto;
    padding:0 20px;
}

.page-header,
.section,
.stat-card {
    background:white;
    border-radius:10px;
    padding:30px;
    margin-bottom:20px;
    box-shadow:0 2px 5px rgba(0,0,0,0.1);
}

/* ================= STAT CARD ================= */
.stat-card {
    border-left:4px solid #667eea;
}

.stat-card .number {
    font-size:36px;
    font-weight:700;
    color: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
}

/* ================= VIOLATOR ROW ================= */
.violator-row {
    display:flex;
    justify-content:space-between;
    align-items:center;
    padding:15px 0;
    border-bottom:1px solid #f0f0f0;
}

.violator-row:hover {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
}

.violator-name {
    font-weight:600;
    
}

.violator-dept {
    font-size:13px;
    color:#666;
}

.violation-count {
    background: #f3e5f5;
    color: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    padding:5px 15px;
    border-radius:15px;
    font-weight:600;
}

.user-link {
    color: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    text-decoration:none;
    font-weight:600;
}

.user-link:hover {
    text-decoration:underline;
}

/* ================= VIOLATION CARD ================= */
.violation-card {
    border:1px solid #eef2ff;
    background:#f8f9ff;
    padding:20px;
    border-radius:8px;
    margin-bottom:15px;
}

.violation-card .header {
    display:flex;
    justify-content:space-between;
    margin-bottom:15px;
}

.violation-card .content {
    background:white;
    padding:15px;
    border-left:4px solid #667eea;
    border-radius:5px;
    margin-bottom:10px;
}

.violation-card .original {
    border:1px dashed #667eea;
    padding:10px;
    border-radius:5px;
    font-size:13px;
    color:#666;
}

.label {
    font-size:12px;
    font-weight:600;
   color: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    margin-bottom:5px;
}

.no-data {
    text-align:center;
    padding:40px;
    color:#999;
}
/* ================= DARK MODE ================= */
body.dark-mode {
    background:#1e1e2f;
    color:#f1f1f1;
}

.dark-mode .navbar {
    background:#1e1e2f;
}

.dark-mode .page-header,
.dark-mode .section,
.dark-mode .stat-card {
    background:#252538;
    color:#f1f1f1;
}

.dark-mode .violator-row {
    border-bottom:1px solid #3a3a50;
}

.dark-mode .violator-row:hover {
    background:#303048;
}

.dark-mode .violator-dept {
    color:#bbbbbb;
}

.dark-mode .violation-card {
    background:#2b2b3d;
    border-color:#3a3a50;
}

.dark-mode .violation-card .content {
    background:#353552;
}

.dark-mode .violation-card .original {
    border-color:#667eea;
    color:#cccccc;
}

.dark-mode .violation-count {
    background:#353552;
    color:#8fa8ff;
}

.dark-mode .user-link {
    color:#8fa8ff;
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
.role-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-left: 6px;
}
.role-employer {
    background: #fff3e0;
    color: #e65100;
}
.role-employee {
    background: #e3f2fd;
    color: #1565c0;
}
</style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

    <div class="navbar">
        <h2>⚠️ Content Violations</h2>
         <div style="display:flex; align-items:center; gap:15px;">
        <form action="ThemeServlet" method="post">
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

           <%
String backHref = "reports.jsp"; // default

if ("globalReports".equals(request.getParameter("source"))) {
    backHref = "globalReports.jsp";
} else if ("reports".equals(request.getParameter("source"))) {
    backHref = "reports.jsp";
}
%>

<a href="<%= backHref %>" class="dashboard-btn">← Back</a>


    <!-- Dashboard Button -->
    <% if (user.isAdmin()) { %>
        <a href="adminDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } else { %>
        <a href="employerDashboard.jsp" class="dashboard-btn">Dashboard</a>
    <% } %>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h1>Bad Word Filter Reports</h1>
            <p>Messages that contain inappropriate content and have been automatically filtered</p>
            
            <!-- Month/Year Selector -->
            <div style="margin-top: 20px; display: flex; gap: 10px; align-items: center;">
                <label style="font-weight: 600;">Filter by:</label>
                <select id="monthSelect" style="padding: 8px; border-radius: 5px; border: 1px solid #ddd;">
                    <option value="">All Time</option>
                    <% 
                    Calendar current = Calendar.getInstance();
                    for (int i = 0; i < 12; i++) {
                        int year = current.get(Calendar.YEAR);
                        int month = current.get(Calendar.MONTH) + 1;
                        String selected = (year == selectedYear && month == selectedMonth) ? "selected" : "";
                    %>
                        <option value="<%= year %>-<%= month %>" <%= selected %>>
                            <%= monthNames[current.get(Calendar.MONTH)] %> <%= year %>
                        </option>
                    <%
                        current.add(Calendar.MONTH, -1);
                    }
                    %>
                </select>
                <button onclick="applyFilter()" style="padding: 8px 20px; background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: 600;">Apply</button>
                <% if (yearParam != null) { %>
                    <a href="reportBadWords.jsp" style="padding: 8px 20px; background: #999; color: white; text-decoration: none; border-radius: 5px; font-weight: 600;">Clear Filter</a>
                <% } %>
            </div>
        </div>
        
        <div class="stats-row">
            <div class="stat-card">
                <h3>Total Violations</h3>
                <div class="number"><%= stats.getOrDefault("totalCensored", 0) %></div>
            </div>
            
            <div class="stat-card">
                <h3>Users with Violations</h3>
                <div class="number"><%= stats.getOrDefault("usersWithViolations", 0) %></div>
            </div>
        </div>
        
        <!-- Top Violators -->
        <div class="section">
            <h2>Top Violators</h2>
            <% if (topViolators.isEmpty()) { %>
                <div class="no-data">No violations found</div>
            <% } else { %>
                <!-- Search Bar -->
                <div style="margin-bottom: 20px;">
                    <input type="text" id="searchInput" placeholder="🔍 Search by name or department..." 
                           style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;"
                           onkeyup="filterViolators()">
                </div>
                
                <div id="violatorsList">
                <% for (Map<String, Object> violator : topViolators) { %>
                    <div class="violator-row" data-name="<%= violator.get("fullName").toString().toLowerCase() %>" 
                         data-dept="<%= violator.get("department").toString().toLowerCase() %>">
                        <div class="violator-info">
                            <div>
                                 <a href="reportUserDetail.jsp?userId=<%= violator.get("userId") %>" class="user-link">
        <div class="violator-name">
            <%= violator.get("fullName") %>
            <% if (isAdmin && violator.get("role") != null) { %>
                <span class="role-badge role-<%= violator.get("role").toString().toLowerCase() %>">
                    <%= violator.get("role") %>
                </span>
            <% } %>
        </div>
    </a>
                                <div class="violator-dept"><%= violator.get("department") %></div>
                            </div>
                        </div>
                        <div class="violation-count"><%= violator.get("violationCount") %> violations</div>
                    </div>
                <% } %>
                </div>
            <% } %>
        </div>
        
        <!-- Censored Messages -->
        <div class="section">
            <h2>Filtered Messages (<%= censoredMessages.size() %>)</h2>
            
            <!-- Search Bar for Messages -->
            <div style="margin-bottom: 20px;">
                <input type="text" id="searchMessagesInput" placeholder="🔍 Search by sender, receiver, or content..." 
                       style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px;"
                       onkeyup="filterMessages()">
            </div>
           <% if (censoredMessages.isEmpty()) { %>
    <div class="no-data">No filtered messages</div>
<% } else { %>
    <div id="messagesList">  <!-- ✅ Add this wrapper -->
        <% for (Map<String,Object> msg : censoredMessages) { %>
        <div class="violation-card"
             data-sender="<%= msg.get("senderName").toString().toLowerCase() %>"
             data-receiver="<%= msg.get("receiverName").toString().toLowerCase() %>"
             data-content="<%= msg.get("messageContent").toString().toLowerCase() %>">
            <div class="header">
                <div class="sender">
                    From: <%= msg.get("senderName") %> → <%= msg.get("receiverName") %>
                </div>
                <div class="date"><%= sdf.format((Timestamp)msg.get("sentAt")) %></div>
            </div>
            <div class="label">Filtered Content:</div>
            <div class="content"><%= msg.get("messageContent") %></div>
            <div class="label">Original Content (Before Filtering):</div>
            <div class="original">
    <%= msg.get("originalContent") != null ? msg.get("originalContent") : "N/A" %>
</div>
        </div>
        <% } %>
    </div>  <!-- ✅ Closes messagesList -->
<% } %>
        </div>
    </div>
    
    <script>
    function applyFilter() {
        const select = document.getElementById('monthSelect');
        const value = select.value;
        
        if (value === '') {
            window.location.href = 'reportBadWords.jsp';
        } else {
            const parts = value.split('-');
            window.location.href = 'reportBadWords.jsp?year=' + parts[0] + '&month=' + parts[1];
        }
    }
    
    function filterViolators() {
        const input = document.getElementById('searchInput');
        const filter = input.value.toLowerCase();
        const rows = document.querySelectorAll('.violator-row');
        
        rows.forEach(row => {
            const name = row.getAttribute('data-name');
            const dept = row.getAttribute('data-dept');
            
            if (name.includes(filter) || dept.includes(filter)) {
                row.style.display = 'flex';
            } else {
                row.style.display = 'none';
            }
        });
    }
    
    function filterMessages() {
    const input = document.getElementById('searchMessagesInput');
    const filter = input.value.toLowerCase();
    const cards = document.querySelectorAll('.violation-card');

    cards.forEach(card => {
        const sender = card.getAttribute('data-sender');
        const receiver = card.getAttribute('data-receiver');
        const content = card.getAttribute('data-content');

        if (sender.includes(filter) || receiver.includes(filter) || content.includes(filter)) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}
    </script>
</body>
</html>
