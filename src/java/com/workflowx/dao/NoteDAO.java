package com.workflowx.dao;

import com.workflowx.model.Note;
import com.workflowx.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NoteDAO {
    
    // CREATE note
    public int createNote(Note note) {
        String sql = "INSERT INTO notes (user_id, title, content, attachment_path, is_pinned) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, note.getUserId());
            stmt.setString(2, note.getTitle());
            stmt.setString(3, note.getContent());
            stmt.setString(4, note.getAttachmentPath());
            stmt.setBoolean(5, note.isPinned());
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
    
    // READ notes for a user
    public List<Note> getUserNotes(int userId) {
        List<Note> notes = new ArrayList<>();
        String sql = "SELECT * FROM notes WHERE user_id = ? ORDER BY is_pinned DESC, created_at DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Note note = new Note();
                note.setNoteId(rs.getInt("note_id"));
                note.setUserId(rs.getInt("user_id"));
                note.setTitle(rs.getString("title"));
                note.setContent(rs.getString("content"));
                note.setAttachmentPath(rs.getString("attachment_path"));
                note.setPinned(rs.getBoolean("is_pinned"));
                note.setCreatedAt(rs.getTimestamp("created_at"));
                note.setUpdatedAt(rs.getTimestamp("updated_at"));
                notes.add(note);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return notes;
    }
    
    // UPDATE note
    public boolean updateNote(Note note) {
        String sql = "UPDATE notes SET title=?, content=?, attachment_path=?, is_pinned=? WHERE note_id=? AND user_id=?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, note.getTitle());
            stmt.setString(2, note.getContent());
            stmt.setString(3, note.getAttachmentPath());
            stmt.setBoolean(4, note.isPinned());
            stmt.setInt(5, note.getNoteId());
            stmt.setInt(6, note.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // DELETE note
    public boolean deleteNote(int noteId, int userId) {
        String sql = "DELETE FROM notes WHERE note_id=? AND user_id=?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, noteId);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // TOGGLE PIN
    public boolean togglePin(int noteId, int userId) {
        String sql = "UPDATE notes SET is_pinned = NOT is_pinned WHERE note_id = ? AND user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, noteId);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}