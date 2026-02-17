package com.workflowx.servlet;

import com.workflowx.dao.TaskDAO;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/UpdateTaskServlet")
public class UpdateTaskServlet extends HttpServlet {
    
    private TaskDAO taskDAO;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String taskIdStr = request.getParameter("taskId");
        String newStatus = request.getParameter("status");
        
        if (taskIdStr == null || newStatus == null) {
            response.sendRedirect("tasks.jsp");
            return;
        }
        
        try {
            int taskId = Integer.parseInt(taskIdStr);
            boolean success = taskDAO.updateTaskStatus(taskId, newStatus);
            
            if (success) {
                request.setAttribute("success", "Task status updated!");
            } else {
                request.setAttribute("error", "Failed to update task");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Invalid task ID");
        }
        
        request.getRequestDispatcher("tasks.jsp").forward(request, response);
    }
}