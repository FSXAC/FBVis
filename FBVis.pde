// Main entry point of the program

import java.util.Map;

// Hash map to hold to the person
IntDict nameToPersonIndexMap;
ArrayList<Person> persons;

ArrayList<Payload> payloads;

MessageManager man;
boolean initialized = false;

// For display loading bars on splashscreen
Progress progress;

void initData() {
    progress = new Progress();
    man = new MessageManager(DATA_ROOT_DIR);

    initialized = true;
}

void setup() {
    size(1280, 720);
    thread("initData");

    nameToPersonIndexMap = new IntDict();
    persons = new ArrayList<Person>();
    payloads = new ArrayList<Payload>();
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
    
    processCurrentmessageData(current);

    background(0);

    // Display the list of messages in the back
    // drawListMode(current);

    // Draw a grid of people
    drawPersons();

    // Draw and update payload
    drawPayload();

    gi++;
}

void processCurrentmessageData(MessageData current) {
    // check if sender and receiver in the persons map
    if (!nameToPersonIndexMap.hasKey(current.sender)) {

        // Add to array and get the index and put it in the map
        addNewPerson(current.sender);
    }
    
    for (String receiver : current.receivers) {
        if (!nameToPersonIndexMap.hasKey(receiver)) {
            addNewPerson(receiver);
        }

        // For each receiving end, we make a payload
        Person senderPerson = persons.get(nameToPersonIndexMap.get(current.sender));
        Person receivePerson = persons.get(nameToPersonIndexMap.get(receiver)); //<>//
        addPayload(senderPerson, receivePerson);
    }
}

void addNewPerson(String name) {
    final int index = persons.size();

    Person new_person = new Person(name);
    final PVector new_position = spiral(index, width/2, height/2);
    new_person.setTargetPosition(new_position.x, new_position.y);
    persons.add(new_person);

    nameToPersonIndexMap.set(name, index);
}

final int PAYLOAD_SELECT = 2;
void addPayload(Person sender, Person receiver) {
    if (PAYLOAD_SELECT == 0) {
        payloads.add(new PayloadDot(sender, receiver));
    } else if (PAYLOAD_SELECT == 1) {
        payloads.add(new PayloadLine(sender, receiver));
    } else if (PAYLOAD_SELECT == 2) {
        payloads.add(new PayloadSegment(sender, receiver));
    }
}

void drawPersons() {
    for (Person person : persons) {
        // person.setTargetPosition(map(x, 0, xcols, padding, width - padding), map(y, 0, yrows, padding, height - padding));
        person.draw();
    }
}

// TODO: could be instanciated elsewhere and just cleared
ArrayList<Payload> toBeRemoved = new ArrayList<Payload>();
void drawPayload() {

    toBeRemoved.clear();

    // Draw and check
    for (Payload payload : payloads) {
        payload.draw();
        
        if (payload.hasArrived()) {
            toBeRemoved.add(payload);

            // Update the target
            // TODO: rename to smoething better
            payload.targetPerson.receive();
        }
    }

    // Remove from active list
    for (Payload payload : toBeRemoved) {
        payloads.remove(payload);
    }
}

void drawListMode(MessageData current) {
    // Draw by listing all the messages one per frame
    // fill(0, 20);
    // rect(0, 0, width, height);
    float y = (frameCount % 40) * height / 40;
    fill(50);
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(current.timestamp));
    textAlign(LEFT, TOP);
    textSize(10);
    text(date, 10, y);
    text(current.sender, 80, y);
    text(current.content, 200, y);
}