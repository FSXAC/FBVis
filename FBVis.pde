// Main entry point of the program

    

import java.util.Map;

// Hash map to hold to the person
HashMap<String, Person> personMap;

MessageManager man;
boolean initialized = false;
float progress_load = 0;
float progress_sort = 0;

void initData() {
    man = new MessageManager(DATA_ROOT_DIR);
    personMap = new HashMap<String, Person>();
    initialized = true;
}

void setup() {
    size(1280, 720);
    thread("initData");
}

void draw() {
    if (!initialized) {
        background(0);
        fill(255);
        noStroke();
        text("NOW LOADING...", 50, 50);
        
        stroke(255);
        line(50, 70, 50 + progress_load, 70);
        line(50, 90, 50 + progress_sort, 90);
        return;
    }

    background(0);
    int i = frameCount % man.organizedMessagesList.size();
    MessageData current = man.organizedMessagesList.get(i);
    text(current.content, width/2, height/2);
    println(frameRate);
}

void drawPersons() {
}