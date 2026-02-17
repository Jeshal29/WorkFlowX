package com.workflowx.servlet;

import com.workflowx.dao.MessageDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/EditMessageServlet")
public class EditMessageServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        int messageId = Integer.parseInt(request.getParameter("messageId"));
        String newContent = request.getParameter("newContent");

        MessageDAO messageDAO = new MessageDAO();

        boolean success = messageDAO.updateMessage(messageId, currentUser.getUserId(), newContent);

        // Redirect back to same chat
        String referer = request.getHeader("Referer");
        response.sendRedirect(referer);
    }
}
