// Person class is a person node
// where messages and other information can travel to and from

final float PERSON_LERP = 0.5;

class Person {
    float positionX;
    float positionY;

    float desiredPositionX;
    float desiredPositionY;
    
    String name;
    boolean isMaster;

    boolean autoUpdate;
    
    public Person(String name) {
        this.name = name;
        this.autoUpdate = true;

        this.init();
    }
    
    public void init() {
        this.positionX = width / 2;
        this.positionY = height / 2;
        this.isMaster = false;
    }
    
    public void draw() {
        pushMatrix();
        translate(this.positionX, this.positionY);
        
        // Draw node
        // final float circleSize = 25;
        // ellipse(0, 0, circleSize, circleSize);

        noFill();
        stroke(80);
        rect(-10, -10, 20, 20);

        textAlign(CENTER, CENTER);
        noStroke();
        fill(80);
        textSize(10);
        text(this.name, 0, 0);

        popMatrix();


        if (this.autoUpdate) {
            this.update();
        }
    }
    
    public void update() {
        // LERP for now
        this.positionX = lerp(this.positionX, this.desiredPositionX, PERSON_LERP);
        this.positionY = lerp(this.positionY, this.desiredPositionY, PERSON_LERP);
    }

    public void setPosition(float x, float y) {
        this.positionX = x;
        this.positionY = y;
    }

    public void setDesiredPosition(float x, float y) {
        this.desiredPositionX = x;
        this.desiredPositionY = y;
    }

    public void setIsMaster(boolean master) {
        this.isMaster = master;
    }
}