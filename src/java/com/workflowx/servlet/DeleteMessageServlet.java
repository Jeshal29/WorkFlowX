package com.workflowx.servlet;

import com.workflowx.dao.MessageDAO;
import com.workflowx.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteMessageServlet")
public class DeleteMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        int messageId = Integer.parseInt(req.getParameter("messageId"));

        MessageDAO dao = new MessageDAO();
        dao.deleteMessage(messageId, currentUser.getUserId());
        resp.sendRedirect(req.getHeader("referer"));
    }
}


