package com.chat.socket;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/chatSocket")
public class ChatWebSocket {

    // Store active connections
    private static Map<String, Session> clients = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session) {
        String query = session.getQueryString();
        if (query != null && query.contains("username=")) {
            String username = query.split("=")[1];
            clients.put(username, session);
        }
    }

    @OnClose
    public void onClose(Session session) {
        clients.values().remove(session);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        // We don't process incoming messages here to avoid complexity.
        // We only use this for server-to-client pushing.
    }

    // --- STATIC METHODS FOR SERVLET TO USE ---

    // 1. Send "New Message" Signal
    public static void sendNewMessage(String receiver, String sender, String type, String msgText, String chatType) {
        sendMessageToUser(receiver, String.format(
            "{\"action\":\"NEW_MSG\", \"type\":\"%s\", \"sender\":\"%s\", \"chatType\":\"%s\", \"message\":\"%s\", \"target\":\"%s\"}",
            type, sender, chatType, clean(msgText), receiver
        ));
    }
    
    // 2. Send "Read Confirmation" (Blue Ticks)
    public static void sendReadReceipt(String originalSender, String reader) {
        sendMessageToUser(originalSender, String.format(
            "{\"action\":\"READ_CONFIRM\", \"reader\":\"%s\"}", reader
        ));
    }

    private static void sendMessageToUser(String username, String json) {
        Session s = clients.get(username);
        if (s != null && s.isOpen()) {
            try { s.getBasicRemote().sendText(json); } catch (IOException e) { e.printStackTrace(); }
        }
    }
    
    private static String clean(String s) {
        return s == null ? "" : s.replace("\"", "\\\"").replace("\n", " ");
    }
}