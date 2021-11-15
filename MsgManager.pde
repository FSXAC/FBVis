class MsgManager {

    String[] msgRootPaths;

    /* ID to person hash map */
    /* TODO: instead of mapping to string, map to person obj */
    HashMap<Integer, String> personMap;

    /* Threads */
    private ArrayList<MsgThread> msgThreads;

    /* Metadata */
    private long earliestTimestamp;
    private long latestTimestamp;
    private int totalMsgs;
    
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

        /* Compute metadata */
        this.populateThreadsMetadata();
    }

    /**
     * Computes the threads metadata at initial-time since it only needs to
     * be done once; metadata includes earliest timestamp, last timestamp,
     * total number of messages, total number of unique participants, etc.
     */
    private void populateThreadsMetadata() {

        /* Calculate earliest and latest timestamp */
        Boolean init = true;
        for (MsgThread t : this.MsgThreads) {
            final long t0 = t.getEarliestTimestamp();
            final long t1 = t.getLatestTimestamp();

            if (init) {
                this.earliestTimestamp = t0;
                this.latestTimestamp = t1;
            } else {
                if (t0 < this.earliestTimestamp) {
                    this.earliestTimestamp = t0;
                }

                if (t1 > this.latestTimestamp) {
                    this.latestTimestamp = t1;
                }
            }
        }

        /* Compute total number of messages */
        this.totalMsgs = 0;
        for (MsgThread t : this.msgThreads) {
            totalMsgs += t.getThreadSize();
        }
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

    /**
     * Reset thread pointers; resets the head index of each thread to
     * point to the first/oldest message of each thread
     */
    public void resetThreadHeads() {
        for (MsgThread t : this.msgThreads) {
            t.resetHead();
        }
    }

    /**
     * Returns an arraylist of MsgData from all the threads up to the given
     * timestamp -- from their current head index
     * @param t the end timestamp in ms
     * @return an arraylist of msgs
     */
    public ArrayList<MsgData> getMsgsUntil(long t) {
        ArrayList<MsgData> msgs = new ArrayList<MsgData>();

        for (MsgThread t : this.msgThreads) {
            msgs.addAll(t.getMsgsUntil());
        }

        return msgs;
    }
}
