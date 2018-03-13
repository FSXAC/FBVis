final int DATE_INDEX = 0;
final int SENDER_INDEX = 1;
final int RECEIVER_INDEX = 2;
final int MSGLEN_INDEX = 3;

class ChatUtil {
    public String currentDate;
    public String currentParticipant;
    public boolean currentParticipantIsSender;
    public int currentMsgLength;

    private Table chats;
    private int chatEndIndex;
    private int chatIndex;
    private String masterName;

    public ChatUtil(String filename) {
        this.chats = this.readChatToTable(filename);

        // Read chat length
        if (FORCE_LENGTH != 0) {
            this.chatEndIndex = STARTING_INDEX + FORCE_LENGTH;
        } else {
            this.chatEndIndex = this.chats.getRowCount();
        }

        // Current
        this.chatIndex = STARTING_INDEX;

        // Read master name
        this.masterName = this.readMasterName();

        // Default current
        this.currentDate = "XXXX-XX";
        this.currentParticipant = "";
        this.currentParticipantIsSender = false;
        this.currentMsgLength = 0;
    }

    public void readNext() {
        if (this.chatIndex < this.chatEndIndex) {
            TableRow entry = this.chats.getRow(this.chatIndex);
            
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
            this.chatIndex++;
        } else {
            this.currentParticipant = "";
            g_zapX = 0;
            g_zapY = 0;
        }
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