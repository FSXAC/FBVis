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


                /* Find all the JSON files in the path */
                // StringList ThreadJsonFiles;
                // try {
                //     sortedJsonFiles = sortFilenamesNumerically(listFileNames(messageDataPath, "backup"));
                // } catch (NotDirectoryException e) {
                //     continue;
                // }
                // try {
                //     ThreadJsonFiles = listFileNames(messageDataPath, "json")
                // } catch (NotDirectoryException e) {
                //     continue;
                // }
                
                /* Get message util object and populate with all the json files */
                // if (CONFIG.enableVerbose) println("Loading: " + messageDataPath);
                MessageFileReader newMessageUtil = new MessageFileReader(messageDataPath);

                /* Populate in reverse order */
                // for (int idx = sortedJsonFiles.length - 1; idx >= 0; idx--) {
                //     String jsonFilePath = pathJoin(messageDataPath, sortedJsonFiles[idx]);
                //     newMessageUtil.processMessageFile(jsonFilePath);
                // }
                
                // newMessageUtil.initialized = true;
                this.messageUtils.add(newMessageUtil);
            }
        }

        // Now let's build the participants name to id map
        for (MessageFileReader mfr : this.messageUtils) {
            if (!mfr.valid) continue;

            for (String name : mfr.participants) {
                if (!this.nameToIdMap.containsKey(name)) {
                    this.nameToIdMap.put(name, this.id_counter);
                    this.id_counter++;
                }
            }
        }

        // Process each message util given the name to id map
        for (MessageFileReader mfr : this.messageUtils) {
            if (!mfr.valid) continue;

            mfr.processMessages(this.nameToIdMap);
        }

        // Build message list
        for (MessageFileReader mfr : this.messageUtils) {
            if (!mfr.valid) continue;
            for (MessageData md : mfr.messages) {

                // No sorting required for the first entry
                // if (this.organizedMessagesList.size() == 0) {
                //     this.organizedMessagesList.add(md);
                //     continue;
                // }

                // int index = this.getInsersionIndex(md.timestamp, 0, this.organizedMessagesList.size() - 1);
                // this.organizedMessagesList.add(index, md);
                this.organizedMessagesList.add(md);
            }
        }

        Collections.sort(this.organizedMessagesList, new MessageDataComparator());
        
        // this.buildMessagesList();
    }
    
    // Builds an timely ordered list
    // public void buildMessagesList() {
    //     if (CONFIG.enableVerbose) println("Building ordered messages list, sorting through all messages by time");
    //     for (int i = 0; i < this.messageUtils.size(); i++) {

    //         // Status
    //         if (CONFIG.enableVerbose) println("Sorting " + str(i) + "/" + str(messageUtils.size()) + " entries");
    //         // progress.setSortingProgress(i / messageUtils.size());

    //         MessageUtil mu = this.messageUtils.get(i);
    //         for (MessageData md : mu.getMessagesList()) {
    //             // No sorting required for the first entry
    //             if (this.organizedMessagesList.size() == 0) {
    //                 this.organizedMessagesList.add(0, md);
    //                 continue;
    //             }

    //             int index = this.getInsersionIndex(md.timestamp, 0, this.organizedMessagesList.size() - 1);
    //             this.organizedMessagesList.add(index, md);
    //         }
    //     }

    //     // Print first 200 results to verify
    //     println("Sorted " + this.organizedMessagesList.size() + " total messages");
    // }

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

public class MessageDataComparator implements Comparator<MessageData> {
    @Override
    public int compare(MessageData md1, MessageData md2) {
        return Long.compare(md1.timestamp, md2.timestamp);
    }
}

class MessageFileReader {
    String filePath;
    JSONObject[] jsonData;

    ArrayList<MessageData> messages;
    StringList participants;

    boolean valid = false;

    // Cache for sender to receiver map, int->int[]
    HashMap<Integer, int[]> senderToReceiversMap = new HashMap<Integer, int[]>();

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
        this.messages = new ArrayList<MessageData>();
        this.check();
    }

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

    public void processMessages(HashMap<String, Integer> nameToIdMap) {
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

                this.messages.add(md);
            }
        }
    }

    // public void process() {
    //     JSONObject json = loadJSONObject(this.filePath);

    //     JSONArray participants = json.getJSONArray("participants");


    //     // local name to id map
    //     HashMap<String, Integer> localNameToIdMap = new HashMap<String, Integer>();
    //     for (int i = 0; i < participants.size(); i++) {
    //         String participantName = participants.getJSONObject(i).getString("name");
    //         localNameToIdMap.put(participantName, -1);

    //         if (participantName.equals(CONFIG.defaultName)) {
    //             // TODO: add support for unknown users
    //             return;
    //         }
    //     }

    //     // Populate local id map with global id map
    //     for (String name : localNameToIdMap.keySet()) {
    //         if (globalNameToIdMap.containsKey(name)) {
    //             localNameToIdMap.put(name, globalNameToIdMap.get(name));
    //         } else {
    //             localNameToIdMap.put(name, id_counter);
    //             globalNameToIdMap.put(name, id_counter);
    //             id_counter++;
    //         }
    //     }

    //     // Process through messages
    //     JSONArray messages = jsonData.getJSONArray("messages");
    //     this.messages = new MessageData[messages.size()];
    //     for (int i = 0; i < messages.size(); i++) {
    //         JSONObject message = messages.getJSONObject(i);

    //         // TODO: add support for other message types
    //         if (!message.getString("type").equals("Generic")) {
    //             continue;
    //         }

    //         String sender = message.getString("sender_name");
    //         if (sender == null) {
    //             continue;
    //         }

    //         String content = message.getString("content");
    //         if (content == null) {
    //             continue;
    //         }

    //         long timestamp = message.getLong("timestamp_ms");

    //         // Get receivers (list of participants minus sender)
    //         ArrayList<String> receivers = new ArrayList<String>();
            
    //         // Check the id map
            
    //     }
        
    //     // A hashmap / table is used to cache the sender -> receiver mapping
    //     // TODO: we have to recompute the table if someone adds/removes people from group chat
    //     HashMap<String, ArrayList<String>> receiverMapping = new HashMap<String, ArrayList<String>>();

    //     // We go backwards because the messages are sorted
    //     // by most recent on top
    //     for (int i = messages.size() - 1; i >= 0; i--) {
    //         JSONObject message = messages.getJSONObject(i);

    //         if (message.getString("type").equals("Generic")) {
    //             String content = message.getString("content");
    //             String sender = message.getString("sender_name");
    //             final long timestamp = message.getLong("timestamp_ms");
                
    //             if (sender == null) {
    //                 sender = "{UNKNOWN USER}";
    //             }
                
    //             if (content == null) {
    //                 content = "{NO CONTENT}";
    //             }

    //             // Get a single or list of receivers
    //             ArrayList<String> receivers;
    //             if (receiverMapping.containsKey(sender)) {
    //                 receivers = receiverMapping.get(sender);

    //             } else {

    //                 receivers = new ArrayList<String>();

    //                 // Find all receivers from the participants list
    //                 for (int j = 0; j < participants.size(); j++) {
    //                     String name = participants.get(j);

    //                     // if participant name is not sender, it must be receiver
    //                     if (!sender.equals(name)) {
    //                         receivers.add(name);
    //                     }
    //                 }

    //                 // Add the list to the table to save computing
    //                 receiverMapping.put(sender, receivers);
    //             }
                
    //             // messagesList.add(new MessageData(timestamp, sender, receivers, content));
    //             messagesList.add(new MessageData(timestamp, 0, null, content));
    //         }
    //     }
        
    // }
}


// Takes a file or arrays of files and construct a single array of 
// uniform time sorted list

// For now, suppose we are only dealing with one chat file

// class MessageUtil {
//     String filePath;
//     ArrayList<MessageData> messagesList;

//     boolean initialized;

//     /* Message util takes a file path and populates
//      * messagesList with the data read from the file
//      * @param path, the path to the inbox mail folder
//      */
//     public MessageUtil(String path) {
//         this.filePath = filePath;
//         this.messagesList = new ArrayList<MessageData>();
//         this.initialized = false;
//     }

//     ////////////////// PUBLIC FUNCTIONS
//     public long getFirstMessageTimestamp() {
//         if (this.messagesList.size() != 0) {
//             return this.messagesList.get(this.messagesList.size() - 1).timestamp;
//         }

//         return 0;
//     }

//     public long getLastMessageTimestamp() {
//         if (this.messagesList.size() != 0) {
//             return this.messagesList.get(0).timestamp;
//         }

//         return 0;
//     }
    
//     public ArrayList<MessageData> getMessagesList() {
//         return messagesList;
//     }

//     public void processMessageFile(String filePath) {
//         // We expect the file path to be JSON

//         // TODO: wrap in try
//         JSONObject jsonData = loadJSONObject(filePath);

//         // Get participants
//         JSONArray participantsData = jsonData.getJSONArray("participants");
//         if (participantsData.size() > LARGE_GROUP_PARTICIPANT_THRES) {
//             return;
//         }

//         ArrayList<String> participants = new ArrayList<String>();

//         for (int i = 0; i < participantsData.size(); i++) {
//             JSONObject nameObj = participantsData.getJSONObject(i);


//             String name = nameObj.getString("name");

//             if (name.equals(CONFIG.defaultName)) {
//                 name += ' ' + str(globalUnknownUserCount);
//                 globalUnknownUserCount++;
//             }

//             participants.add(name);
//         }

//         // Get messages
//         JSONArray messages = jsonData.getJSONArray("messages");
        
//         // A hashmap / table is used to cache the sender -> receiver mapping
//         // TODO: we have to recompute the table if someone adds/removes people from group chat
//         HashMap<String, ArrayList<String>> receiverMapping = new HashMap<String, ArrayList<String>>();

//         // We go backwards because the messages are sorted
//         // by most recent on top
//         for (int i = messages.size() - 1; i >= 0; i--) {
//             JSONObject message = messages.getJSONObject(i);

//             if (message.getString("type").equals("Generic")) {
//                 String content = message.getString("content");
//                 String sender = message.getString("sender_name");
//                 final long timestamp = message.getLong("timestamp_ms");
                
//                 if (sender == null) {
//                     sender = "{UNKNOWN USER}";
//                 }
                
//                 if (content == null) {
//                     content = "{NO CONTENT}";
//                 }

//                 // Get a single or list of receivers
//                 ArrayList<String> receivers;
//                 if (receiverMapping.containsKey(sender)) {
//                     receivers = receiverMapping.get(sender);

//                 } else {

//                     receivers = new ArrayList<String>();

//                     // Find all receivers from the participants list
//                     for (int j = 0; j < participants.size(); j++) {
//                         String name = participants.get(j);

//                         // if participant name is not sender, it must be receiver
//                         if (!sender.equals(name)) {
//                             receivers.add(name);
//                         }
//                     }

//                     // Add the list to the table to save computing
//                     receiverMapping.put(sender, receivers);
//                 }
                
//                 // messagesList.add(new MessageData(timestamp, sender, receivers, content));
//                 messagesList.add(new MessageData(timestamp, 0, null, content));
//             }
//         }

//         if (CONFIG.enableVerbose) {
//             println("Finished processsing file");
//             println("Total of " + str(this.messagesList.size()) + " messages");
//         }
//     }
// }
