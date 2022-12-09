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

		// Draw the other stuff in the corner
		pg.pushMatrix();
		pg.translate(mouseX + 10, mouseY + 50);
		pg.fill(20, 200);
		pg.rect(0, 0, 200, 200);
		pg.textAlign(LEFT, TOP);
		pg.fill(255, 87, 201);
		float sentRatio = float(this.person.stats.msgSent) / (this.person.stats.msgReceived + this.person.stats.msgSent);
		pg.text("Sent " + str(this.person.stats.msgSent), 10, 20);
		pg.ellipse(100, 130, 50, 50);
		pg.fill(105, 255, 225);
		pg.text("Received " + str(this.person.stats.msgReceived), 10, 40);
		pg.arc(100, 130, 50, 50, -HALF_PI, TWO_PI * (1 - sentRatio) - HALF_PI, PIE);
		pg.popMatrix();

		this.show = false;
	}

	void draw() {
		draw(g);
	}
}
