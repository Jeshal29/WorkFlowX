package com.workflowx.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Leave Model Class
 * Represents a leave application in the system
 */
public class Leave {
    
    private int leaveId;
    private int employeeId;
    private String leaveType;       // SICK, CASUAL, VACATION, EMERGENCY, OTHER
    private Date startDate;
    private Date endDate;
    private int totalDays;
    private String reason;
    private String status;          // PENDING, APPROVED, REJECTED
    private Integer approvedBy;
    private Timestamp appliedAt;
    private Timestamp reviewedAt;
    private String remarks;
    
    // For display purposes (not in database)
    private String employeeName;
    private String approverName;
    
    // Default Constructor
    public Leave() {
    }
    
    // Constructor for applying leave
    public Leave(int employeeId, String leaveType, Date startDate, 
                 Date endDate, int totalDays, String reason) {
        this.employeeId = employeeId;
        this.leaveType = leaveType;
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalDays = totalDays;
        this.reason = reason;
        this.status = "PENDING";
    }
    
    // Getters and Setters
    public int getLeaveId() {
        return leaveId;
    }
    
    public void setLeaveId(int leaveId) {
        this.leaveId = leaveId;
    }
    
    public int getEmployeeId() {
        return employeeId;
    }
    
    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }
    
    public String getLeaveType() {
        return leaveType;
    }
    
    public void setLeaveType(String leaveType) {
        this.leaveType = leaveType;
    }
    
    public Date getStartDate() {
        return startDate;
    }
    
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }
    
    public Date getEndDate() {
        return endDate;
    }
    
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
    
    public int getTotalDays() {
        return totalDays;
    }
    
    public void setTotalDays(int totalDays) {
        this.totalDays = totalDays;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Integer getApprovedBy() {
        return approvedBy;
    }
    
    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }
    
    public Timestamp getAppliedAt() {
        return appliedAt;
    }
    
    public void setAppliedAt(Timestamp appliedAt) {
        this.appliedAt = appliedAt;
    }
    
    public Timestamp getReviewedAt() {
        return reviewedAt;
    }
    
    public void setReviewedAt(Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }
    
    public String getRemarks() {
        return remarks;
    }
    
    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
    
    public String getEmployeeName() {
        return employeeName;
    }
    
    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }
    
    public String getApproverName() {
        return approverName;
    }
    
    public void setApproverName(String approverName) {
        this.approverName = approverName;
    }
    
    // Utility methods
    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(this.status);
    }
    
    public boolean isApproved() {
        return "APPROVED".equalsIgnoreCase(this.status);
    }
    
    public boolean isRejected() {
        return "REJECTED".equalsIgnoreCase(this.status);
    }
    
    @Override
    public String toString() {
        return "Leave{" +
                "leaveId=" + leaveId +
                ", leaveType='" + leaveType + '\'' +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                ", totalDays=" + totalDays +
                ", status='" + status + '\'' +
                '}';
    }
}