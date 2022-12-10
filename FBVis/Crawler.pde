class Crawler {
    PVector pos;
    Node target;

    public Crawler(Node source, Node target)
    {
        this.pos = source.pos;
        this.target = target;
    }

    private void update() {
        // Move towards target lerp
        this.pos = PVector.lerp(this.pos, this.target.pos, 0.1);
    }

    public boolean hasArrived() {
        if (this.getArrived()) {
            //this.target.refresh();
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
    private ArrayList<Crawler> crawlers;

    public Crawlers() {
        this.crawlers = new ArrayList<Crawler>();
    }

    public void addCrawler(Node source, Node target) {
        this.crawlers.add(new Crawler(source, target));
    }

    public void update() {
        for (Crawler crawler : this.crawlers) {
            crawler.update();
        }

        // Remove crawlers that have arrived
        this.crawlers.removeIf(Crawler::hasArrived);
    }

    public ArrayList<Crawler> getCrawlers() {
        return this.crawlers;
    }
}
