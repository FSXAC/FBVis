

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
