class RenderPeopleLayer extends RenderLayer {
    MasterPersonNode root;

    ArrayList<Node> cachedNodes;

    public RenderPeopleLayer(MasterPersonNode root) {
        super();
        this.root = root;
        this.cachedNodes = new ArrayList<Node>();
    }

    @Override
    protected void renderGraphics() {
        this.pg.clear();
        this.pg.pushMatrix();
        this.pg.translate(width/2, height/2);

        if (this.root.refreshNeeded) {
            this.cachedNodes = this.root.getAllNodes();
            this.root.refreshNeeded = false;
        }

        this.pg.textAlign(CENTER, CENTER);
        this.pg.textSize(PERSON_NAME_TEXT_SIZE);
        for (Node node : this.cachedNodes) {

            PVector pos = node.pos;

            // render the node differently depending on its type
            if (node instanceof PersonNode) {
                if (((PersonNode) node).refreshScore < REFRESH_THRES) {
                    continue;
                }
                this.pg.image(
                    sprites.personNodeSprites[floor(((PersonNode) node).refreshScore * 9)], pos.x-10, pos.y-10);
                this.pg.fill(map(((PersonNode) node).refreshScore, 0, 1, 70, 255));
                this.pg.text(node.name, pos.x, pos.y+PERSON_NODE_SIZE);

            } else {
                this.pg.image(sprites.personNodeSprites[8], pos.x-10, pos.y-10);
                // gold fill
                this.pg.fill(255, 215, 0);
                this.pg.text(node.name, pos.x, pos.y+PERSON_NODE_SIZE);
            }

            node.update();
        }


        this.pg.popMatrix();
    }
}
