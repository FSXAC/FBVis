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

int gi = 0;
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

    //background(0, 50);
    fill(0, 5);
    rect(0, 0, width, height);
    int di = gi % man.organizedMessagesList.size();
    float y = (frameCount % 40) * height / 40;
    MessageData current = man.organizedMessagesList.get(di);
    fill(255);
    
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(current.timestamp * 1000L));
    text(date, 10, y);
    text(current.sender, 80, y);
    text(current.content, 200, y);
    
    gi++;
}

void drawPersons() {
}