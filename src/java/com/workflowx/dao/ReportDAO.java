package com.workflowx.dao;

import com.workflowx.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {
    
    // ========== USER REPORTS ==========
    
    public List<Map<String, Object>> getAllUsersReport() {
        List<Map<String, Object>> users = new ArrayList<>();
        String sql = "SELECT user_id, username, full_name, email, role, department, " +
                    "is_active, created_at, last_login FROM users ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> user = new HashMap<>();
                user.put("userId", rs.getInt("user_id"));
                user.put("username", rs.getString("username"));
                user.put("fullName", rs.getString("full_name"));
                user.put("email", rs.getString("email"));
                user.put("role", rs.getString("role"));
                user.put("department", rs.getString("department"));
                user.put("isActive", rs.getBoolean("is_active"));
                user.put("createdAt", rs.getTimestamp("created_at"));
                user.put("lastLogin", rs.getTimestamp("last_login"));
                users.add(user);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return users;
    }
    
    public Map<String, Object> getUserDetails(int userId) {
        Map<String, Object> details = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Basic info
            String sql1 = "SELECT * FROM users WHERE user_id = ?";
            PreparedStatement stmt1 = conn.prepareStatement(sql1);
            stmt1.setInt(1, userId);
            ResultSet rs1 = stmt1.executeQuery();
            if (rs1.next()) {
                details.put("username", rs1.getString("username"));
                details.put("fullName", rs1.getString("full_name"));
                details.put("email", rs1.getString("email"));
                details.put("role", rs1.getString("role"));
                details.put("department", rs1.getString("department"));
                details.put("createdAt", rs1.getTimestamp("created_at"));
                details.put("lastLogin", rs1.getTimestamp("last_login"));
            }
            
            // Message stats
            String sql2 = "SELECT COUNT(*) as count FROM messages WHERE sender_id = ?";
            PreparedStatement stmt2 = conn.prepareStatement(sql2);
            stmt2.setInt(1, userId);
            ResultSet rs2 = stmt2.executeQuery();
            if (rs2.next()) details.put("messagesSent", rs2.getInt("count"));
            
            String sql3 = "SELECT COUNT(*) as count FROM messages WHERE receiver_id = ?";
            PreparedStatement stmt3 = conn.prepareStatement(sql3);
            stmt3.setInt(1, userId);
            ResultSet rs3 = stmt3.executeQuery();
            if (rs3.next()) details.put("messagesReceived", rs3.getInt("count"));
            
            // Censored messages
            String sql7 = "SELECT COUNT(*) as count FROM messages WHERE sender_id = ? AND is_censored = TRUE";
            PreparedStatement stmt7 = conn.prepareStatement(sql7);
            stmt7.setInt(1, userId);
            ResultSet rs7 = stmt7.executeQuery();
            if (rs7.next()) details.put("censoredMessages", rs7.getInt("count"));
            
            // Task stats
            String sql4 = "SELECT COUNT(*) as count FROM tasks WHERE assigned_to = ?";
            PreparedStatement stmt4 = conn.prepareStatement(sql4);
            stmt4.setInt(1, userId);
            ResultSet rs4 = stmt4.executeQuery();
            if (rs4.next()) details.put("tasksAssigned", rs4.getInt("count"));
            
            String sql5 = "SELECT COUNT(*) as count FROM tasks WHERE assigned_to = ? AND status = 'COMPLETED'";
            PreparedStatement stmt5 = conn.prepareStatement(sql5);
            stmt5.setInt(1, userId);
            ResultSet rs5 = stmt5.executeQuery();
            if (rs5.next()) details.put("tasksCompleted", rs5.getInt("count"));
            
            // Leave stats
            String sql6 = "SELECT COUNT(*) as count FROM leaves WHERE employee_id = ?";
            PreparedStatement stmt6 = conn.prepareStatement(sql6);
            stmt6.setInt(1, userId);
            ResultSet rs6 = stmt6.executeQuery();
            if (rs6.next()) details.put("leavesApplied", rs6.getInt("count"));
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return details;
    }
    
    // ========== BAD WORD REPORTS ==========
    
    public List<Map<String, Object>> getCensoredMessages() {
        String sql = "SELECT m.message_id, m.subject, m.message_content, m.original_content, " +
                    "m.sent_at, sender.user_id as sender_id, sender.full_name as sender_name, " +
                    "receiver.full_name as receiver_name " +
                    "FROM messages m " +
                    "JOIN users sender ON m.sender_id = sender.user_id " +
                    "JOIN users receiver ON m.receiver_id = receiver.user_id " +
                    "WHERE m.is_censored = TRUE " +
                    "ORDER BY m.sent_at DESC";
        
        return getCensoredMessagesQuery(sql);
    }
    private List<Map<String, Object>> getCensoredMessagesQueryWithParams(String sql, int year, int month) {
    List<Map<String, Object>> messages = new ArrayList<>();

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, year);
        stmt.setInt(2, month);

        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> msg = new HashMap<>();
            msg.put("messageId", rs.getInt("message_id"));
            msg.put("subject", rs.getString("subject"));
            msg.put("messageContent", rs.getString("message_content"));
            msg.put("originalContent", rs.getString("original_content"));
            msg.put("sentAt", rs.getTimestamp("sent_at"));
            msg.put("senderId", rs.getInt("sender_id"));
            msg.put("senderName", rs.getString("sender_name"));
            msg.put("receiverName", rs.getString("receiver_name"));
            messages.add(msg);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return messages;
}

    public List<Map<String, Object>> getCensoredMessagesByMonth(int year, int month) {
        String sql = "SELECT m.message_id, m.subject, m.message_content, m.original_content, " +
                    "m.sent_at, sender.user_id as sender_id, sender.full_name as sender_name, " +
                    "receiver.full_name as receiver_name " +
                    "FROM messages m " +
                    "JOIN users sender ON m.sender_id = sender.user_id " +
                    "JOIN users receiver ON m.receiver_id = receiver.user_id " +
                    "WHERE m.is_censored = TRUE " +
                    "AND YEAR(m.sent_at) = ? AND MONTH(m.sent_at) = ? " +
                    "ORDER BY m.sent_at DESC";
        
        return getCensoredMessagesQueryWithParams(sql, year, month);
    }
    
    private List<Map<String, Object>> getCensoredMessagesQuery(String sql) {
        List<Map<String, Object>> messages = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> msg = new HashMap<>();
                msg.put("messageId", rs.getInt("message_id"));
                msg.put("subject", rs.getString("subject"));
                msg.put("messageContent", rs.getString("message_content"));
                msg.put("originalContent", rs.getString("original_content"));
                msg.put("sentAt", rs.getTimestamp("sent_at"));
                msg.put("senderId", rs.getInt("sender_id"));
                msg.put("senderName", rs.getString("sender_name"));
                msg.put("receiverName", rs.getString("receiver_name"));
                messages.add(msg);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return messages;
    }
    
   
    
   
    public Map<String, Integer> getBadWordStats() {
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql1 = "SELECT COUNT(*) as count FROM messages WHERE is_censored = TRUE";
            PreparedStatement stmt1 = conn.prepareStatement(sql1);
            ResultSet rs1 = stmt1.executeQuery();
            if (rs1.next()) stats.put("totalCensored", rs1.getInt("count"));
            
            String sql2 = "SELECT COUNT(DISTINCT sender_id) as count FROM messages WHERE is_censored = TRUE";
            PreparedStatement stmt2 = conn.prepareStatement(sql2);
            ResultSet rs2 = stmt2.executeQuery();
            if (rs2.next()) stats.put("usersWithViolations", rs2.getInt("count"));
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    public List<Map<String, Object>> getTopViolators() {
        List<Map<String, Object>> violators = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.department, COUNT(m.message_id) as violation_count " +
                    "FROM messages m " +
                    "JOIN users u ON m.sender_id = u.user_id " +
                    "WHERE m.is_censored = TRUE " +
                    "GROUP BY u.user_id " +
                    "ORDER BY violation_count DESC LIMIT 10";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> violator = new HashMap<>();
                violator.put("userId", rs.getInt("user_id"));
                violator.put("fullName", rs.getString("full_name"));
                violator.put("department", rs.getString("department"));
                violator.put("violationCount", rs.getInt("violation_count"));
                violators.add(violator);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return violators;
    }
    
    // ========== MESSAGE REPORTS ==========
    
    public List<Map<String, Object>> getMessageActivity() {
        List<Map<String, Object>> activity = new ArrayList<>();
        String sql = "SELECT DATE(sent_at) as date, COUNT(*) as count " +
                    "FROM messages " +
                    "GROUP BY DATE(sent_at) " +
                    "ORDER BY date DESC LIMIT 30";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> day = new HashMap<>();
                day.put("date", rs.getDate("date"));
                day.put("count", rs.getInt("count"));
                activity.add(day);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activity;
    }
    
    public List<Map<String, Object>> getTopMessageSenders() {
        List<Map<String, Object>> senders = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.department, COUNT(m.message_id) as message_count " +
                    "FROM messages m " +
                    "JOIN users u ON m.sender_id = u.user_id " +
                    "GROUP BY u.user_id " +
                    "ORDER BY message_count DESC LIMIT 10";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> sender = new HashMap<>();
                sender.put("userId", rs.getInt("user_id"));
                sender.put("fullName", rs.getString("full_name"));
                sender.put("department", rs.getString("department"));
                sender.put("messageCount", rs.getInt("message_count"));
                senders.add(sender);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return senders;
    }
    
    // ========== TASK REPORTS ==========
    
    public List<Map<String, Object>> getTasksByStatus(String status) {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT t.task_id, t.task_title, t.priority, t.status, t.deadline, " +
                    "t.created_at, assigner.full_name as assigned_by, assignee.full_name as assigned_to " +
                    "FROM tasks t " +
                    "JOIN users assigner ON t.assigned_by = assigner.user_id " +
                    "JOIN users assignee ON t.assigned_to = assignee.user_id " +
                    "WHERE t.status = ? " +
                    "ORDER BY t.deadline ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("taskId", rs.getInt("task_id"));
                task.put("taskTitle", rs.getString("task_title"));
                task.put("priority", rs.getString("priority"));
                task.put("status", rs.getString("status"));
                task.put("deadline", rs.getDate("deadline"));
                task.put("createdAt", rs.getTimestamp("created_at"));
                task.put("assignedBy", rs.getString("assigned_by"));
                task.put("assignedTo", rs.getString("assigned_to"));
                tasks.add(task);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return tasks;
    }
    
    public List<Map<String, Object>> getEmployeePerformance() {
        List<Map<String, Object>> performance = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.department, " +
                    "COUNT(t.task_id) as total_tasks, " +
                    "SUM(CASE WHEN t.status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_tasks " +
                    "FROM users u " +
                    "LEFT JOIN tasks t ON u.user_id = t.assigned_to " +
                    "WHERE u.role = 'EMPLOYEE' " +
                    "GROUP BY u.user_id " +
                    "ORDER BY completed_tasks DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> perf = new HashMap<>();
                perf.put("userId", rs.getInt("user_id"));
                perf.put("fullName", rs.getString("full_name"));
                perf.put("department", rs.getString("department"));
                perf.put("totalTasks", rs.getInt("total_tasks"));
                perf.put("completedTasks", rs.getInt("completed_tasks"));
                
                int total = rs.getInt("total_tasks");
                int completed = rs.getInt("completed_tasks");
                double rate = total > 0 ? (completed * 100.0 / total) : 0;
                perf.put("completionRate", rate);
                
                performance.add(perf);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return performance;
    }
    
    // ========== LEAVE REPORTS ==========
    
    public List<Map<String, Object>> getLeavesByStatus(String status) {
        List<Map<String, Object>> leaves = new ArrayList<>();
        String sql = "SELECT l.leave_id, l.leave_type, l.start_date, l.end_date, l.total_days, " +
                    "l.reason, l.status, l.applied_at, emp.full_name as employee_name, " +
                    "emp.department, mgr.full_name as manager_name " +
                    "FROM leaves l " +
                    "JOIN users emp ON l.employee_id = emp.user_id " +
                    "LEFT JOIN users mgr ON l.approved_by = mgr.user_id " +
                    "WHERE l.status = ? " +
                    "ORDER BY l.applied_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> leave = new HashMap<>();
                leave.put("leaveId", rs.getInt("leave_id"));
                leave.put("leaveType", rs.getString("leave_type"));
                leave.put("startDate", rs.getDate("start_date"));
                leave.put("endDate", rs.getDate("end_date"));
                leave.put("totalDays", rs.getInt("total_days"));
                leave.put("reason", rs.getString("reason"));
                leave.put("status", rs.getString("status"));
                leave.put("appliedAt", rs.getTimestamp("applied_at"));
                leave.put("employeeName", rs.getString("employee_name"));
                leave.put("department", rs.getString("department"));
                leave.put("managerName", rs.getString("manager_name"));
                leaves.add(leave);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return leaves;
    }
    
    // ========== ACTIVITY LOGS ==========
    
    public List<Map<String, Object>> getRecentActivity(int limit) {
        List<Map<String, Object>> activities = new ArrayList<>();
        String sql = "SELECT a.activity_type, a.activity_details, a.created_at, a.ip_address, " +
                    "u.full_name, u.role " +
                    "FROM activity_logs a " +
                    "JOIN users u ON a.user_id = u.user_id " +
                    "ORDER BY a.created_at DESC LIMIT ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> activity = new HashMap<>();
                activity.put("activityType", rs.getString("activity_type"));
                activity.put("activityDetails", rs.getString("activity_details"));
                activity.put("createdAt", rs.getTimestamp("created_at"));
                activity.put("ipAddress", rs.getString("ip_address"));
                activity.put("fullName", rs.getString("full_name"));
                activity.put("role", rs.getString("role"));
                activities.add(activity);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    // ========== STATISTICS ==========
    
    public Map<String, Integer> getOverallStats() {
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            stats.put("totalUsers", getStat(conn, "SELECT COUNT(*) FROM users WHERE is_active = TRUE"));
            stats.put("totalEmployees", getStat(conn, "SELECT COUNT(*) FROM users WHERE role = 'EMPLOYEE' AND is_active = TRUE"));
            stats.put("totalEmployers", getStat(conn, "SELECT COUNT(*) FROM users WHERE role = 'EMPLOYER' AND is_active = TRUE"));
            stats.put("totalMessages", getStat(conn, "SELECT COUNT(*) FROM messages"));
            stats.put("totalTasks", getStat(conn, "SELECT COUNT(*) FROM tasks"));
            stats.put("completedTasks", getStat(conn, "SELECT COUNT(*) FROM tasks WHERE status = 'COMPLETED'"));
            stats.put("pendingTasks", getStat(conn, "SELECT COUNT(*) FROM tasks WHERE status = 'PENDING'"));
            stats.put("totalLeaves", getStat(conn, "SELECT COUNT(*) FROM leaves"));
            stats.put("approvedLeaves", getStat(conn, "SELECT COUNT(*) FROM leaves WHERE status = 'APPROVED'"));
            stats.put("pendingLeaves", getStat(conn, "SELECT COUNT(*) FROM leaves WHERE status = 'PENDING'"));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    private int getStat(Connection conn, String sql) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
    
    public Map<String, Integer> getTaskStatsByStatus() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT status, COUNT(*) as count FROM tasks GROUP BY status";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                stats.put(rs.getString("status"), rs.getInt("count"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    public Map<String, Integer> getLeaveStatsByStatus() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT status, COUNT(*) as count FROM leaves GROUP BY status";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                stats.put(rs.getString("status"), rs.getInt("count"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    public Map<String, Integer> getDepartmentStats() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT department, COUNT(*) as count FROM users " +
                    "WHERE role = 'EMPLOYEE' AND is_active = TRUE GROUP BY department";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                String dept = rs.getString("department");
                if (dept != null && !dept.isEmpty()) {
                    stats.put(dept, rs.getInt("count"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    public Map<String, Integer> getMessageStats() {
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            stats.put("total", getStat(conn, "SELECT COUNT(*) FROM messages"));
            stats.put("read", getStat(conn, "SELECT COUNT(*) FROM messages WHERE is_read = TRUE"));
            stats.put("unread", getStat(conn, "SELECT COUNT(*) FROM messages WHERE is_read = FALSE"));
            stats.put("censored", getStat(conn, "SELECT COUNT(*) FROM messages WHERE is_censored = TRUE"));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    // ========== DEPARTMENT-FILTERED METHODS (FOR EMPLOYERS) ==========
    
    public List<Map<String, Object>> getCensoredMessagesByDepartment(String department) {
        List<Map<String, Object>> messages = new ArrayList<>();
        String sql = "SELECT m.message_id, m.subject, m.message_content, m.original_content, " +
                    "m.sent_at, sender.user_id as sender_id, sender.full_name as sender_name, " +
                    "receiver.full_name as receiver_name " +
                    "FROM messages m " +
                    "JOIN users sender ON m.sender_id = sender.user_id " +
                    "JOIN users receiver ON m.receiver_id = receiver.user_id " +
                    "WHERE m.is_censored = TRUE " +
                    "AND (sender.department = ? OR receiver.department = ?) " +
                    "ORDER BY m.sent_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, department);
            stmt.setString(2, department);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> msg = new HashMap<>();
                msg.put("messageId", rs.getInt("message_id"));
                msg.put("subject", rs.getString("subject"));
                msg.put("messageContent", rs.getString("message_content"));
                msg.put("originalContent", rs.getString("original_content"));
                msg.put("sentAt", rs.getTimestamp("sent_at"));
                msg.put("senderId", rs.getInt("sender_id"));
                msg.put("senderName", rs.getString("sender_name"));
                msg.put("receiverName", rs.getString("receiver_name"));
                messages.add(msg);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return messages;
    }
    
    public List<Map<String, Object>> getTopViolatorsByDepartment(String department) {
        List<Map<String, Object>> violators = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.department, COUNT(m.message_id) as violation_count " +
                    "FROM messages m " +
                    "JOIN users u ON m.sender_id = u.user_id " +
                    "WHERE m.is_censored = TRUE AND u.department = ? " +
                    "GROUP BY u.user_id " +
                    "ORDER BY violation_count DESC LIMIT 10";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, department);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> violator = new HashMap<>();
                violator.put("userId", rs.getInt("user_id"));
                violator.put("fullName", rs.getString("full_name"));
                violator.put("department", rs.getString("department"));
                violator.put("violationCount", rs.getInt("violation_count"));
                violators.add(violator);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return violators;
    }
    // ========== ADMIN MESSAGE CATEGORY REPORT ==========
public List<Map<String, Object>> getMessagesBySenderRole(String role) {
    List<Map<String, Object>> messages = new ArrayList<>();

    String sql = "SELECT m.message_id, m.subject, m.message_content, m.sent_at, " +
                 "sender.user_id as sender_id, sender.full_name as sender_name, " +
                 "receiver.full_name as receiver_name " +
                 "FROM messages m " +
                 "JOIN users sender ON m.sender_id = sender.user_id " +
                 "JOIN users receiver ON m.receiver_id = receiver.user_id " +
                 "WHERE sender.role = ? " +
                 "ORDER BY m.sent_at DESC";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setString(1, role);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> msg = new HashMap<>();
            msg.put("messageId", rs.getInt("message_id"));
            msg.put("subject", rs.getString("subject"));
            msg.put("messageContent", rs.getString("message_content"));
            msg.put("sentAt", rs.getTimestamp("sent_at"));
            msg.put("senderId", rs.getInt("sender_id"));
            msg.put("senderName", rs.getString("sender_name"));
            msg.put("receiverName", rs.getString("receiver_name"));
            messages.add(msg);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return messages;
}
// Get messages by sender role AND department
public List<Map<String, Object>> getMessagesBySenderRoleByDepartment(String role, String department) {
    List<Map<String, Object>> messages = new ArrayList<>();

    String sql = "SELECT m.message_id, m.subject, m.message_content, m.sent_at, " +
                 "sender.user_id as sender_id, sender.full_name as sender_name, " +
                 "receiver.full_name as receiver_name " +
                 "FROM messages m " +
                 "JOIN users sender ON m.sender_id = sender.user_id " +
                 "JOIN users receiver ON m.receiver_id = receiver.user_id " +
                 "WHERE sender.role = ? AND sender.department = ? " +
                 "ORDER BY m.sent_at DESC";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setString(1, role);
        stmt.setString(2, department);

        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> msg = new HashMap<>();
            msg.put("messageId", rs.getInt("message_id"));
            msg.put("subject", rs.getString("subject"));
            msg.put("messageContent", rs.getString("message_content"));
            msg.put("sentAt", rs.getTimestamp("sent_at"));
            msg.put("senderId", rs.getInt("sender_id"));
            msg.put("senderName", rs.getString("sender_name"));
            msg.put("receiverName", rs.getString("receiver_name"));
            messages.add(msg);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return messages;
}

}