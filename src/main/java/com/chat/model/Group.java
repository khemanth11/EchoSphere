package com.chat.model;

public class Group {
    private int id;
    private String name;
    private String createdBy;
    private int unreadCount; // NEW FIELD

    public Group() {}
    public Group(int id, String name, String createdBy) {
        this.id = id; this.name = name; this.createdBy = createdBy;
    }

    // Existing Getters/Setters...
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    // NEW Getter/Setter
    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }
}