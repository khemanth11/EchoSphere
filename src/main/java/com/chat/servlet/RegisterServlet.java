package com.chat.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.chat.dao.UserDAO;
import com.chat.model.User;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get the data from the form
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 2. Create a User object
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);

        // 3. Call DAO to save it
        UserDAO dao = new UserDAO();
        boolean isSuccess = dao.register(user);

        if (isSuccess) {
            // Success: Send them to Login Page
            response.sendRedirect("login.jsp");
        } else {
            // Failure: Stay on Register page and show error
            response.sendRedirect("register.jsp?error=1");
        }
    }
}