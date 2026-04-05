package com.chat.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.chat.config.DBConnection;
import com.chat.model.Message;

public class MessageDAO {

    public boolean saveMessage(Message msg) {
        boolean isSuccess = false;
        try {
            Connection con = DBConnection.getConnection();
            String query = "INSERT INTO messages(sender, receiver, message_text, msg_type) VALUES(?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, msg.getSender());
            ps.setString(2, msg.getReceiver());
            ps.setString(3, msg.getMessageText());
            
            String type = msg.getMsgType();
            if(type == null || type.isEmpty()) type = "TEXT";
            ps.setString(4, type);

            if (ps.executeUpdate() > 0) isSuccess = true;
        } catch (Exception e) { e.printStackTrace(); }
        return isSuccess;
    }

    public List<Message> getChatHistory(String me, String other, String type) {
        List<Message> list = new ArrayList<>();
        try {
            Connection con = DBConnection.getConnection();
            String query;
            PreparedStatement ps;

            if ("GROUP".equals(type)) {
                // Fetch Group Messages (using 'other' as Group ID)
                query = "SELECT * FROM messages WHERE group_id = ? ORDER BY id ASC";
                ps = con.prepareStatement(query);
                ps.setInt(1, Integer.parseInt(other));
            } else {
                // Fetch Private Messages (1-on-1)
                query = "SELECT * FROM messages WHERE group_id IS NULL AND " +
                        "((sender=? AND receiver=?) OR (sender=? AND receiver=?)) ORDER BY id ASC";
                ps = con.prepareStatement(query);
                ps.setString(1, me); ps.setString(2, other);
                ps.setString(3, other); ps.setString(4, me);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Message m = new Message();
                m.setSender(rs.getString("sender"));
                m.setMessageText(rs.getString("message_text"));
                m.setMsgType(rs.getString("msg_type"));
                m.setIsRead(rs.getInt("is_read"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public void markAsRead(String sender, String receiver) {
        try {
            Connection con = DBConnection.getConnection();
            String query = "UPDATE messages SET is_read = 1 WHERE sender = ? AND receiver = ? AND is_read = 0";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, sender);
            ps.setString(2, receiver);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}