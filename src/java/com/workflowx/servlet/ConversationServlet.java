package com.workflowx.servlet;

import com.workflowx.dao.MessageDAO;
import com.workflowx.model.Message;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/ConversationServlet")
public class ConversationServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        int currentUserId = (int) session.getAttribute("userId");
        int chatUserId = Integer.parseInt(request.getParameter("userId"));

        MessageDAO dao = new MessageDAO();
        List<Message> messages = dao.getConversation(currentUserId, chatUserId);

        request.setAttribute("messages", messages);
        request.getRequestDispatcher("conversation.jsp").forward(request, response);
    }
}
