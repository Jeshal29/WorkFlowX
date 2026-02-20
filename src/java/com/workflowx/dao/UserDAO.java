package com.workflowx.dao;

import com.workflowx.model.User;
import com.workflowx.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO - Data Access Object for User operations
 * Handles all database operations related to users
 */
public class UserDAO {
    
    /**
     * Register a new user
     * @param user User object with registration details
     * @return true if registration successful, false otherwise
     */
    public boolean register(User user) {
        String sql = "INSERT INTO users (username, email, password_hash, full_name, " +
             "role, department, profile_picture, theme_preference) " +
             "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getUsername());
stmt.setString(2, user.getEmail());
stmt.setString(3, user.getPasswordHash());
stmt.setString(4, user.getFullName());
stmt.setString(5, user.getRole());
stmt.setString(6, user.getDepartment());
stmt.setString(7, user.getProfilePicture());
stmt.setString(8, user.getThemePreference());

            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in register(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Authenticate user - verify credentials (supports all roles: EMPLOYEE, EMPLOYER, ADMIN)
     * @param username Username entered by user
     * @param password Plain text password entered by user
     * @return User object if authentication successful, null otherwise
     */
    public User authenticateUser(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedPasswordHash = rs.getString("password_hash");
                
                // Compare password (you should use BCrypt.checkpw() for hashed passwords)
                // For now, using simple comparison (CHANGE THIS in production!)
                if (password.equals(storedPasswordHash)) {
                    // Create user object from result set
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setFullName(rs.getString("full_name"));
                    user.setRole(rs.getString("role"));
                    user.setDepartment(rs.getString("department"));
                    user.setProfilePicture(rs.getString("profile_picture"));
                    user.setThemePreference(rs.getString("theme_preference"));
                    user.setActive(rs.getBoolean("is_active"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setLastLogin(rs.getTimestamp("last_login"));
                    
                    return user;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error in authenticateUser(): " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;  // Authentication failed
    }
    
    /**
     * Login user - verify credentials (legacy method - use authenticateUser instead)
     * @param username Username entered by user
     * @param password Plain text password entered by user
     * @return User object if login successful, null otherwise
     */
    public User login(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedPasswordHash = rs.getString("password_hash");
                
                // Compare password (you should use BCrypt.checkpw() for hashed passwords)
                // For now, using simple comparison (CHANGE THIS in production!)
                if (password.equals(storedPasswordHash)) {
                    // Create user object from result set
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setFullName(rs.getString("full_name"));
                    user.setRole(rs.getString("role"));
                    user.setDepartment(rs.getString("department"));
                    user.setProfilePicture(rs.getString("profile_picture"));
                    user.setThemePreference(rs.getString("theme_preference"));
                    user.setActive(rs.getBoolean("is_active"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setLastLogin(rs.getTimestamp("last_login"));
                    
                    // Update last login time
                    updateLastLogin(user.getUserId());
                    
                    return user;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error in login(): " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;  // Login failed
    }
    
    /**
     * Get user by ID
     * @param userId User ID
     * @return User object if found, null otherwise
     */
    public List<User> getAllUsers() {
    List<User> users = new ArrayList<>();

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users");
         ResultSet rs = stmt.executeQuery()) {

        while (rs.next()) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setFullName(rs.getString("full_name"));
            user.setEmail(rs.getString("email"));
            user.setRole(rs.getString("role"));
            user.setDepartment(rs.getString("department"));
            user.setActive(rs.getBoolean("is_active"));

            users.add(user);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return users;  // NEVER return null
}

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setDepartment(rs.getString("department"));
                user.setProfilePicture(rs.getString("profile_picture"));
                user.setThemePreference(rs.getString("theme_preference"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                
                return user;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getUserById(): " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get user by username
     * @param username Username
     * @return User object if found, null otherwise
     */
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setRole(rs.getString("role"));
                user.setDepartment(rs.getString("department"));
                user.setProfilePicture(rs.getString("profile_picture"));
                user.setThemePreference(rs.getString("theme_preference"));
                user.setActive(rs.getBoolean("is_active"));
                
                return user;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in getUserByUsername(): " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    public List<User> getUsersByStatus(boolean status) {

    List<User> users = new ArrayList<>();
    String sql = "SELECT * FROM users WHERE is_active = ?";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setBoolean(1, status);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            User user = new User();

            user.setUserId(rs.getInt("user_id"));
            user.setFullName(rs.getString("full_name"));
            user.setEmail(rs.getString("email"));
            user.setRole(rs.getString("role"));
            user.setDepartment(rs.getString("department"));
            user.setActive(rs.getBoolean("is_active"));

            users.add(user);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return users;
}

    /**
     * Get all active employees (for employer/admin to view)
     * @return List of all active employees
     */
    public List<User> getActiveEmployees() {
        List<User> employees = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role='EMPLOYEE' AND is_active=TRUE ORDER BY full_name";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setDepartment(rs.getString("department"));
                user.setActive(rs.getBoolean("is_active"));

                employees.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return employees;
    }
    
    /**
     * Get active employees by department (for employers)
     * @param department Department name
     * @return List of active employees in the department
     */
    public List<User> getActiveEmployeesByDepartment(String department) {
        List<User> employees = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role='EMPLOYEE' AND is_active=TRUE AND department=? ORDER BY full_name";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, department);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setDepartment(rs.getString("department"));
                user.setActive(rs.getBoolean("is_active"));

                employees.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return employees;
    }
    
    /**
     * Get all inactive employees
     * @return List of inactive employees
     */
    public List<User> getInactiveEmployees() {
        List<User> employees = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role='EMPLOYEE' AND is_active=FALSE ORDER BY full_name";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setDepartment(rs.getString("department"));
                user.setActive(rs.getBoolean("is_active"));

                employees.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return employees;
    }
    
    /**
     * Check if username already exists
     * @param username Username to check
     * @return true if exists, false otherwise
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in usernameExists(): " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if email already exists
     * @param email Email to check
     * @return true if exists, false otherwise
     */
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error in emailExists(): " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update last login timestamp
     * @param userId User ID
     */
    public void updateLastLogin(int userId) {
        String sql = "UPDATE users SET last_login = NOW() WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error in updateLastLogin(): " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Update user profile
     * @param user User object with updated details
     * @return true if update successful, false otherwise
     */
    public boolean updateProfile(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, department = ?, " +
                    "profile_picture = ? WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getDepartment());
            stmt.setString(4, user.getProfilePicture());
            stmt.setInt(5, user.getUserId());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateProfile(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update user theme preference
     * @param userId User ID
     * @param theme Theme (LIGHT or DARK)
     * @return true if update successful, false otherwise
     */
    public boolean updateTheme(int userId, String theme) {
        String sql = "UPDATE users SET theme_preference = ? WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, theme);
            stmt.setInt(2, userId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updateTheme(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update user active status (activate/deactivate)
     * @param userId User ID
     * @param status Active status (true/false)
     */
    public void updateUserStatus(int userId, boolean status) {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, status);
            stmt.setInt(2, userId);
            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            // NOTE: In production, hash the password using BCrypt!
            // newPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            stmt.setString(1, newPassword);
            stmt.setInt(2, userId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error in updatePassword(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
        public List<User> getAllActiveUsers() {
    List<User> users = new ArrayList<>();
    String sql = "SELECT * FROM users WHERE is_active = TRUE AND role IN ('EMPLOYEE', 'EMPLOYER') ORDER BY full_name";
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql);
         ResultSet rs = stmt.executeQuery()) {
        
        while (rs.next()) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setUsername(rs.getString("username"));
            user.setEmail(rs.getString("email"));
            user.setFullName(rs.getString("full_name"));
            user.setRole(rs.getString("role"));
            user.setDepartment(rs.getString("department"));
            user.setProfilePicture(rs.getString("profile_picture"));
            user.setThemePreference(rs.getString("theme_preference"));
            user.setActive(rs.getBoolean("is_active"));
            user.setCreatedAt(rs.getTimestamp("created_at"));
            user.setLastLogin(rs.getTimestamp("last_login"));
            users.add(user);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return users;
}
        public List<User> getEmployeesByDepartment(String department) {
    List<User> employees = new ArrayList<>();
    String sql = "SELECT * FROM users WHERE role = 'EMPLOYEE' AND is_active = TRUE " +
                 "AND department = ? ORDER BY full_name";
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, department);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setUsername(rs.getString("username"));
            user.setEmail(rs.getString("email"));
            user.setFullName(rs.getString("full_name"));
            user.setRole(rs.getString("role"));
            user.setDepartment(rs.getString("department"));
            user.setProfilePicture(rs.getString("profile_picture"));
            employees.add(user);
        }
    } catch (SQLException e) {
        System.err.println("Error in getEmployeesByDepartment: " + e.getMessage());
    }
    return employees;
}
        public List<User> getEmployeesByDepartmentAndStatus(String department, boolean active) {
    List<User> employees = new ArrayList<>();
    String sql = "SELECT * FROM users WHERE role = 'EMPLOYEE' AND department = ? " +
                 "AND is_active = ? ORDER BY full_name";
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, department);
        stmt.setBoolean(2, active);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            User user = new User();
            user.setUserId(rs.getInt("user_id"));
            user.setUsername(rs.getString("username"));
            user.setEmail(rs.getString("email"));
            user.setFullName(rs.getString("full_name"));
            user.setRole(rs.getString("role"));
            user.setDepartment(rs.getString("department"));
            user.setProfilePicture(rs.getString("profile_picture"));
            user.setActive(rs.getBoolean("is_active"));
            employees.add(user);
        }
    } catch (SQLException e) {
        System.err.println("Error in getEmployeesByDepartmentAndStatus: " + e.getMessage());
    }
    return employees;
}
        public List<User> getUsersByRoleAndStatus(String role, boolean status) {
    List<User> list = new ArrayList<>();
    String sql = "SELECT * FROM users WHERE role=? AND is_active=?";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, role);
        ps.setBoolean(2, status);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            User u = new User();
            u.setUserId(rs.getInt("user_id"));
            u.setFullName(rs.getString("full_name"));
            u.setEmail(rs.getString("email"));
            u.setRole(rs.getString("role"));
            u.setDepartment(rs.getString("department"));
            u.setActive(rs.getBoolean("is_active"));
            list.add(u);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}
    }
