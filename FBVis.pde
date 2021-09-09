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

// Render layers
RenderUILayer g_uiLayer;
RenderPeopleLayer g_pplLayer;

StatCardHover statcardHover;

// Hash map to hold to the person
IntDict nameToPersonIndexMap;
ArrayList<PersonNode> persons;

ArrayList<Payload> payloads;
final int PAYLOADS_MAXSIZE = 2048;
PayloadFactory payloadFactory;
MessageManager man;

// For display loading bars on splashscreen
Progress progress;

// timing
long currentTimestamp;
long nextTimestamp;
Timeline timeline;
SpeedControl speedControl;

// Font
PFont font;
PFont monospaceFont;

// Global togglable flags
Boolean g_toggle_UI = true;

int g_state;
final int STATE_UNINIT = 0;
final int STATE_RUN = 1;
final int STATE_PAUSE = 2;

void settings() {
    // Size and fullscreen should go inside here
    // But none of the Processing functions are available
    size(1200, 700, P2D);
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
    g_state = STATE_UNINIT;
    nameToPersonIndexMap = new IntDict();
    persons = new ArrayList<PersonNode>();

    payloads = new ArrayList<Payload>();
    payloadFactory = new PayloadFactory(payloads);

    timeline = new Timeline(50, height - 50, width - 100, 30);
    speedControl = new SpeedControl();
    statcardHover = new StatCardHover();

    if (CONFIG.enableShaders) {
        fx = new PostFX(this);
        fx.preload(RGBSplitPass.class);
        fx.preload(BloomPass.class);
    }
    frameRate(CONFIG.fps);

    // [3]
    thread("initialize");
}

// Async initialization function
void initialize() {
    // Load types
    font = createFont("Helvetica", 32);
    monospaceFont = createFont("Courier", 32);
     //<>// //<>//
    // Load and process 
    progress = new Progress();
    man = new MessageManager(CONFIG.dataRootPath);

    // Initialize layers
    g_uiLayer = new RenderUILayer();
    g_uiLayer.timeline = timeline;
    g_uiLayer.speedControl = speedControl;
    g_uiLayer.statCardHover = statcardHover;

    g_pplLayer = new RenderPeopleLayer();
    g_pplLayer.persons = persons;

    // Set flag to true when done
    g_state = STATE_RUN;
}

int gi = 0;
boolean startFlag = true;

// TODO: reset program
void reset() {
    // not implemented
}

void drawLoadingScreen() {
    // Draws the loading screen (before finished initialization)
    background(0);
    fill(255);
    noStroke();
    textAlign(LEFT, TOP);
    text("FBVis version 0.6.0", 10, 10);
    text("github.com/FSXAC/FBVis", 10, 25);
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
    switch (g_state) {
        case STATE_UNINIT:
            drawLoadingScreen();
            break;
        case STATE_RUN:
            updateState();
            drawRun();
            break;
        case STATE_PAUSE:
            drawRun();
            break;
    }
}

void drawRun() {

    //background(0);
    fill(0, 100);
    noStroke();
    rect(0, 0, width, height);
    
    // Draw a grid of people
    g_pplLayer.render();
    image(g_pplLayer.pg, 0, 0);

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

    // Draw current date and timeline
    if (g_toggle_UI) {
        updateTimeline();
        g_uiLayer.timestamp = currentTimestamp;
        g_uiLayer.render();
        image(g_uiLayer.pg, 0, 0);
    }

    // HACK: we need another robust way to indicate global index
    if (gi >= man.organizedMessagesList.size()) {
        gi = 0;
        g_state = STATE_PAUSE;
    }
}

void updateState() {
    if (gi == 0) {
        resetPersonStats();
    }

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
        nextTimestamp = currentTimestamp + (CONFIG.deltaTimestamp * speedControl.getSpeed());

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
        for (int i = 0; i < (CONFIG.numMsgPerFrame * speedControl.getSpeed()); i++) {
            int di = gi % man.organizedMessagesList.size();
            MessageData current = man.organizedMessagesList.get(di);
            processCurrentmessageData(current);
            gi++;
            currentTimestamp = current.timestamp;
        }
    }

    // Update persons
    for (PersonNode person : persons) {
        person.update();
    }
}

void updateTimeline() {
    timeline.setPercentage(((float) gi % man.organizedMessagesList.size()) / man.organizedMessagesList.size());
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
        PersonNode senderPerson = persons.get(nameToPersonIndexMap.get(current.sender));
        PersonNode receivePerson = persons.get(nameToPersonIndexMap.get(receiver));   
    
        if (current.receivers.size() <= 1) {
            payloadFactory.makeIndividualPayload(senderPerson, receivePerson, current.contentSizeSqrt);
        } else {
            payloadFactory.makeGroupPayload(senderPerson, receivePerson, current.contentSizeSqrt);
        }

        // For each person, update their stats
        senderPerson.incrementMsgSent();
        receivePerson.incrementMsgReceived();
        senderPerson.stats.lastInteractTimestamp = current.timestamp;
        receivePerson.stats.lastInteractTimestamp = current.timestamp;
    }
}

void addNewPerson(String name) {
    final int index = persons.size();

    PersonNode new_person;
    if (name.equals(CONFIG.masterName)) {
        new_person = new PersonMasterNode(name);
    } else {
        new_person = new PersonNode(name);
    }

    final PVector new_position = spiral(index, width/2, height/2);

    new_person.setTargetPosition(new_position.x, new_position.y);
    persons.add(new_person);

    nameToPersonIndexMap.set(name, index);
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

void resetPersonStats() {
    for (PersonNode p : persons) {
        p.stats.reset();
    }
}


// Input handling
void keyPressed() {
    if (key == 'l') {
        currentTimestamp += CONFIG.deltaSkipTimestamp;
    } else if (key == 'h') {
        g_toggle_UI = !g_toggle_UI;
    }

    // Speed control (test)
    else if (key == '=') {
        speedControl.incrementSpeed();
    }
    else if (key == '-') {
        speedControl.decrementSpeed();
    }

    // play/pause
    else if (key == ' ') {
        if (g_state == STATE_RUN) {
            g_state = STATE_PAUSE;
        } else if (g_state == STATE_PAUSE) {
            g_state = STATE_RUN;
        }
    }
}
