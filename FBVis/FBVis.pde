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
    man = new MessageManager(CONFIG.dataRootPath);
    println("Done loading data");
    println(man.organizedMessagesList.size());
}

void draw() {
    ellipse(mouseX, mouseY, 10, 10);
}