// Given master.txt and sorted.csv
// Visualize message transactions of messages

import java.util.Map;

final int FORCE_LENGTH = 0;
final int STARTING_INDEX = 11000;

final int PEOPLE_SIZE = 20;
final float ENABLE_ENLARGE_FACTOR = 1.2;
final float PEOPLE_LERPNESS = 0.5;
final int NAME_OFFSET = 20;
final String MSG_FILE = "sorted.csv";

HashMap<String, Person> g_participants;
ChatUtil g_cu;

PGraphics pg_zap;

// Setup
void setup() {
    fullScreen(P2D);
    background(0);
    drawLoading();

    // Create chat utility
    g_cu = new ChatUtil();

    // Create hashmap for all participants
    g_participants = new HashMap<String, Person>();

    // Create graphic layer for zapping
    pg_zap = createGraphics(width, height);
}

void draw() {
    background(0);
}