package com.chat.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.chat.config.DBConnection;
import com.chat.model.User;

public class UserDAO {

    public boolean register(User user) {
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("INSERT INTO users(username, password) VALUES(?,?)");
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public User login(String username, String password) {
        User user = null;
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setProfileImage(rs.getString("profile_image")); // Load Image
                updateLastSeen(user.getUsername());
            }
        } catch (Exception e) { e.printStackTrace(); }
        return user;
    }

    public void updateLastSeen(String username) {
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("UPDATE users SET last_seen = NOW() WHERE username = ?");
            ps.setString(1, username);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
    
    // NEW: Update Profile Image
    public boolean updateProfileImage(int userId, String base64Image) {
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("UPDATE users SET profile_image = ? WHERE id = ?");
            ps.setString(1, base64Image);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // NEW: Delete User
    public boolean deleteUser(int id) {
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("DELETE FROM users WHERE id=?");
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public List<User> getAllUsers(String myUsername) {
        List<User> list = new ArrayList<>();
        try {
            Connection con = DBConnection.getConnection();
            // Fetch profile_image too
            String query = "SELECT u.*, " +
                           "TIMESTAMPDIFF(SECOND, u.last_seen, NOW()) as seconds_ago, " +
                           "(SELECT COUNT(*) FROM messages m WHERE m.sender = u.username AND m.receiver = ? AND m.is_read = 0) as unread_count " +
                           "FROM users u WHERE u.username != ?";
            
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, myUsername);
            ps.setString(2, myUsername);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setUnreadCount(rs.getInt("unread_count"));
                u.setProfileImage(rs.getString("profile_image")); // Get Image
                
                int secondsAgo = rs.getInt("seconds_ago");
                if(secondsAgo < 20) u.setStatus("Online");
                else if(secondsAgo < 60) u.setStatus("Just now");
                else if(secondsAgo < 3600) u.setStatus((secondsAgo/60) + "m ago");
                else u.setStatus((secondsAgo/3600) + "h ago");
                
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}