package com.workflowx.model;

import java.sql.Timestamp;

/**
 * User Model Class (POJO)
 * Represents a user (Employee or Employer) in the system
 */
public class User {
    
    private int userId;
    private String username;
    private String email;
    private String passwordHash;
    private String fullName;
    private String role; // EMPLOYEE or EMPLOYER
    private String department;
    private String profilePicture;
    private String themePreference; // LIGHT or DARK
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp lastLogin;
    
    // Default Constructor
    public User() {
    }
    
    // Constructor for Registration
    public User(String username, String email, String passwordHash, 
                String fullName, String role, String department) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.role = role;
        this.department = department;
        this.themePreference = "LIGHT";
        this.isActive = true;
    }
    
    // Constructor for Login (after authentication)
    public User(int userId, String username, String email, String fullName, 
                String role, String department, String themePreference) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
        this.department = department;
        this.themePreference = themePreference;
    }
    
    // Getters and Setters
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPasswordHash() {
        return passwordHash;
    }
    
    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public String getDepartment() {
        return department;
    }
    
    public void setDepartment(String department) {
        this.department = department;
    }
    
    public String getProfilePicture() {
        return profilePicture;
    }
    
    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }
    
    public String getThemePreference() {
        return themePreference;
    }
    
    public void setThemePreference(String themePreference) {
        this.themePreference = themePreference;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getLastLogin() {
        return lastLogin;
    }
    
    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }
    
    // Utility methods
   public boolean isEmployer() {
    return "EMPLOYER".equalsIgnoreCase(this.role);
}

public boolean isEmployee() {
    return "EMPLOYEE".equalsIgnoreCase(this.role);
}

public boolean isAdmin() {
    return "ADMIN".equalsIgnoreCase(this.role);
}
    
    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", role='" + role + '\'' +
                ", department='" + department + '\'' +
                '}';
    }
}