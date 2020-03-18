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
		this.pg = createGraphics(w, h, P2D);
	}

	public RenderLayer() {
		this.pg = createGraphics(width, height, P2D);
	}

	public void render() {
		this.pg.beginDraw();
		renderGraphics();
		this.pg.endDraw();
	}

	protected void renderGraphics() {
		this.pg.clear();
	}
}

class RenderUILayer extends RenderLayer {
	
	// Layer states
	long timestamp;

	public RenderUILayer() {
		super();
		this.timestamp = 0;
	}

	@Override
	protected void renderGraphics() {
		this.pg.clear();
		this.renderTimestamp();
	}

	private void renderTimestamp() {
		this.pg.textFont(monospaceFont);
		this.pg.textAlign(CENTER, CENTER);
		String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date(this.timestamp));
		this.pg.textSize(20);
		this.pg.fill(255);
		this.pg.text(date, width/2, 20);
	}
}
