class Person {
    float desiredX, desiredY;
    float positionX, positionY;
    int activeness;
    String name;
    boolean master;

    public Person(String name) {
        this.name = name;
        this.positionX = 0;
        this.positionY = 0;
        this.desiredX = 0;
        this.desiredY = 0;
        this.activeness = 255;
        this.master = false;
    }

    public Person(String name, float desiredX, float desiredY) {
        this(name);
        this.desiredX = desiredX;
        this.desiredY = desiredY;
    }

    public Person(String name, float desiredX, float desiredY, float x, float y) {
        this(name, desiredX, desiredY);
        this.positionX = x;
        this.positionY = y;
    }

    public void draw(boolean active) {
        if (active) {
            fill(255, 255, 0);
            ellipse(this.positionX, this.positionY, PEOPLE_SIZE * ENABLE_ENLARGE_FACTOR, PEOPLE_SIZE * ENABLE_ENLARGE_FACTOR);
            this.activeness = 255;
        } else {
            if (this.master) {
                fill(0, 255, 255);
            } else {
                fill(255, this.activeness);
            }
            ellipse(this.positionX, this.positionY, PEOPLE_SIZE, PEOPLE_SIZE);
        }
        textSize(10);
        text(this.name, this.positionX, this.positionY + NAME_OFFSET);

        this.update();
    }

    public void setDesired(float x, float y) {
        this.desiredX = x;
        this.desiredY = y;
    }

    public void setMaster() {
        this.master = true;
    }

    private void update() {
        this.positionX = lerp(this.positionX, this.desiredX, PEOPLE_LERPNESS);
        this.positionY = lerp(this.positionY, this.desiredY, PEOPLE_LERPNESS);

        if (this.activeness > 25) {
            this.activeness--;
        }
    }
}