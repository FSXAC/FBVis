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
HashMap<Integer, Node> personNodes;

// Crawers
Crawlers crawlers;

// ============ render layers ============

RenderPeopleLayer peopleLayer;
RenderCrawlerLayer crawlerLayer;
String RENDERER = P2D;

// ============ visualization ============

void settings() {
    size(1280, 720, RENDERER);
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

    // Initialize the person nodes map with root
    personNodes = new HashMap<Integer, Node>();
    int root_id = msgManager.nameToIdMap.get(CONFIG.masterName);
    root = new MasterPersonNode(root_id, CONFIG.masterName);
    personNodes.put(root_id, root);

    // Initialize visualization
    peopleLayer = new RenderPeopleLayer(root);

    crawlers = new Crawlers();
    crawlerLayer = new RenderCrawlerLayer(crawlers);

    state = AppState.RUNNING;
}

void draw() {
    if (state == AppState.INIT) {
        background(255);
    } else if (state == AppState.RUNNING) {
        background(30);
        fill(255);

        // Do something with msg data every turn
        MessageData msg = msgScheduler.next();
        if (msg == null) {
            state = AppState.PAUSED;
            return;
        }
        updateIdNodeMap(msg);
        updateCrawlers(msg);

        image(peopleLayer.getRender(), 0, 0);
        image(crawlerLayer.getRender(), 0, 0);
        // pushMatrix();
        // if (RENDERER == P3D) {
        //     translate(width/2, height/2, -400);
        // } else {
        //     translate(width/2, height/2);
        // }
        // root.draw(this.g);
        // popMatrix();

        text(frameRate, 10, 10);


    } else if (state == AppState.PAUSED) {
        background(0);
        fill(255);
        text("Paused", 10, 10);
    }
}

void updateIdNodeMap(MessageData msg) {
    int sender_id = msg.sender_id;
    int[] receiver_ids = msg.receiver_ids;

    if (personNodes.containsKey(sender_id) == false) {
        PersonNode senderNode = new PersonNode(sender_id, msgManager.idToNameMap.get(sender_id));
        personNodes.put(sender_id, senderNode);
        root.addNode(senderNode);
    }

    for (int i = 0; i < receiver_ids.length; i++) {
        int receiver_id = receiver_ids[i];
        if (personNodes.containsKey(receiver_id) == false) {
            PersonNode receiverNode = new PersonNode(receiver_id, msgManager.idToNameMap.get(receiver_id));
            personNodes.put(receiver_id, receiverNode);
            root.addNode(receiverNode);
        }
    }
}

void updateCrawlers(MessageData msg) {
    for (int i = 0; i < msg.receiver_ids.length; i++) {
        crawlers.addCrawler(
            personNodes.get(msg.sender_id),
            personNodes.get(msg.receiver_ids[i])
        );
    }
}


void keyPressed() {
    if (key == ' ') {
        if (state == AppState.RUNNING) {
            state = AppState.PAUSED;
        } else if (state == AppState.PAUSED) {
            state = AppState.RUNNING;
        }
    }
}
