package com.workflowx.servlet;

import com.workflowx.dao.TaskDAO;
import com.workflowx.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

/**
 * AssignTaskServlet - Handles task assignment with optional file attachment
 */
@WebServlet("/AssignTaskServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 10,       // 10 MB
    maxRequestSize = 1024 * 1024 * 15     // 15 MB
)
public class AssignTaskServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads/tasks";
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
        
        User user = (User) session.getAttribute("user");
        
        // Only employers can assign tasks
        if (!user.isEmployer()) {
            response.sendRedirect("employeeDashboard.jsp");
            return;
        }
        
        try {
            // Get form parameters
            String employeeIdStr = request.getParameter("employeeId");
            String taskTitle = request.getParameter("taskTitle");
            String taskDescription = request.getParameter("taskDescription");
            String priority = request.getParameter("priority");
            String deadlineStr = request.getParameter("deadline");
            
            // Validation
            if (employeeIdStr == null || employeeIdStr.trim().isEmpty()) {
                request.setAttribute("error", "Please select an employee");
                request.getRequestDispatcher("assignTask.jsp").forward(request, response);
                return;
            }
            
            if (taskTitle == null || taskTitle.trim().isEmpty()) {
                request.setAttribute("error", "Task title is required");
                request.getRequestDispatcher("assignTask.jsp").forward(request, response);
                return;
            }
            
            if (deadlineStr == null || deadlineStr.trim().isEmpty()) {
                request.setAttribute("error", "Deadline is required");
                request.getRequestDispatcher("assignTask.jsp").forward(request, response);
                return;
            }
            
            // Parse employee ID
            int employeeId = Integer.parseInt(employeeIdStr);
            
            // Handle file upload (optional)
            String attachmentPath = null;
            Part filePart = request.getPart("taskFile");
            
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName())
                                      .getFileName().toString();
                
                // Validate file size (10MB max)
                if (filePart.getSize() > 10 * 1024 * 1024) {
                    request.setAttribute("error", "File size must be less than 10MB");
                    request.getRequestDispatcher("assignTask.jsp").forward(request, response);
                    return;
                }
                
                // Generate unique filename
                String uniqueFileName = "task_" + System.currentTimeMillis() + "_" + fileName;
                
                // Get upload path
                String appPath = request.getServletContext().getRealPath("");
                String uploadPath = appPath + File.separator + UPLOAD_DIR;
                
                // Create directory if doesn't exist
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                // Save file
                String filePath = uploadPath + File.separator + uniqueFileName;
                filePart.write(filePath);
                
                attachmentPath = UPLOAD_DIR + "/" + uniqueFileName;
            }
            
            // Create task
            int taskId = taskDAO.createTask(
                user.getUserId(),
                employeeId,
                taskTitle.trim(),
                taskDescription != null ? taskDescription.trim() : "",
                priority != null ? priority : "MEDIUM",
                deadlineStr,
                attachmentPath
            );
            
            if (taskId > 0) {
                request.setAttribute("success", "Task assigned successfully! Task ID: " + taskId);
            } else {
                // Delete uploaded file if task creation failed
                if (attachmentPath != null) {
                    String appPath = request.getServletContext().getRealPath("");
                    File uploadedFile = new File(appPath + File.separator + attachmentPath);
                    if (uploadedFile.exists()) {
                        uploadedFile.delete();
                    }
                }
                request.setAttribute("error", "Failed to assign task");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid employee ID");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid deadline format");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        request.getRequestDispatcher("assignTask.jsp").forward(request, response);
    }
}