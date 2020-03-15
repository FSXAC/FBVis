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

    // Stats
    int msgReceived;
    int msgSent;
    long lastInteraction;

    public Person(String name) {
        this.name = name;
        this.autoUpdate = true;
        this.fresh = 0;

        this.init();
        
        if (name.equals(CONFIG.masterName)) {
            this.isMaster = true;
        } else if (CONFIG.hideRealNames) {
            this.name = CONFIG.hideNameReplacement;
        }

        // Reset stats
        msgReceived = 0;
        msgSent = 0;
        lastInteraction = 0;
    }
    
    public void init() {
        this.x = width / 2;
        this.y = height / 2;
        this.isMaster = false;
    }
    
    public void draw() {
        float tempF = this.fresh;
        if (abs(mouseX - this.x) < 15 && abs(mouseY - this.y) < 15) {
            drawNodeFocus();
            return;
        } else if (this.fresh < 0.01) {
            // TODO: put this threshold in a constant
            return;
        }
    
        // Todo: master user should be a separate class to avoid redundant check
        if (this.isMaster) {
            drawMasterNode();
        } else {
            drawNode(tempF);
        }

        if (this.autoUpdate) {
            this.update();
        }
    }

    private void drawMasterNode() {
        pushMatrix();
        translate(this.x, this.y);
        strokeWeight(4);
        stroke(50);
        fill(255, 230, 64);
        ellipse(0, 0, 20, 20);
        fill(255);
        textSize(14);
        text(this.name, 0, 20);
        popMatrix();
    }
    
    private void drawNode(float fresh) {
        pushMatrix();
        translate(this.x, this.y);
        float f = map(this.fresh, 0, 1, 0, 245);
        float sf = map(this.fresh, 0, 1, 5, 50);
            
        // Draw circle node
        // TODO: make this a constant
        final float circleSize = 15;
        strokeWeight(4);
        stroke(sf);
        fill(10 + f);
        ellipse(0, 0, circleSize, circleSize);
        textAlign(CENTER, CENTER);
        fill(255, f);
        textSize(10);
        text(this.name, 0, circleSize);
        popMatrix();
    }

    private void drawNodeFocus() {
        pushMatrix();
        translate(this.x, this.y);

        final float circleSize = 15;
        strokeWeight(4);
        stroke(100);
        fill(255, 0, 255);
        ellipse(0, 0, circleSize, circleSize);
        textAlign(CENTER, CENTER);
        fill(255);
        textSize(10);
        text(this.name, 0, circleSize);
        drawPersonStats();
        popMatrix();
    }

    private void drawPersonStats() {
        text("Sent: " + str(this.msgSent), 100, 100);
        text("Received: " + str(this.msgReceived), 100, 120);
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

    public void refresh() {
        this.fresh = 1.0;
    }

    public boolean equals(String name) {
        return this.name.equals(name);
    }

    public void incrementMsgReceived() {
        this.msgReceived++;
    }

    public void incrementMsgSent() {
        this.msgSent++;
    }
}
