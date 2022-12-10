
// import date stuff
import java.util.Date;
import java.text.SimpleDateFormat;


class MessageScheduler {
    
    private ArrayList<MessageData> messages;
    private int currentMessageIndex = 0;

    // Time-based configuration
    private long currentTimestamp = 0;

    // Time step is ms between each second
    private long timeStepPerSecond;

    // Keep track of how long since the last call to nextTimeStep
    private long timeSinceLastTimeStep = 0;

    MessageScheduler(MessageManager messageManager) {

        // set timestep ratio to 1 day per second
        this.timeStepPerSecond = 1000 * 60 * 60 * 24;

        this.messages = messageManager.organizedMessagesList;
        this.currentTimestamp = this.messages.get(0).timestamp;
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

    public boolean finished() {
        return currentMessageIndex >= messages.size();
    }

    public ArrayList<MessageData> nextTimeStep() {

        // Calculate how long since the last call to nextTimeStep
        float timeStepMultiplier = (millis() - this.timeSinceLastTimeStep) / 1000.0f;
        long delta = (long) (timeStepMultiplier * this.timeStepPerSecond);

        // update the current time
        this.currentTimestamp += delta;

        ArrayList<MessageData> nextMessages = new ArrayList<MessageData>();

        // Get all messages from currentmMessageIndex to currentTimestamp
        for (int i = currentMessageIndex; i < messages.size(); i++) {
            MessageData message = messages.get(i);
            if (message.timestamp > this.currentTimestamp) {
                break;
            }
            nextMessages.add(message);
            currentMessageIndex++;
        }

        // If messages are empty, check condition for fast forward
        if (nextMessages.size() == 0) {
            if (messages.get(currentMessageIndex).timestamp - this.currentTimestamp > 2 * this.timeStepPerSecond) {
                this.currentTimestamp = messages.get(currentMessageIndex).timestamp;
            }
        }

        this.timeSinceLastTimeStep = millis();
        return nextMessages;
    }

    public String getCurrentTime() {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date(this.currentTimestamp));
    }
}
