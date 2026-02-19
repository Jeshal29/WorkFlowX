package com.workflowx.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    
    
    private static final String DB_URL = System.getenv("DATABASE_URL") != null 
        ? System.getenv("DATABASE_URL") 
        : "jdbc:mysql://localhost:3306/workflowx_db?useSSL=false";
    
    private static final String DB_USER = System.getenv("DATABASE_USER") != null 
        ? System.getenv("DATABASE_USER") 
        : "root";
    
    private static final String DB_PASSWORD = System.getenv("DATABASE_PASSWORD") != null 
        ? System.getenv("DATABASE_PASSWORD") 
        : "8957";
    
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    
    public static Connection getConnection() throws SQLException {
        Connection connection = null;
        
        try {
            Class.forName(DB_DRIVER);
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("Database connected successfully!");
            
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found!");
            e.printStackTrace();
            throw new SQLException("Driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Connection failed!");
            e.printStackTrace();
            throw e;
        }
        
        return connection;
    }
    
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Database connection closed.");
            } catch (SQLException e) {
                System.err.println("Error closing connection!");
                e.printStackTrace();
            }
        }
    }
    
    // Test the connection
    public static void main(String[] args) {
        try {
            Connection conn = getConnection();
            if (conn != null) {
                System.out.println("✓ Connection test successful!");
                closeConnection(conn);
            }
        } catch (SQLException e) {
            System.err.println("✗ Connection test failed!");
            e.printStackTrace();
        }
    }
}