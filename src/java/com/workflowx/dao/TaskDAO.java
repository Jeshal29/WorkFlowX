package com.workflowx.dao;

import com.workflowx.model.Task;
import com.workflowx.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TaskDAO - Data Access Object for Task operations
 */
public class TaskDAO {
    
    /**
     * Create/Assign a new task
     * @return Task ID if successful, -1 if failed
     */
    public int createTask(int assignedBy, int assignedTo, String title, 
                         String description, String priority, String deadline,
                         String attachmentPath) {
    
        String sql = "INSERT INTO tasks (assigned_by, assigned_to, task_title, " +
                    "task_description, priority, deadline, attachment_path, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, assignedBy);
            stmt.setInt(2, assignedTo);
            stmt.setString(3, title);
            stmt.setString(4, description);
            stmt.setString(5, priority);
            stmt.setDate(6, java.sql.Date.valueOf(deadline));
            stmt.setString(7, attachmentPath);
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                // Get the generated task ID
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
            
            return -1; // Failed
            
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }
    
    /**
     * Get tasks assigned to an employee
     * @param employeeId Employee's user ID
     * @return List of tasks
     */
    public List<Task> getTasksForEmployee(int employeeId) {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name as assigned_by_name " +
                    "FROM tasks t " +
                    "JOIN users u ON t.assigned_by = u.user_id " +
                    "WHERE t.assigned_to = ? " +
                    "ORDER BY " +
                    "CASE t.status " +
                    "  WHEN 'PENDING' THEN 1 " +
                    "  WHEN 'IN_PROGRESS' THEN 2 " +
                    "  WHEN 'COMPLETED' THEN 3 " +
                    "  WHEN 'OVERDUE' THEN 0 " +
                    "END, " +
                    "t.deadline ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Task task = extractTaskFromResultSet(rs);
                task.setAssignedByName(rs.getString("assigned_by_name"));
                tasks.add(task);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getTasksForEmployee(): " + e.getMessage());
        }
        
        return tasks;
    }
    
    /**
     * Get tasks assigned by an employer
     * @param employerId Employer's user ID
     * @return List of tasks
     */
    public List<Task> getTasksByEmployer(int employerId) {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT t.*, u.full_name as assigned_to_name " +
                    "FROM tasks t " +
                    "JOIN users u ON t.assigned_to = u.user_id " +
                    "WHERE t.assigned_by = ? " +
                    "ORDER BY t.created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employerId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Task task = extractTaskFromResultSet(rs);
                task.setAssignedToName(rs.getString("assigned_to_name"));
                tasks.add(task);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getTasksByEmployer(): " + e.getMessage());
        }
        
        return tasks;
    }
    
    /**
     * Get task by ID
     * @param taskId Task ID
     * @return Task object or null
     */
    public Task getTaskById(int taskId) {
        String sql = "SELECT t.*, " +
                    "assigner.full_name as assigned_by_name, " +
                    "assignee.full_name as assigned_to_name " +
                    "FROM tasks t " +
                    "JOIN users assigner ON t.assigned_by = assigner.user_id " +
                    "JOIN users assignee ON t.assigned_to = assignee.user_id " +
                    "WHERE t.task_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Task task = extractTaskFromResultSet(rs);
                task.setAssignedByName(rs.getString("assigned_by_name"));
                task.setAssignedToName(rs.getString("assigned_to_name"));
                return task;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getTaskById(): " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Update task status
     * @param taskId Task ID
     * @param newStatus New status
     * @return true if successful
     */
    public boolean updateTaskStatus(int taskId, String newStatus) {
        String sql;
        
        if ("COMPLETED".equalsIgnoreCase(newStatus)) {
            sql = "UPDATE tasks SET status = ?, completed_at = NOW() WHERE task_id = ?";
        } else {
            sql = "UPDATE tasks SET status = ? WHERE task_id = ?";
        }
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, newStatus.toUpperCase());
            stmt.setInt(2, taskId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateTaskStatus(): " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get count of pending tasks for an employee
     * @param employeeId Employee ID
     * @return Count of pending tasks
     */
    public int getPendingTaskCount(int employeeId) {
        String sql = "SELECT COUNT(*) FROM tasks " +
                    "WHERE assigned_to = ? AND status IN ('PENDING', 'IN_PROGRESS')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getPendingTaskCount(): " + e.getMessage());
        }
        
        return 0;
    }
    
    /**
     * Helper method to extract Task from ResultSet
     */
    private Task extractTaskFromResultSet(ResultSet rs) throws SQLException {
        Task task = new Task();
        task.setTaskId(rs.getInt("task_id"));
        task.setAssignedBy(rs.getInt("assigned_by"));
        task.setAssignedTo(rs.getInt("assigned_to"));
        task.setTaskTitle(rs.getString("task_title"));
        task.setTaskDescription(rs.getString("task_description"));
        task.setPriority(rs.getString("priority"));
        task.setStatus(rs.getString("status"));
        task.setDeadline(rs.getDate("deadline"));
        task.setCreatedAt(rs.getTimestamp("created_at"));
        task.setUpdatedAt(rs.getTimestamp("updated_at"));
        task.setCompletedAt(rs.getTimestamp("completed_at"));
        
        // Get attachment path if column exists
        try {
            task.setAttachmentPath(rs.getString("attachment_path"));
        } catch (SQLException e) {
            // Column doesn't exist, ignore
        }
        
        return task;
    }
}