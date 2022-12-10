import java.util.Map;


FBVisConfig CONFIG;


MessageManager man;

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
    man = new MessageManager(CONFIG.dataRootPath);
    int duration = millis() - startTime;
    println("Done loading data");
    println(man.organizedMessagesList.size());
    println("Took " + duration + "ms");

    // Verify sorted message list
    for (int i = 0; i < 10; i++) {
        // print time stamp
        println(man.organizedMessagesList.get(i).timestamp);
    }

    println("...");

    for (int i = man.organizedMessagesList.size() - 11; i < man.organizedMessagesList.size(); i++) {
        println(man.organizedMessagesList.get(i).timestamp);
    }
}

void draw() {
    ellipse(mouseX, mouseY, 10, 10);
}