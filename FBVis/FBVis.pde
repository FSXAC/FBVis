import java.util.Map;



// ============ application states enum ============
enum AppState {
    INIT, RUNNING, PAUSED
}
AppState state = AppState.INIT;

// ============ data ============

FBVisConfig CONFIG;

MessageManager msgManager;
MessageScheduler msgScheduler;

MasterPersonNode root;
HashMap<Integer, PersonNode> personNodes;

// ============ render layers ============

RenderPeopleLayer peopleLayer;
String RENDERER = P3D;

// ============ visualization ============

void settings() {
    size(800, 600, RENDERER);
}

void setup() {
    CONFIG = new FBVisConfig();
    thread("initializeData");

    // Initialize visualization
    root = new MasterPersonNode(CONFIG.masterName);
    peopleLayer = new RenderPeopleLayer(root);
}

void initializeData() {
    // Start timer
    int startTime = millis();
    msgManager = new MessageManager(CONFIG.dataRootPath);
    int duration = millis() - startTime;
    println("Done loading data");
    println(msgManager.organizedMessagesList.size());
    println("Took " + duration + "ms");


    msgScheduler = new MessageScheduler(msgManager);

    state = AppState.RUNNING;
}

void draw() {
    if (state == AppState.INIT) {
        background(255);
    } else if (state == AppState.RUNNING) {
        background(100);
        fill(255);

        // MessageData msg = msgScheduler.next();
        // if (msg == null) {
        //     state = AppState.PAUSED;
        //     return;
        // }

        // image(peopleLayer.getRender(), 0, 0);
        pushMatrix();
        if (RENDERER == P3D) {
            translate(width/2, height/2, -400);
        } else {
            translate(width/2, height/2);
        }
        root.draw(this.g);
        popMatrix();


    } else if (state == AppState.PAUSED) {
        background(0);
        fill(255);
        text("Paused", 10, 10);
    }
}


void keyPressed() {
    if (key == ' ') {
        if (state == AppState.RUNNING) {
            state = AppState.PAUSED;
        } else if (state == AppState.PAUSED) {
            state = AppState.RUNNING;
        }
    } else if (key == 'a') {
        root.addNode(new PersonNode("test"));
        println("Added node");
    }
}