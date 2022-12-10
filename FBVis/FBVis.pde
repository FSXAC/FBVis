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

// ============ visualization ============

void settings() {
    size(800, 600);
}

void setup() {
    CONFIG = new FBVisConfig();
    thread("initializeData");
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
        background(0);
        fill(255);

        MessageData msg = msgScheduler.next();
        if (msg == null) {
            state = AppState.PAUSED;
            return;
        }

        // draw message
        try {
            text(msg.content, 10, 10);
        } catch (NullPointerException e) {
            println("Null pointer exception for message: " + msg.toString());
        }

    } else if (state == AppState.PAUSED) {
        background(0);
        fill(255);
        text("Paused", 10, 10);
    }
}
