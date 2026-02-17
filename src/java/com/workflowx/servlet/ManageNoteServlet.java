package com.workflowx.servlet;

import com.workflowx.dao.NoteDAO;
import com.workflowx.model.Note;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/ManageNoteServlet")
public class ManageNoteServlet extends HttpServlet {
    
    private NoteDAO noteDAO;
    
    @Override
    public void init() throws ServletException {
        noteDAO = new NoteDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            createNote(request, user);
        } else if ("update".equals(action)) {
            updateNote(request, user);
        } else if ("delete".equals(action)) {
            deleteNote(request, user);
        } else if ("togglePin".equals(action)) {
            togglePin(request, user);
        }
        
        request.getRequestDispatcher("notes.jsp").forward(request, response);
    }
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    response.sendRedirect("notes.jsp");
}
    private void createNote(HttpServletRequest request, User user) {
    String title = request.getParameter("noteTitle");
    String content = request.getParameter("noteContent");
    String isPinnedStr = request.getParameter("isPinned");
    
    if (content == null || content.trim().isEmpty()) {
        request.setAttribute("error", "Note content is required");
        return;
    }
    
    Note note = new Note();
    note.setUserId(user.getUserId());
    note.setTitle(title);
    note.setContent(content.trim());
    note.setPinned("on".equals(isPinnedStr));
    note.setAttachmentPath(null);  // ADD THIS LINE
    
    int noteId = noteDAO.createNote(note);
    
    if (noteId > 0) {
        request.setAttribute("success", "Note created successfully!");
    } else {
        request.setAttribute("error", "Failed to create note");
    }
}
    
    private void updateNote(HttpServletRequest request, User user) {
    String noteIdStr = request.getParameter("noteId");
    String title = request.getParameter("noteTitle");
    String content = request.getParameter("noteContent");
    String isPinnedStr = request.getParameter("isPinned");
    
    try {
        int noteId = Integer.parseInt(noteIdStr);
        
        Note note = new Note();
        note.setNoteId(noteId);
        note.setUserId(user.getUserId());
        note.setTitle(title);
        note.setContent(content);
        note.setPinned("on".equals(isPinnedStr));
        note.setAttachmentPath(null);  // ADD THIS LINE
        
        boolean success = noteDAO.updateNote(note);
        
        if (success) {
            request.setAttribute("success", "Note updated successfully!");
        } else {
            request.setAttribute("error", "Failed to update note");
        }
        
    } catch (Exception e) {
        request.setAttribute("error", "Error: " + e.getMessage());
    }

    }
    
    private void deleteNote(HttpServletRequest request, User user) {
        String noteIdStr = request.getParameter("noteId");
        
        try {
            int noteId = Integer.parseInt(noteIdStr);
            boolean success = noteDAO.deleteNote(noteId, user.getUserId());
            
            if (success) {
                request.setAttribute("success", "Note deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete note");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
    }
    
    private void togglePin(HttpServletRequest request, User user) {
        String noteIdStr = request.getParameter("noteId");
        
        try {
            int noteId = Integer.parseInt(noteIdStr);
            noteDAO.togglePin(noteId, user.getUserId());
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
    }
}