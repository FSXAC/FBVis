class StatCardHover {
	final float STATCARD_HOVER_TEXT_SIZE = 16;
	final float STATCARD_HOVER_V_PADDING = 6;
	final float STATCARD_HOVER_H_PADDING = 20;

	Boolean show;
	PersonNode person;

	public StatCardHover() {
		this.show = false;
	}

	// UI element for displaying statistics
	void drawStatCardHover(PGraphics pg) {
		if (!this.show) return;
		if (this.person == null) return;

		pg.pushMatrix();
		pg.translate(mouseX, mouseY);
		float tw = textWidth(this.person.name);
		textSize(STATCARD_HOVER_TEXT_SIZE);
		stroke(50);
		fill(100, 50);
		rect(0, 0, tw + STATCARD_HOVER_H_PADDING * 2, th + STATCARD_HOVER_V_PADDING * 2);
		fill(255);
		textAlign(LEFT, TOP);
		textSize(th);
		text(test, STATCARD_HOVER_H_PADDING, STATCARD_HOVER_V_PADDING);
		popMatrix();
		pg.popMatrix();

		this.show = false;
	}

	void drawStatCardHover() {
		drawStatCardHover(g);
	}
}