// Given master.txt and sorted.csv
// Visualize message transactions of messages

import java.util.Map;

final int FORCE_LENGTH = 0;
final int STARTING_INDEX = 11000;

final int PEOPLE_SIZE = 20;
final float ENABLE_ENLARGE_FACTOR = 1.2;
final float PEOPLE_LERPNESS = 0.25;
final int NAME_OFFSET = 20;
final String MSG_FILE = "sorted.csv";

HashMap<String, Person> g_participants;
Person g_master;
StringList g_newParticipantsList;
ChatUtil g_cu;

PGraphics pg_zap;

// Setup
void setup() {
    fullScreen(P2D);
    background(0);
    drawLoading();

    // Create chat utility
    g_cu = new ChatUtil(MSG_FILE);

    // Create hashmap for all participants
    g_participants = new HashMap<String, Person>();

    // Create string list to store new participants to be added
    g_newParticipantsList = new StringList();

    // Create graphic layer for zapping
    pg_zap = createGraphics(width, height);

    // Setup graphics
    textAlign(CENTER, CENTER);

    // Draw master
    g_master = new Person(g_cu.masterName());
    g_master.setDesired(width/2, height/2);
}

void draw() {
    background(0);
    g_master.draw(false);
}