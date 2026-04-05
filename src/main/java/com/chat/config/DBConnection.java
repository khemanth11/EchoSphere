package com.chat.config;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // 1. UPDATE THESE VARIABLES WITH YOUR CLOUD DETAILS
            String host = "gateway01.ap-southeast-1.prod.aws.tidbcloud.com"; // EXAMPLE! Put YOUR Host here
            String port = "4000"; // TiDB uses port 4000
            String dbName = "chat_app"; // Based on your screenshot, this is correct!
            String user = "3Dp6K2fotAvMi6r.root"; // e.g. 2G9s8...root
            String password = "TSFfEBxgdtCq0w6y"; // The one you saved in Notepad
            
            // 2. The Connection URL (Do not change this structure)
            String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName + "?sslMode=VERIFY_IDENTITY&useSSL=true&allowPublicKeyRetrieval=true";
            
            con = DriverManager.getConnection(url, user, password);
            
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return con;
    }
}