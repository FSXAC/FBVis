class RenderPeopleLayer extends RenderLayer {
    Node root;

    public RenderPeopleLayer(Node root) {
        super();
        this.root = root;
    }

    @Override
    protected void renderGraphics() {
        this.pg.clear();
        this.pg.pushMatrix();
        this.pg.translate(width/2, height/2);
        this.root.draw(this.pg);
        this.pg.popMatrix();
    }
}
