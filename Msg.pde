class MsgManager {

    String[] msgRootPaths;

    /* ID to person hash map */
    /* TODO: instead of mapping to string, map to person obj */
    HashMap<Integer, String> personMap;

    /* Threads */
    private ArrayList<MsgThread> msgThreads;
    
    /**
     * MsgManager handles all the data processing of the messages
     * .json files, as well as holding onto the data containers of msgs
     * @param rootPath the rootpath where the downloaded messages are archived
     */
    public MsgManager(String rootPath) {

        /* Add messages paths to be searched */
        this.msgRootPaths = new String[3];
        this.msgRootPaths[0] = pathJoin(rootPath, "messages", "inbox");
        this.msgRootPaths[1] = pathJoin(rootPath, "messages", "archived_threads");
        this.msgRootPaths[2] = pathJoin(rootPath, "messages", "filtered_threads");

        this.personMap = new HashMap<Integer, String>();

        this.msgThreads = new ArrayList<MsgThread>();
    }

    /**
     * Read all data
     * @param progressBar reference to a progressBar object for updaing the
     * progress of populating the messages data
     */
    public void populate() { this.populate(null); }
    public void populate(Progress progressBar) {

        /* A master list of all thread directories that contains .json files */
        StringList threadList = new StringList();

        /* Find all threads */
        for (String rootPath : this.msgRootPaths) {
            try {

                /* Add to master list */
                StringList threads = listFileNames(rootPath);

                /* If there are no threads; move on to next */
                if (threads == null)
                    continue;

                /* For each thread, add to the master list */
                for (String thread : threads) {
                    
                    /* If it's in the ignore list (defined in CONFIG), ignore */
                    if (CONFIG.checkIfIgnored(thread))
                        continue;

                    threadList.append(pathJoin(rootPath, thread));
                }
                


            } catch (NotDirectoryException e) {
                println("Error while trying to access root paths: "
                        + rootPath);
                continue;
            }
        }

        /* Instantiate MsgThread for each thread for processing */
        int numProcessableThreads = threadList.size();
        for (int i = 0; i < threadList.size(); i++) {
            
            /* Create a new MsgThread object; add to list if it's valid */
            MsgThread newMsg = new MsgThread(this, threadList.get(i));
            if (newMsg.isInitialized()) {
                this.msgThreads.add(newMsg);
            }

            if (progressBar != null) {
                /* TODO: handle progress bar */
                println(str(i) + "/" + str());
            }
        }

        // DEBUG
        println("Total threads processed: " + str(this.msgThreads.size());
    }

    /**
     * Get an ID given a name
     * @param name the name
     * @return the id associated with the name; -1 if is not found
     */
    public int getPersonIDFromName(String name) {
        for (Map.Entry person : this.personMap.entrySet()) {
            if (person.getValue().equals(name)) {
                return (int) person.getKey();
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
    private String name;
    private String threadType;

    private Boolean initialized;

    /* Contains all the message data */
    private ArrayList<MsgData> messagesData;

    /* The index that points to the head of messagesData */
    private int head;

    /* Participants (ids of people) */
    private ArrayList<Integer> participant_ids;

    /* Maximum group chat size (TODO: parameterize in config) */
    private const int MAX_PARTICIPANTS = 20;

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

        this.initialized = false;

        /* assign parent/manager */
        this.manager = manager;
        
        /* given the rootPath, add all json file paths to filePaths */
        this.threadRootPath = threadPath;
        try {
            this.jsonFiles = sortFilenamesNumerically(
                listFileNames(threadPath, "json"));
        } catch (NotDirectoryException e) {
            println("Not a directory exception occured while "
                    + "attempting to parse " + threadPath);
        }

        /* Messages data container */
        messagesData = new ArrayList<MsgData>();

        /* process all files */
        if (this.jsonFiles != null)
            this.initialized = this.processAllJsonFiles();

        /* reset data pointer */
        this.head = 0;
    }

    /**
     * Process all the json files -- paths are stored in filePaths
     * @return true if process successful
     */
    private Boolean processAllJsonFiles() {

        /* process all messages in reverse order of sorting (oldest first) */
        for (int idx = this.jsonFiles.length - 1; idx >= 0; idx--) {

            /* Load JSON file */
            String jsonFilePath = pathJoin(this.threadRootPath, this.jsonFiles[idx]);
            final JSONObject jsonData = loadJSONObject(filepath);

            /* Populate metadata about thread */
            if (idx == this.jsonFiles.length - 1) {
                if (!this.processJSONMetadata(jsonData)) {
                    return false;
                }
            }

            /* Process messages */
            this.processJsonFile(jsonData);
        }

        return true;
    }

    /**
     * Process and populate thread metadata such as array of parcipant ids
     * (only need to run once even for multiple json files)
     * @param jsonData the json data of the file
     * @return true if successfullly parses metadata; false if cancel
     */
    private Boolean processJSONMetadata(JSONObject jsonData) {

        /* Get thread metadata */
        this.name = jsonData.getString("title");
        this.threadType = jsonData.getString("thread_type");

        /* Get thread participants */
        if (!processJSONParticipants())
            return false;

        return true;
    }

    /**
     * Process the participants in a thread
     * @param jsonData the json data
     * @return true if process is successful, false if fails due to invalid
     * set of participants
     */
    private Boolean processJSONParticipants(JSONObject jsonData) {
        /* Get participants in this thread */
        final JSONArray participantsData = jsonData.getJSONArray("participants");
        
        /* Stop processing if number of participants is too few
         * or if the number of participants is too large
         */
        if (participantsData.size() <= 1 ||
            participantsData.size() > MAX_PARTICIPANTS) {
            return false;
        }

        /* Instantiate array of participant ids */
        this.participant_ids = new ArrayList<Integer>();

        /* Get participants from file */
        /* TODO: if this is a group chat, then ignore any "Facebook User" chats */
        /* TODO: otherwise if this is a 1:1 chat, then simply do "renaming" */
        for (int i = 0; i < participantsData.size(); i++) {
            String name = participantsData.getJSONObject(i).getString("name");

            /* Check if the name is "default name/no name" */
            if (name.equals(CONFIG.defaultName)) {
                name += ' '  + str(UnknownPersonCounter.count++);
            }

            /* Get ID from manager and populate member array */
            this.participant_ids.add(manager.getAndSetPersonIDFromName(name));
        }
    }

    /**
     * Process a single json file
     * @param jsonData the json data of the file
     */
    private void processJsonFile(JSONObject jsonData) {

        /* Get message data */
        final JSONArray msgsData = jsonData.getJSONArray("messages");

        // DEBUG:
        print(filepath);
        print(" ");
        println(msgsData.size());

        /* Loop in reverse such that it's sorted oldest to newest */
        for (int i = msgsData.size() - 1; i >= 0; i--) {
            final JSONObject msgData = msgsData.getJSONObject(i);

            if (msgData.getBoolean("is_unsent"))
                continue;

            if (msgData.getString("type").equals("Generic")) {
                
                /**
                 * Sender id
                 * NOTE: if the facebook user deleted their profile,
                 * the sender_name retrievied here would be 'Other User'
                 * (as of Nov. 2021).
                 * This is problematic because the participant ID already maps
                 * to a different name that goes by "Facebook User x" where x
                 * is a number. 
                 *
                 * TODO: (?) what happens in a large group chat where >1 people
                 * have gone offline?
                 */
                final String sender = msgData.getString("sender_name");
                assert sender != null;
                final int sender_id = this.manager.getPersonIDFromName(sender);
                assert sender_id != -1;

                /* Timestamp */
                final long timestamp = msgData.getLong("timestamp_ms");


                /* Determine what kind of message it is */
                /* TODO: for now we'll just focus on text msgs (see below) */
                final String content = msgData.getString("content");
                // final JSONArray photos = msgData.getJSONArray("photos");
                // final JSONObject sticker = msgData.getJSONObject("sticker");
                if (content == null)
                    continue;

                /* Get receivers
                 * -- which should just be a copy of the participants
                 * list minus the sender
                 */
                ArrayList<Integer> receiver_ids = new ArrayList<Integer>(
                    this.participant_ids);
                receiver_ids.remove(Integer.valueOf(sender_id));

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

    /**
     * Returns whether this thread has been processed and initialized
     */
    public Boolean isInitialized() {
        return this.initialized;
    }
}

/**
 * Container calss for each message
 * It contains the timestamp of the message, sender and receiver IDs,
 * and the message content itself
 *
 * TODO: in the future this should support different types of msgs
 * -- since add/remove participants in the thread is registered as a type
 * of msg (e.g. subscribe, unsubscribe). Therefore it's appropriate to
 * create a parent MsgEvent class that can be used
 */
class MsgData {

    /* Msg data members */
    private long timestamp;
    private int sender_id;
    private ArrayList<Integer> receiver_ids;
    private String content;

    public MsgData(long timestamp, int sender_id, ArrayList<Integer> receiver_ids,
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
    public int getSenderId() { return this.sender_id; }
    public String getContent() { return this.content; }
    public int getContentLength() { return this.content.length(); }
}
