// Given master.txt and sorted.csv
// Visualize message transactions of messages

import java.util.Map;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

final int START_TIME = 0; // 0 for very beginning
final int TIME_DIFF = 3600; // hourly

final int PEOPLE_SIZE = 20;
final float ENABLE_ENLARGE_FACTOR = 1.2;
final float PEOPLE_LERPNESS = 0.03;
final boolean PEOPLE_DO_DECAY = false;
final float PEOPLE_ACTIVE_DECAY_RATE = 0.5;
final float PEOPLE_INACTIVE_THRESHOLD = 25;
final float PEOPLE_INACTIVE_DECAY_RATE = 0.01;
final int NAME_OFFSET = 20;
final boolean USE_ARCHIMEDEAN_SPIRAL = true;
final float SPIRAL_C = 40;
final int SPIRAL_OFFSET = 4;

final String MSG_FILE = "sorted.csv";
final float MSG_LENGTH_ZAP_K = 0.2;
final int MSG_LENGTH_ZAP_MIN_WIDTH = 2;
final float MSG_DECAY_FACTOR = 30;

// Colors
final color BACKGROUND_COLOR = #000000;
final color RECEIVE_COLOR = color(255, 50, 50);
final color SEND_COLOR = color(50, 255, 50);
final color ACTIVE_PERSON_COLOR = color(255, 255, 0);
final color MASTER_COLOR = color(255);

// Participants
HashMap<String, Person> g_participants;
Person g_master;
StringList g_newParticipantsList;
StringList g_inactiveParticipantsList;
ChatUtil g_cu;
boolean g_hasInactiveParticipants;

// Chat buffer
ArrayList<ChatEntry> g_nowChats;
StringList g_activeParticipantsList;

// Zappng effect
PGraphics pg_zap;

// Graphics
PostFX fx;

// Setup
void setup() {
    //fullScreen(P2D);
    size(1280, 960, P2D);
    background(BACKGROUND_COLOR);
    drawLoading();

    // Create chat utility
    g_cu = new ChatUtil(MSG_FILE);
    g_nowChats = new ArrayList<ChatEntry>();

    // Create hashmap for all participants
    g_participants = new HashMap<String, Person>();

    // Create string list to store new participants to be added
    g_newParticipantsList = new StringList();
    g_inactiveParticipantsList = new StringList();
    g_activeParticipantsList = new StringList();

    // Create graphic layer for zapping
    pg_zap = createGraphics(width, height);

    // Setup graphics
    textAlign(CENTER, CENTER);
    noStroke();
    fx = new PostFX(this);
    
    // Draw master
    g_master = new Person(g_cu.masterName(), width/2, height/2, width/2, height/2);
    g_master.setMaster();
}

void draw() {
    // Get info from next
    g_cu.next();

    // Add people from the new participants list
    addParticipants();

    // Reset canvas
    background(0);

    // Draw zap (background)
    drawZaps();

    // Draw master
    g_master.draw(false);

    // Draw participants
    drawParticipants();

    // Clear active participants list
    g_activeParticipantsList.clear();

    // Reposition participants if necessary
    if (g_hasInactiveParticipants) {
        removeInactiveParticipants();
        repositionParticipants();
        g_hasInactiveParticipants = false;
    }

    // add bloom filter
    fx.render()
    .bloom(0.5, 20, 30)
    .compose();

    // Finally, draw UI stuff
    drawTopText(g_cu.currentDate);
}

void addParticipants() {
    if (g_newParticipantsList.size() != 0) {
        for (int i = 0, l = g_newParticipantsList.size(); i < l; i++) {
            String newName = g_newParticipantsList.get(i);
            int n = g_participants.size();
            PVector start = spiral(n, width/2, height/2);
            g_participants.put(newName, new Person(newName, start.x, start.y, g_master.positionX, g_master.positionY));
        }

        // Clear the list
        g_newParticipantsList.clear();
    }
}

void drawParticipants() {
    stroke(30);
    strokeWeight(4);
    for (String name:g_participants.keySet()) {
        Person p = g_participants.get(name);
        if (g_activeParticipantsList.hasValue(name)) {
            p.draw(true);
        } else {
            p.draw(false);
        }

        // If participant is inactive, delete them and request a reposition call
        if (p.inactive) {
            g_inactiveParticipantsList.append(name);
            g_hasInactiveParticipants = true;
        }
    }
}

void removeInactiveParticipants() {
    if (g_inactiveParticipantsList.size() != 0) {
        for (int i = 0, l = g_inactiveParticipantsList.size(); i < l; i++) {
            g_participants.remove(g_inactiveParticipantsList.get(i));
        }
        g_inactiveParticipantsList.clear();
    }
}

void repositionParticipants() {
    int index = 0;
    for (String name:g_participants.keySet()) {
        Person p = g_participants.get(name);
        PVector newPos = spiral(index, width/2, height/2);
        p.setDesired(newPos.x, newPos.y);
        index++;
    }
}

void drawZaps() {
    if (g_nowChats.size() == 0) return;

    pg_zap.beginDraw();
    pg_zap.noStroke();
    pg_zap.fill(BACKGROUND_COLOR, MSG_DECAY_FACTOR);
    pg_zap.rect(0, 0, width, height);

    // Draw zap for each chat that is happening right now
    for (ChatEntry c:g_nowChats) {
        if (c.isParticipantSender) {
            pg_zap.stroke(RECEIVE_COLOR);
        } else {
            pg_zap.stroke(SEND_COLOR);
        }

        // Add to active participants list
        if (!g_activeParticipantsList.hasValue(c.participant)) {
            g_activeParticipantsList.append(c.participant);
        }

        pg_zap.strokeWeight(MSG_LENGTH_ZAP_K * c.msgLength + MSG_LENGTH_ZAP_MIN_WIDTH);

        // Obtain postion and draw
        Person p = g_participants.get(c.participant);
        pg_zap.line(g_master.positionX, g_master.positionY, p.positionX, p.positionY);
    }

    pg_zap.endDraw();
    image(pg_zap, 0, 0);
}

// Function that gives a vector around a point 
PVector spiral(int n, float centerX, float centerY) {
    float x, y;
    if (USE_ARCHIMEDEAN_SPIRAL) {
        float a = (n + SPIRAL_OFFSET) * 137.5;
        float r = SPIRAL_C * sqrt(n + SPIRAL_OFFSET);
        x = r * cos(a) + centerX;
        y = r * sin(a) + centerY;
    } else {
        x = (100 + 6 * n) * sin(n * PI/5) + centerX;
        y = (100 + 6 * n) * cos(n * PI/5) + centerY;
    }

    return new PVector(x, y);
}