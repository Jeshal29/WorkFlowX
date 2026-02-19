package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
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
 * UploadProfilePicServlet - Handles profile picture uploads
 */
@WebServlet("/UploadProfilePicServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,      // 5 MB
    maxRequestSize = 1024 * 1024 * 10   // 10 MB
)
public class UploadProfilePicServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "uploads/profiles";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // Get the file part
            Part filePart = request.getPart("profilePicture");
            
            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "Please select a file to upload");
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }
            
            // Validate file size
            if (filePart.getSize() > MAX_FILE_SIZE) {
                request.setAttribute("error", "File size must be less than 5MB");
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }
            
            // Get filename
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            
            // Validate file type
            String contentType = filePart.getContentType();
            if (!contentType.startsWith("image/")) {
                request.setAttribute("error", "Only image files are allowed");
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }
            
            // Get file extension
            String fileExtension = "";
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex > 0) {
                fileExtension = fileName.substring(dotIndex);
            }
            
            // Generate unique filename: userId_timestamp.ext
            String uniqueFileName = "user_" + user.getUserId() + "_" + System.currentTimeMillis() + fileExtension;
            
            // Get upload path
            String appPath = request.getServletContext().getRealPath("");
            String uploadPath = "C:/project/EmployeeApp1/uploads/profiles/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
                }
      
            
            // Delete old profile picture if exists (except default.jpg)
            String oldPicture = user.getProfilePicture();
            if (oldPicture != null && !oldPicture.equals("default.jpg")) {
                File oldFile = new File(uploadPath + File.separator + oldPicture);
                if (oldFile.exists()) {
                    oldFile.delete();
                }
            }
            
            // Save the file
            String filePath = uploadPath + File.separator + uniqueFileName;
            filePart.write(filePath);
            
            // Update database
            UserDAO userDAO = new UserDAO();
            user.setProfilePicture(uniqueFileName);
            boolean updated = userDAO.updateProfile(user);
            
            if (updated) {
                // Update session
                session.setAttribute("user", user);
                request.setAttribute("success", "Profile picture updated successfully!");
            } else {
                // Delete uploaded file if database update failed
                new File(filePath).delete();
                request.setAttribute("error", "Failed to update profile picture");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error uploading file: " + e.getMessage());
        }
        
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}