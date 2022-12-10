
// import date stuff
import java.util.Date;
import java.text.SimpleDateFormat;


class MessageScheduler {
    
    ArrayList<MessageData> messages;
    int currentMessageIndex = 0;


    // Time-based configuration
    long current_time = 0;
    long previous_time = 0;
    long time_step = 0;

    MessageScheduler(MessageManager messageManager) {
        this.messages = messageManager.organizedMessagesList;

        // default time step to 2 minutes
        // this.time_step = 2 * 60 * 1000;

        // set time step to 1 day
        this.time_step = 24 * 60 * 60 * 1000;

        // Hack: timestep is entire duration of simulation
        // this.time_step = this.messages.get(this.messages.size() - 1).timestamp - this.messages.get(0).timestamp;

        this.current_time = this.messages.get(0).timestamp;
        this.previous_time = this.current_time;
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

        // update the current time
        this.previous_time = this.current_time;
        this.current_time += this.time_step;

        ArrayList<MessageData> nextMessages = new ArrayList<MessageData>();

        // Get all messages from currentmMessageIndex to current_time
        for (int i = currentMessageIndex; i < messages.size(); i++) {
            MessageData message = messages.get(i);
            if (message.timestamp > this.current_time) {
                break;
            }
            nextMessages.add(message);
            currentMessageIndex++;
        }

        return nextMessages;
    }

    public String getCurrentTime() {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date(this.current_time));
    }
}
