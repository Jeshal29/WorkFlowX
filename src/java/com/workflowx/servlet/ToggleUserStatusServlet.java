package com.workflowx.servlet;
import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;
import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ToggleUserStatusServlet")
public class ToggleUserStatusServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if (!user.isEmployer() && !user.isAdmin()) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            String userIdStr = request.getParameter("userId");
            String currentStatusStr = request.getParameter("currentStatus");
            String returnPage = request.getParameter("returnPage");
            
            if (userIdStr == null || currentStatusStr == null) {
                String redirect = (returnPage != null) ? returnPage : "employees.jsp";
                response.sendRedirect(redirect + "?error=missing_params");
                return;
            }
            
            int userId = Integer.parseInt(userIdStr);
            boolean currentStatus = Boolean.parseBoolean(currentStatusStr);
            
            // Fetch target user
            UserDAO userDAO = new UserDAO();
            User targetUser = userDAO.getUserById(userId);
            
            if (targetUser == null) {
                String redirect = (returnPage != null) ? returnPage : "employees.jsp";
                response.sendRedirect(redirect + "?error=user_not_found");
                return;
            }
            
            // Employer can only toggle employees in their own department
            if (user.isEmployer()) {
                if (!targetUser.isEmployee()) {
                    response.sendRedirect("employees.jsp?error=unauthorized");
                    return;
                }
                if (!targetUser.getDepartment().equals(user.getDepartment())) {
                    response.sendRedirect("employees.jsp?error=unauthorized");
                    return;
                }
            }
            
            // Admin can toggle Employers and Employees but NOT other Admins
            if (user.isAdmin()) {
                if (targetUser.isAdmin()) {
                    response.sendRedirect("manageEmployers.jsp?error=unauthorized");
                    return;
                }
            }
            
            // Toggle status
            boolean newStatus = !currentStatus;
            
            // Update in database
            userDAO.updateUserStatus(userId, newStatus);
            
            // Determine redirect page
            String redirectPage;
            if (returnPage != null && !returnPage.isEmpty()) {
                redirectPage = returnPage;
            } else if (user.isAdmin()) {
                redirectPage = "manageEmployers.jsp";
            } else {
                redirectPage = "employees.jsp";
            }
            
            String action = newStatus ? "activated" : "deactivated";
            response.sendRedirect(redirectPage + "?success=" + action);
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            String redirect = (user.isAdmin()) ? "manageEmployers.jsp" : "employees.jsp";
            response.sendRedirect(redirect + "?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            String redirect = (user.isAdmin()) ? "manageEmployers.jsp" : "employees.jsp";
            response.sendRedirect(redirect + "?error=update_failed");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
        } else if (user.isAdmin()) {
            response.sendRedirect("manageEmployers.jsp");
        } else if (user.isEmployer()) {
            response.sendRedirect("employees.jsp");
        } else {
            response.sendRedirect("login.jsp");
        }
    }
}