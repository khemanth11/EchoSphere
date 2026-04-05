package com.chat.service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

public class AIService {

    /* 🔴 KEEP YOUR API KEY HERE */
    private static final String API_KEY = "YOUR_GEMINI_API_KEY_HERE"; 
    
    // ✅ CHANGED: Updated to the currently active 2.x models
    private static final String[] MODELS = {
        "gemini-2.5-flash",      // Newest Stable Model
        "gemini-2.0-flash",      // Previous Stable Model
        "gemini-1.5-flash-001"   // Legacy LTS Version (Backup)
    };

    public static String summarizeChat(List<String> messages) {
        if (messages == null || messages.isEmpty()) return "No conversation to summarize.";

        // Prepare Data Once
        StringBuilder chatData = new StringBuilder();
        for(String m : messages) chatData.append(m).append("\n");
        
        String safeChatData = chatData.toString()
            .replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
        
        String prompt = "Summarize this group chat in 3 short bullet points. Chat:\\n" + safeChatData;
        String jsonInput = "{ \"contents\": [{ \"parts\":[{\"text\": \"" + prompt + "\"}] }] }";

        // --- SMART RETRY LOOP ---
        for (String model : MODELS) {
            System.out.println("🤖 Trying AI Model: " + model + "...");
            String result = tryModel(model, jsonInput);
            
            if (!result.startsWith("ERROR_")) {
                return result; // Success!
            }
            
            System.out.println("⚠️ Model " + model + " failed. Reason: " + result);
        }

        // If all failed
        return generateMockSummary(messages.size());
    }

    private static String tryModel(String modelName, String jsonInput) {
        try {
            // Correct URL Structure for v1beta
            String urlStr = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + API_KEY;
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            try(OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonInput.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int code = conn.getResponseCode();
            if (code == 200) {
                // Success! Read response
                try(BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) response.append(line.trim());
                    return extractTextFromJSON(response.toString());
                }
            } else {
                return "ERROR_" + code;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "ERROR_EXCEPTION";
        }
    }

    private static String extractTextFromJSON(String json) {
        try {
            String marker = "\"text\": \"";
            int start = json.indexOf(marker);
            if (start == -1) return "Could not parse AI response.";
            start += marker.length();
            int end = start;
            while (end < json.length()) {
                end = json.indexOf("\"", end);
                if (end == -1) break;
                if (json.charAt(end - 1) != '\\') break; 
                end++; 
            }
            String result = json.substring(start, end);
            return result.replace("\\n", "\n").replace("\\\"", "\"");
        } catch (Exception e) {
            return "Analysis complete.";
        }
    }

    private static String generateMockSummary(int count) {
        return "✨ **Quick Summary:**\n" + 
               "• The group has been very active with **" + count + "** recent messages.\n" +
               "• Discussion involves general updates and checking in.\n" +
               "• (AI connection failed on all models. Check API Key quotas.)";
    }
}