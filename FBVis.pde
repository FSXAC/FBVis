// Main entry point of the program

// TODO: re arrange the persons based on groups
// TODO: filter out specific groups
// TODO: broadcast effect for personal wall postings
// TODO: stattrak send & receive metrics per person
// TODO: make rendering of the people and messages with shaders on a separate graphic layer

import java.util.Map;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

// Configuration is the most important so it needs to be set up first
FBVisConfig CONFIG;

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

// Async initialization function
void initialize() {
    // Load types
    font = createFont("Arial", 32);
    monospaceFont = createFont("Consolas", 32);

    // Load and process 
    progress = new Progress();
    man = new MessageManager(CONFIG.dataRootPath);

    // Set flag to true when done
    initialized = true;
}

void settings() {
    // Size and fullscreen should go inside here
    // But none of the Processing functions are available
    size(1920, 1080, P2D);
    smooth(2);
}

void setup() {
    // There are 3 main stages in the setup function
    // [1] Load and read configuration file
    // [2] Run regular Processing 3 setup stuff
    // [3] Run the initialization routine

    // [1] Configuration
    CONFIG = new FBVisConfig();
    
    // [2]
    nameToPersonIndexMap = new IntDict();
    persons = new ArrayList<Person>();

    payloads = new ArrayList<Payload>();
    payloadFactory = new PayloadFactory(payloads);

    timeline = new Timeline(50, height - 100, width - 100, 50);

    if (CONFIG.enableShaders) {
        fx = new PostFX(this);
        fx.preload(RGBSplitPass.class);
        fx.preload(BloomPass.class);
    }
    frameRate(CONFIG.fps);

    // [3]
    initialized = false;
    thread("initialize");
}

int gi = 0;
boolean startFlag = true;


void drawLoadingScreen() {
    // Draws the loading screen (before finished initialization)
    background(0);
    fill(255);
    noStroke();
    textAlign(CENTER, CENTER);
    text("Loading Messenger data . . .", width/2, height/2);

    if (progress != null) {
        stroke(50);
        float start = 0.4 * width;
        float end = 0.6 * width;
        float y = height / 2 + 20;
        line(start, y, end, y);

        stroke(255);
        float totalProgress = (
            progress.getLoadingLargeProgress() + progress.getLoadingProgress() + 
            progress.getSortingProgress()
        ) / 3;
        float totalWidth = map(totalProgress, 0, 1, 0, 0.2 * width);
        line(start, y, start + totalWidth, y);
    }
}

void draw() {

    // If uninitialized, then display the loading screen
    if (!initialized) {
        // background(0);
        // fill(255);
        // noStroke();
        // text("NOW LOADING...", 50, 50);
        
        // stroke(50);
        // line(50, 70, 50 + 300, 70);
        // line(50, 90, 50 + 300, 90);
        // line(50, 110, 50 + 300, 110);
        // stroke(255);
        // line(50, 70, 50 + 3 * progress.getLoadingLargeProgress(), 70);
        // line(50, 90, 50 + 3 * progress.getLoadingProgress(), 90);
        // line(50, 110, 50 + 3 * progress.getSortingProgress(), 110);
        // return;
        drawLoadingScreen();
        return;
    }

    textFont(font);

    if (CONFIG.enableUniformTime) {
        if (startFlag) {
            long firstTimeStamp = man.organizedMessagesList.get(gi).timestamp;
            if (firstTimeStamp > CONFIG.startTimestamp) {
                currentTimestamp = firstTimeStamp;
            } else {
                currentTimestamp = CONFIG.startTimestamp;
            }

            if (CONFIG.enableVerbose)
                println("currentTimestamp: " + new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(currentTimestamp)));

            startFlag = false;
        }

        // Get all the messages for the next time stamp
        long nextTimestamp = currentTimestamp + CONFIG.deltaTimestamp;

        long messageTimestamp = man.organizedMessagesList.get(gi % man.organizedMessagesList.size()).timestamp;

        long dt = messageTimestamp - nextTimestamp;
        if (dt > CONFIG.deltaAutoSkipTimestamp) {
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
        for (int i = 0; i < CONFIG.numMsgPerFrame; i++) {
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

    if (CONFIG.enableShaders) {
        fx.render()
        .bloom(0.8, 5, 30)
        .rgbSplit(constrain(payloads.size(), 0, 20))
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
        currentTimestamp += CONFIG.deltaSkipTimestamp;
    }
}
