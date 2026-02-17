package com.workflowx.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Task Model Class
 * Represents a task in the system
 */
public class Task {
    
    private int taskId;
    private int assignedBy;
    private int assignedTo;
    private String taskTitle;
    private String taskDescription;
    private String priority;        // LOW, MEDIUM, HIGH
    private String status;          // PENDING, IN_PROGRESS, COMPLETED, OVERDUE
    private Date deadline;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp completedAt;
    private String attachmentPath;
    // For display purposes (not in database)
    private String assignedByName;
    private String assignedToName;
    
    // Default Constructor
    public Task() {
    }
    
    // Constructor for creating new task
    public Task(int assignedBy, int assignedTo, String taskTitle, 
                String taskDescription, String priority, Date deadline) {
        this.assignedBy = assignedBy;
        this.assignedTo = assignedTo;
        this.taskTitle = taskTitle;
        this.taskDescription = taskDescription;
        this.priority = priority;
        this.deadline = deadline;
        this.status = "PENDING";
    }
    
    // Getters and Setters
    public int getTaskId() {
        return taskId;
    }
    
    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }
    
    public int getAssignedBy() {
        return assignedBy;
    }
    
    public void setAssignedBy(int assignedBy) {
        this.assignedBy = assignedBy;
    }
    
    public int getAssignedTo() {
        return assignedTo;
    }
    
    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }
    
    public String getTaskTitle() {
        return taskTitle;
    }
    
    public void setTaskTitle(String taskTitle) {
        this.taskTitle = taskTitle;
    }
    
    public String getTaskDescription() {
        return taskDescription;
    }
    
    public void setTaskDescription(String taskDescription) {
        this.taskDescription = taskDescription;
    }
    
    public String getPriority() {
        return priority;
    }
    
    public void setPriority(String priority) {
        this.priority = priority;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Date getDeadline() {
        return deadline;
    }
    public String getAttachmentPath() {
    return attachmentPath;
}

public void setAttachmentPath(String attachmentPath) {
    this.attachmentPath = attachmentPath;
}
    public void setDeadline(Date deadline) {
        this.deadline = deadline;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public Timestamp getCompletedAt() {
        return completedAt;
    }
    
    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }
    
    public String getAssignedByName() {
        return assignedByName;
    }
    
    public void setAssignedByName(String assignedByName) {
        this.assignedByName = assignedByName;
    }
    
    public String getAssignedToName() {
        return assignedToName;
    }
    
    public void setAssignedToName(String assignedToName) {
        this.assignedToName = assignedToName;
    }
    
    // Utility methods
    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(this.status);
    }
    
    public boolean isInProgress() {
        return "IN_PROGRESS".equalsIgnoreCase(this.status);
    }
    
    public boolean isCompleted() {
        return "COMPLETED".equalsIgnoreCase(this.status);
    }
    
    public boolean isOverdue() {
        return "OVERDUE".equalsIgnoreCase(this.status);
    }
    
    public boolean isHighPriority() {
        return "HIGH".equalsIgnoreCase(this.priority);
    }
    
    @Override
    public String toString() {
        return "Task{" +
                "taskId=" + taskId +
                ", taskTitle='" + taskTitle + '\'' +
                ", priority='" + priority + '\'' +
                ", status='" + status + '\'' +
                ", deadline=" + deadline +
                '}';
    }
}