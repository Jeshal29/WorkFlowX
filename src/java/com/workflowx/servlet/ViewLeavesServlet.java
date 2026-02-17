package com.workflowx.servlet;

import com.workflowx.dao.LeaveDAO;
import com.workflowx.model.Leave;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * ViewLeavesServlet
 * Handles displaying leaves for both employees and employers
 */
@WebServlet("/ViewLeavesServlet")
public class ViewLeavesServlet extends HttpServlet {
    
    private LeaveDAO leaveDAO;
    
    @Override
    public void init() throws ServletException {
        leaveDAO = new LeaveDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        
        // Check if user is employer or employee
        if (user.isEmployer()) {
            // For employers, show pending leave approvals
            List<Leave> pendingLeaves = leaveDAO.getAllPendingLeaves();
            request.setAttribute("pendingLeaves", pendingLeaves);
            request.getRequestDispatcher("approveLeaves.jsp").forward(request, response);
        } else {
            // For employees, show their own leaves
            List<Leave> myLeaves = leaveDAO.getEmployeeLeaves(user.getUserId());
            request.setAttribute("myLeaves", myLeaves);
            request.getRequestDispatcher("leaves.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}