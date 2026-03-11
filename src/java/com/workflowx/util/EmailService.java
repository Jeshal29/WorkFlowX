package com.workflowx.util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class EmailService {
    
    // Gmail SMTP Configuration
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_FROM = "jeshaldsouza29@gmail.com"; // ← CHANGE THIS
    private static final String EMAIL_PASSWORD = "lhwg abjy rdgh eghi"; // ← CHANGE THIS
    
    /**
     * Send OTP email for password reset
     */
    public boolean sendOTP(String toEmail, String otp, String userName) {
        try {
            // Email properties
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            
            // Create session
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_FROM, EMAIL_PASSWORD);
                }
            });
            
            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_FROM, "WorkFlowX"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Password Reset OTP - WorkFlowX");
            
            // Email body (HTML)
            String emailBody = buildOTPEmailBody(otp, userName);
            message.setContent(emailBody, "text/html; charset=utf-8");
            
            // Send email
            Transport.send(message);
            
            System.out.println("✅ OTP email sent successfully to: " + toEmail);
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ Failed to send OTP email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Build HTML email body for OTP
     */
    private String buildOTPEmailBody(String otp, String userName) {
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head>" +
               "    <style>" +
               "        body { font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 20px; }" +
               "        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }" +
               "        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }" +
               "        .header h1 { margin: 0; font-size: 28px; }" +
               "        .content { padding: 40px 30px; }" +
               "        .otp-box { background: #f8f9fa; border: 2px dashed #667eea; border-radius: 10px; padding: 20px; text-align: center; margin: 30px 0; }" +
               "        .otp { font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 8px; }" +
               "        .expiry { color: #f57c00; font-weight: 600; margin-top: 10px; }" +
               "        .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 12px; }" +
               "    </style>" +
               "</head>" +
               "<body>" +
               "    <div class='container'>" +
               "        <div class='header'>" +
               "            <h1>🔐 WorkFlowX</h1>" +
               "            <p>Password Reset Request</p>" +
               "        </div>" +
               "        <div class='content'>" +
               "            <h2>Hi " + userName + ",</h2>" +
               "            <p>We received a request to reset your password. Use the OTP below to proceed:</p>" +
               "            <div class='otp-box'>" +
               "                <div class='otp'>" + otp + "</div>" +
               "                <div class='expiry'>⏱️ Valid for 5 minutes</div>" +
               "            </div>" +
               "            <p><strong>Important:</strong></p>" +
               "            <ul>" +
               "                <li>Do not share this OTP with anyone</li>" +
               "                <li>This OTP will expire in 5 minutes</li>" +
               "                <li>If you didn't request this, please ignore this email</li>" +
               "            </ul>" +
               "            <p>Thanks,<br>The WorkFlowX Team</p>" +
               "        </div>" +
               "        <div class='footer'>" +
               "            <p>This is an automated email. Please do not reply.</p>" +
               "            <p>&copy; 2026 WorkFlowX. All rights reserved.</p>" +
               "        </div>" +
               "    </div>" +
               "</body>" +
               "</html>";
    }
}