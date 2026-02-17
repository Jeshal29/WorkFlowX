package com.workflowx.dao;

import com.workflowx.model.Message;
import com.workflowx.util.DatabaseConnection;
import com.workflowx.util.BadWordFilter;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    // Send a message
    public int sendMessage(int senderId, int receiverId, String messageText, String attachmentPath) {
        boolean hasBadWords = BadWordFilter.containsBadWords(messageText);
        String censoredText = hasBadWords ? BadWordFilter.censorText(messageText) : messageText;
        String originalText = hasBadWords ? messageText : null;

        String sql = "INSERT INTO messages (sender_id, receiver_id, message_content, original_content, is_censored, is_read, attachment_path, sent_at) " +
                     "VALUES (?, ?, ?, ?, ?, FALSE, ?, NOW())";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, senderId);
            stmt.setInt(2, receiverId);
            stmt.setString(3, censoredText);
            stmt.setString(4, originalText);
            stmt.setBoolean(5, hasBadWords);
            stmt.setString(6, attachmentPath);

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Get chat threads (distinct users you have chatted with)
    public List<Integer> getChatUserIds(int userId) {
        List<Integer> userIds = new ArrayList<>();
        String sql = "SELECT DISTINCT CASE WHEN sender_id=? THEN receiver_id ELSE sender_id END AS chat_user " +
                     "FROM messages WHERE sender_id=? OR receiver_id=?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) userIds.add(rs.getInt("chat_user"));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return userIds;
    }

    // Get conversation with a specific user
    public List<Message> getConversation(int userId, int otherUserId) {
        List<Message> messages = new ArrayList<>();
        String sql = "SELECT m.*, s.full_name AS sender_name, r.full_name AS receiver_name " +
                     "FROM messages m " +
                     "JOIN users s ON m.sender_id=s.user_id " +
                     "JOIN users r ON m.receiver_id=r.user_id " +
                     "WHERE (sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?) " +
                     "ORDER BY sent_at ASC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, otherUserId);
            stmt.setInt(3, otherUserId);
            stmt.setInt(4, userId);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Message msg = new Message();
                msg.setMessageId(rs.getInt("message_id"));
                msg.setSenderId(rs.getInt("sender_id"));
                msg.setReceiverId(rs.getInt("receiver_id"));
                msg.setMessageContent(rs.getString("message_content"));
                msg.setOriginalContent(rs.getString("original_content"));
                msg.setCensored(rs.getBoolean("is_censored"));
                msg.setRead(rs.getBoolean("is_read"));
                msg.setAttachmentPath(rs.getString("attachment_path"));
                msg.setSentAt(rs.getTimestamp("sent_at"));
                msg.setSenderName(rs.getString("sender_name"));
                msg.setReceiverName(rs.getString("receiver_name"));
                messages.add(msg);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return messages;
    }
// Update message (only sender can edit)
public boolean updateMessage(int messageId, int userId, String newContent) {

    String sql = "UPDATE messages SET message_content=? " +
                 "WHERE message_id=? AND sender_id=?";

    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setString(1, newContent);
        stmt.setInt(2, messageId);
        stmt.setInt(3, userId);

        return stmt.executeUpdate() > 0;

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return false;
}


    // Delete a message
    public boolean deleteMessage(int messageId, int userId) {
        String sql = "DELETE FROM messages WHERE message_id=? AND (sender_id=? OR receiver_id=?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, messageId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
    public void markMessagesAsRead(int receiverId, int senderId) {
    String sql = "UPDATE messages SET is_read=TRUE WHERE receiver_id=? AND sender_id=? AND is_read=FALSE";
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, receiverId);
        stmt.setInt(2, senderId);
        stmt.executeUpdate();
    } catch(SQLException e){ e.printStackTrace(); }
    
}
    // MessageDAO.java
public boolean hasUnreadMessages(int receiverId, int senderId) {
    boolean result = false;
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT COUNT(*) FROM messages WHERE sender_id=? AND receiver_id=? AND is_read=0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    result = true;
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return result;
}


}
