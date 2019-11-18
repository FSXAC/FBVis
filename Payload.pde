// This is a graphic version of the message

// Abstract payload
class Payload {
    float x;
    float y;
    Person targetPerson;
    public Payload(Person source, Person target)
    {
        this.x = source.x;
        this.y = source.y;
        this.targetPerson = target;

        // Sender gets refreshed
        source.refresh();
    }

    public void draw() {
        line(this.x, this.y, this.targetPerson.x, this.targetPerson.y);
    }

    public void update() {
        return;
    }

    public boolean hasArrived() {
        if (this.getArrived()) {
            this.targetPerson.refresh();
            return true;
        }

        return false;
    }

    protected boolean getArrived() {
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
    protected boolean getArrived() {
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
        strokeWeight(1);
        line(this.x, this.y, this.targetPerson.x, this.targetPerson.y);
    }

    protected boolean getArrived() {
        return life-- == 0;
    }
}

class PayloadSegment extends Payload{
    float x;
    float y;
    float prevX;
    float prevY;
    Person targetPerson;

    float radius = random(3, 8);
    float opacity = random(CONFIG.payloadOpacityMin, CONFIG.payloadOpacityMax);

    float travel_lerp;
    float travel_y_lerp_mult;

    boolean isMasterSending = false;

    public PayloadSegment(Person source, Person target, float size) {
        super(source, target);
        this.x = source.x + random(-RANDOM_START_D, RANDOM_START_D);
        this.y = source.y + random(-RANDOM_START_D, RANDOM_START_D);
        this.prevX = this.x;
        this.prevY = this.y;
        
        if (CONFIG.payloadSizeBasedOnMessageLength) {
            this.radius = size;
        }

        this.travel_lerp = random(CONFIG.payloadSegmentLerpMin, CONFIG.payloadSegmentLerpMax);
        this.travel_y_lerp_mult = random(0.5, 0.8);
        
        this.targetPerson = target;
        
        // TODO: FIXME:
        if (source.equals(CONFIG.masterName)) {
            this.isMasterSending = true;
        }
    }

    @Override
    public void draw() {
        pushMatrix();
        stroke(this.isMasterSending ? CONFIG.payloadSendColor : CONFIG.payloadReceiveColor, this.opacity);
        strokeWeight(this.radius);
        line(this.x, this.y, this.prevX, this.prevY);
        popMatrix();

        this.update();
    }

    @Override
    public void update() {
        this.prevX = this.x;
        this.prevY = this.y;
        this.x = lerp(this.x, this.targetPerson.x, this.travel_lerp);
        this.y = lerp(this.y, this.targetPerson.y, this.travel_lerp * travel_y_lerp_mult);
    }

    @Override
    protected boolean getArrived() {
        final float dx = abs(this.targetPerson.x - this.x);
        final float dy = abs(this.targetPerson.y - this.y);

        return dx < ARRIVE_THRESHOLD_PX && dy < ARRIVE_THRESHOLD_PX;
    }
}

class PayloadSegment2 extends PayloadSegment {
    public PayloadSegment2(Person source, Person target, float size) {
        super(source, target, size);
        this.travel_lerp = random(CONFIG.payloadSegmentGroupLerpMin, CONFIG.payloadSegmentGroupLerpMax);
    }

    @Override
    public void draw() {
        pushMatrix();
        stroke(CONFIG.payloadGroupColor, this.opacity);
        strokeWeight(this.radius);
        line(this.x, this.y, this.prevX, this.prevY);
        popMatrix();

        this.update();
    }
}

class PayloadFactory {

    ArrayList<Payload> payloads;

    public PayloadFactory(ArrayList<Payload> payloads) {
        this.payloads = payloads;
    }

    public void makeIndividualPayload(Person sender, Person receiver, float size) {
        this.payloads.add(new PayloadSegment(sender, receiver, size));
    }

    public void makeGroupPayload(Person sender, Person receiver, float size) {
        this.payloads.add(new PayloadSegment2(sender, receiver, size));
    }
}
