class MsgManager {

    String[] msgRootPaths;

    /* ID to person hash map */
    /* TODO: instead of mapping to string, map to person obj */
    HashMap<int, String> personMap;
    
    /**
     * MsgManager handles all the data processing of the messages
     * .json files, as well as holding onto the data containers of msgs
     * @param rootPath the rootpath where the downloaded messages are archived
     */
    public MsgManager(String rootPath) {

        /* Add messages paths to be searched */
        this.msgRootPaths = {
            pathJoin(rootPath, "messages", "inbox"),
            pathJoin(rootPath, "messages", "archived_threads"),
            pathJoin(rootPath, "messages", "filtered_threads")
        };

        this.personMap = new HashMap<int, String>();
    }

    /**
     * Get an ID given a name
     * @param name the name
     * @return the id associated with the name; -1 if is not found
     */
    public int getPersonIDFromName(String name) {
        for (Map.Entry person : this.personMap.entrySet()) {
            if (person.getValue().equals(name)) {
                return person.getKey();
            }
        }

        return -1;
    }

    /**
     * Get an ID given a name; allocate a new ID->name mapping if not found
     * @param name the name
     * @param the id associated with the name
     */
    public int getAndSetPersonIDFromName(String name) {
        final int id = this.getPersonIDFromName(name);
        if (id == -1) {
            int new_id = this.personMap.size();
            this.personMap.put(new_id, name);
            return new_id;
        } else {
            return id;
        }
    }
}

/* Parses a single thread */
class MsgThread {

    /* Reference to parent/manager (for people look up) */
    private MsgManager manager;

    /* Message data */
    private String threadRootPath;
    private String[] jsonFiles;

    /* Contains all the message data */
    private ArrayList<MsgData> messagesData;

    /* The index that points to the head of messagesData */
    private int head;

    /* Participants (ids of people) */
    private IntList participant_ids;

    /* Unknown person counter (for renaming) */
    private static int unknownCounter = 0;

    /**
     * Constructor for the thread parser; takes in a path to where the
     * message .json files are located -- Messenger splits larger
     * threads into multiple .json files;
     * @param manager the parent MsgManager obj -- must be instantiated
     * through here
     * @param threadPath the root path of the thread where .json files
     * are stored
     */
    public MsgThread(MsgManager manager, String threadPath) {

        /* assign parent/manager */
        this.manager = manager;
        
        /* given the rootPath, add all json file paths to filePaths */
        this.threadRootPath = threadPath;
        String[] sortedJsonFiles;
        try {
            sortedJsonFiles = sortFilenamesNumerically(
                listFileNames(threadPath, "json"));
        } catch (NotDirectoryException e) {
            println("Not a directory exception occured while \
                    attempting to parse " + threadPath);
            exit();
        }

        /* initialize message containers */
        this.jsonFiles = new String[sortedJsonFiles.length];

        /* process all files */
        this.processAllJsonFiles();

        /* reset data pointer */
        this.head = 0;
    }

    /**
     * Process all the json files -- paths are stored in filePaths
     */
    private void processAllJsonFiles() {
        /* process all messages in reverse order of sorting (oldest first) */

        for (int idx = this.jsonFiles.length - 1; idx >= 0; idx--) {
            // TODO: run once for participant processing
            String jsonFilePath = pathJoin(this.threadRootPath, this.jsonFiles[idx]);

            /* Process participants */
            if (idx == this.jsonFiles.length - 1) {
                this.processParticipants(jsonFilePath);
            }

            this.processJsonFile(jsonFilePath);
        }
    }

    /**
     * Process and populate array of parcipant ids
     * (only need to run once even for multiple json files)
     * @param filepath the full path to the .json file
     */
    private int processParticipants(String filepath) {
        /* Load JSON object using Processing's JSON function */
        final JSONObject jsonData = loadJSONObject(filepath);

        /* Get participants in this thread */
        final JSONArray participantsData = jsonData.getJSONArray("participants");
        
        /* TODO: ignore/cancel processing if group size is greater than theshold
         * Perhaps it'a a good idea to THROW?
         */

        /* Instantiate array of participant ids */
        this.participant_ids = new ArrayList<int>();

        /* Get participants from file */
        for (int i = 0; i < participantsData.size(); i++) {
            String name = participantsData.getJSONObject(i).getString("name");

            /* Check if the name is "default name/no name" */
            if (name.equals(CONFIG.defaultName)) {
                name += ' '  + str(unknownCounter);
                unknownCounter++;
            }

            /* Get ID from manager and populate member array */
            this.participant_ids.add(manager.getAndSetPersonIDFromName(name));
        }
    }

    /**
     * Process a single json file
     * @param filepath the full path to the .json file
     */
    private void processJsonFile(String filepath) {

        /* Load JSON object using Processing's JSON function */
        final JSONObject jsonData = loadJSONObject(filepath);

        /* Get message data */
        final JSONArray msgsData = jsonData.getJSONArray("messages");

        /* Loop in reverse such that it's sorted oldest to newest */
        for (int i = msgsData.size() - 1; i >= 0; i--) {
            final JSONObject msgData = msgsData.getJSONObject(i);

            if (msgData.getBoolean(is_unsent))
                continue;

            if (msgData.getString("type").equals("Generic") {
                
                /* Read and verify the data from file */
                final String content = msgData.getString("content");
                final String sender = msgData.getString("sender_name");
                assert content;
                assert sender;

                final int sender_id = this.manager.getPersonIDFromName(sender);
                assert sender_id != -1;

                final long timestamp = msgData.getLong("timestamp_ms");

                /* Get receivers
                 * -- which should just be a copy of the participants
                 * list minus the sender
                 */
                final ArrayList<int> receiver_ids = this.participant_ids.copy()
                    .remove(Integer.valueOf(sender_id));

                /* Create new message data container */
                MsgData msg = new MsgData(
                    timestamp,
                    sender_id,
                    receiver_ids,
                    content
                );

                /* Add msg to list of msgs */
                messagesData.add(msg);
            }
        }
    }

    /**
     * Reset messages data index/pointer
     */
    public void resetHead() {
        this.head = 0;
    }

    /**
     * Get HEAD msg
     * @return HEAD MsgData
     */
    public MsgData getHeadMsgData() {
        return this.messagesData.get(this.head);
    }

    /**
     * Get the timestamp of the HEAD
     * @return the timestamp of the MsgData at HEAD
     */
    public long getHeadTimestamp() {
        return this.getHeadMsgData().getTimestamp();
    }

    /**
     * Get a list of messages from head to a specified timestamp
     * Then increase the HEAD index up to the time
     * @param endTime the end timestamp
     */
    public ArrayList<MsgData> getMsgsUntil(long endTime) {

        ArrayList<MsgData> msgs = new ArrayList<MsgData>();
        while (this.getHeadTimestamp() < endTime) {

            /* Add head msg and increment head */
            msgs.add(this.getHeadMsgData());
            this.head++;
        }

        return msgs;
    }
}

/**
 * Container calss for each message
 * It contains the timestamp of the message, sender and receiver IDs,
 * and the message content itself
 *
 * TODO: in the future this should support different types of msgs
 */
class MsgData {

    /* Msg data members */
    private long timestamp;
    private int sender_id;
    private ArrayList<int> receiver_ids;
    private String content;

    public MsgData(long timestamp, int sender_id, ArrayList<int> receiver_ids,
                   String content) {

        this.timestamp = timestamp;
        this.sender_id = sender_id;
        this.receiver_ids = receiver_ids;
        this.content = content;
    }

    /**
     * Returns true if this message is sent in a group (if the number of 
     * recipients is greater than 1)
     */
    public Boolean isGroupMessage() {
        return this.receiver_ids.size() > 1;
    }

    /**
     * Getters
     */
    public long getTimestamp() { return this.timestamp; }
}
