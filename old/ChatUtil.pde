final int DATE_INDEX = 0;
final int SENDER_INDEX = 1;
final int RECEIVER_INDEX = 2;
final int MSGLEN_INDEX = 3;

class ChatUtil {
    public String currentDate;

    private Table chats;
    private int chatEndIndex;
    private int chatIndex;
    private long time;
    private long timeNext;
    private String masterName;

    public ChatUtil(String filename) {
        this.chats = this.readChatToTable(filename);

        // Indexing
        this.chatEndIndex = this.chats.getRowCount();
        this.chatIndex = 0;

        // Read master name
        this.masterName = this.readMasterName();

        // Starting time
        long readInitialTime = this.chats.getInt(0, 0);
        if (readInitialTime > START_TIME) {
            this.time = readInitialTime;
        } else {
            this.time = START_TIME;
        }

        // Next time
        this.timeNext = this.time + TIME_DIFF;
    }

    public void next() {
        if (this.chatIndex < this.chatEndIndex) {
            // Time of current chat index
            long t0 = this.chats.getInt(this.chatIndex, DATE_INDEX);

            // TODO: improve logic here to cover more corner cases such as when t0 > timenext
            while (t0 >= this.time && t0 < this.timeNext) {
                g_nowChats.add(this.read(this.chatIndex));
                
                if (this.chatIndex < this.chatEndIndex - 1) {
                    this.chatIndex++;
                    t0 = this.chats.getInt(this.chatIndex, DATE_INDEX);
                } else {
                    break;
                }
            }

            // Next interval of time
            if (this.chatIndex < this.chatEndIndex - 1) {
                this.time = this.timeNext;
                this.timeNext += TIME_DIFF;
                this.currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(1000L * this.time));
            }
        }
    }

    public ChatEntry read(int index) {
        String sender = this.chats.getString(index, SENDER_INDEX);
        String receiver = this.chats.getString(index, RECEIVER_INDEX);

        boolean isParticipantSender;
        String participant;
        if (sender.equals(this.masterName)) {
            isParticipantSender = false;
            participant = receiver;
            
            if (!g_participants.containsKey(receiver)) {
                int n = g_participants.size();
                PVector start = spiral(n, width/2, height/2);
                g_participants.put(receiver, new Person(receiver, start.x, start.y, g_master.positionX, g_master.positionY));
            }
        } else {
            isParticipantSender = true;
            participant = sender;

            if (!g_participants.containsKey(sender)) {
                int n = g_participants.size();
                PVector start = spiral(n, width/2, height/2);
                g_participants.put(sender, new Person(sender, start.x, start.y, g_master.positionX, g_master.positionY));
            }
        }

        return new ChatEntry(
            this.chats.getInt(index, DATE_INDEX),
            participant,
            isParticipantSender,
            this.chats.getInt(index, MSGLEN_INDEX)
        );
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

class ChatEntry {
    long timestamp;
    // String date;
    String participant;
    boolean isParticipantSender;
    int msgLength;

    public ChatEntry(long timestamp, String partName, boolean partIsSender, int msgLength) {
        this.timestamp = timestamp;
        // this.date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(1000L * this.timestamp));
        this.participant = partName;
        this.isParticipantSender = partIsSender;
        this.msgLength = msgLength;
    }
}

class ChatEntryAgent {
    short life = 20;
    float x, y, x_p, y_p;
    float destX, destY;
    float size;
    color c;
    float rate;
    public ChatEntryAgent(float x, float y, float destX, float destY, float size, color c) {
        this.x = x;
        this.y = y;
        this.x_p = x;
        this.y_p = y;
        this.destX = destX;
        this.destY = destY;
        this.size = size;
        this.c = c;
        this.rate = random(0.2, 0.6);
    }
    
    public void draw(PGraphics pg) {
        if (this.life != 0) {
            //pg.fill(this.c);
            //pg.ellipse(this.x, this.y, this.size, this.size);
            //pg.ellipse(this.x, this.y, 10, 10);
            pg.stroke(this.c);
            pg.strokeWeight(this.size);
            pg.line(this.x, this.y, this.x_p, this.y_p);
            
            // update
            this.x_p = x;
            this.y_p = y;
            this.x = lerp(this.x, this.destX, this.rate);
            this.y = lerp(this.y, this.destY, this.rate);
            
            this.life--;
        }
    }
}