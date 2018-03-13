class Person {
    float desiredX, desiredY;
    float positionX, positionY;
    float activeness;
    String name;
    boolean master;
    boolean inactive;

    public Person(String name) {
        this.name = name;
        this.positionX = 0;
        this.positionY = 0;
        this.desiredX = 0;
        this.desiredY = 0;
        this.activeness = 255;
        this.master = false;
        this.inactive = false;
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
            fill(ACTIVE_PERSON_COLOR);
            ellipse(this.positionX, this.positionY, PEOPLE_SIZE * ENABLE_ENLARGE_FACTOR, PEOPLE_SIZE * ENABLE_ENLARGE_FACTOR);
            this.activeness = 255;
        } else {
            if (this.master) {
                fill(MASTER_COLOR);
            } else {
                fill(255, constrain(this.activeness, 25, 255));
            }
            ellipse(this.positionX, this.positionY, PEOPLE_SIZE, PEOPLE_SIZE);
        }
        textSize(12);
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
            this.activeness -= PEOPLE_ACTIVE_DECAY_RATE;
        } else if (this.activeness > 0) {
            this.activeness -= PEOPLE_INACTIVE_DECAY_RATE;
        } else {
            // Mark this person for deletion
            this.inactive = true;
        }
    }
}