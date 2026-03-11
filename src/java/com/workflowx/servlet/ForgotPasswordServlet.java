package com.workflowx.servlet;

import com.workflowx.dao.UserDAO;
import com.workflowx.model.User;
import com.workflowx.util.EmailService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("sendOTP".equals(action)) {
            handleSendOTP(request, response);
        } else if ("verifyOTP".equals(action)) {
            handleVerifyOTP(request, response);
        } else if ("resetPassword".equals(action)) {
            handleResetPassword(request, response);
        } else {
            response.sendRedirect("forgotPassword.jsp");
        }
    }
    
    /**
     * Step 1: Send OTP to email
     */
    private void handleSendOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your email address");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        try {
            UserDAO userDAO = new UserDAO();
            
            // Check if email exists
            User user = userDAO.getUserByEmail(email.trim());
            
            if (user == null) {
                request.setAttribute("error", "Email not found in our records");
                request.setAttribute("step", "email");
                request.setAttribute("email", email);
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }
            
            // Generate 6-digit OTP
            String otp = generateOTP();
            
            // Store OTP in session with timestamp
            HttpSession session = request.getSession();
            session.setAttribute("resetOTP", otp);
            session.setAttribute("resetEmail", email.trim());
            session.setAttribute("otpTimestamp", System.currentTimeMillis());
            // Send OTP via email

            EmailService emailService = new EmailService();
boolean emailSent = emailService.sendOTP(email.trim(), otp, user.getFullName());

if (!emailSent) {
    request.setAttribute("error", "Failed to send OTP. Please try again.");
    request.setAttribute("step", "email");
    request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    return;
}

// Also log to console for debugging
System.out.println("✅ OTP sent to: " + email + " | OTP: " + otp);
            // Show OTP verification page
            request.setAttribute("step", "verifyOTP");
            request.setAttribute("email", email.trim());
            request.setAttribute("maskedEmail", maskEmail(email.trim()));
            request.setAttribute("info", "OTP sent successfully! (Check console for OTP - Development Mode)");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again.");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
        }
    }
    
    /**
     * Step 2: Verify OTP
     */
    private void handleVerifyOTP(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String enteredOTP = request.getParameter("otp");
        
        HttpSession session = request.getSession();
        String storedOTP = (String) session.getAttribute("resetOTP");
        String storedEmail = (String) session.getAttribute("resetEmail");
        Long otpTimestamp = (Long) session.getAttribute("otpTimestamp");
        
        // Validate session data
        if (storedOTP == null || storedEmail == null || otpTimestamp == null) {
            request.setAttribute("error", "Session expired. Please request a new OTP.");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        // Check if email matches
        if (!storedEmail.equals(email)) {
            request.setAttribute("error", "Invalid request");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        // Check OTP expiry (5 minutes)
        long currentTime = System.currentTimeMillis();
        long otpAge = (currentTime - otpTimestamp) / 1000; // in seconds
        
        if (otpAge > 300) { // 5 minutes = 300 seconds
            session.removeAttribute("resetOTP");
            session.removeAttribute("resetEmail");
            session.removeAttribute("otpTimestamp");
            
            request.setAttribute("error", "OTP expired. Please request a new one.");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        // Verify OTP
        if (!storedOTP.equals(enteredOTP)) {
            request.setAttribute("error", "Invalid OTP. Please try again.");
            request.setAttribute("step", "verifyOTP");
            request.setAttribute("email", email);
            request.setAttribute("maskedEmail", maskEmail(email));
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        // OTP verified successfully
        session.setAttribute("otpVerified", true);
        
        request.setAttribute("step", "resetPassword");
        request.setAttribute("email", email);
        request.setAttribute("success", "OTP verified! Now set your new password.");
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }
    
    /**
     * Step 3: Reset Password
     */
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");
        String email = request.getParameter("email");
        String storedEmail = (String) session.getAttribute("resetEmail");
        
        // Verify OTP was verified
        if (otpVerified == null || !otpVerified) {
            request.setAttribute("error", "Please verify OTP first");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        // Verify email matches
        if (!email.equals(storedEmail)) {
            request.setAttribute("error", "Invalid request");
            request.setAttribute("step", "email");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate passwords
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.setAttribute("step", "resetPassword");
            request.setAttribute("email", email);
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        if (newPassword.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters");
            request.setAttribute("step", "resetPassword");
            request.setAttribute("email", email);
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        
        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserByEmail(email);
            
            if (user == null) {
                request.setAttribute("error", "User not found");
                request.setAttribute("step", "email");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }
            
            // Update password
            boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);
            
            if (updated) {
                // Clear session attributes
                session.removeAttribute("resetOTP");
                session.removeAttribute("resetEmail");
                session.removeAttribute("otpTimestamp");
                session.removeAttribute("otpVerified");
                
                // Redirect to login with success message
                request.setAttribute("success", 
                    "✅ Password reset successful! You can now login with your new password.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to reset password. Please try again.");
                request.setAttribute("step", "resetPassword");
                request.setAttribute("email", email);
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.setAttribute("step", "resetPassword");
            request.setAttribute("email", email);
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
        }
    }
    
    /**
     * Generate 6-digit OTP
     */
    private String generateOTP() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000); // 6-digit number
        return String.valueOf(otp);
    }
    
    /**
     * Mask email for display
     * Example: john.doe@example.com -> j***e@example.com
     */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        
        String[] parts = email.split("@");
        String username = parts[0];
        String domain = parts[1];
        
        if (username.length() <= 2) {
            return username.charAt(0) + "***@" + domain;
        }
        
        return username.charAt(0) + "***" + username.charAt(username.length() - 1) + "@" + domain;
    }
}