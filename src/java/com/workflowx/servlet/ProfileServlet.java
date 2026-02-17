package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String department = request.getParameter("department");

        user.setFullName(fullName);
        user.setEmail(email);
        user.setDepartment(department);

        UserDAO userDAO = new UserDAO();
        boolean updated = userDAO.updateProfile(user);

        if (updated) {
            session.setAttribute("user", user);
            request.setAttribute("success", "Profile updated successfully!");
        } else {
            request.setAttribute("error", "Update failed. Try again.");
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
