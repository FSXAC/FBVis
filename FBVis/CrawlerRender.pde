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
        this.pg.blendMode(SCREEN);
        this.pg.strokeWeight(1);

        // Draw inbound crawlers
        this.pg.stroke(160, 80, 80);
        for (Crawler c : this.crawlers.inboundCrawlers) {
            this.pg.line(c.pos.x, c.pos.y, c.prev_pos.x, c.prev_pos.y);
        }

        // Draw outbound crawlers
        this.pg.stroke(80, 160, 80);
        for (Crawler c : this.crawlers.outboundCrawlers) {
            this.pg.line(c.pos.x, c.pos.y, c.prev_pos.x, c.prev_pos.y);
        }
        this.pg.popMatrix();

        this.updateCrawlers();
    }
}
