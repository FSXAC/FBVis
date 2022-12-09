// if number of participants in a thread is bigger than this number, ignore it
final int LARGE_GROUP_PARTICIPANT_THRES = 20;

// This should be a class that manages all messages, and message utils
class MessageManager {
    ArrayList<MessageData> organizedMessagesList;
    ArrayList<MessageUtil> messageUtils;
    String rootPath;
    ArrayList<String> rootPaths;

    public MessageManager(String root) {
        this.organizedMessagesList = new ArrayList<MessageData>();
        this.messageUtils = new ArrayList<MessageUtil>();
        this.rootPaths = new ArrayList<String>();
        
        // TODO: this should go in the config
        this.rootPaths.add(pathJoin(root, "messages", "inbox"));
        this.rootPaths.add(pathJoin(root, "messages", "archived_threads"));
        this.rootPaths.add(pathJoin(root, "messages", "filtered_threads"));

        int j = 0;
        StringList filenames;
        for (String path : this.rootPaths) {
            try {
                filenames = listFileNames(path);
            } catch (NotDirectoryException e) {
                println("Error");
                exit();
                return;
                
                // TODO: throw exception
            }

            // Null check
            if (filenames == null) continue;
            
            // create a new messageutil for each entry
            int i = 0;
            for (String filename : filenames) {
                
                // If in the ignore list, then skip
                boolean ignore = false;
                for (String ignoredItem : CONFIG.ignoreList) {
                    if (ignoredItem.equals(filename)) {
                        ignore = true;
                        break;
                    }
                }
                if (ignore) {
                    i++;
                    continue;
                }
                
                String messageDataPath = pathJoin(path, filename);

                /* Find all the JSON files in the path */
                String[] sortedJsonFiles;
                try {
                    sortedJsonFiles = sortFilenamesNumerically(listFileNames(messageDataPath, "json"));
                } catch (NotDirectoryException e) {
                    continue;
                }
                
                /* Get message util object and populate with all the json files */
                if (CONFIG.enableVerbose) println("Loading: " + messageDataPath);
                MessageUtil newMessageUtil = new MessageUtil(messageDataPath);

                /* Populate in reverse order */
                for (int idx = sortedJsonFiles.length - 1; idx >= 0; idx--) {
                    String jsonFilePath = pathJoin(messageDataPath, sortedJsonFiles[idx]);
                    newMessageUtil.processMessageFile(jsonFilePath);
                }
                
                newMessageUtil.initialized = true;
                this.messageUtils.add(newMessageUtil);
                
                i++;
                
                // Status
                progress.setLoadingProgress(i / filenames.size());
            }

            j++;
            progress.setLoadingLargeProgress(j / this.rootPaths.size());
        }
        
        this.buildMessagesList();
    }
    
    // Builds an timely ordered list
    public void buildMessagesList() {
        if (CONFIG.enableVerbose) println("Building ordered messages list, sorting through all messages by time");
        for (int i = 0; i < this.messageUtils.size(); i++) {

            // Status
            if (CONFIG.enableVerbose) println("Sorting " + str(i) + "/" + str(messageUtils.size()) + " entries");
            progress.setSortingProgress(i / messageUtils.size());

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
    float contentSizeSqrt;

    public MessageData(long timestamp, String sender, ArrayList<String> receivers, String content) {
        super();
        this.timestamp = timestamp;
        this.sender = sender;
        this.receivers = receivers;
        this.content = content;
        this.contentSizeSqrt = sqrt(this.content.length());
    }
}


// Takes a file or arrays of files and construct a single array of 
// uniform time sorted list

// For now, suppose we are only dealing with one chat file
int globalUnknownUserCount = 0;
class MessageUtil {
    String filePath;
    ArrayList<MessageData> messagesList;

    boolean initialized;

    /* Message util takes a file path and populates
     * messagesList with the data read from the file
     * @param path, the path to the inbox mail folder
     */
    public MessageUtil(String path) {
        this.filePath = filePath;
        this.messagesList = new ArrayList<MessageData>();
        this.initialized = false;
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

    public void processMessageFile(String filePath) {
        // We expect the file path to be JSON

        // TODO: wrap in try
        JSONObject jsonData = loadJSONObject(filePath);

        // Get participants
        JSONArray participantsData = jsonData.getJSONArray("participants");
        if (participantsData.size() > LARGE_GROUP_PARTICIPANT_THRES) {
            return;
        }

        ArrayList<String> participants = new ArrayList<String>();

        for (int i = 0; i < participantsData.size(); i++) {
            JSONObject nameObj = participantsData.getJSONObject(i);


            String name = nameObj.getString("name");

            if (name.equals(CONFIG.defaultName)) {
                name += ' ' + str(globalUnknownUserCount);
                globalUnknownUserCount++;
            }

            participants.add(name);
        }

        // Get messages
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
                        String name = participants.get(j);

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

        if (CONFIG.enableVerbose) {
            println("Finished processsing file");
            println("Total of " + str(this.messagesList.size()) + " messages");
        }
    }
}
