// Takes a file or arrays of files and construct a single array of 
// uniform time sorted list

// For now, suppose we are only dealing with one chat file

class MessageUtil {
    String filePath;
    ArrayList<MessageData> messagesList;

    public MessageUtil(String filePath) {
        this.filePath = filePath;
        this.messagesList = new ArrayList<MessageData>();

        this.processMessageFile(filePath);
    }

    public long getFirstMessageTimestamp() {
        if (this.messagesList.size() != 0) {
            return this.messagesList.get(this.messagesList.size() - 1).timestamp;
        }

        return 0;
    }

    public long getLastMessageTimestamp() {
        if (this.messagesList.size() != 0) {
            return this.messagesList.get(0).timestamp;
        }

        return 0;
    }

    private void processMessageFile(String filePath) {
        // We expect the file path to be JSON

        // TODO: wrap in try
        JSONObject jsonData = loadJSONObject(filePath);

        JSONArray participants = jsonData.getJSONArray("participants");
        JSONArray messages = jsonData.getJSONArray("messages");

        // We go backwards because the messages are sorted
        // by most recent on topS
        for (int i = messages.size() - 1; i >= 0; i--) {
            JSONObject message = messages.getJSONObject(i);

            if (message.getString("type").equals("Generic")) {
                final String content = message.getString("content");
                final String sender = message.getString("sender_name");
                final long timestamp = message.getLong("timestamp_ms") / 1000;
                
                messagesList.add(new MessageData(timestamp, sender, content));
            }
        }

        println("Finished processsing file");
        println("Total of " + str(this.messagesList.size()) + " messages");
    }
}