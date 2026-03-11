<%@page import="java.sql.Timestamp  "%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.workflowx.dao.ReportDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%
String role = user.getRole();
if (!role.equals("ADMIN") && !role.equals("EMPLOYER")) {
    response.sendRedirect("employeeDashboard.jsp");
    return;
}
String userIdParam = request.getParameter("userId");
if (userIdParam == null) {
    response.sendRedirect("reportBadWords.jsp");
    return;
}
boolean isAdmin = user.isAdmin();
ReportDAO dao = new ReportDAO();

int userId;
    try {
        userId = Integer.parseInt(request.getParameter("userId"));
    } catch (Exception e) {
        response.sendRedirect("reports.jsp");
        return;
    }

    // SECURITY: Employer can only view employees from their own department
    if (!user.isAdmin()) {
        boolean allowed = dao.isUserInDepartment(userId, user.getDepartment());
        if (!allowed) {
            response.sendRedirect("reports.jsp");
            return;
        }
    }
    Map<String, Object> userDetails = dao.getUserDetails(userId);
    if (userDetails.isEmpty()) {
        response.sendRedirect("reports.jsp");
        return;
    }
List<Map<String, Object>> allCensored = dao.getCensoredMessages();

List<Map<String, Object>> userViolations = new ArrayList<>();

for (Map<String, Object> msg : allCensored) {
    if ((int)msg.get("senderId") == userId) {
        userViolations.add(msg);
    }
}
SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Violation Details</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
<style>
body {
    margin:0;
    font-family:'Segoe UI',sans-serif;
    background:#f4f6f9;
    transition:0.3s;
}

body.dark-mode {
    background:#1e1e2f;
    color:white;
}

/* NAVBAR */
.navbar {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    padding:15px 30px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    color:white;
}

body.dark-mode .navbar {
    background: linear-gradient(135deg,#232526,#414345);
}

.navbar-left {
    display:flex;
    align-items:center;
    gap:15px;
}

.navbar-right {
    display:flex;
    align-items:center;
    gap:10px;
}

.navbar .dashboard-btn {
    color:white;
    text-decoration:none;
    background:rgba(255,255,255,0.2);
    padding:8px 15px;
    border-radius:5px;
}

/* TOGGLE */
.toggle-btn {
    cursor:pointer;
    background:white;
    color:#f5576c;
    border:none;
    padding:8px 15px;
    border-radius:20px;
    font-weight:600;
}

body.dark-mode .toggle-btn {
    background:#333;
    color:white;
}

/* CONTAINER */
.container {
    width:80%;
    margin:40px auto;
}

/* CARD */
.card {
    background:white;
    padding:25px;
    border-radius:10px;
    margin-bottom:25px;
    box-shadow:0 4px 15px rgba(0,0,0,0.08);
}

body.dark-mode .card {
    background:#252538;
}

/* VIOLATION BOX */
.violation {
    background: <%= isAdmin 
        ? "linear-gradient(135deg,#f093fb,#f5576c)" 
        : "linear-gradient(135deg, #764ba2 0%, #667eea 100%)" %>;
    border-left:4px solid #f5576c;
    padding:15px;
    margin-bottom:15px;
    border-radius:8px;
}

body.dark-mode .violation {
    background:#2b2b3d;
}

.label {
    font-weight:600;
    margin-top:8px;
</style>

<script>
function toggleTheme() {
    document.body.classList.toggle("dark-mode");
}
</script>

</head>

<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

<div class="navbar">
    <h2>👥 User Details</h2>
    
    <div style="display:flex; align-items:center; gap:15px;">

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

        <%
String source = request.getParameter("source");
String department = request.getParameter("department");

String backHref = "reportUsers.jsp";

if (department != null && !department.trim().isEmpty()) {
    backHref = "reportUsers.jsp?source=" + source + "&department=" + department;
} else if (source != null) {
    backHref = "reportUsers.jsp?source=" + source;
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

    <!-- USER INFO -->
    <div class="card">
        <h2><%= userDetails.get("fullName") %></h2>
        <p><strong>Email:</strong> <%= userDetails.get("email") %></p>
        <p><strong>Department:</strong> <%= userDetails.get("department") %></p>
        <p><strong>Total Violations:</strong> <%= userViolations.size() %></p>
        <p><strong>Total Messages Sent:</strong> <%= userDetails.get("messagesSent") %></p>
        <p><strong>Censored Messages:</strong> <%= userDetails.get("censoredMessages") %></p>
    </div>

    <!-- VIOLATION LIST -->
    <div class="card">
        <h2>Filtered Messages</h2>

        <% if (userViolations.isEmpty()) { %>
            <p>No violations found for this user.</p>
        <% } else { 
            for (Map<String, Object> msg : userViolations) { %>

            <div class="violation">
                <div><strong>To:</strong> <%= msg.get("receiverName") %></div>
                <div><strong>Date:</strong> <%= sdf.format((Timestamp)msg.get("sentAt")) %></div>

                <% if (msg.get("subject") != null && !msg.get("subject").toString().isEmpty()) { %>
                    <div><strong>Subject:</strong> <%= msg.get("subject") %></div>
                <% } %>

                <div class="label">Filtered Content:</div>
                <div><%= msg.get("messageContent") %></div>

                <div class="label">Original Content:</div>
                <div><%= msg.get("originalContent") %></div>
            </div>

        <% } } %>

    </div>

</div>

</body>
</html>
