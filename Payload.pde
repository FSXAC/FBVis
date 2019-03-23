// This is a graphic version of the message

final float PAYLOAD_LERP = 0.1;
final float ARRIVE_THRESHOLD_PX = 5.0;

final float RANDOM_START_D = 5.0;

class Payload {
    float x;
    float y;
    Person targetPerson;

    float r;
    float f;

    public Payload(Person source, Person target) {
        this.x = source.x + random(-RANDOM_START_D, RANDOM_START_D);
        this.y = source.y + random(-RANDOM_START_D, RANDOM_START_D);
        
        this.targetPerson = target;

        this.r = random(5, 12);
        this.f = random(80, 200);
    }

    public void draw() {
        pushMatrix();
        translate(this.x, this.y);
        fill(this.f);
        ellipse(0, 0, this.r, this.r);
        popMatrix();

        this.update();
    }

    public void update() {
        this.x = lerp(this.x, this.targetPerson.x, PAYLOAD_LERP);
        this.y = lerp(this.y, this.targetPerson.y, PAYLOAD_LERP);
    }

    public boolean hasArrived() {
        final float dx = abs(this.targetPerson.x - this.x);
        final float dy = abs(this.targetPerson.y - this.y);

        return dx < ARRIVE_THRESHOLD_PX && dy < ARRIVE_THRESHOLD_PX;
    }
}