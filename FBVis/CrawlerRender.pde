class RenderCrawlerLayer extends RenderLayer {
    
    private Crawlers crawlers;

    public RenderCrawlerLayer(Crawlers crawlers) {
        super();
        this.crawlers = crawlers;
    }

    private void updateCrawlers() {
        this.crawlers.update();
    }

    @Override
    protected void renderGraphics() {
        this.pg.clear();
        this.pg.pushMatrix();
        this.pg.translate(width/2, height/2);
        // this.pg.noStroke();
        // this.pg.fill(255, 0, 0);
        this.pg.stroke(255, 0, 0);
        this.pg.strokeWeight(3);
        for (Crawler c : this.crawlers.getCrawlers()) {
            // this.pg.ellipse(c.pos.x, c.pos.y, 10, 10);
            this.pg.point(c.pos.x, c.pos.y);
        }
        this.pg.popMatrix();

        this.updateCrawlers();
    }
}