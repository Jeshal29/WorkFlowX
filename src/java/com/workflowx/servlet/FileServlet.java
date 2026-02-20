package com.workflowx.servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

@WebServlet("/uploads/*")
public class FileServlet extends HttpServlet {
    
    // Point to permanent uploads folder
    private static final String UPLOAD_DIR = "C:/project/EmployeeApp1/uploads/";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String requestedFile = request.getPathInfo();
        
        if (requestedFile == null || requestedFile.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // Remove leading slash
        requestedFile = requestedFile.substring(1);
        
        // Build full file path
        File file = new File(UPLOAD_DIR, requestedFile);
        
        // Security check
        try {
            if (!file.getCanonicalPath().startsWith(new File(UPLOAD_DIR).getCanonicalPath())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        
        // Check if file exists
        if (!file.exists() || file.isDirectory()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
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
            fileName.endsWith(".jpeg") || fileName.endsWith(".png")) {
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
        }
    }
}