class MessageScheduler {
    
    ArrayList<MessageData> messages;
    int currentMessageIndex = 0;

    MessageScheduler(MessageManager messageManager) {
        this.messages = messageManager.organizedMessagesList;
    }

    /**
     * Returns the next message in the list of messages.
     * @return the next message in the list of messages.
     */
    public MessageData next() {
        if (currentMessageIndex < messages.size()) {
            return messages.get(currentMessageIndex++);
        } else {
            return null;
        }
    }

    /**
     * Returns the next n messages up to a given timestamp.
     * @param timestamp the timestamp to stop at.
     */
    public MessageData[] next(int n, long timestamp) {
        ArrayList<MessageData> nextMessages = new ArrayList<MessageData>();
        for (int i = 0; i < n; i++) {
            MessageData message = next();
            if (message == null) {
                break;
            }
            if (message.timestamp > timestamp) {
                break;
            }
            nextMessages.add(message);
        }
        return nextMessages.toArray(new MessageData[nextMessages.size()]);
    }
}