// Main entry point of the program

// TODO: re arrange the persons based on groups
// TODO: filter out specific groups
// TODO: broadcast effect for personal wall postings
// TODO: stattrak send & receive metrics per person

import java.util.Map;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

PostFX fx;

// Hash map to hold to the person
IntDict nameToPersonIndexMap;
ArrayList<Person> persons;

ArrayList<Payload> payloads;
PayloadFactory payloadFactory;

MessageManager man;
boolean initialized;

// For display loading bars on splashscreen
Progress progress;

// timing
long currentTimestamp;

Timeline timeline;

// Font
PFont font;
PFont monospaceFont;

void initFont() {
    font = createFont("Suisse Int'l Medium", 32);
    monospaceFont = createFont("Fira Code", 32);
    
    String[] fontList = PFont.list();
    printArray(fontList);
}

void initData() {
    progress = new Progress();
    man = new MessageManager(DATA_ROOT_DIR);

    initialized = true;
}

void setup() {

    initialized = false;

     //fullScreen(P2D);
    size(1280, 960, P2D);
    frame.setResizable(true);

    initFont();
    
    thread("initData");

    nameToPersonIndexMap = new IntDict();
    persons = new ArrayList<Person>();

    payloads = new ArrayList<Payload>();
    payloadFactory = new PayloadFactory(payloads);

    timeline = new Timeline(50, height - 100, width - 100, 50);

    if (SHADERS)
        fx = new PostFX(this);
        fx.preload(RGBSplitPass.class);
        fx.preload(BloomPass.class);
        
    smooth(4);
    frameRate(DESIRED_FPS);
}

int gi = 0;
boolean startFlag = true;

void draw() {

    // If uninitialized, then display the loading screen
    if (!initialized) {
        background(0);
        fill(255);
        noStroke();
        text("NOW LOADING...", 50, 50);
        
        stroke(50);
        line(50, 70, 50 + 300, 70);
        line(50, 90, 50 + 300, 90);
        line(50, 110, 50 + 300, 110);
        stroke(255);
        line(50, 70, 50 + 3 * progress.getLoadingLargeProgress(), 70);
        line(50, 90, 50 + 3 * progress.getLoadingProgress(), 90);
        line(50, 110, 50 + 3 * progress.getSortingProgress(), 110);
        return;
    }

    textFont(font);

    if (USE_UNIFORM_TIME) {
        if (startFlag) {
            long firstTimeStamp = man.organizedMessagesList.get(gi).timestamp;
            if (firstTimeStamp > START_TIMESTAMP) {
                currentTimestamp = firstTimeStamp;
            } else {
                currentTimestamp = START_TIMESTAMP;
            }

            if (VERBOSE)
                println("currentTimestamp: " + new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(currentTimestamp)));

            startFlag = false;
        }

        // Get all the messages for the next time stamp
        long nextTimestamp = currentTimestamp + DELTA_TIMESTAMP;

        long messageTimestamp = man.organizedMessagesList.get(gi % man.organizedMessagesList.size()).timestamp;

        long dt = messageTimestamp - nextTimestamp;
        if (dt > AUTO_SKIP_TIMESTAMP) {
            // Then we know that we need to skip
            nextTimestamp = messageTimestamp;
        } else if (dt > 0) {
            // Don't do anything
        } else {
            while (messageTimestamp < nextTimestamp) {
                int di = gi % man.organizedMessagesList.size();
                MessageData current = man.organizedMessagesList.get(di);

                processCurrentmessageData(current);
                gi++;

                messageTimestamp = current.timestamp;
            }
        }

        currentTimestamp = nextTimestamp;

    } else {
        for (int i = 0; i < SPEED_SCALE; i++) {
            int di = gi % man.organizedMessagesList.size();
            MessageData current = man.organizedMessagesList.get(di);
            processCurrentmessageData(current);
            gi++;
            currentTimestamp = current.timestamp;
        }
    }

    //background(0);
    fill(0, 100);
    noStroke();
    rect(0, 0, width, height);
    
    // Draw a grid of people
    drawPersons(); 

    // Draw and update payload
    blendMode(SCREEN);
    drawPayload();
    blendMode(BLEND);

    if (SHADERS) {
        fx.render()
        .bloom(0.8, 10, 30)
        //.rgbSplit(constrain(payloads.size(), 0, 300))
        .compose();
    } 

    // Draw current date
    textFont(monospaceFont);
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(currentTimestamp));
    textSize(20);
    fill(255);
    text(date, width/2, 20);

    timeline.setPercentage(((float) gi % man.organizedMessagesList.size()) / man.organizedMessagesList.size());
    timeline.draw();
    timeline.handleMouseInput();
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
        Person receivePerson = persons.get(nameToPersonIndexMap.get(receiver));   
    
        if (current.receivers.size() <= 1) {
            payloadFactory.makeIndividualPayload(senderPerson, receivePerson, current.contentSizeSqrt);
        } else {
            payloadFactory.makeGroupPayload(senderPerson, receivePerson, current.contentSizeSqrt);
        }
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
        }
    }

    // Remove from active list
    for (Payload payload : toBeRemoved) {
        payloads.remove(payload);
    }
}

    // Draw by listing all the messages one per frame
void drawListMode(MessageData current) {
    float y = (frameCount % 40) * height / 40;
    fill(50);
    String date = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(current.timestamp));
    textAlign(LEFT, TOP);
    textSize(10);
    text(date, 10, y);
    text(current.sender, 80, y);
    text(current.content, 200, y);
}


// Input handling
void keyPressed() {
    if (key == 'l') {
        currentTimestamp += SKIP_TIMESTAMP;
    }
}
