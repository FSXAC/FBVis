// Given master.txt and sorted.csv
// Visualize message transactions of messages

import java.util.Map;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

PostFX fx;

final int FORCE_LENGTH = 0;
final int STARTING_INDEX = 171000;

final int PEOPLE_SIZE = 20;
final float ENABLE_ENLARGE_FACTOR = 1.2;
final float PEOPLE_LERPNESS = 0.3;
final int NAME_OFFSET = 20;
final String MSG_FILE = "sorted.csv";

HashMap<String, Person> g_participants;
Person g_master;
StringList g_newParticipantsList;
ChatUtil g_cu;

PGraphics pg_zap;
float zapX, zapY;

// Setup
void setup() {
    // fullScreen(P2D);
    size(1280, 960, P2D);
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
    fx = new PostFX(this);
    
    // Draw master
    g_master = new Person(g_cu.masterName());
    g_master.setDesired(width/2, height/2);
    g_master.setMaster();
}

void draw() {
    // Get info from next
    g_cu.readNext();

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

    // add bloom filter
    fx.render()
    .bloom(0.7, 40, 30)
    .compose();

    // Finally, draw UI stuff
    drawTopText(g_cu.currentDate);
}

void addParticipants() {
    if (g_newParticipantsList.size() != 0) {
        for (int i = 0, l = g_newParticipantsList.size(); i < l; i++) {
            String newName = g_newParticipantsList.get(i);
            int n = g_participants.size();
            int x = width / 12 * (n % 12) + 50;
            int y = 50 * floor((n / 12)) + 50;
            g_participants.put(newName, new Person(newName, x, y, g_master.positionX, g_master.positionY));
        }

        // Clear the list
        g_newParticipantsList.clear();
    }
}

void drawParticipants() {
    for (String name:g_participants.keySet()) {
        Person p = g_participants.get(name);
        if (g_cu.currentParticipant.equals(name)) {
            p.draw(true);
            zapX = p.positionX;
            zapY = p.positionY;
        } else {
            p.draw(false);
        }
    }
}

void drawZaps() {
    pg_zap.beginDraw();
    pg_zap.noStroke();
    pg_zap.fill(0, 15);
    pg_zap.rect(0, 0, width, height);
    if (g_cu.currentParticipantIsSender) {
        pg_zap.stroke(255, 100, 100);
    } else {
        pg_zap.stroke(100, 255, 100);
    }
    pg_zap.strokeWeight(0.2 * g_cu.currentMsgLength + 2);
    pg_zap.line(g_master.positionX, g_master.positionY, zapX, zapY);
    pg_zap.endDraw();
    image(pg_zap, 0, 0);
}