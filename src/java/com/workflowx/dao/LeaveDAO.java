package com.workflowx.dao;

import com.workflowx.model.Leave;
import com.workflowx.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveDAO {
    
    public int applyLeave(Leave leave) {
        String sql = "INSERT INTO leaves (employee_id, leave_type, start_date, end_date, " +
                    "total_days, reason, status, applied_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', NOW())";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, leave.getEmployeeId());
            stmt.setString(2, leave.getLeaveType());
            stmt.setDate(3, leave.getStartDate());
            stmt.setDate(4, leave.getEndDate());
            stmt.setInt(5, leave.getTotalDays());
            stmt.setString(6, leave.getReason());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error in applyLeave(): " + e.getMessage());
        }
        
        return -1;
    }
    
    public List<Leave> getEmployeeLeaves(int employeeId) {
        List<Leave> leaves = new ArrayList<>();
        String sql = "SELECT l.*, approver.full_name as approver_name " +
                    "FROM leaves l " +
                    "LEFT JOIN users approver ON l.approved_by = approver.user_id " +
                    "WHERE l.employee_id = ? " +
                    "ORDER BY l.applied_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Leave leave = extractLeaveFromResultSet(rs);
                leave.setApproverName(rs.getString("approver_name"));
                leaves.add(leave);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getEmployeeLeaves(): " + e.getMessage());
        }
        
        return leaves;
    }
    
    public List<Leave> getAllPendingLeaves() {
        List<Leave> leaves = new ArrayList<>();
        String sql = "SELECT l.*, emp.full_name as employee_name " +
                    "FROM leaves l " +
                    "JOIN users emp ON l.employee_id = emp.user_id " +
                    "WHERE l.status = 'PENDING' " +
                    "ORDER BY l.applied_at ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Leave leave = extractLeaveFromResultSet(rs);
                leave.setEmployeeName(rs.getString("employee_name"));
                leaves.add(leave);
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getAllPendingLeaves(): " + e.getMessage());
        }
        
        return leaves;
    }
    
    public boolean updateLeaveStatus(int leaveId, String status, int approverId, String remarks) {
        String sql = "UPDATE leaves SET status = ?, approved_by = ?, reviewed_at = NOW(), " +
                    "remarks = ? WHERE leave_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status.toUpperCase());
            stmt.setInt(2, approverId);
            stmt.setString(3, remarks);
            stmt.setInt(4, leaveId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateLeaveStatus(): " + e.getMessage());
            return false;
        }
    }
    
    private Leave extractLeaveFromResultSet(ResultSet rs) throws SQLException {
        Leave leave = new Leave();
        leave.setLeaveId(rs.getInt("leave_id"));
        leave.setEmployeeId(rs.getInt("employee_id"));
        leave.setLeaveType(rs.getString("leave_type"));
        leave.setStartDate(rs.getDate("start_date"));
        leave.setEndDate(rs.getDate("end_date"));
        leave.setTotalDays(rs.getInt("total_days"));
        leave.setReason(rs.getString("reason"));
        leave.setStatus(rs.getString("status"));
        leave.setApprovedBy((Integer) rs.getObject("approved_by"));
        leave.setAppliedAt(rs.getTimestamp("applied_at"));
        leave.setReviewedAt(rs.getTimestamp("reviewed_at"));
        leave.setRemarks(rs.getString("remarks"));
        return leave;
    }
}