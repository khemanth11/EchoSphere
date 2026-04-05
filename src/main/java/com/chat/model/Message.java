package com.chat.model;

public class Message {
    private int id;
    private String sender;
    private String receiver;
    private String messageText;
    private String createdAt;
    private String msgType; 
    private int isRead; // NEW FIELD: 0 or 1

    public Message() {}

    public Message(String sender, String receiver, String messageText, String createdAt) {
        this.sender = sender;
        this.receiver = receiver;
        this.messageText = messageText;
        this.createdAt = createdAt;
        this.msgType = "TEXT";
        this.isRead = 0;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }

    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }

    public String getMessageText() { return messageText; }
    public void setMessageText(String messageText) { this.messageText = messageText; }
    
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getMsgType() { return msgType; }
    public void setMsgType(String msgType) { this.msgType = msgType; }

    // NEW METHODS
    public int getIsRead() { return isRead; }
    public void setIsRead(int isRead) { this.isRead = isRead; }
}