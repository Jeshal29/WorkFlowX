package com.workflowx.servlet;

import com.workflowx.dao.MessageDAO;
import com.workflowx.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Path;

@WebServlet("/SendMessageServlet")
@MultipartConfig // Required for file uploads
public class SendMessageServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ServletException {

        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String receiverIdStr = request.getParameter("receiverId");
        if (receiverIdStr == null || receiverIdStr.isEmpty()) {
            response.sendRedirect("messages.jsp"); // fallback
            return;
        }
        int receiverId = Integer.parseInt(receiverIdStr);

        String messageText = request.getParameter("messageText");
        if (messageText == null) messageText = "";

        // ===== Handle file upload =====
        Part filePart = request.getPart("attachment");
String attachmentPath = "";

if (filePart != null && filePart.getSize() > 0) {

    String originalFileName = Path.of(filePart.getSubmittedFileName())
                                  .getFileName()
                                  .toString();

    String newFileName = System.currentTimeMillis() + "_" + originalFileName;

    String uploadDir = "C:/EmployeeAppUploads";

    File uploadFolder = new File(uploadDir);
    if (!uploadFolder.exists()) {
        uploadFolder.mkdirs();
    }

    String filePath = uploadDir + File.separator + newFileName;
    filePart.write(filePath);

    // store only filename in DB
    attachmentPath = newFileName;
}


        // Block only if both are empty
        if (messageText.trim().isEmpty() && attachmentPath.trim().isEmpty()) {
            response.sendRedirect("messages.jsp?chatUserId=" + receiverId);
            return;
        }

        // Save message
        MessageDAO dao = new MessageDAO();
        dao.sendMessage(currentUser.getUserId(), receiverId, messageText, attachmentPath);

        response.sendRedirect("messages.jsp?chatUserId=" + receiverId);
    }
}
