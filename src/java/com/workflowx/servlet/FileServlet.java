package com.workflowx.servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/uploads/*")
public class FileServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Determine upload directory dynamically
        String baseUploadDir;
        
        // Try webapp directory first (works on Render)
        String webappPath = getServletContext().getRealPath("/uploads/");
        if (webappPath != null && new File(webappPath).exists()) {
            baseUploadDir = webappPath;
        } 
        // Try environment variable
        else if (System.getenv("UPLOAD_DIR") != null) {
            baseUploadDir = System.getenv("UPLOAD_DIR");
        } 
        // Fallback to local development path
        else {
            baseUploadDir = "C:/project/EmployeeApp1/uploads/";
        }
        
        System.out.println("FileServlet using base directory: " + baseUploadDir);
        
        // Get requested file path
        String requestedFile = request.getPathInfo();
        
        if (requestedFile == null || requestedFile.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "No file specified");
            return;
        }
        
        // Remove leading slash
        requestedFile = requestedFile.substring(1);
        
        // Build full file path
        File file = new File(baseUploadDir, requestedFile);
        
        System.out.println("FileServlet trying to serve: " + file.getAbsolutePath());
        
        // Security check - prevent directory traversal
        try {
            String canonicalBase = new File(baseUploadDir).getCanonicalPath();
            String canonicalFile = file.getCanonicalPath();
            
            if (!canonicalFile.startsWith(canonicalBase)) {
                System.err.println("Security violation: " + canonicalFile);
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
        } catch (IOException e) {
            System.err.println("Security check failed: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        
        // Check if file exists
        if (!file.exists()) {
            System.err.println("File not found: " + file.getAbsolutePath());
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found: " + requestedFile);
            return;
        }
        
        if (file.isDirectory()) {
            System.err.println("Cannot serve directory: " + file.getAbsolutePath());
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Cannot serve directories");
            return;
        }
        
        // Set content type
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLength((int) file.length());
        
        // Set headers
        String fileName = file.getName();
        if (fileName.endsWith(".pdf") || fileName.endsWith(".jpg") || 
            fileName.endsWith(".jpeg") || fileName.endsWith(".png") ||
            fileName.endsWith(".gif") || fileName.endsWith(".webp")) {
            response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        } else {
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        }
        
        // Stream file to response
        try (InputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            
            System.out.println("Successfully served file: " + file.getAbsolutePath());
            
        } catch (IOException e) {
            System.err.println("Error streaming file: " + e.getMessage());
            e.printStackTrace();
        }
    }
}