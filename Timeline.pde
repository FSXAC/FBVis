class Timeline {

    float x;
    float y;
    float w;
    float h;

    float percentage;
    
    boolean hovered;

    public Timeline(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;

        this.percentage = 0;
        
        this.hovered = false;
    }

    public void draw() {
        noFill();
        stroke(255, this.hovered ? 255 : 10);
        strokeWeight(1);
        rect(this.x, this.y, this.w, this.h);
        
        final float percentageX = map(this.percentage, 0, 1, this.x, this.x + this.w);
        strokeWeight(3);
        line(percentageX, this.y, percentageX, this.y + this.h);
    }

    public void setPercentage(float percentage) {
        this.percentage = constrain(percentage, 0, 1);
    }

    public void handleMouseInput() {
        // Check if mouse is inside the box
        final float x2 = this.x + this.w;
        
        this.hovered = mouseX > this.x && mouseX < x2 && mouseY > this.y && mouseY < this.y + this.h;
        
        if (this.hovered) {
            if (mousePressed) {
                final float new_percentage = map(mouseX, this.x, x2, 0, 1);
                this.setPercentage(new_percentage);
    
                // TODO: should not change global variable
                final int new_gi = (int) map(new_percentage, 0, 1, 0, man.organizedMessagesList.size());
                gi = new_gi;
                currentTimestamp = man.organizedMessagesList.get(gi).timestamp;
            }
        }
    }
}
