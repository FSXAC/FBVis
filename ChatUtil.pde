final int DATE_INDEX = 0;
final int SENDER_INDEX = 1;
final int RECEIVER_INDEX = 2;
final int MSGLEN_INDEX = 3;

class ChatUtil {

    private Table chats;
    private int chatLength;
    private int chatCurrent;
    private String masterName;

    private String currentDate;
    private String currentParticipant;
    private boolean currentParticipantIsSender;
    private int currentMsgLength;

    public ChatUtil(String filename) {
        this.chats = this.readChatToTable(filename);

        // Read chat length
        if (FORCE_LENGTH == 0) {
            this.chatLength = FORCE_LENGTH;
        } else {
            this.chatLength = this.chats.getRowCount();
        }

        // Current
        this.chatCurrent = STARTING_INDEX;

        // Read master name
        this.masterName = this.readMasterName();
    }

    public void readNext() {
        TableRow entry = this.chats.getRow(this.chatCurrent);
        
        this.currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(1000L * entry.getInt(DATE_INDEX)));
        String sender = entry.getString(SENDER_INDEX);
        String receiver = entry.getString(RECEIVER_INDEX);
        this.currentMsgLength = entry.getInt(MSGLEN_INDEX);

        if (sender.equals(masterName)) {
            this.currentParticipantIsSender = false;
            this.currentParticipant = receiver;
            
            // Check if receiver in the participants list
            if (!g_participants.containsKey(receiver)) {
                g_newParticipantsList.append(receiver);
            }

        } else {
            this.currentParticipantIsSender = true;
            this.currentParticipant = sender;

            if (!g_participants.containsKey(sender)) {
                g_newParticipantsList.append(sender);
            }
        }

        // Next index
        if (this.chatCurrent < chatLength)
            this.chatCurrent++;
    }

    public String masterName() {
        return this.masterName;
    }

    private Table readChatToTable(String filename) {
        return loadTable(filename, "header");
    }

    private String readMasterName() {
        BufferedReader reader = createReader("master.txt");
        String name = null;
        try {
            name = reader.readLine();
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return name;
    }
}