class MessageData {
    long timestamp;
    String sender;
    String content;

    public MessageData(long timestamp, String sender, String content) {
        this.timestamp = timestamp;
        this.sender = sender;
        this.content = content;
    }
}