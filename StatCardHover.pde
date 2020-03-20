class StatCardHover {
	final float STATCARD_HOVER_TEXT_SIZE = 16;
	final float STATCARD_HOVER_V_PADDING = 8;
	final float STATCARD_HOVER_H_PADDING = 20;

	Boolean show;
	PersonNode person;

	public StatCardHover() {
		this.show = false;
	}

	// UI element for displaying statistics
	void draw(PGraphics pg) {
		if (!this.show) return;
		if (this.person == null) return;

		pg.pushMatrix();
		pg.translate(mouseX, mouseY);
		float tw = textWidth(this.person.name);
		pg.noStroke();
		pg.textSize(STATCARD_HOVER_TEXT_SIZE);
		pg.fill(20, 200);
		pg.rect(0, 0, tw + STATCARD_HOVER_H_PADDING * 2, STATCARD_HOVER_TEXT_SIZE + STATCARD_HOVER_V_PADDING * 2);
		pg.fill(255);
		pg.textAlign(LEFT, TOP);
		pg.text(this.person.name, STATCARD_HOVER_H_PADDING, STATCARD_HOVER_V_PADDING);
		pg.popMatrix();

		this.show = false;
	}

	void draw() {
		draw(g);
	}
}
