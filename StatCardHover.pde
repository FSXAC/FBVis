class StatCardHover {
	final float STATCARD_HOVER_TEXT_SIZE = 14;
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
		pg.translate(mouseX + 10, mouseY + 10);
		float w = textWidth(this.person.name) + (STATCARD_HOVER_H_PADDING * 2);
		float h = STATCARD_HOVER_TEXT_SIZE + (STATCARD_HOVER_V_PADDING * 2);
		pg.noStroke();
		pg.textSize(STATCARD_HOVER_TEXT_SIZE);
		pg.fill(20, 200);
		pg.rect(0, 0, w, h);
		pg.fill(255);
		pg.textAlign(CENTER, CENTER);
		pg.text(this.person.name, w / 2, h / 2);
		pg.popMatrix();

		this.show = false;
	}

	void draw() {
		draw(g);
	}
}
