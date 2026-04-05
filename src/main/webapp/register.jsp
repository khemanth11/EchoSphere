<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Account</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #00b894; /* Green for Register */
            --bg-gradient: linear-gradient(135deg, #00b894 0%, #00cec9 100%);
        }
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background: var(--bg-gradient);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.2);
            width: 350px;
            text-align: center;
        }
        h2 { color: #333; margin-bottom: 5px; }
        .subtitle { color: #666; font-size: 14px; margin-bottom: 25px; }
        
        input {
            width: 100%;
            padding: 15px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 12px;
            box-sizing: border-box;
            background: #f4f4f4;
            font-family: inherit;
        }
        input:focus { border-color: var(--primary); outline: none; background: white; }
        
        button {
            width: 100%;
            padding: 15px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 15px;
            font-size: 16px;
            transition: 0.3s;
        }
        button:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0, 184, 148, 0.4); }
        
        .links { margin-top: 20px; font-size: 14px; }
        a { color: var(--primary); text-decoration: none; font-weight: 600; }
    </style>
</head>
<body>

    <div class="glass-card">
        <h2>Join Us</h2>
        <p class="subtitle">Start chatting with your friends today.</p>

        <% 
            String msg = request.getParameter("error");
            if(msg != null) {
        %>
            <p style="color:red; font-size: 13px;">⚠ Username already taken!</p>
        <% } %>

        <form action="RegisterServlet" method="post">
            <input type="text" name="username" placeholder="Choose a Username" required autocomplete="off">
            <input type="password" name="password" placeholder="Choose a Password" required>
            <button type="submit">Create Account</button>
        </form>
        
        <div class="links">
            Already have an account? <a href="login.jsp">Log In</a>
        </div>
    </div>

</body>
</html>