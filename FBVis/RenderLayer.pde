// The idea of the class "Renderlayer" is that 
// it is a wrapper around PGraphics, for better organization
// of what is going to be rendered in the program.
// 
// The derived classes of the RenderLayer abstract class
// could be used as singletons to draw layers with specific
// functions such as UI, payload, people, etc.

abstract class RenderLayer {
    PGraphics pg;

    public RenderLayer(int w, int h, String renderer) {
        this.pg = createGraphics(w, h, renderer);
    }

    public RenderLayer(int w, int h) {
        this.pg = createGraphics(w, h, RENDERER);
    }

    public RenderLayer() {
        this.pg = createGraphics(width, height);
    }

    protected void render() {
        this.pg.beginDraw();
        renderGraphics();
        this.pg.endDraw();
    }

    protected void renderGraphics() {
        this.pg.clear();
    }

    public PGraphics getRender() {
        this.render();
        return this.pg;
    }
}

// class RenderUILayer extends RenderLayer {
    
// 	// Layer states
// 	long timestamp;

// 	// Reference to the timeline object
// 	Timeline timeline;
// 	SpeedControl speedControl;
// 	StatCardHover statCardHover;

// 	public RenderUILayer() {
// 		super();
// 		this.timestamp = 0;
// 	}

// 	@Override
// 	protected void renderGraphics() {
// 		this.pg.clear();
// 		this.renderTimestamp();
// 		this.renderTimeline();
// 		this.renderSpeedControl();
// 		this.renderStatCardHover();
// 	}

// 	private void renderTimestamp() {
// 		this.pg.textFont(monospaceFont);
// 		this.pg.textAlign(CENTER, CENTER);
// 		String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(this.timestamp));
// 		this.pg.textSize(20);
// 		this.pg.fill(255);
// 		this.pg.text(date, width/2, 20);
// 	}

// 	private void renderTimeline() {
// 		this.pg.noFill();

// 		// Set opacity of the timeline to 70 if not hovered or 255 if hovered
// 		this.pg.stroke(255, this.timeline.hovered ? 255 : 70);
// 		this.pg.strokeWeight(1);
// 		this.pg.rect(this.timeline.x, this.timeline.y, this.timeline.w, this.timeline.h);
        
// 		// Draw a cursor of where in the timeline we're currently are at
// 		final float percentX = map(this.timeline.percentage, 0, 1, this.timeline.x, this.timeline.x + this.timeline.w);
// 		this.pg.strokeWeight(3);
// 		this.pg.line(percentX, this.timeline.y, percentX, this.timeline.y + this.timeline.h);
// 	}

// 	private void renderSpeedControl() {
// 		if (this.speedControl == null) return;
// 		this.pg.image(this.speedControl.getSpeedIcon(), 10, 10);
// 	}

// 	private void renderStatCardHover() {
// 		this.pg.textFont(font);
// 		if (this.statCardHover == null) return;
// 		this.statCardHover.draw(this.pg);
// 	}
// }

class RenderPeopleLayer extends RenderLayer {
    Node root;

    public RenderPeopleLayer(Node root) {
        super();
        this.root = root;
    }

    @Override
    protected void renderGraphics() {
        this.pg.clear();
        this.pg.background(255);
        this.pg.lights();
        this.pg.translate(width/2, height/2, 0);
        this.root.draw(this.pg);
    }
}
