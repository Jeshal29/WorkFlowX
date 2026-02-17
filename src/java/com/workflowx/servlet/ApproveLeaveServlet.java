package com.workflowx.servlet;

import com.workflowx.dao.LeaveDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/ApproveLeaveServlet")
public class ApproveLeaveServlet extends HttpServlet {
    
    private LeaveDAO leaveDAO;
    
    @Override
    public void init() throws ServletException {
        leaveDAO = new LeaveDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        
        if (!user.isEmployer()) {
            response.sendRedirect("employeeDashboard.jsp");
            return;
        }
        
        String leaveIdStr = request.getParameter("leaveId");
        String action = request.getParameter("action");
        String remarks = request.getParameter("remarks");
        
        if (leaveIdStr == null || action == null) {
            response.sendRedirect("approveLeaves.jsp");
            return;
        }
        
        try {
            int leaveId = Integer.parseInt(leaveIdStr);
            String status = action.equalsIgnoreCase("approve") ? "APPROVED" : "REJECTED";
            
            boolean success = leaveDAO.updateLeaveStatus(leaveId, status, user.getUserId(), remarks);
            
            if (success) {
                request.setAttribute("success", "Leave " + status.toLowerCase() + " successfully!");
            } else {
                request.setAttribute("error", "Failed to update leave status");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Invalid request: " + e.getMessage());
        }
        
        request.getRequestDispatcher("approveLeaves.jsp").forward(request, response);
    }
}