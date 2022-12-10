class Crawler {
    PVector pos;
    PVector prev_pos;

    Node target;

    // Appearance
    float travel_lerp;
    float travel_y_lerp_mult;

    public Crawler(Node source, Node target)
    {
        this.pos = source.pos.copy();
        this.prev_pos = source.pos.copy();
        this.target = target;

        this.travel_lerp = random(CONFIG.payloadSegmentLerpMin, CONFIG.payloadSegmentLerpMax);
        this.travel_y_lerp_mult = random(0.5, 0.8);

        // if the source is personnode
        if (source instanceof PersonNode) {
            ((PersonNode) source).refresh();
        }
    }

    private void update() {
        // Move towards target lerp
        this.prev_pos.set(this.pos);
        // this.pos = PVector.lerp(this.pos, this.target.pos, 0.1);
        this.pos.x = lerp(this.pos.x, this.target.pos.x, this.travel_lerp);
        this.pos.y = lerp(this.pos.y, this.target.pos.y, this.travel_lerp * this.travel_y_lerp_mult);
    }

    public boolean hasArrived() {
        if (this.getArrived()) {

            if (target instanceof PersonNode) {
                ((PersonNode) target).refresh();
            }
            return true;
        }

        return false;
    }

    protected boolean getArrived() {
        // Return true if close enough to target
        return (this.pos.dist(this.target.pos) < 10);
    }
}

class Crawlers {
    public ArrayList<Crawler> inboundCrawlers;
    public ArrayList<Crawler> outboundCrawlers;

    public Crawlers() {
        this.inboundCrawlers = new ArrayList<Crawler>();
        this.outboundCrawlers = new ArrayList<Crawler>();
    }

    public void addCrawler(Node source, Node target, boolean inbound) {
        if (inbound) {
            this.inboundCrawlers.add(new Crawler(source, target));
        } else {
            this.outboundCrawlers.add(new Crawler(source, target));
        }
    }

    public void update() {
        // Update crawlers
        this.inboundCrawlers.forEach(Crawler::update);
        this.outboundCrawlers.forEach(Crawler::update);

        // Remove crawlers that have arrived
        this.inboundCrawlers.removeIf(Crawler::hasArrived);
        this.outboundCrawlers.removeIf(Crawler::hasArrived);
    }

    public int getNumCrawlers() {
        return this.inboundCrawlers.size() + this.outboundCrawlers.size();
    }
}
