package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/ThemeServlet")
public class ThemeServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user != null) {
            String currentTheme = request.getParameter("currentTheme");
            String newTheme = currentTheme.equals("DARK") ? "LIGHT" : "DARK";

            UserDAO userDAO = new UserDAO();
            userDAO.updateTheme(user.getUserId(), newTheme);

            user.setThemePreference(newTheme);
            session.setAttribute("user", user);
        }

        response.sendRedirect(request.getHeader("Referer"));
    }
}
