package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/AdminCreateEmployerServlet")
public class AdminCreateEmployerServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Security: Only admins can access this servlet
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get form parameters
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String department = request.getParameter("department");
        
        UserDAO userDAO = new UserDAO();
        
        // Validation
        if (username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            department == null || department.trim().isEmpty()) {
            
            request.setAttribute("error", "All fields are required!");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
            return;
        }
        
        // Check password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
            return;
        }
        
        // Check password length
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters!");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
            return;
        }
        
        // Check if username already exists
        if (userDAO.usernameExists(username)) {
            request.setAttribute("error", "Username already exists!");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
            return;
        }
        
        // Check if email already exists
        if (userDAO.emailExists(email)) {
            request.setAttribute("error", "Email already exists!");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
            return;
        }
        
        // Create new employer user
        User newEmployer = new User();
        newEmployer.setUsername(username);
        newEmployer.setEmail(email);
        newEmployer.setPasswordHash(password); // Will be hashed in UserDAO
        newEmployer.setFullName(fullName);
        newEmployer.setRole("EMPLOYER"); // Fixed role
        newEmployer.setDepartment(department);
        newEmployer.setProfilePicture("default.jpg");
        newEmployer.setActive(true);
        
        // Register the employer
        boolean success = userDAO.register(newEmployer);
        
        if (success) {
            request.setAttribute("success", "Employer account created successfully for " + fullName + "!");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("adminCreateEmployer.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Security: Only admins can access this page
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        response.sendRedirect("adminCreateEmployer.jsp");
    }
}