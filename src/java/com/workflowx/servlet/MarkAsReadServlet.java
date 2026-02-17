package com.workflowx.servlet;

import java.io.IOException;
import com.workflowx.dao.MessageDAO;
import com.workflowx.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Marks all messages from a specific sender as read.
 */
@WebServlet("/MarkAsReadServlet")
public class MarkAsReadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get current user from session
        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get senderId from request
        String senderIdStr = request.getParameter("senderId");
        if (senderIdStr == null || senderIdStr.isEmpty()) return;

        int senderId = Integer.parseInt(senderIdStr);

        // Mark messages as read in the database
        MessageDAO dao = new MessageDAO();
        dao.markMessagesAsRead(currentUser.getUserId(), senderId);

        // Optional: send OK response for AJAX
        response.setStatus(HttpServletResponse.SC_OK);
    }

    @Override
    public String getServletInfo() {
        return "Marks all messages from a specific sender as read";
    }
}
