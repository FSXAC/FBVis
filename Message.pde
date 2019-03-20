// This should be a class that manages all messages, and message utils
class MessageManager {
    ArrayList<MessageData> organizedMessagesList;
    ArrayList<MessageUtil> messageUtils;
    String rootPath;

    public MessageManager(String root) {
        this.organizedMessagesList = new ArrayList<MessageData>();
        this.messageUtils = new ArrayList<MessageUtil>();
        
        
        this.rootPath = pathJoin(root, "messages\\inbox");
        String[] filenames = listFileNames(this.rootPath);
        //printArray(filenames);
        
        // create a new messageutil for each entry
        int i = 0;
        for (String filename : filenames) {
            String[] pathSegments = {this.rootPath, filename, "message.json"};
            String messageDataPath = pathJoins(pathSegments);
            
            println("Loading: " + messageDataPath);
            MessageUtil newMessageUtil = new MessageUtil(messageDataPath);
            
            this.messageUtils.add(newMessageUtil);
            
            i++;
            
            // Status
            progress.setLoadingProgress(100.0 * i / filenames.length);
        }
        
        this.buildMessagesList();
    }
    
    // Builds an timely ordered list
    public void buildMessagesList() {
        println("Building ordered messages list, sorting through all messages by time");
        for (int i = 0; i < this.messageUtils.size(); i++) {

            // Status
            println("Sorting " + str(i) + "/" + str(messageUtils.size()) + " entries");
            progress.setSortingProgress(100.0 * i / messageUtils.size());

            MessageUtil mu = this.messageUtils.get(i);
            for (MessageData md : mu.getMessagesList()) {
                // No sorting required for the first entry
                if (this.organizedMessagesList.size() == 0) {
                    this.organizedMessagesList.add(0, md);
                    continue;
                }

                int index = this.getInsersionIndex(md.timestamp, 0, this.organizedMessagesList.size() - 1);
                this.organizedMessagesList.add(index, md);
            }
        }

        // Print first 200 results to verify
        println("Sorted " + this.organizedMessagesList.size() + " total messages");
    }

    private int getInsersionIndex(long timestamp, int start, int end) {
        // Recursive function that use binary search to get index to insert
        
        // Edge case
        if (start == end) {
            if (this.organizedMessagesList.get(start).timestamp > timestamp) {
                return start;
            } else {
                return start + 1;
            }
        }

        // Exit condition
        if (start > end) {
            return start;
        }

        // All other cases
        int mid = (start + end) / 2;
        long midTime = this.organizedMessagesList.get(mid).timestamp;
        if (midTime < timestamp) {
            return this.getInsersionIndex(timestamp, mid + 1, end);
        } else if (midTime > timestamp) {
            return this.getInsersionIndex(timestamp, start, mid - 1);
        } else {
            return mid;
        }
    }
}


// Primitive object for a single entry of message
class MessageData{
    long timestamp;
    String sender;
    ArrayList<String> receivers;
    String content;

    public MessageData(long timestamp, String sender, ArrayList<String> receivers, String content) {
        super();
        this.timestamp = timestamp;
        this.sender = sender;
        this.receivers = receivers;
        this.content = content;
    }
}


// Takes a file or arrays of files and construct a single array of 
// uniform time sorted list

// For now, suppose we are only dealing with one chat file

class MessageUtil {
    String filePath;
    ArrayList<MessageData> messagesList;

    boolean initialized;

    ////////////////// CONSTRUCTOR
    public MessageUtil(String filePath) {
        this.filePath = filePath;
        this.messagesList = new ArrayList<MessageData>();

        this.processMessageFile(filePath);
        this.initialized = true;
    }

    ////////////////// PUBLIC FUNCTIONS
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
    
    public ArrayList<MessageData> getMessagesList() {
        return messagesList;
    }

    ////////////////// PRIVATE FUNCTIONS
    private void processMessageFile(String filePath) {
        // We expect the file path to be JSON

        // TODO: wrap in try
        JSONObject jsonData = loadJSONObject(filePath);

        // Get participants
        JSONArray participants = jsonData.getJSONArray("participants");
        JSONArray messages = jsonData.getJSONArray("messages");
        
        // A hashmap / table is used to cache the sender -> receiver mapping
        // TODO: we have to recompute the table if someone adds/removes people from group chat
        HashMap<String, ArrayList<String>> receiverMapping = new HashMap<String, ArrayList<String>>();

        // We go backwards because the messages are sorted
        // by most recent on top
        for (int i = messages.size() - 1; i >= 0; i--) {
            JSONObject message = messages.getJSONObject(i);

            if (message.getString("type").equals("Generic")) {
                String content = message.getString("content");
                String sender = message.getString("sender_name");
                final long timestamp = message.getLong("timestamp_ms");
                
                if (sender == null) {
                    sender = "{UNKNOWN USER}";
                }
                
                if (content == null) {
                    content = "{NO CONTENT}";
                }

                // Get a single or list of receivers
                ArrayList<String> receivers;
                if (receiverMapping.containsKey(sender)) {
                    receivers = receiverMapping.get(sender);

                } else {

                    receivers = new ArrayList<String>();

                    // Find all receivers from the participants list
                    for (int j = 0; j < participants.size(); j++) {
                        JSONObject nameObj = participants.getJSONObject(j);
                        String name = nameObj.getString("name");

                        // if participant name is not sender, it must be receiver
                        if (!sender.equals(name)) {
                            receivers.add(name);
                        }
                    }

                    // Add the list to the table to save computing
                    receiverMapping.put(sender, receivers);
                }
                
                messagesList.add(new MessageData(timestamp, sender, receivers, content));
            }
        }

        println("Finished processsing file");
        println("Total of " + str(this.messagesList.size()) + " messages");
    }
}