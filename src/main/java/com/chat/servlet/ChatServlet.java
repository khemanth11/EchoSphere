package com.chat.servlet;

import java.io.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.chat.dao.*;
import com.chat.model.*;
import com.chat.socket.ChatWebSocket;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {
    
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	// POST: Sending Messages & Creating Groups
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ✅ 1. Fix Character Encoding for incoming messages
        request.setCharacterEncoding("UTF-8");
        
        User user = (User) request.getSession().getAttribute("user");
        if(user == null) return;
        
        new UserDAO().updateLastSeen(user.getUsername());
        
        String action = request.getParameter("action");
        
        // 2. GROUP ACTIONS
        if("createGroup".equals(action)) {
            String name = request.getParameter("groupName");
            String[] members = request.getParameterValues("members[]");
            new GroupDAO().createGroup(name, user.getUsername(), members);
            return;
        }
        if("deleteGroup".equals(action)) {
            try {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                String creator = new GroupDAO().getGroupCreator(groupId);
                if(creator != null && creator.trim().equals(user.getUsername())) {
                    new GroupDAO().deleteGroup(groupId);
                }
            } catch (Exception e) { e.printStackTrace(); }
            return;
        }

        // 3. SEND MESSAGE
        String text = request.getParameter("message");
        String type = request.getParameter("type");
        String chatType = request.getParameter("chatType");
        String target = request.getParameter("receiver");

        // ✅ Safety check for nulls
        if (text == null) text = "";
        if (type == null) type = "TEXT";

        Message msg = new Message();
        msg.setSender(user.getUsername());
        msg.setMessageText(text);
        msg.setMsgType(type);

        if("GROUP".equals(chatType)) {
            try {
                int groupId = Integer.parseInt(target);
                // Save to DB
                java.sql.Connection con = com.chat.config.DBConnection.getConnection();
                java.sql.PreparedStatement ps = con.prepareStatement("INSERT INTO messages(sender, group_id, message_text, msg_type) VALUES(?,?,?,?)");
                ps.setString(1, user.getUsername()); ps.setInt(2, groupId); ps.setString(3, text); ps.setString(4, type);
                ps.executeUpdate();
                
                new GroupDAO().markGroupAsRead(user.getUsername(), groupId);

                // Notify all members via WebSocket
                List<User> members = new GroupDAO().getGroupMembers(groupId);
                for(User u : members) {
                    if(!u.getUsername().equals(user.getUsername())) {
                        ChatWebSocket.sendNewMessage(u.getUsername(), user.getUsername(), type, text, "GROUP");
                    }
                }
            } catch(Exception e) { e.printStackTrace(); }
        } else {
            // Private Chat
            msg.setReceiver(target);
            new MessageDAO().saveMessage(msg);
            ChatWebSocket.sendNewMessage(target, user.getUsername(), type, text, "PRIVATE");
        }
    }

    // GET: Fetching Data
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if(user == null) { response.setStatus(401); return; } // Handle logout safely
        
        new UserDAO().updateLastSeen(user.getUsername());
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        String action = request.getParameter("action");

        try {
            // ✅ 1. GET SIDEBAR (Now uses escapeJson)
            if ("getSidebar".equals(action)) {
                List<User> users = new UserDAO().getAllUsers(user.getUsername());
                List<Group> groups = new GroupDAO().getUserGroups(user.getUsername());
                StringBuilder json = new StringBuilder("[");
                
                for(Group g : groups) {
                    json.append(String.format("{\"id\":\"%s\",\"name\":\"%s\",\"unread\":%d,\"type\":\"GROUP\"},", 
                        g.getId(), escapeJson(g.getName()), g.getUnreadCount()));
                }
                
                for(int i=0; i<users.size(); i++) {
                    User u = users.get(i);
                    String img = u.getProfileImage() != null ? u.getProfileImage() : "";
                    json.append(String.format("{\"id\":\"%s\",\"name\":\"%s\",\"image\":\"%s\",\"status\":\"%s\",\"unread\":%d,\"type\":\"PRIVATE\"}", 
                        u.getUsername(), escapeJson(u.getUsername()), img, u.getStatus(), u.getUnreadCount()));
                    if(i < users.size()-1) json.append(",");
                }
                
                if(json.length() > 1 && json.charAt(json.length()-1) == ',') {
                    json.deleteCharAt(json.length()-1);
                }
                json.append("]");
                out.print(json.toString());
                return;
            }

            // ✅ 2. SUMMARIZE GROUP (Uses escapeJson for text)
            if ("summarizeGroup".equals(action)) {
                String groupIdStr = request.getParameter("groupId");
                List<Message> msgs = new MessageDAO().getChatHistory(user.getUsername(), groupIdStr, "GROUP");
                
                StringBuilder chatText = new StringBuilder();
                int start = Math.max(0, msgs.size() - 40); 
                
                for(int i = start; i < msgs.size(); i++) {
                    Message m = msgs.get(i);
                    if("TEXT".equals(m.getMsgType())) {
                        String safeTxt = escapeJson(m.getMessageText());
                        chatText.append(m.getSender()).append(": ").append(safeTxt).append("\\n");
                    }
                }
                out.print("{\"chatContent\":\"" + chatText.toString() + "\"}");
                return;
            }

            // ✅ 3. GET GROUP MEMBERS (Uses escapeJson)
            if ("getGroupMembers".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                GroupDAO gDao = new GroupDAO();
                List<User> members = gDao.getGroupMembers(groupId);
                String creator = gDao.getGroupCreator(groupId);
                
                StringBuilder json = new StringBuilder("{\"creator\":\"" + creator + "\", \"members\":[");
                for(int i=0; i<members.size(); i++) {
                    User u = members.get(i);
                    json.append(String.format("{\"username\":\"%s\",\"image\":\"%s\",\"status\":\"%s\"}", 
                        escapeJson(u.getUsername()), u.getProfileImage() != null ? u.getProfileImage() : "", u.getStatus()));
                    if(i < members.size()-1) json.append(",");
                }
                json.append("]}");
                out.print(json.toString());
                return;
            }

            // ✅ 4. GET MESSAGES (CRITICAL: Uses escapeJson to prevent loading errors)
            String target = request.getParameter("contact");
            String type = request.getParameter("chatType");
            
            if(target != null) {
                if("GROUP".equals(type)) {
                    new GroupDAO().markGroupAsRead(user.getUsername(), Integer.parseInt(target));
                } else {
                    new MessageDAO().markAsRead(target, user.getUsername());
                    ChatWebSocket.sendReadReceipt(target, user.getUsername());
                }
            }
            
            List<Message> msgs = new MessageDAO().getChatHistory(user.getUsername(), target, type);
            StringBuilder json = new StringBuilder("[");
            for(int i=0; i<msgs.size(); i++) {
                Message m = msgs.get(i);
                
                // Clean the text properly!
                String cleanText = escapeJson(m.getMessageText());
                
                json.append(String.format("{\"sender\":\"%s\",\"message\":\"%s\",\"type\":\"%s\",\"isRead\":%d}", 
                    escapeJson(m.getSender()), cleanText, m.getMsgType(), m.getIsRead()));
                if(i < msgs.size()-1) json.append(",");
            }
            json.append("]");
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500); // Send 500 so frontend knows something went wrong
        }
    }

    // ✅ HELPER: The Magic Cleaner Function
    // Safely escapes characters that would otherwise break the JSON format
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")   // Escape backslashes first
                   .replace("\"", "\\\"")   // Escape quotes
                   .replace("\n", "\\n")    // Escape new lines
                   .replace("\r", "")       // Remove carriage returns
                   .replace("\t", "\\t");   // Escape tabs
    }
}