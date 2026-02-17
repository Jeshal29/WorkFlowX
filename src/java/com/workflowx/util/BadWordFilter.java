package com.workflowx.util;

import com.workflowx.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * BadWordFilter - Utility class for filtering inappropriate words
 */
public class BadWordFilter {
    
    private static List<String> badWords = null;
    
    /**
     * Load bad words from database
     */
    private static void loadBadWords() {
        if (badWords != null) {
            return;  // Already loaded
        }
        
        badWords = new ArrayList<>();
        String sql = "SELECT word FROM bad_words";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                badWords.add(rs.getString("word").toLowerCase());
            }
            
            System.out.println("Loaded " + badWords.size() + " bad words from database");
            
        } catch (SQLException e) {
            System.err.println("Error loading bad words: " + e.getMessage());
        }
    }
    
    /**
     * Check if text contains bad words
     * @param text Text to check
     * @return true if contains bad words, false otherwise
     */
    public static boolean containsBadWords(String text) {
        if (text == null || text.trim().isEmpty()) {
            return false;
        }
        
        loadBadWords();
        
        String lowerText = text.toLowerCase();
        
        for (String badWord : badWords) {
            // Check for whole word match (not partial)
            if (lowerText.matches(".*\\b" + badWord + "\\b.*")) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Censor bad words in text
     * @param text Text to censor
     * @return Censored text with bad words replaced by ****
     */
    public static String censorText(String text) {
        if (text == null || text.trim().isEmpty()) {
            return text;
        }
        
        loadBadWords();
        
        String censoredText = text;
        
        for (String badWord : badWords) {
            // Replace bad word with asterisks (case-insensitive)
            String replacement = "****";
            censoredText = censoredText.replaceAll("(?i)\\b" + badWord + "\\b", replacement);
        }
        
        return censoredText;
    }
    
    /**
     * Get list of bad words found in text
     * @param text Text to analyze
     * @return List of bad words found
     */
    public static List<String> getBadWordsFound(String text) {
        List<String> found = new ArrayList<>();
        
        if (text == null || text.trim().isEmpty()) {
            return found;
        }
        
        loadBadWords();
        
        String lowerText = text.toLowerCase();
        
        for (String badWord : badWords) {
            if (lowerText.matches(".*\\b" + badWord + "\\b.*")) {
                found.add(badWord);
            }
        }
        
        return found;
    }
    
    /**
     * Reload bad words from database (useful if list is updated)
     */
    public static void reloadBadWords() {
        badWords = null;
        loadBadWords();
    }
    
    /**
     * Test method
     */
    public static void main(String[] args) {
        // Test the filter
        String testMessage = "This is a damn stupid message";
        
        System.out.println("Original: " + testMessage);
        System.out.println("Contains bad words: " + containsBadWords(testMessage));
        System.out.println("Bad words found: " + getBadWordsFound(testMessage));
        System.out.println("Censored: " + censorText(testMessage));
    }
}