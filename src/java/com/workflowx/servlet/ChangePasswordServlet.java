package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ChangePasswordServlet - Handles password updates
 */
@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validation
        if (currentPassword == null || currentPassword.trim().isEmpty()) {
            request.setAttribute("error", "Current password is required");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }
        
        if (newPassword == null || newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New passwords do not match");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }
        
        // Verify current password
        User verifiedUser = userDAO.login(user.getUsername(), currentPassword);
        if (verifiedUser == null) {
            request.setAttribute("error", "Current password is incorrect");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }
        
        // Update password in database
        boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);
        
        if (updated) {
            request.setAttribute("success", "Password changed successfully!");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to update password. Please try again.");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("changePassword.jsp");
    }
}