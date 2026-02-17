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
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet("/ApplyLeaveServlet")
public class ApplyLeaveServlet extends HttpServlet {
    
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
        
        String leaveType = request.getParameter("leaveType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String reason = request.getParameter("reason");
        
        if (leaveType == null || startDateStr == null || endDateStr == null) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("leaves.jsp").forward(request, response);
            return;
        }
        
        try {
            Date startDate = Date.valueOf(startDateStr);
            Date endDate = Date.valueOf(endDateStr);
            
            LocalDate start = startDate.toLocalDate();
            LocalDate end = endDate.toLocalDate();
            int totalDays = (int) ChronoUnit.DAYS.between(start, end) + 1;
            
            if (totalDays <= 0) {
                request.setAttribute("error", "End date must be after start date");
                request.getRequestDispatcher("leaves.jsp").forward(request, response);
                return;
            }
            
            Leave leave = new Leave();
            leave.setEmployeeId(user.getUserId());
            leave.setLeaveType(leaveType);
            leave.setStartDate(startDate);
            leave.setEndDate(endDate);
            leave.setTotalDays(totalDays);
            leave.setReason(reason != null ? reason.trim() : "");
            
            int leaveId = leaveDAO.applyLeave(leave);
            
            if (leaveId > 0) {
                request.setAttribute("success", "Leave application submitted successfully!");
            } else {
                request.setAttribute("error", "Failed to submit leave application");
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Invalid input: " + e.getMessage());
        }
        
        request.getRequestDispatcher("leaves.jsp").forward(request, response);
    }
}