package com.chat.dao;

import java.sql.*;
import java.util.*;
import com.chat.config.DBConnection;
import com.chat.model.Group;
import com.chat.model.User;

public class GroupDAO {

    // 1. Create Group (Unchanged)
    public boolean createGroup(String groupName, String creator, String[] members) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);
            
            // Insert Group
            PreparedStatement ps = con.prepareStatement("INSERT INTO chat_groups (name, created_by) VALUES (?, ?)", Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, groupName); ps.setString(2, creator);
            ps.executeUpdate();
            
            ResultSet rs = ps.getGeneratedKeys();
            int groupId = 0; if(rs.next()) groupId = rs.getInt(1);

            // Add Creator & Members
            addMember(con, groupId, creator);
            if(members != null) { for(String m : members) addMember(con, groupId, m); }
            
            con.commit();
            return true;
        } catch (Exception e) {
            try { if(con != null) con.rollback(); } catch(SQLException ex) {}
            e.printStackTrace(); return false;
        }
    }

    private void addMember(Connection con, int groupId, String user) throws SQLException {
        PreparedStatement ps = con.prepareStatement("INSERT INTO group_members (group_id, username) VALUES (?, ?)");
        ps.setInt(1, groupId); ps.setString(2, user);
        ps.executeUpdate();
        
        // Also initialize read status
        PreparedStatement psRead = con.prepareStatement("INSERT IGNORE INTO group_reads (group_id, username) VALUES (?, ?)");
        psRead.setInt(1, groupId); psRead.setString(2, user);
        psRead.executeUpdate();
    }

    // 2. UPDATED: Get User Groups with UNREAD COUNT
    public List<Group> getUserGroups(String username) {
        List<Group> list = new ArrayList<>();
        try {
            Connection con = DBConnection.getConnection();
            // This query counts messages sent AFTER the user's last_read_at time
            String sql = "SELECT g.id, g.name, g.created_by, " +
                         "(SELECT COUNT(*) FROM messages m " +
                         " WHERE m.group_id = g.id " +
                         " AND m.sender != ? " +  // Don't count my own messages
                         " AND m.created_at > COALESCE((SELECT last_read_at FROM group_reads gr WHERE gr.group_id=g.id AND gr.username=?), '1970-01-01')) " +
                         "as unread_count " +
                         "FROM chat_groups g " +
                         "JOIN group_members gm ON g.id = gm.group_id " +
                         "WHERE gm.username = ?";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, username);
            
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Group g = new Group(rs.getInt("id"), rs.getString("name"), rs.getString("created_by"));
                // We'll store unread count in a temporary way or handle in servlet. 
                // For simplicity, let's assume Group model has no unread field, we will handle in Servlet JSON construction
                // Hack: We can abuse 'createdBy' to store count string if we really want, but let's do it clean.
                // Actually, let's just return a Map or DTO, but to save creating files, 
                // I will add a transient field to Group or just fetch logic in Servlet.
                // Let's modify Group.java briefly or just use this logic:
                // We will append the unread count to the name temporarily? No, that's messy.
                // Let's Just add a field to Group class (See Step 2.5)
                g.setUnreadCount(rs.getInt("unread_count")); 
                list.add(g);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 3. NEW: Mark Group as Read
    public void markGroupAsRead(String username, int groupId) {
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO group_reads (username, group_id, last_read_at) VALUES (?, ?, NOW()) " +
                "ON DUPLICATE KEY UPDATE last_read_at = NOW()"
            );
            ps.setString(1, username);
            ps.setInt(2, groupId);
            ps.executeUpdate();
        } catch(Exception e) { e.printStackTrace(); }
    }

    // 4. Get Members (Robust Online Check)
    public List<User> getGroupMembers(int groupId) {
        List<User> list = new ArrayList<>();
        try {
            Connection con = DBConnection.getConnection();
            // SQL Logic: If last_seen is within 15 seconds of NOW(), they are Online.
            String sql = "SELECT u.username, u.profile_image, " +
                         "CASE WHEN u.last_seen > NOW() - INTERVAL 15 SECOND THEN 'Online' ELSE 'Offline' END as status " +
                         "FROM users u " +
                         "JOIN group_members gm ON u.username = gm.username " +
                         "WHERE gm.group_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                User u = new User();
                u.setUsername(rs.getString("username"));
                u.setProfileImage(rs.getString("profile_image"));
                u.setStatus(rs.getString("status")); // Set pure status directly from SQL
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public String getGroupCreator(int groupId) {
        String creator = "";
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT created_by FROM chat_groups WHERE id=?");
            ps.setInt(1, groupId);
            ResultSet rs = ps.executeQuery();
            if(rs.next()) creator = rs.getString("created_by");
        } catch(Exception e) { e.printStackTrace(); }
        return creator;
    }

    public void deleteGroup(int groupId) {
        try {
            Connection con = DBConnection.getConnection();
            // Reads, Members, Messages, and Group
            con.prepareStatement("DELETE FROM group_reads WHERE group_id=" + groupId).executeUpdate();
            con.prepareStatement("DELETE FROM messages WHERE group_id=" + groupId).executeUpdate();
            con.prepareStatement("DELETE FROM chat_groups WHERE id=" + groupId).executeUpdate();
        } catch(Exception e) { e.printStackTrace(); }
    }
}