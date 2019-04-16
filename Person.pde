// Person class is a person node
// where messages and other information can travel to and from

final float PERSON_LERP = 0.5;

final float FRESH_DECAY = 0.99;

class Person {
    float x;
    float y;

    float targetX;
    float targetY;
    
    String name;
    boolean isMaster;

    boolean autoUpdate;

    float fresh;
    
    public Person(String name) {
        this.name = name;
        this.autoUpdate = true;
        this.fresh = 0;

        this.init();
    }
    
    public void init() {
        this.x = width / 2;
        this.y = height / 2;
        this.isMaster = false;
    }
    
    public void draw() {
        pushMatrix();
        translate(this.x, this.y);
        float f = map(this.fresh, 0, 1, 0, 175);
        
        // Draw circle node
        final float circleSize = 15;
        strokeWeight(4);
        stroke(50);
        fill(80 + f);
        ellipse(0, 0, circleSize, circleSize);
        textAlign(CENTER, CENTER);
        fill(255, f);
        textSize(10);
        text(this.name, 0, circleSize);
        
        popMatrix();

        if (this.autoUpdate) {
            this.update();
        }
    }
    
    public void update() {
        // LERP for now
        this.x = lerp(this.x, this.targetX, PERSON_LERP);
        this.y = lerp(this.y, this.targetY, PERSON_LERP);
        
        this.fresh *= FRESH_DECAY;
    }

    public void setPosition(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public void setTargetPosition(float x, float y) {
        this.targetX = x;
        this.targetY = y;
    }

    public void setIsMaster(boolean master) {
        this.isMaster = master;
    }

    public void refresh() {
        this.fresh = 1.0;
    }

    public boolean equals(String name) {
        return this.name.equals(name);
    }
}