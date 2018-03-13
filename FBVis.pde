// Given master.txt and sorted.csv
// Visualize message transactions of messages

import java.util.Map;

final int FORCE_LENGTH = 0;
final int STARTING_INDEX = 0;

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
    // fullScreen(P2D);
    size(1280, 960);
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
    noStroke();

    // Draw master
    g_master = new Person(g_cu.masterName());
    g_master.setDesired(width/2, height/2);
}

void draw() {
    // Get info from next
    g_cu.readNext();

    // Add people from the new participants list
    addParticipants();

    // Reset canvas
    background(0);

    // Draw master
    g_master.draw(false);

    // Draw participants
    drawParticipants();

    // Finally, draw UI stuff
    drawTopText(g_cu.currentDate);
    println(g_participants.size());
}

void addParticipants() {
    if (g_newParticipantsList.size() != 0) {
        for (int i = 0, l = g_newParticipantsList.size(); i < l; i++) {
            String newName = g_newParticipantsList.get(i);
            int n = g_participants.size();
            int x = 50 * (n % 20) + 50;
            int y = 50 * floor((n / 20)) + 50;
            g_participants.put(newName, new Person(newName, x, y, width/2, height/2));
        }

        // Clear the list
        g_newParticipantsList.clear();
    }
}

void drawParticipants() {
    for (String name:g_participants.keySet()) {
        g_participants.get(name).draw(false);
    }
}