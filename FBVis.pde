// Main entry point of the program

    

import java.util.Map;

// Hash map to hold to the person
HashMap<String, Person> personMap;

MessageManager man;
boolean initialized = false;

// For display loading bars on splashscreen
Progress progress;

void initData() {
    progress = new Progress();
    man = new MessageManager(DATA_ROOT_DIR);
    personMap = new HashMap<String, Person>();
    initialized = true;
}

void setup() {
    size(1280, 720);
    thread("initData");
}

int gi = 0;
void draw() {

    // If uninitialized, then display the loading screen
    if (!initialized) {
        background(0);
        fill(255);
        noStroke();
        text("NOW LOADING...", 50, 50);
        
        stroke(255);
        line(50, 70, 50 + 3 * progress.getLoadingProgress(), 70);
        line(50, 90, 50 + 3 * progress.getSortingProgress(), 90);
        return;
    }

    int di = gi % man.organizedMessagesList.size();
    MessageData current = man.organizedMessagesList.get(di);

    drawListMode(current);
    gi++;
}

void drawPersons() {
}

void drawListMode(MessageData current) {
    // Draw by listing all the messages one per frame
    fill(0, 5);
    rect(0, 0, width, height);
    float y = (frameCount % 40) * height / 40;
    fill(255);
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(current.timestamp));
    text(date, 10, y);
    text(current.sender, 80, y);
    text(current.content, 200, y);
}