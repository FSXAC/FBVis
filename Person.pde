// Person class is a person node
// where messages and other information can travel to and from
class Person {
    float positionX;
    float positionY;
    
    String name;
    boolean isMaster;
    
    public Person(String name) {
        this.name = name;
        this.init();
    }
    
    public void init() {
        this.positionX = 0;
        this.positionY = 0;
        this.isMaster = false;
    }
    
    public void draw() {
        pushMatrix();
        translate(this.positionX, this.positionY);
        
        // Draw node
        final float circleSize = 25;
        ellipse(0, 0, circleSize, circleSize);

        textAlign(CENTER, CENTER);
        text(this.name, 0, -circleSize);

        popMatrix();
    }
    
    public void update() {
    }

    public void setPosition(float x, float y) {
        this.positionX = x;
        this.positionY = y;
    }

    public void setIsMaster(boolean master) {
        this.isMaster = master;
    }
}