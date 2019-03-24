// This is a graphic version of the message

class Payload {
    float x;
    float y;
    Person targetPerson;
    public Payload(Person source, Person target)
    {
        this.x = source.x;
        this.y = source.y;
        this.targetPerson = target;
    }

    public void draw() {
        line(this.x, this.y, this.targetPerson.x, this.targetPerson.y);
    }

    public void update() {
        return;
    }

    public boolean hasArrived() {
        return true;
    }
}


final float PAYLOAD_LERP = 0.1;
final float ARRIVE_THRESHOLD_PX = 5.0;

final float RANDOM_START_D = 5.0;


class PayloadDot extends Payload{
    float x;
    float y;
    Person targetPerson;

    float r;
    float f;

    public PayloadDot(Person source, Person target) {
        super(source, target);
        this.x = source.x + random(-RANDOM_START_D, RANDOM_START_D);
        this.y = source.y + random(-RANDOM_START_D, RANDOM_START_D);
        
        this.targetPerson = target;

        this.r = random(5, 12);
        this.f = random(80, 200);
    }

    @Override
    public void draw() {
        pushMatrix();
        translate(this.x, this.y);
        fill(this.f);
        ellipse(0, 0, this.r, this.r);
        popMatrix();

        this.update();
    }

    @Override
    public void update() {
        this.x = lerp(this.x, this.targetPerson.x, PAYLOAD_LERP);
        this.y = lerp(this.y, this.targetPerson.y, PAYLOAD_LERP);
    }

    @Override
    public boolean hasArrived() {
        final float dx = abs(this.targetPerson.x - this.x);
        final float dy = abs(this.targetPerson.y - this.y);

        return dx < ARRIVE_THRESHOLD_PX && dy < ARRIVE_THRESHOLD_PX;
    }
}

class PayloadLine extends Payload{
    float x;
    float y;
    Person targetPerson;

    int life;

    public PayloadLine(Person source, Person target) {
        super(source, target);
        this.x = source.x + random(-RANDOM_START_D, RANDOM_START_D);
        this.y = source.y + random(-RANDOM_START_D, RANDOM_START_D);
        
        this.targetPerson = target;
        this.life = 15;
    }

    public void draw() {
        stroke(255, 255, 0);
        line(this.x, this.y, this.targetPerson.x, this.targetPerson.y);
    }

    public boolean hasArrived() {
        return life-- == 0;
    }
}

class PayloadSegment extends Payload{
    float x;
    float y;
    float prevX;
    float prevY;
    Person targetPerson;

    float r;
    float f;

    public PayloadSegment(Person source, Person target) {
        super(source, target);
        this.x = source.x + random(-RANDOM_START_D, RANDOM_START_D);
        this.y = source.y + random(-RANDOM_START_D, RANDOM_START_D);
        this.prevX = this.x;
        this.prevY = this.y;
        
        this.targetPerson = target;

        this.r = random(5, 12);
        this.f = random(80, 200);
    }

    @Override
    public void draw() {
        pushMatrix();
        stroke(this.f);
        strokeWeight(this.r / 2);
        line(this.x, this.y, this.prevX, this.prevY);
        
        // translate(this.x, this.y);
        // fill(this.f);
        // ellipse(0, 0, this.r, this.r);
        popMatrix();

        this.update();
    }

    @Override
    public void update() {
        this.prevX = this.x;
        this.prevY = this.y;
        this.x = lerp(this.x, this.targetPerson.x, PAYLOAD_LERP);
        this.y = lerp(this.y, this.targetPerson.y, PAYLOAD_LERP);
    }

    @Override
    public boolean hasArrived() {
        final float dx = abs(this.targetPerson.x - this.x);
        final float dy = abs(this.targetPerson.y - this.y);

        return dx < ARRIVE_THRESHOLD_PX && dy < ARRIVE_THRESHOLD_PX;
    }
}

class PayloadSegmentPhysics extends PayloadSegment {
    final static float MAX_VEL = 5;

    PVector velocity;
    PVector acceleration;

    float mass;

    int grace;

    public PayloadSegmentPhysics(Person source, Person target) {
        super(source, target);
        this.mass = this.r * this.r;
        
        // Random magnitude * Random direction
        float randomMag = 0.75;
        float randomDir = random(0, TWO_PI);

        this.velocity = new PVector(randomMag * cos(randomDir), randomMag * sin(randomDir));

        this.grace = 12;
    }

    @Override
    public void update() {
        this.prevX = this.x;
        this.prevY = this.y;

        this.x += this.velocity.x;
        this.y += this.velocity.y;

        if (this.grace != 0) {
            this.grace--;
            return;
        }

        final float dx = this.targetPerson.x - this.x;
        final float dy = this.targetPerson.y - this.y;

        // get acceleration
        this.acceleration = new PVector(dx - this.velocity.x, dy - this.velocity.y);
        this.acceleration.mult(1 / this.mass);
        // this.acceleration.mult(1000 / (sq(dx) + sq(dy)));
        // forceVec.normalize();
        // forceVec.mult(10);
        // forceVec.mult(100 / (sq(dx) + sq(dy)));
        // forceVec.mult(1 / this.mass);

        // this.velX += forceVec.x;
        // this.velY += forceVec.y;
        this.velocity.add(this.acceleration);
        this.velocity.setMag(PayloadSegmentPhysics.MAX_VEL);

        // if (sq(this.velX) + sq(this.velY) < sq(PayloadSegmentPhysics.MAX_VEL)) {
        //     this.velX += forceVec.x;
        //     this.velY += forceVec.y;
        // }
    }
}