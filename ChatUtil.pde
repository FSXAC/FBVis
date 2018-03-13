class ChatUtil {

    private Table chats;
    private int chatLength;
    private int chatCurrent;
    private String masterName;

    public ChatUtil(String filename) {
        this.chats = this.readChatToTable(filename);

        // Read chat length
        if (FORCE_LENGTH == 0) {
            this.chatLength = FORCE_LENGTH;
        } else {
            this.chatLength = this.chats.getRowCount();
        }

        // Read master name
        this.masterName = this.readMasterName();
    }

    Table readChatToTable(String filename) {
        return loadTable(filename, "header");
    }

    String readMasterName() {
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