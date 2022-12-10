import java.util.Collections;

// This should be a class that manages all messages, and message utils
class MessageManager {
    String rootPath;
    ArrayList<String> rootPaths;

    ArrayList<MessageData> organizedMessagesList;
    ArrayList<MessageFileReader> messageUtils;

    HashMap<String, Integer> nameToIdMap = new HashMap<String, Integer>();
    int id_counter = 0;

    public MessageManager(String root) {
        this.organizedMessagesList = new ArrayList<MessageData>();
        this.messageUtils = new ArrayList<MessageFileReader>();
        this.rootPaths = new ArrayList<String>();
        
        // TODO: this should go in the config
        this.rootPaths.add(pathJoin(root, "messages", "inbox"));
        this.rootPaths.add(pathJoin(root, "messages", "archived_threads"));
        this.rootPaths.add(pathJoin(root, "messages", "filtered_threads"));

        StringList filenames;
        for (String path : this.rootPaths) {
            try {
                filenames = listFileNames(path);
            } catch (NotDirectoryException e) {
                println("Error: " + path + " is not a directory");
                exit();
                return;   
            }

            // Null check
            if (filenames == null) continue;
            
            // create a new messageutil for each entry
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
                    continue;
                }
                
                String messageDataPath = pathJoin(path, filename);
                MessageFileReader newMessageUtil = new MessageFileReader(messageDataPath);
                this.messageUtils.add(newMessageUtil);
            }
        }

        // Now let's build the participants name to id map
        this.processParticipants();

        // Process each message util given the name to id map
        this.processMessages();

        // Sort the messages by timestamp
        Collections.sort(this.organizedMessagesList, new MessageDataComparator());
    }

    private void processParticipants() {
         for (MessageFileReader mfr : this.messageUtils) {
            if (!mfr.valid) continue;

            for (String name : mfr.participants) {
                if (!this.nameToIdMap.containsKey(name)) {
                    this.nameToIdMap.put(name, this.id_counter);
                    this.id_counter++;
                }
            }
        }
    }

    private void processMessages() {
        for (MessageFileReader mfr : this.messageUtils) {
            if (!mfr.valid) continue;
            mfr.processMessages(this.nameToIdMap, this.organizedMessagesList);
        }
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
class MessageData {
    long timestamp;

    int sender_id;
    int[] receivers_ids;

    String content;

    public MessageData(long timestamp, int sender_id, int[] receivers_ids, String content) {
        this.timestamp = timestamp;
        this.sender_id = sender_id;
        this.receivers_ids = receivers_ids;
        this.content = content;
    }
}

/* Comparator for sorting messages by timestamp */
public class MessageDataComparator implements Comparator<MessageData> {
    @Override
    public int compare(MessageData md1, MessageData md2) {
        return Long.compare(md1.timestamp, md2.timestamp);
    }
}

class MessageFileReader {
    String filePath;
    JSONObject[] jsonData;

    StringList participants;

    boolean valid = false;

    // Cache for sender to receiver map, int->int[]
    HashMap<Integer, int[]> senderToReceiversMap = new HashMap<Integer, int[]>();

    /**
     * Constructor
     * @param filePath Path to the folder containing all the json files for this thread
     */
    public MessageFileReader(String filePath) {
        this.filePath = filePath;

        // Populate json files
        StringList jsonFiles;
        try {
            jsonFiles = listFileNames(this.filePath, "json");
        } catch (NotDirectoryException e) {
            return;
        }

        this.jsonData = new JSONObject[jsonFiles.size()];
        for (int i = 0; i < jsonFiles.size(); i++) {
            String jsonFilePath = pathJoin(this.filePath, jsonFiles.get(i));
            this.jsonData[i] = loadJSONObject(jsonFilePath);
        }

        // Check if this thread is useful
        this.participants = new StringList();
        this.check();
    }

    /**
     * Checks if this thread is useful, if so, the valid flag is set to true
     * and the participants list is populated
     */
    private void check() {
        if (this.jsonData.length == 0) return;

        // Check number of participants
        // TODO: add support for group chats
        JSONArray participants = this.jsonData[0].getJSONArray("participants");
        if (this.jsonData[0].getJSONArray("participants").size() > 2) {
            return;
        }

        // If one of the participant doesn't have a name, ignore
        for (int i = 0; i < participants.size(); i++) {
            if (participants.getJSONObject(i).getString("name").equals(CONFIG.defaultName)) {
                return;
            }
            this.participants.append(participants.getJSONObject(i).getString("name"));
        }

        // If we made it here, this thread is useful
        this.valid = true;
    }

    /**
     * Processes a single message and returns a MessageData object
     * @param message JSONObject of the message
     * @param nameToIdMap HashMap of name to id
     * @return
     */
    public MessageData processSingleMessage(JSONObject message, HashMap<String, Integer> nameToIdMap) {

        // Ignore non-generic messages
        if (!message.getString("type").equals("Generic")) return null;

        // Get timestamp
        long timestamp = message.getLong("timestamp_ms");

        // Get sender
        String sender = message.getString("sender_name");

        // if the sender is not in the name to id map, ignore
        if (!nameToIdMap.containsKey(sender)) return null;
        int sender_id = nameToIdMap.get(sender);

        // Get content
        String content = message.getString("content");

        // Get receivers
        if (this.senderToReceiversMap.containsKey(sender_id)) {
            return new MessageData(timestamp, sender_id, this.senderToReceiversMap.get(sender_id), content);
        }

        // Get receivers by taking the participants and removing the sender
        int[] receivers_ids = new int[this.participants.size() - 1];
        for (int pi = 0, ri = 0; pi < this.participants.size(); pi++) {
            if (this.participants.get(pi).equals(sender)) continue;
            receivers_ids[ri] = nameToIdMap.get(this.participants.get(pi));
            ri++;
        }

        // If the sender to receivers map doesn't contain the sender, add it
        if (!this.senderToReceiversMap.containsKey(sender_id)) {
            this.senderToReceiversMap.put(sender_id, receivers_ids);
        }

        return new MessageData(timestamp, sender_id, receivers_ids, content);
    }

    /**
     * Process all messages in the thread
     * @param nameToIdMap HashMap of name to id
     * @param outputMessages ArrayList of MessageData objects from the thread
     */
    public void processMessages(HashMap<String, Integer> nameToIdMap, ArrayList<MessageData> outputMessages) {
        if (!this.valid) return;

        // Process each json file
        for (int i = 0; i < this.jsonData.length; i++) {
            JSONObject json = this.jsonData[i];

            // Get messages
            JSONArray messages = json.getJSONArray("messages");

            // Process each message
            for (int j = 0; j < messages.size(); j++) {
                MessageData md = this.processSingleMessage(messages.getJSONObject(j), nameToIdMap);
                if (md == null) continue;

                outputMessages.add(md);
            }
        }
    }
}