package com.workflowx.dao;

import com.workflowx.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatbotDAO {
    
    public String getAnswer(String userQuestion) {
        String answer = null;
        String sql = "SELECT answer, priority FROM chatbot_faq " +
                    "WHERE is_active = TRUE AND " +
                    "(LOWER(question) LIKE ? OR LOWER(keywords) LIKE ?) " +
                    "ORDER BY priority DESC, faq_id ASC LIMIT 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchTerm = "%" + userQuestion.toLowerCase() + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                answer = rs.getString("answer");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return answer;
    }
    
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM chatbot_faq WHERE is_active = TRUE ORDER BY category";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return categories;
    }
    
    public List<String> getQuestionsByCategory(String category) {
        List<String> questions = new ArrayList<>();
        String sql = "SELECT question FROM chatbot_faq WHERE category = ? AND is_active = TRUE ORDER BY priority DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, category);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                questions.add(rs.getString("question"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return questions;
    }
}