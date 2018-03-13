// Given master.txt and sorted.csv
// Visualize message transactions of messages

Table chats;
int chatLength;
int current;

String masterName;

final boolean FORCE_LENGTH = false;
final int FORCE_LENGTH_N = 100;

// TODO: use a hashmap
StringList participants;

PGraphics zapLayer;

void setup() {
    size(1000, 1000);
    chats = loadTable("sorted.csv", "header");
    
    if (FORCE_LENGTH) {
        chatLength = FORCE_LENGTH_N;
    } else {
        chatLength = chats.getRowCount();
    }

    current = 175000;
    
    masterName = readMaster();
    participants = new StringList();
    
    zapLayer = createGraphics(width, height);
}

String currentDate;
void draw() {
    background(0);
    readMsgHistory();
    image(zapLayer, 0, 0);
    textSize(20);
    fill(255);
    text(currentDate, width/2, 20); 
    textSize(10);
    drawMaster();
    drawParticipants();
    drawZap();
}

boolean sentFromMaster;
String currentChatParticipant;
int currentMsgLen;


void readMsgHistory() {
    TableRow chatEntry = chats.getRow(current);
    int timestamp = chatEntry.getInt(0);
    currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date (timestamp*1000L));
    String sender = chatEntry.getString(1);
    String receiver = chatEntry.getString(2);
    int msglen = chatEntry.getInt(3);
    
    if (sender.equals(masterName)) {
        if (!participants.hasValue(receiver)) {
            participants.append(receiver);
        }
        
        sentFromMaster = true;
        currentChatParticipant = receiver;
    } else {
        if (!participants.hasValue(sender)) {
            participants.append(sender);
        }
        
        sentFromMaster = false;
        currentChatParticipant = sender;
    }
    
    currentMsgLen = msglen;
    
    if (current < chatLength - 1)
        current++;
}

String readMaster() {
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

void drawMaster() {
    fill(255);
    noStroke();
    ellipse(width/2, height/2, 20, 20);
    textAlign(CENTER, CENTER);
    text(masterName, width/2, height/2 + 20);
}

// float radius = 400;
float radiusMin = 100;
float radiusIncrement = 50;
float zapX, zapY;
void drawParticipants() {
    if (participants.size() == 0) {
        return;
    } else {
        float da = constrain(TWO_PI / participants.size(), PI/6, 3);
        for (int i = 0; i < participants.size(); i++) {
            float x = (radiusMin + 6 * i) * sin(i * da) + width/2;
            float y = (radiusMin + 6 * i) * cos(i * da) + height/2;
            String name = participants.get(i);
            
            if (name.equals(currentChatParticipant)) {
                zapX = x;
                zapY = y;
                fill(255, 255, 0);
            } else {
                fill(255);
            }
            noStroke();
            ellipse(x, y, 20, 20);
            text(name, x, y + 20);
        }
    }
}

void drawZap() {
    zapLayer.beginDraw();
    zapLayer.noStroke();
    zapLayer.fill(0, 15);
    zapLayer.rect(0, 0, width, height);
    if (sentFromMaster) {
        zapLayer.stroke(100, 255, 100);
    } else {
        zapLayer.stroke(255, 100, 100);
    }
    zapLayer.strokeWeight(0.2 * currentMsgLen + 2);
    zapLayer.line(width/2, height/2, zapX, zapY);
    zapLayer.endDraw();
}