<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.chat.dao.UserDAO, com.chat.model.User, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if(currentUser == null) { response.sendRedirect("login.jsp"); return; }
    List<User> allFriends = new UserDAO().getAllUsers(currentUser.getUsername());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        :root { --sidebar-bg: #1e1e2d; --sidebar-active: #2b2b40; --chat-bg: #f5f7fb; --primary: #6c5ce7; --white: #ffffff; }
        body { margin: 0; font-family: 'Inter', sans-serif; height: 100vh; display: flex; overflow: hidden; background: var(--chat-bg); transition: background 0.5s ease; }
        
        .wallpaper-1 { background: #f5f7fb; }
        .wallpaper-2 { background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); }
        .wallpaper-3 { background: linear-gradient(120deg, #e0c3fc 0%, #8ec5fc 100%); }
        .wallpaper-4 { background: #1a1a2e; }
        .wallpaper-4 .chat-header, .wallpaper-4 .input-area { background: #16213e; color: white; border-color: #0f3460; }
        .wallpaper-4 .chat-header i { color: #e94560 !important; }
        .wallpaper-4 .msg.received { background: #16213e; color: white; }
        .wallpaper-4 h2 { color: white !important; }

        .sidebar { width: 320px; background-color: var(--sidebar-bg); color: #a6a6bd; display: flex; flex-direction: column; border-right: 1px solid rgba(0,0,0,0.1); z-index: 20;}
        .sidebar-header { padding: 20px; color: var(--white); font-size: 18px; font-weight: 600; display: flex; align-items: center; justify-content: space-between; height: 60px; box-sizing: border-box;}
        .dashboard-icon { cursor: pointer; transition: 0.2s; padding: 8px; border-radius: 50%; }
        .dashboard-icon:hover { color: var(--primary); background: rgba(255,255,255,0.1); }
        .user-list { flex: 1; overflow-y: auto; padding-top: 5px; }
        .user-item { padding: 15px 20px; cursor: pointer; transition: 0.2s; display: flex; align-items: center; gap: 15px; font-size: 15px; position: relative; border-bottom: 1px solid rgba(255,255,255,0.02); }
        .user-item:hover, .user-item.active { background-color: var(--sidebar-active); color: var(--white); }
        .avatar-circle { width: 40px; height: 40px; background: linear-gradient(45deg, #6c5ce7, #a29bfe); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 15px; flex-shrink: 0; }
        .avatar-img { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(255,255,255,0.1); flex-shrink: 0; }
        .unread-badge { background-color: #ff4757; color: white; font-size: 11px; font-weight: bold; padding: 3px 7px; border-radius: 20px; margin-left: auto; box-shadow: 0 2px 5px rgba(255, 71, 87, 0.4); display: none; }
        .sidebar-footer { margin-top: auto; border-top: 1px solid rgba(255,255,255,0.05); }
        .action-btn { width: 100%; padding: 15px; background: transparent; color: #a6a6bd; border: none; text-align: left; cursor: pointer; transition: 0.2s; font-size: 14px; display: flex; align-items: center; gap: 10px; }
        .action-btn:hover { background: #2b2b40; color: white; }
        .logout { color: #ff4757; }

        .chat-area { flex: 1; display: flex; flex-direction: column; position: relative; z-index: 10; height: 100%; }
        .chat-header { padding: 0 15px; height: 60px; background: var(--white); border-bottom: 1px solid #eaeaea; font-weight: 600; font-size: 16px; color: #2d3436; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 5px rgba(0,0,0,0.02); flex-shrink: 0; transition: background 0.3s; }
        
        .header-left { display: flex; align-items: center; gap: 10px; cursor: pointer; } 
        .header-left:hover { opacity: 0.8; }
        .back-btn { display: none; font-size: 18px; cursor: pointer; color: #666; padding: 10px; margin-left: -10px; position: relative; }
        
        .header-right { display: flex; align-items: center; gap: 15px; }
        .header-icon { font-size: 18px; color: #b2bec3; cursor: pointer; transition: 0.2s; }
        .header-icon:hover { color: var(--primary); transform: scale(1.1); }
        .boss-icon:hover { color: #ff4757; }
        
        .messages { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; scroll-behavior: smooth; }
        .msg { padding: 10px 16px; border-radius: 18px; max-width: 75%; font-size: 14px; line-height: 1.4; box-shadow: 0 1px 2px rgba(0,0,0,0.05); animation: fadeIn 0.3s ease; position: relative; word-wrap: break-word; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .sent { align-self: flex-end; background: linear-gradient(135deg, #6c5ce7, #a29bfe); color: white; border-bottom-right-radius: 4px; }
        .received { align-self: flex-start; background: white; color: #2d3436; border-bottom-left-radius: 4px; }
        .encrypted-msg { background: #fff0f0; border: 1px dashed #ff7675; color: #d63031; cursor: pointer; font-family: monospace; }
        .msg-img { max-width: 200px; border-radius: 12px; cursor: pointer; transition: transform 0.2s; display: block; }
        .msg-img:hover { transform: scale(1.05); }
        .audio-msg { width: 200px; height: 40px; }
        .paperclip-btn { background: #f1f2f6; color: #57606f; border: 1px solid #dfe4ea; margin-right: 5px; }
        
        .tick-container { font-size: 10px; margin-left: 5px; display: inline-block; vertical-align: bottom; }
        .tick-grey { color: rgba(255,255,255,0.7); }
        .tick-blue { color: #00e6ff; }
        
        .input-area { padding: 10px 15px; background: var(--white); border-top: 1px solid #eaeaea; display: none; gap: 10px; align-items: center; flex-shrink: 0; transition: background 0.3s; }
        input { flex: 1; padding: 12px 15px; border: 1px solid #eaeaea; border-radius: 25px; outline: none; background: #f9f9f9; font-size: 14px; }
        input:focus { background: white; border-color: var(--primary); }
        .circle-btn { width: 40px; height: 40px; border-radius: 50%; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px; transition: 0.2s; flex-shrink: 0; }
        .send-btn { background: var(--primary); color: white; }
        .spy-btn { background: #2d3436; color: #00cec9; border: 1px solid #00cec9; }
        .spy-btn.active { background: #00cec9; color: black; box-shadow: 0 0 10px #00cec9; }
        .mic-btn { background: #f1f2f6; color: #57606f; border: 1px solid #dfe4ea; }
        .mic-btn.recording { background: #ff4757; color: white; animation: pulse 1.5s infinite; }
        
        /* SELECTION MODE STYLES */
        .selection-mode .msg { cursor: pointer; transition: 0.2s; border: 2px solid transparent; }
        .selection-mode .msg:hover { opacity: 0.8; border-color: #a29bfe; }
        .msg.selected-range { background: #ffeaa7 !important; color: #d35400 !important; border: 2px solid #fdcb6e; }
        .select-btn-active { color: #fdcb6e !important; text-shadow: 0 0 10px #fdcb6e; transform: scale(1.2); }
        
        .modal { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.5); align-items:center; justify-content:center; z-index: 1000; }
        .modal-content { background: #1e1e2d; color: white; padding: 25px; border-radius: 12px; width: 320px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); position:relative; }
        .modal-content h3 { margin-top: 0; color: #6c5ce7; }
        .friend-list-check { max-height: 150px; overflow-y: auto; margin: 15px 0; background: #2b2b40; padding: 10px; border-radius: 8px; }
        .friend-row { padding: 5px; display: flex; align-items: center; gap: 10px; }
        
        .group-members-list { margin-top: 10px; max-height: 200px; overflow-y: auto; }
        .group-member-item { display: flex; align-items: center; gap: 10px; padding: 8px; border-bottom: 1px solid #2b2b40; }
        .group-member-item:last-child { border-bottom: none; }
        .status-txt-on { color: #2ecc71; font-weight: bold; font-size: 11px; }
        .status-txt-off { color: #95a5a6; font-size: 11px; }
        
        #dashboardView { display: none; flex: 1; background: white; padding: 20px; text-align: center; overflow-y: auto; }
        .dash-card { background: #fff; max-width: 400px; margin: 20px auto; padding: 30px; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); border: 1px solid #eee; }
        .big-avatar-container { position: relative; width: 100px; height: 100px; margin: 0 auto 15px auto; cursor: pointer; }
        .big-avatar { width: 100px; height: 100px; background: linear-gradient(135deg, #6c5ce7, #a29bfe); color: white; font-size: 40px; font-weight: bold; display: flex; align-items: center; justify-content: center; border-radius: 50%; object-fit: cover; }
        .camera-icon { position: absolute; bottom: 0; right: 0; background: #333; color: white; padding: 8px; border-radius: 50%; font-size: 12px; border: 2px solid white; }
        .stats-grid { display: flex; gap: 10px; justify-content: center; margin-bottom: 20px; }
        .stat-box { background: #f8f9fa; padding: 10px; border-radius: 10px; width: 80px; }
        
        #bossScreen { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: none; padding: 20px; box-sizing: border-box; font-family: 'Times New Roman', serif; color: black; overflow-y: auto; }
        @media (max-width: 768px) {
            .sidebar { width: 100%; height: 100%; position: absolute; z-index: 20; display: flex; }
            .chat-area { width: 100%; height: 100%; position: absolute; z-index: 30; display: none; }
            .back-btn { display: block; }
        }
    </style>
</head>
<body class="wallpaper-1" id="mainBody">
    <audio id="notifySound" src="https://codeskulptor-demos.commondatastorage.googleapis.com/pang/pop.mp3" preload="auto"></audio>
    
    <div id="bossScreen" onclick="toggleBossMode()">
        <h2>Java - Wikipedia</h2>
        <p>Java is a high-level, class-based, object-oriented programming language...</p>
        <center><small><i>(Click to return)</i></small></center>
    </div>

    <div id="groupModal" class="modal">
        <div class="modal-content">
            <h3><i class="fas fa-users"></i> Create Group</h3>
            <input type="text" id="newGroupName" placeholder="Group Name" style="width:90%; padding:10px; border-radius:5px; border:none; margin-bottom:10px;">
            <div class="friend-list-check">
                <% for(User u : allFriends) { %>
                    <div class="friend-row">
                        <input type="checkbox" class="friend-check" value="<%=u.getUsername()%>"> 
                        <%=u.getUsername()%>
                    </div>
                <% } %>
            </div>
            <div style="text-align:right; margin-top:15px;">
                <button onclick="document.getElementById('groupModal').style.display='none'" style="background:#444; color:white; padding:8px 15px; border-radius:5px;">Cancel</button>
                <button onclick="submitGroup()" style="background:#6c5ce7; color:white; padding:8px 15px; border-radius:5px;">Create</button>
            </div>
        </div>
    </div>

    <div id="summaryModal" class="modal">
        <div class="modal-content" style="background: linear-gradient(135deg, #1e1e2d 0%, #2d2d44 100%); border: 1px solid #6c5ce7;">
            <h3 style="color: #a29bfe;"><i class="fas fa-magic"></i> AI Catch Up</h3>
            <div id="aiSummaryText" style="color: #e0e0e0; line-height: 1.6; padding: 15px; background: rgba(0,0,0,0.2); border-radius: 8px; min-height: 80px;">
                Thinking... <i class="fas fa-spinner fa-spin"></i>
            </div>
            <div style="text-align:right; margin-top:15px;">
                <button onclick="document.getElementById('summaryModal').style.display='none'" style="background:#6c5ce7; color:white; padding:8px 15px; border-radius:5px; border:none; cursor:pointer;">Thanks AI!</button>
            </div>
        </div>
    </div>

    <div id="groupDetailsModal" class="modal">
        <div class="modal-content">
            <h3 id="detailsGroupName"><i class="fas fa-info-circle"></i> Group Info</h3>
            <div style="font-size:12px; color:#aaa; margin-bottom:5px;">Members:</div>
            <div class="group-members-list" id="groupMembersList">
                <div style="text-align:center; padding:10px; color:#aaa;">Loading...</div>
            </div>
            
            <div style="display:flex; justify-content:space-between; margin-top:15px;">
                <button id="deleteGroupBtn" onclick="deleteGroup()" style="background:#ff4757; color:white; padding:8px 15px; border-radius:5px; display:none;">
                    <i class="fas fa-trash"></i> Delete Group
                </button>
                <button onclick="document.getElementById('groupDetailsModal').style.display='none'" style="background:#6c5ce7; color:white; padding:8px 15px; border-radius:5px;">Close</button>
            </div>
        </div>
    </div>

    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div><i class="fas fa-comments"></i> &nbsp; MyChat</div>
            <div style="display:flex; gap:10px;">
                <i class="fas fa-users-cog dashboard-icon" onclick="document.getElementById('groupModal').style.display='flex'" title="Create Group"></i>
                <i class="fas fa-th-large dashboard-icon" onclick="showDashboard()" title="Dashboard"></i>
            </div>
        </div>
        <div class="user-list" id="sidebarUserList">
            <div style="text-align:center; color:#666; padding:20px;">Loading...</div>
        </div>
        <div class="sidebar-footer">
            <a href="login.jsp" style="text-decoration:none;"><button class="action-btn logout"><i class="fas fa-sign-out-alt"></i> Logout</button></a>
        </div>
    </div>

    <div class="chat-area" id="chatArea">
        <div id="chatInterface" style="display:flex; flex-direction:column; height:100%;">
            <div class="chat-header">
                <div class="header-left" onclick="showGroupInfo()">
                    <i class="fas fa-arrow-left back-btn" id="mobileBackBtn" onclick="event.stopPropagation(); goBackToContacts()"></i>
                    <div id="chatHeaderContent" style="display:flex; align-items:center; gap:10px;">
                        <i class="far fa-paper-plane" style="color:#b2bec3;"></i> &nbsp; Select a contact
                    </div>
                </div>
                <div class="header-right">
                <select id="targetLang" style="padding:5px; border-radius:5px; border:1px solid #ddd; margin-right:10px; font-size:12px;">
                        <option value="English">English</option>
                        <option value="Hindi">Hindi</option>
                        <option value="Telugu">Telugu</option>
                        <option value="Spanish">Spanish</option>
                        <option value="French">French</option>
                        <option value="Japanese">Japanese</option>
                    </select>
                    <i class="fas fa-check-double header-icon" id="selectModeBtn" onclick="toggleSelectionMode()" title="Select Messages to Summarize"></i>
                    
                    <i class="fas fa-palette header-icon" onclick="changeWallpaper()" title="Change Wallpaper"></i>
                    <i class="fas fa-book header-icon boss-icon" onclick="toggleBossMode()" title="Boss Mode (Panic)"></i>
                </div>
            </div>
            
            <div class="messages" id="messageBox">
                <div style="margin:auto; text-align:center; color:#b2bec3;"><i class="fas fa-comments" style="font-size:50px; opacity:0.3;"></i><p>Pick a friend or group</p></div>
            </div>
            
            <div class="input-area" id="inputArea">
                <input type="file" id="chatFileInput" accept="image/*" style="display:none" onchange="sendImageMessage(this)">
                <button class="circle-btn paperclip-btn" onclick="document.getElementById('chatFileInput').click()">
                    <i class="fas fa-paperclip"></i>
                </button>
                <button class="circle-btn spy-btn" id="spyToggle" onclick="toggleSpyMode()"><i class="fas fa-user-secret"></i></button>
                <input type="text" id="msgInput" placeholder="Message..." onkeypress="handleEnter(event)">
                <button class="circle-btn mic-btn" id="recordBtn" onclick="toggleRecording()"><i class="fas fa-microphone"></i></button>
                <button class="circle-btn send-btn" onclick="sendMessage()"><i class="fas fa-paper-plane"></i></button>
            </div>
        </div>

        <div id="dashboardView">
            <div class="dash-card">
                <i class="fas fa-times" style="float:right; cursor:pointer; font-size:20px;" onclick="closeDashboard()"></i>
                <div class="big-avatar-container" onclick="document.getElementById('fileInput').click()">
                    <% String myImg = currentUser.getProfileImage(); if(myImg != null && !myImg.isEmpty()) { %>
                        <img src="<%= myImg %>" class="big-avatar">
                    <% } else { %>
                        <div class="big-avatar"><%= currentUser.getUsername().substring(0,1).toUpperCase() %></div>
                    <% } %>
                    <i class="fas fa-camera camera-icon"></i>
                </div>
                <input type="file" id="fileInput" accept="image/*" style="display:none" onchange="uploadImage(this)">
                <div style="font-size:22px; font-weight:600;"><%= currentUser.getUsername() %></div>
                <div style="color:#888; font-size:14px; margin-bottom:20px;">ID: #<%= currentUser.getId() %></div>
                <div class="stats-grid">
                    <div class="stat-box"><div style="font-size:18px; font-weight:bold;"><%= allFriends.size() %></div><div style="font-size:11px;">Friends</div></div>
                    <div class="stat-box"><div style="font-size:18px; font-weight:bold; color:#2ecc71;">ON</div><div style="font-size:11px;">Status</div></div>
                </div>
                <form action="DeleteUserServlet" method="post" onsubmit="return confirm('Are you sure?');">
                     <button type="submit" class="action-btn" style="background:#ffecec; color:#ff4757; justify-content:center; border-radius:8px;">
                        <i class="fas fa-trash-alt"></i> Delete My Account
                     </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        // ⚡️ CONFIGURATION
        const GROQ_API_KEY = "YOUR_GROQ_API_KEY_HERE"; // 🔴 PASTE KEY
        
        var currentReceiver = null;
        var currentReceiverName = null;
        var myName = "<%= currentUser.getUsername() %>";
        var isSelectionMode = false;
        var startElement = null;
        var endElement = null;
        
        // Performance Variables
        var chatType = "PRIVATE"; 
        var isSpyMode = false;
        var isRecording = false;
        var mediaRecorder = null;
        var audioChunks = [];
        var currentWall = 1;

        // --- 1. OPTIMIZED WEBSOCKET (The Heart of Speed) ---
        // Automatically switch between 'ws://' (for localhost) and 'wss://' (for Render/Cloud)
		// 1. Auto-Detect Secure (wss) vs Insecure (ws)
        var protocol = (document.location.protocol === "https:") ? "wss://" : "ws://";
        
        // 2. Auto-Detect the App Name (Localhost = "/ChatSystem", Render = "")
        var contextPath = "<%= request.getContextPath() %>";

        // 3. Build the correct URL dynamically
        var wsUrl = protocol + document.location.host + contextPath + "/chatSocket?username=" + myName;
        var socket = new WebSocket(wsUrl);
        
        socket.onopen = function() { console.log("✅ Socket Connected (Real-time Mode)"); };
        
        socket.onmessage = function(event) {
            var msg = JSON.parse(event.data);
            
            // 1. Read Receipt (Instant Blue Ticks)
            if(msg.action === "READ_CONFIRM") {
                document.querySelectorAll('.tick-grey').forEach(t => {
                    t.className = "tick-container tick-blue"; 
                    t.innerHTML = '<i class="fas fa-check-double"></i>';
                });
                return;
            }
            
            var isCurrent = (msg.chatType === "PRIVATE" && msg.sender === currentReceiver) || 
                            (msg.chatType === "GROUP" && msg.target === currentReceiver);

            if (isCurrent) {
                // YES: Append it instantly (Smooth)
                appendReceivedMessage(msg);
                
                // Mark as read in background (Don't block UI)
                fetch("ChatServlet?contact=" + currentReceiver + "&chatType=" + msg.chatType);
            } else {
                // NO: Just play sound (Don't reload everything)
                document.getElementById("notifySound").play().catch(e=>{});
                refreshSidebar(); // Only refresh sidebar if necessary
            }
        };

        // --- 2. SIDEBAR LOGIC (Lag Fix) ---
        // OLD CODE: Refreshed every 2 seconds (BAD!)
        // NEW CODE: Refreshes every 15 seconds just to sync status.
        setInterval(refreshSidebar, 15000); 
        refreshSidebar(); 

        function refreshSidebar() {
            fetch("ChatServlet?action=getSidebar").then(r => r.json()).then(items => {
                var html = ""; 
                var totalUnread = 0;
                items.forEach(item => {
                    var active = (currentReceiver == item.id) ? "active" : "";
                    
                    if(item.type === "GROUP") {
                        var badgeStyle = (item.unread > 0 && currentReceiver != item.id) ? "display:inline-block" : "display:none";
                        if(item.unread > 0) totalUnread += item.unread;
                        
                        html += `<div class="user-item \${active}" onclick="startChat('\${item.id}', '\${item.name}', 'GROUP')">
                            <div class="avatar-circle" style="background:#e056fd"><i class="fas fa-users"></i></div>
                            <div style="flex:1; font-weight:bold;">\${item.name}<span class="unread-badge" style="\${badgeStyle}">\${item.unread}</span></div></div>`;
                    } else {
                        var avatarHtml = item.image ? `<img src="\${item.image}" class="avatar-img">` : `<div class="avatar-circle">\${item.name[0].toUpperCase()}</div>`;
                        var badgeStyle = (item.unread > 0 && currentReceiver != item.id) ? "display:inline-block" : "display:none";
                        if(item.unread > 0) totalUnread += item.unread;
                        var statusColor = item.status === "Online" ? "#2ecc71" : "#a6a6bd";
                        
                        html += `<div class="user-item \${active}" onclick="startChat('\${item.id}', '\${item.name}', 'PRIVATE')">
                                \${avatarHtml}<div style="flex:1;"><div style="font-weight:500; display:flex; align-items:center;">\${item.name}<span class="unread-badge" style="\${badgeStyle}">\${item.unread}</span></div>
                                <span style="font-size:11px; color:\${statusColor}">\${item.status}</span></div></div>`;
                    }
                });
                
                // Only update DOM if something actually changed (prevents flickering)
                var list = document.getElementById("sidebarUserList");
                if(list.innerHTML !== html) list.innerHTML = html;
                
                var backBtn = document.getElementById("mobileBackBtn");
                if(totalUnread > 0) backBtn.classList.add("has-new-msg"); else backBtn.classList.remove("has-new-msg");
            });
        }

        // --- 3. SENDING LOGIC (Instant Echo) ---
        function sendMessage() {
            var inputField = document.getElementById("msgInput"); 
            var text = inputField.value;
            if(text.trim() === "" || currentReceiver === null) return;
            
            var displayContent = text; 
            var serverContent = text;
            
            if(isSpyMode) { 
                serverContent = "SPY::" + btoa(text); 
                displayContent = "🔒 " + text; 
            }
            
            // 1. Show it IMMEDIATELY (Zero Lag)
            appendLocalMessage(displayContent, "TEXT"); 
            inputField.value = "";
            inputField.focus();

            // 2. Send to Server in Background
            fetch("ChatServlet", { 
                method: "POST", 
                headers: { "Content-Type": "application/x-www-form-urlencoded" }, 
                body: "receiver=" + currentReceiver + "&message=" + encodeURIComponent(serverContent) + "&type=TEXT&chatType=" + chatType 
            });
        }

        // --- 4. MESSAGE DISPLAY HELPERS ---
        function appendReceivedMessage(msg) {
            var box = document.getElementById("messageBox");
            var content = msg.message;
            var senderLabel = (msg.chatType === "GROUP") ? `<div style='font-size:10px;color:#888;font-weight:bold'>\${msg.sender}</div>` : "";
            
            if(msg.type === "IMAGE") content = `<img src="\${content}" class="msg-img" onclick="window.open(this.src)">`;
            else if(msg.type === "AUDIO") content = `<audio controls src="\${content}" class="audio-msg"></audio>`;
            
            // 🌍 NEW: Add Translation Button
            var translateBtn = `<i class="fas fa-globe-asia" onclick="translateMessage(this)" title="Translate" style="margin-left:8px; cursor:pointer; color:#b2bec3; font-size:12px;"></i>`;
            
            var div = document.createElement("div");
            div.className = "msg received";
            // We wrap content in a span so we can replace just the text later
            div.innerHTML = senderLabel + `<span class="msg-text">\${content}</span>` + translateBtn;
            
            box.appendChild(div);
            scrollToBottom();
            document.getElementById("notifySound").play().catch(e=>{});
        }

        function appendLocalMessage(content, type) {
            var box = document.getElementById("messageBox");
            var innerContent = content;
            if (type === "IMAGE") innerContent = `<img src="\${content}" class="msg-img">`;
            else if (type === "AUDIO") innerContent = `<audio controls src="\${content}" class="audio-msg"></audio>`;
            
            // Add grey tick initially
            innerContent += '<span class="tick-container tick-grey"><i class="fas fa-check"></i></span>';
            
            var div = document.createElement("div");
            div.className = "msg sent";
            div.innerHTML = innerContent;
            box.appendChild(div);
            scrollToBottom();
        }

        function scrollToBottom() {
            var box = document.getElementById("messageBox");
            box.scrollTop = box.scrollHeight;
        }

        // --- 5. CHAT SWITCHING ---
        function startChat(id, name, type) {
            if (window.innerWidth <= 768) { 
                document.getElementById("sidebar").style.display = "none"; 
                document.getElementById("chatArea").style.display = "block"; 
            }
            document.getElementById("dashboardView").style.display = "none"; 
            document.getElementById("chatInterface").style.display = "flex";
            
            currentReceiver = id; 
            currentReceiverName = name; 
            chatType = type;

            // Setup Header
            var headerHtml = "";
            if(type === "GROUP") {
                headerHtml = `
                    <div style="display:flex; justify-content:space-between; width:100%; align-items:center;">
                        <div style="display:flex; align-items:center;">
                            <div class="avatar-circle" style="background:#e056fd; width:32px; height:32px; font-size:13px; margin-right:10px;"><i class="fas fa-users"></i></div> 
                            <div>\${name}</div>
                        </div>
                        <div style="display:flex; gap:10px;">
                            <i class="fas fa-magic" title="Summarize All" onclick="event.stopPropagation(); getAISummary()" 
                            style="color:#a29bfe; cursor:pointer; font-size:18px; padding:10px; background:rgba(108, 92, 231, 0.1); border-radius:50%;"></i>
                        </div>
                    </div>`;
            } else {
                headerHtml = `<div class="avatar-circle" style="width:32px;height:32px;font-size:13px;background:#6c5ce7">\${name[0].toUpperCase()}</div> &nbsp; \${name}`;
            }
            document.getElementById("chatHeaderContent").innerHTML = headerHtml;
            document.getElementById("inputArea").style.display = "flex";
            document.getElementById("messageBox").innerHTML = '<div style="text-align:center;color:#ccc;margin-top:20px;">Loading history...</div>';
            
            // Load messages
            loadHistory();
            refreshSidebar(); // Update unread counts immediately
        }

        function loadHistory() {
            fetch("ChatServlet?contact=" + currentReceiver + "&chatType=" + chatType + "&t=" + new Date().getTime())
            .then(r => r.json())
            .then(data => {
                var box = document.getElementById("messageBox"); 
                var html = "";
                data.forEach(msg => {
                    var cls = (msg.sender === myName) ? "msg sent" : "msg received";
                    var content = msg.message;
                    var senderLabel = (chatType === "GROUP" && msg.sender !== myName) ? `<div style='font-size:10px;color:#888;font-weight:bold'>\${msg.sender}</div>` : "";
                    
                    if (msg.type === "IMAGE") content = `<img src="\${content}" class="msg-img" onclick="window.open(this.src)">`;
                    else if (msg.type === "AUDIO") content = `<audio controls src="\${content}" class="audio-msg"></audio>`;
                    else if(msg.message.startsWith("SPY::")) {
                        var secretPart = msg.message.substring(5);
                        if(msg.sender === myName) content = "🔒 " + atob(secretPart);
                        else { cls += " encrypted-msg"; content = "🔒 ENCRYPTED (Click)"; } 
                    }
                    
                    var tick = "";
                    if(msg.sender === myName && chatType === "PRIVATE") {
                        var color = (msg.isRead === 1) ? "tick-blue" : "tick-grey";
                        tick = `<span class="tick-container \${color}"><i class="fas fa-check-double"></i></span>`;
                    }
                    html += `<div class="\${cls}">\${senderLabel}\${content}\${tick}</div>`;
                });
                box.innerHTML = html; 
                scrollToBottom();
            });
        }

        // --- 6. SELECTION MODE (Keep existing logic) ---
        function toggleSelectionMode() {
            isSelectionMode = !isSelectionMode;
            const btn = document.getElementById("selectModeBtn");
            const box = document.getElementById("messageBox");
            if (isSelectionMode) {
                btn.classList.add("select-btn-active");
                box.classList.add("selection-mode");
                alert("SELECT MODE: Click START message, then Click END message.");
            } else {
                btn.classList.remove("select-btn-active");
                box.classList.remove("selection-mode");
                clearSelection();
            }
        }
        document.getElementById("messageBox").addEventListener("click", function(e) {
            if (!isSelectionMode) return;
            const msgDiv = e.target.closest(".msg");
            if (!msgDiv) return;
            if (!startElement) { startElement = msgDiv; msgDiv.classList.add("selected-range"); } 
            else if (!endElement) { endElement = msgDiv; msgDiv.classList.add("selected-range"); processSelectedRange(); } 
            else { clearSelection(); startElement = msgDiv; msgDiv.classList.add("selected-range"); }
        });
        function clearSelection() { startElement = null; endElement = null; document.querySelectorAll(".selected-range").forEach(el => el.classList.remove("selected-range")); }
        function processSelectedRange() {
            const allMsgs = Array.from(document.querySelectorAll("#messageBox .msg"));
            const min = Math.min(allMsgs.indexOf(startElement), allMsgs.indexOf(endElement));
            const max = Math.max(allMsgs.indexOf(startElement), allMsgs.indexOf(endElement));
            if (min === -1 || max === -1) return;
            let selectedText = "";
            for (let i = min; i <= max; i++) {
                allMsgs[i].classList.add("selected-range");
                selectedText += allMsgs[i].innerText.replace(/\n/g, " ").trim() + "\n";
            }
            if(confirm("Summarize selection?")) { toggleSelectionMode(); getAISummary(selectedText); } else { clearSelection(); }
        }

        // --- 7. GROQ AI (Keep existing logic) ---
        function getAISummary(customText = null) {
            document.getElementById("summaryModal").style.display = "flex";
            document.getElementById("aiSummaryText").innerHTML = '<div style="text-align:center;padding:20px;"><i class="fas fa-bolt fa-pulse" style="font-size:30px;color:#a29bfe;"></i><br><br>Analyzing...</div>';
            if (customText) callGroqAPI(customText);
            else fetch("ChatServlet?action=summarizeGroup&groupId=" + currentReceiver).then(r => r.json()).then(d => callGroqAPI(d.chatContent));
        }
        function callGroqAPI(chatText) {
            const url = "https://api.groq.com/openai/v1/chat/completions";
            const MODELS = ["llama-3.1-8b-instant", "llama-3.3-70b-versatile", "mixtral-8x7b-32768"];
            tryGroqModel(chatText, MODELS, 0, url);
        }
        function tryGroqModel(text, models, index, url) {
            if(index >= models.length) { document.getElementById("aiSummaryText").innerText = "AI Unavailable."; return; }
            const payload = { "model": models[index], "messages": [{ "role": "user", "content": "Analyze this chat and give exactly 3 bullet points. Rules:\n1. Start bullets with User Name.\n2. State why they prefer their choice.\n3. Keep bullets under 15 words.\n\nChat:\n" + text }] };
            fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + GROQ_API_KEY }, body: JSON.stringify(payload) })
            .then(r => r.json()).then(data => {
                if(data.error) tryGroqModel(text, models, index + 1, url);
                else document.getElementById("aiSummaryText").innerHTML = data.choices[0].message.content.replace(/\*\*(.*?)\*\*/g, "<b>$1</b>").replace(/\n/g, "<br>");
            }).catch(e => tryGroqModel(text, models, index + 1, url));
        }
     // --- 9. TRANSLATION FEATURE ---
        function translateMessage(btnElement) {
            // 1. Get the message text and target language
            var msgSpan = btnElement.parentElement.querySelector(".msg-text");
            var originalText = msgSpan.innerText;
            var targetLang = document.getElementById("targetLang").value;

            // 2. Show "Translating..." animation
            var originalIcon = btnElement.className;
            btnElement.className = "fas fa-spinner fa-spin"; // Spin icon
            
            // 3. Call Groq AI
            const url = "https://api.groq.com/openai/v1/chat/completions";
            const payload = {
                "model": "llama-3.1-8b-instant", // Fast model for translation
                "messages": [{
                    "role": "user",
                    "content": `Translate the following text to \${targetLang}. Return ONLY the translated text, nothing else.\n\nText: "\${originalText}"`
                }]
            };

            fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + GROQ_API_KEY },
                body: JSON.stringify(payload)
            })
            .then(r => r.json())
            .then(data => {
                if(data.error) {
                    alert("Translation Failed: " + data.error.message);
                    btnElement.className = originalIcon; // Revert icon
                } else {
                    // 4. Update the Message Bubble with Translation
                    var translatedText = data.choices[0].message.content;
                    msgSpan.innerHTML = `<b>[\${targetLang}]</b> ` + translatedText;
                    btnElement.className = "fas fa-check"; // Show Checkmark
                    btnElement.style.color = "#2ecc71"; // Green color
                }
            })
            .catch(e => {
                console.error(e);
                btnElement.className = originalIcon;
                alert("Network Error");
            });
        }

        // --- 8. UTILITIES ---
        function sendImageMessage(input) { if (input.files[0]) { var r = new FileReader(); r.onload = function(e) { appendLocalMessage(e.target.result, "IMAGE"); fetch("ChatServlet", { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body: "receiver=" + currentReceiver + "&message=" + encodeURIComponent(e.target.result) + "&type=IMAGE&chatType=" + chatType }); }; r.readAsDataURL(input.files[0]); } }
        function toggleRecording() { var btn = document.getElementById("recordBtn"); if (!isRecording) { navigator.mediaDevices.getUserMedia({ audio: true }).then(s => { mediaRecorder = new MediaRecorder(s); mediaRecorder.start(); audioChunks = []; isRecording = true; btn.classList.add("recording"); mediaRecorder.ondataavailable = e => audioChunks.push(e.data); mediaRecorder.onstop = () => { var b = new Blob(audioChunks, { type: 'audio/webm' }); var r = new FileReader(); r.readAsDataURL(b); r.onloadend = () => { appendLocalMessage(r.result, "AUDIO"); fetch("ChatServlet", { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body: "receiver=" + currentReceiver + "&message=" + encodeURIComponent(r.result) + "&type=AUDIO&chatType=" + chatType }); }; }; }); } else { mediaRecorder.stop(); isRecording = false; btn.classList.remove("recording"); } }
        function showDashboard() { document.getElementById("chatInterface").style.display = "none"; document.getElementById("dashboardView").style.display = "block"; if (window.innerWidth <= 768) document.getElementById("sidebar").style.display = "none"; }
        function closeDashboard() { document.getElementById("dashboardView").style.display = "none"; document.getElementById("chatInterface").style.display = "flex"; if (window.innerWidth <= 768) goBackToContacts(); }
        function uploadImage(input) { if (input.files[0]) { var r = new FileReader(); r.onload = function(e) { var f = document.createElement("form"); f.method = "POST"; f.action = "UploadServlet"; var i = document.createElement("input"); i.type = "hidden"; i.name = "imageData"; i.value = e.target.result; f.appendChild(i); document.body.appendChild(f); f.submit(); }; r.readAsDataURL(input.files[0]); } }
        function deleteGroup() { if(confirm("Delete Group?")) fetch("ChatServlet", { method: "POST", headers: {"Content-Type":"application/x-www-form-urlencoded"}, body: "action=deleteGroup&groupId=" + currentReceiver }).then(() => { document.getElementById('groupDetailsModal').style.display='none'; goBackToContacts(); refreshSidebar(); alert("Deleted."); }); }
        function handleEnter(e) { if(e.key === 'Enter') sendMessage(); }
        function goBackToContacts() { if (window.innerWidth <= 768) { document.getElementById("chatArea").style.display = "none"; document.getElementById("sidebar").style.display = "flex"; currentReceiver = null; } }
        function changeWallpaper() { var b = document.getElementById("mainBody"); b.classList.remove("wallpaper-" + currentWall); currentWall++; if(currentWall > 4) currentWall = 1; b.classList.add("wallpaper-" + currentWall); }
        function toggleBossMode() { isBossMode = !isBossMode; document.getElementById("bossScreen").style.display = isBossMode ? "block" : "none"; document.title = isBossMode ? "Java - Wikipedia" : "MyChat"; }
        function toggleSpyMode() { isSpyMode = !isSpyMode; var b = document.getElementById("spyToggle"); var i = document.getElementById("msgInput"); if(isSpyMode) { b.classList.add("active"); i.placeholder = "Spy Mode..."; i.style.border = "1px solid #00cec9"; } else { b.classList.remove("active"); i.placeholder = "Message..."; i.style.border = "1px solid #eaeaea"; } }
        document.addEventListener('keydown', function(event) { if (event.key === "Escape") toggleBossMode(); });
    </script>
</body>
</html>