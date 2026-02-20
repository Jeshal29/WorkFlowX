package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ToggleUserStatusServlet")
public class ToggleUserStatusServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Security check - only EMPLOYER or ADMIN can toggle status
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if (!currentUser.isEmployer() && !currentUser.isAdmin()) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // Get parameters
            String userIdStr = request.getParameter("userId");
            String currentStatusStr = request.getParameter("currentStatus");
            String returnPage = request.getParameter("returnPage"); // Optional parameter
            
            if (userIdStr == null || currentStatusStr == null) {
                String redirect = (returnPage != null) ? returnPage : "employees.jsp";
                response.sendRedirect(redirect + "?error=missing_params");
                return;
            }
            
            int userId = Integer.parseInt(userIdStr);
            boolean currentStatus = Boolean.parseBoolean(currentStatusStr);
            
            // Toggle the status
            boolean newStatus = !currentStatus;
            
            // Update in database
            UserDAO userDAO = new UserDAO();
            userDAO.updateUserStatus(userId, newStatus);
            
            // Determine redirect page
            String redirectPage = "employees.jsp"; // Default
            if (returnPage != null && !returnPage.isEmpty()) {
                redirectPage = returnPage;
            } else if (currentUser.isAdmin()) {
                redirectPage = "manageEmployers.jsp"; // Admin goes to manageUsers
            }
            
            // Redirect back with success message
            String action = newStatus ? "activated" : "deactivated";
            response.sendRedirect(redirectPage + "?success=" + action);
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            String redirect = (currentUser.isAdmin()) ? "manageEmployers.jsp" : "employees.jsp";
            response.sendRedirect(redirect + "?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            String redirect = (currentUser.isAdmin()) ? "manageEmployers.jsp" : "employees.jsp";
            response.sendRedirect(redirect + "?error=update_failed");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
        } else if (currentUser.isAdmin()) {
            response.sendRedirect("manageEmployers.jsp");
        } else if (currentUser.isEmployer()) {
            response.sendRedirect("employees.jsp");
        } else {
            response.sendRedirect("login.jsp");
        }
    }
}