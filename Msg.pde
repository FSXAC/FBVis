class MsgManager {

    String[] msgRootPaths;
    public MsgManager(String rootPath) {

        /* Add messages paths to be searched */
        msgRootPaths = {
            pathJoin(rootPath, "messages", "inbox"),
            pathJoin(rootPath, "messages", "archived_threads"),
            pathJoin(rootPath, "messages", "filtered_threads")
        };
    }


}

/* Parses a single thread */
class MsgThread {

    /* Reference to parent/manager (for people look up) */
    MsgManager manager;

    /* Members */
    String threadRootPath;
    String[] jsonFiles;
    ArrayList<MsgData> messagesList;

    /**
     * Constructor for the thread parser; takes in a path to where the
     * message .json files are located -- Messenger splits larger
     * threads into multiple .json files;
     * @param threadPath the root path of the thread where .json files are stored
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
    }

    /**
     * Process all the json files -- paths are stored in filePaths
     */
    private void processAllJsonFiles() {
        /* process all messages in reverse order of sorting (oldest first) */
        for (int idx = this.filePath.length - 1; idx >= 0; idx--) {
            String jsonFilePath = pathJoin(this.threadRootPath, this.jsonFilePath[idx]);
            this.processJsonFile(jsonFilePath);
        }
    }

    /**
     * Process a single json file
     */
    private void processJsonFile(String filepath) {

        /* Load JSON object using Processing's JSON function */
        final JSONObject jsonData = loadJSONObject(filepath);

        /* Get participants in this thread */
        final JSONArray participants = jsonData.getJSONArray("participants");
        
        /* TODO: ignore/cancel processing if group size is greater than theshold */
        ArrayList<int> participants = new 
    }
}

class MsgData {

    /* Msg data members */
    long timestamp;
    int sender_id;
    int[] receiver_ids;
    String content;

    public MsgData(long timestamp, int sender_id, int[] receiver_ids, String content) {
        this.timestamp = timestamp;
        this.sender_id = sender_id;
        this.receiver_ids = receiver_ids;
        this.content = content;
    }
}
