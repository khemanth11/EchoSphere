package com.chat.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.chat.dao.UserDAO;
import com.chat.model.User;

@WebServlet("/UploadServlet")
public class UploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get current user
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user != null) {
            // 2. Get the massive text string (the image)
            String base64Image = request.getParameter("imageData");
            
            if (base64Image != null && !base64Image.isEmpty()) {
                // 3. Save to database
                UserDAO dao = new UserDAO();
                boolean success = dao.updateProfileImage(user.getId(), base64Image);
                
                if(success) {
                    // Update session so we see it immediately
                    user.setProfileImage(base64Image);
                    session.setAttribute("user", user);
                }
            }
        }
        
        // 4. Go back to chat
        response.sendRedirect("chat.jsp");
    }
}