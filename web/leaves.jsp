<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="com.workflowx.dao.LeaveDAO"%>
<%@page import="com.workflowx.model.Leave"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/userSession.jsp" %>
<%@ include file="/common/employeeOnly.jsp" %>
<%
    LeaveDAO leaveDAO = new LeaveDAO();
    List<Leave> myLeaves = leaveDAO.getEmployeeLeaves(user.getUserId());
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Leaves - WorkFlowX</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/base.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
       

/* DARK MODE FULL OVERRIDE */
       body.dark-mode {
            background: #1e1e2f;
            color: #f1f1f1;
        }

        .dark-mode .navbar {
                background: linear-gradient(135deg, #232526 0%, #414345 100%);
        }

        

        body.dark-mode .navbar h2,
body.dark-mode .navbar a {
    color: #ffffff !important;
}

body.dark-mode .navbar a {
    background: #222222 !important;
}

body.dark-mode .navbar a:hover {
    background: #333333 !important;
}

/* Main Containers */
body.dark-mode .apply-form,
body.dark-mode .leave-list {
    background: #111111 !important;
    color: #ffffff !important;
}

/* Form Header */
body.dark-mode .form-header {
    border-bottom: 1px solid #333 !important;
}

body.dark-mode .form-header h3 {
    color: #ffffff !important;
}

/* Labels */
body.dark-mode .form-group label {
    color: #cccccc !important;
}

/* Inputs */
body.dark-mode input,
body.dark-mode select,
body.dark-mode textarea {
    background: #1a1a1a !important;
    color: #ffffff !important;
    border: 1px solid #333 !important;
}

/* Leave Items */
body.dark-mode .leave-item {
    background: #111111 !important;
    border-bottom: 1px solid #222 !important;
}

body.dark-mode .leave-item:hover {
    background: #1a1a1a !important;
}

/* Leave Type & Dates */
body.dark-mode .leave-type-badge,
body.dark-mode .leave-dates {
    color: #ffffff !important;
}

/* Reason Section */
body.dark-mode .reason-section {
    background: #1a1a1a !important;
    color: #ffffff !important;
}

/* Remarks Section */
body.dark-mode .remarks-section {
    background: #1a1a1a !important;
    border-left: 4px solid #555 !important;
    color: #ffffff !important;
}

/* Empty State */
body.dark-mode .empty-state {
    color: #cccccc !important;
}

/* Applied text */
body.dark-mode .leave-item div[style] {
    color: #888 !important;
}
 
        .navbar { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            backdrop-filter: blur(10px);
            padding: 15px 30px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
        }
        
        .navbar h2 { 
            font-size: 24px; 
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .navbar .dashboard-btn { color: white; text-decoration: none; padding: 8px 15px; background: rgba(255,255,255,0.2); border-radius: 5px; }
        
        .navbar a:hover { 
            background: #667eea; 
            color: white;
            transform: translateY(-2px);
        }
        
        .container { 
            max-width: 1200px; 
            margin: 30px auto; 
            padding: 0 20px; 
        }
        
        .apply-form { 
            background: white; 
            padding: 30px; 
            border-radius: 15px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.2); 
            margin-bottom: 30px;
        }
        
        .form-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .form-header h3 {
            font-size: 22px;
            color: #333;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .form-group { 
            margin-bottom: 20px; 
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        .form-group label { 
            display: block; 
            margin-bottom: 8px; 
            color: #555; 
            font-weight: 600;
            font-size: 14px;
        }
        
        .form-group input, 
        .form-group select, 
        .form-group textarea { 
            width: 100%; 
            padding: 12px 15px; 
            border: 2px solid #e0e0e0; 
            border-radius: 8px;
            font-family: inherit;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .form-group textarea { 
            resize: vertical; 
            min-height: 100px; 
        }
        
        .btn { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            color: white; 
            border: none; 
            padding: 14px 35px; 
            border-radius: 8px; 
            cursor: pointer; 
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .success { 
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); 
            color: white; 
            padding: 15px 20px; 
            border-radius: 10px; 
            margin-bottom: 20px; 
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            box-shadow: 0 5px 15px rgba(17, 153, 142, 0.3);
        }
        
        .error { 
            background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%); 
            color: white; 
            padding: 15px 20px; 
            border-radius: 10px; 
            margin-bottom: 20px; 
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.3);
        }
        
        .section-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .section-header h3 {
            font-size: 22px;
            color: white;
        }
        
        .leave-list { 
            background: white; 
            border-radius: 15px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        
        .leave-item { 
            padding: 25px; 
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.3s;
        }
        
        .leave-item:hover {
            background: #f8f9fa;
        }
        
        .leave-item:last-child { 
            border-bottom: none; 
        }
        
        .leave-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 15px; 
        }
        
        .leave-type-badge {
            font-size: 18px;
            font-weight: 700;
            color: #333;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .leave-dates {
            color: #666; 
            font-size: 14px; 
            margin-top: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .status-badge { 
            padding: 8px 20px; 
            border-radius: 25px; 
            font-size: 13px; 
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-pending { 
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); 
            color: white; 
        }
        
        .status-approved { 
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); 
            color: white; 
        }
        
        .status-rejected { 
            background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%); 
            color: white; 
        }
        
        .reason-section {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
        }
        
        .reason-section strong {
            display: block;
            margin-bottom: 8px;
            color: #667eea;
        }
        
        .remarks-section {
            background: #fff8dc;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            border-left: 4px solid #ffc107;
        }
        
        .remarks-section strong {
            display: block;
            margin-bottom: 8px;
            color: #856404;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .empty-state svg {
            width: 100px;
            height: 100px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .leave-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
        }

</style>
</head>
<body class="<%= theme.equals("DARK") ? "dark-mode" : "" %>">

    <div class="navbar">
        <h2>📅 My Leave Applications</h2>
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


        <a href="employeeDashboard.jsp" class="dashboard-btn" >← Back to Dashboard</a>
    </div>
    </div>
    <div class="container">
        <div class="apply-form">
            <div class="form-header">
                <h3>✍️ Apply for New Leave</h3>
            </div>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="success">
                    ✓ <%= request.getAttribute("success") %>
                </div>
            <% } %>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error">
                    ✗ <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form action="ApplyLeaveServlet" method="post">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Leave Type *</label>
                        <select name="leaveType" required>
                            <option value="">-- Select Leave Type --</option>
                            <option value="SICK">🤒 Sick Leave</option>
                            <option value="CASUAL">😊 Casual Leave</option>
                            <option value="VACATION">🏖️ Vacation</option>
                            <option value="EMERGENCY">🚨 Emergency</option>
                            <option value="OTHER">📋 Other</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <!-- Placeholder for grid alignment -->
                    </div>
                    
                    <div class="form-group">
                        <label>Start Date *</label>
                        <input type="date" name="startDate" required 
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    </div>
                    
                    <div class="form-group">
                        <label>End Date *</label>
                        <input type="date" name="endDate" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    </div>
                    
                    <div class="form-group full-width">
                        <label>Reason (Optional)</label>
                        <textarea name="reason" placeholder="Brief description of why you need this leave..."></textarea>
                    </div>
                </div>
                
                <button type="submit" class="btn">🚀 Submit Application</button>
            </form>
        </div>
        
        <div class="section-header">
            <h3>📋 Leave History</h3>
        </div>
        
        <div class="leave-list">
            <% if (myLeaves.isEmpty()) { %>
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11z"/>
                    </svg>
                    <h3>No Leave Applications Yet</h3>
                    <p>You haven't applied for any leaves. Use the form above to submit your first application.</p>
                </div>
            <% } else {
                for (Leave leave : myLeaves) {
                    String statusClass = leave.getStatus().toLowerCase();
                    String statusIcon = leave.isApproved() ? "✓" : (leave.isRejected() ? "✗" : "⏳");
            %>
                <div class="leave-item">
                    <div class="leave-header">
                        <div>
                            <div class="leave-type-badge">
                                <%= leave.getLeaveType().replace("_", " ") %>
                            </div>
                            <div class="leave-dates">
                                📅 <%= dateFormat.format(leave.getStartDate()) %> - 
                                <%= dateFormat.format(leave.getEndDate()) %> 
                                (<%= leave.getTotalDays() %> <%= leave.getTotalDays() == 1 ? "day" : "days" %>)
                            </div>
                        </div>
                        <span class="status-badge status-<%= statusClass %>">
                            <%= statusIcon %> <%= leave.getStatus() %>
                        </span>
                    </div>
                    
                    <% if (leave.getReason() != null && !leave.getReason().trim().isEmpty()) { %>
                        <div class="reason-section">
                            <strong>Reason:</strong>
                            <%= leave.getReason() %>
                        </div>
                    <% } %>
                    
                    <% if (leave.getRemarks() != null && !leave.getRemarks().trim().isEmpty()) { %>
                        <div class="remarks-section">
                            <strong>Manager's Remarks:</strong>
                            <%= leave.getRemarks() %>
                        </div>
                    <% } %>
                    
                    <div style="color: #999; font-size: 12px; margin-top: 15px;">
                        Applied on: <%= dateFormat.format(leave.getAppliedAt()) %>
                        <% if (leave.getReviewedAt() != null) { %>
                            | Reviewed on: <%= dateFormat.format(leave.getReviewedAt()) %>
                        <% } %>
                    </div>
                </div>
            <% 
                }
            } 
            %>
        </div>
    </div>
    
    <script>
        // Auto-calculate days when dates are selected
        document.querySelector('input[name="startDate"]').addEventListener('change', calculateDays);
        document.querySelector('input[name="endDate"]').addEventListener('change', calculateDays);
        
        function calculateDays() {
            const startDate = document.querySelector('input[name="startDate"]').value;
            const endDate = document.querySelector('input[name="endDate"]').value;
            
            if (startDate && endDate) {
                const start = new Date(startDate);
                const end = new Date(endDate);
                const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24)) + 1;
                
                if (days > 0) {
                    console.log('Total days: ' + days);
                }
            }
        }
    </script>
</body>
</html>
