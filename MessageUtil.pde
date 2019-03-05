// Takes a file or arrays of files and construct a single array of 
// uniform time sorted list

// For now, suppose we are only dealing with one chat file

class MessageUtil {
    String filePath;

    public MessageUtil(String filePath) {
        this.filePath = filePath;

        this.processMessageFile(filePath);
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
                println(message.getString("content"));
            }
        }
    }
}