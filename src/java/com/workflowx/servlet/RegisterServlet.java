package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * RegisterServlet - Handles user registration
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get form parameters
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String role = request.getParameter("role");
        String department = request.getParameter("department");
        
        // Validation
        if("ADMIN".equalsIgnoreCase(role)){
    response.sendRedirect("register.jsp?error=invalidrole");
    return;
}

        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "Username is required");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (password == null || password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Full name is required");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        if (role == null || role.trim().isEmpty()) {
            request.setAttribute("error", "Please select a role");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // Check if username already exists
        if (userDAO.usernameExists(username)) {
            request.setAttribute("error", "Username already exists");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // Check if email already exists
        if (userDAO.emailExists(email)) {
            request.setAttribute("error", "Email already registered");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // Create user object
        // NOTE: In production, hash the password using BCrypt!
        // For now, storing plain text (CHANGE THIS!)
        User user = new User();
        user.setUsername(username.trim());
        user.setEmail(email.trim());
        user.setPasswordHash(password);  // Should be: BCrypt.hashpw(password, BCrypt.gensalt())
        user.setFullName(fullName.trim());
        user.setRole(role.toUpperCase());
        user.setDepartment(department != null ? department.trim() : "");
        user.setThemePreference("LIGHT");
        user.setActive(true);
        
        // Register user
        boolean success = userDAO.register(user);
        
        if (success) {
            // Registration successful
            request.setAttribute("success", "Registration successful! Please login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            // Registration failed
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to registration page
        response.sendRedirect("register.jsp");
    }
}