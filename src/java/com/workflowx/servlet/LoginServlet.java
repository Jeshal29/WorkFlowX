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
 * LoginServlet - Handles user authentication
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    // Add these methods to your existing LoginServlet.java

@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String role = request.getParameter("role");

    UserDAO userDAO = new UserDAO();
    User user = userDAO.authenticateUser(username, password);

    // ❌ If user not found
    if (user == null) {
        request.setAttribute("error", "Invalid username or password");
        if ("ADMIN".equals(role)) {
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
        return;
    }

    // ❌ If account is deactivated
    if (!user.isActive()) {
        request.setAttribute("error", "Your account has been deactivated. Contact admin.");
        if ("ADMIN".equals(role)) {
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
        return;
    }

    // ❌ If role does not match selected login type
    if (role != null && !user.getRole().equalsIgnoreCase(role)) {
        request.setAttribute("error", "Invalid credentials for " + role + " login");
        if ("ADMIN".equals(role)) {
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
        return;
    }

    // ✅ Update last login
    userDAO.updateLastLogin(user.getUserId());

    // ✅ Create session
    HttpSession session = request.getSession();
    session.setAttribute("user", user);
    session.setMaxInactiveInterval(30 * 60); // 30 minutes

    // ✅ Redirect based on role
    if (user.isAdmin()) {
        response.sendRedirect("adminDashboard.jsp");
    } else if (user.isEmployer()) {
        response.sendRedirect("employerDashboard.jsp");
    } else {
        response.sendRedirect("employeeDashboard.jsp");
    }
}

}
