package com.workflowx.servlet;

import com.workflowx.dao.ChatbotDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/ChatbotServlet")
public class ChatbotServlet extends HttpServlet {
    
    private ChatbotDAO chatbotDAO;
    
    @Override
    public void init() throws ServletException {
        chatbotDAO = new ChatbotDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String userMessage = request.getParameter("message");
        
        if (userMessage == null || userMessage.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"Please enter a message\"}");
            return;
        }
        
        String answer = chatbotDAO.getAnswer(userMessage.trim());
        
        if (answer != null) {
            out.print("{\"success\": true, \"message\": \"" + escapeJson(answer) + "\"}");
        } else {
            out.print("{\"success\": true, \"message\": \"I'm sorry, I couldn't find an answer to that question. Please try rephrasing or contact support.\"}");
        }
        
        out.flush();
    }
    
    private String escapeJson(String str) {
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}