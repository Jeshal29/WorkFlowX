package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/RemoveProfilePicServlet")
public class RemoveProfilePicServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            User user = (User) session.getAttribute("user");

            if (user != null) {

                user.setProfilePicture("default.jpg");

                UserDAO dao = new UserDAO();
                boolean updated = dao.updateProfile(user);

                if (updated) {
                    session.setAttribute("user", user);
                }
            }
        }

        response.sendRedirect("profile.jsp");
    }
}
