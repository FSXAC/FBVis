// Main entry point of the program

    

import java.util.Map;

// Hash map to hold to the person
IntDict nameToPersonIndexMap;
ArrayList<Person> persons;

MessageManager man;
boolean initialized = false;

// For display loading bars on splashscreen
Progress progress;

void initData() {
    progress = new Progress();
    man = new MessageManager(DATA_ROOT_DIR);

    nameToPersonIndexMap = new IntDict();
    persons = new ArrayList<Person>();

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
    
    processCurrentmessageData(current); //<>//
    drawPersons();
    drawListMode(current);
    gi++;
}

void processCurrentmessageData(MessageData current) {
    // check if sender and receiver in the persons map
    if (!nameToPersonIndexMap.hasKey(current.sender)) {

        // Add to array and get the index and put it in the map
        persons.add(new Person(current.sender));
        nameToPersonIndexMap.set(current.sender, persons.size() - 1);
    }
    
    for (String receiver : current.receivers) {
        if (!nameToPersonIndexMap.hasKey(receiver)) {
            persons.add(new Person(receiver));
            nameToPersonIndexMap.set(receiver, persons.size() - 1);
        }
    }
}

float padding = 75;
int xcols = 12;
float yrows = 10;
void drawPersons() {
    // Iterate through all the people in the map
    int x = 0;
    int y = 0;

    for (Person person : persons) {
        person.setDesiredPosition(map(x, 0, xcols, padding, width - padding), map(y, 0, yrows, padding, height - padding));
        person.draw();
        
        
        if (x == xcols - 1) {
            x = 0;
            y += 1;
        } else {
            x += 1;
        }
    }
}

void drawListMode(MessageData current) {
    // Draw by listing all the messages one per frame
    fill(0, 20);
    rect(0, 0, width, height);
    float y = (frameCount % 40) * height / 40;
    fill(50);
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(current.timestamp));
    textAlign(LEFT, TOP);
    textSize(10);
    text(date, 10, y);
    text(current.sender, 80, y);
    text(current.content, 200, y);
}