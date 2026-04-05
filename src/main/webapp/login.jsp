<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Welcome Back</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6c5ce7;
            --bg-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background: var(--bg-gradient);
            height: 100vh;
            /* Fix for mobile centering */
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            padding: 40px 30px; /* Less padding on sides for mobile */
            border-radius: 20px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            backdrop-filter: blur(4px);
            
            /* RESPONSIVE WIDTH FIX */
            width: 90%; 
            max-width: 400px;
            
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.18);
            box-sizing: border-box;
        }
        h2 { color: #333; margin-bottom: 10px; font-weight: 600; font-size: 24px; }
        .subtitle { color: #666; font-size: 14px; margin-bottom: 30px; }
        
        input {
            width: 100%;
            padding: 15px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 12px;
            box-sizing: border-box;
            background: #f9f9f9;
            transition: 0.3s;
            font-family: inherit;
            font-size: 16px; /* Prevents zoom on iPhone */
        }
        input:focus {
            border-color: var(--primary);
            outline: none;
            background: #fff;
            box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.1);
        }
        button {
            width: 100%;
            padding: 15px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: 0.3s;
            margin-top: 10px;
            font-size: 16px;
        }
        button:hover {
            background: #5a4ad1;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(108, 92, 231, 0.4);
        }
        .error-msg {
            color: #e74c3c;
            background: #fadbd8;
            padding: 10px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 15px;
            display: none;
        }
        .links { margin-top: 20px; font-size: 14px; }
        a { color: var(--primary); text-decoration: none; font-weight: 600; }
    </style>
</head>
<body>

    <div class="glass-card">
        <h2>Welcome Back</h2>
        <p class="subtitle">Enter your credentials to access your chats.</p>
        
        <% 
            String msg = request.getParameter("error");
            if(msg != null) {
        %>
            <div class="error-msg" style="display: block;">⚠ Invalid Username or Password</div>
        <% } %>

        <form action="LoginServlet" method="post">
            <input type="text" name="username" placeholder="Username" required autocomplete="off">
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Sign In</button>
        </form>
        
        <div class="links">
            Don't have an account? <a href="register.jsp">Create one</a>
        </div>
    </div>

</body>
</html>