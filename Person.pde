// Person class is a person node
// where messages and other information can travel to and from

final float PERSON_LERP = 0.5;
final float PERSON_HITBOX_R = 15;
final float PERSON_NODE_SIZE = 15;
final float PERSON_MASTER_NODE_SIZE = 20;
final float PERSON_NAME_TEXT_SIZE = 12;

final float REFRESH_DECAY = 0.99;
final float REFRESH_THRES = 0.01;

class PersonStat { 
	int msgReceived;
	int msgSent;
	long lastInteractTimestamp;

	public PersonStat() {
		msgReceived = 0;
		msgSent = 0;
		lastInteractTimestamp = 0;
	}
}

class PersonNode {
	float x, targetX; 
	float y, targetY;

	String name;
	float refreshScore;

	// Stats
	PersonStat stats;
	
	public PersonNode(String name) {
		this.refreshScore = 1.0;

		this.x = width / 2;
		this.y = height / 2;

		// Reset stats
		this.stats = new PersonStat();

		// Set name
		if (CONFIG.hideRealNames) {
			this.name = CONFIG.hideNameReplacement;
		} else {
			this.name = name;
		}
	}

	public void setPosition(float x, float y) {
		this.x = x;
		this.y = y;
	}

	public void setTargetPosition(float x, float y) {
		this.targetX = x;
		this.targetY = y;
	}

	public void refresh() {
		this.refreshScore = 1.0;
	}

	public boolean equals(String name) {
		return this.name.equals(name);
	}

	public void incrementMsgReceived() {
		this.stats.msgReceived++;
	}

	public void incrementMsgSent() {
		this.stats.msgSent++;
	}

	public void draw() {
		// If no PGraphics object is selected, then we draw to default PGraphics instead
		this.draw(g);
	}

	public void draw(PGraphics pg) {
		// If mouse position is over the person, change UI
		if (abs(mouseX - this.x) < PERSON_HITBOX_R && abs(mouseY - this.y) < PERSON_HITBOX_R) {
			this.drawNodeInFocus(pg);
		} else if (this.refreshScore < REFRESH_THRES) {
			return;
		} else {
			this.drawNode(pg);
		}

		// Update upon draw
		this.update();
	}

	protected void drawNodeInFocus(PGraphics pg) {
		pg.pushMatrix();
		pg.translate(this.x, this.y);

		// Draw circle outline
		pg.strokeWeight(4);
		pg.stroke(50);

		// Draw inner circle
		pg.fill(50, 255, 50);
		pg.ellipse(0, 0, PERSON_NODE_SIZE, PERSON_NODE_SIZE);

		// Draw name tag
		pg.textAlign(CENTER, CENTER);
		pg.fill(255);
		pg.textSize(PERSON_NAME_TEXT_SIZE);
	
		pg.text(this.name, 0, PERSON_NODE_SIZE);

		// Done
		pg.popMatrix();
	}

	protected void drawNode(PGraphics pg) {
		pg.pushMatrix();
		pg.translate(this.x, this.y);

		float fillScore = map(this.refreshScore, 0, 1, 0, 245);
		float strokeFillScore = map(this.refreshScore, 0, 1, 5, 50);
			
		// Draw circle outline
		pg.strokeWeight(4);
		pg.stroke(strokeFillScore);

		// Draw inner circle
		pg.fill(10 + fillScore);
		pg.ellipse(0, 0, PERSON_NODE_SIZE, PERSON_NODE_SIZE);

		// Draw name tag
		pg.textAlign(CENTER, CENTER);
		pg.fill(255, fillScore);
		pg.textSize(PERSON_NAME_TEXT_SIZE);
		pg.text(this.name, 0, PERSON_NODE_SIZE);

		// Done
		pg.popMatrix();
	}

	private void update() {
		// Update position by lerping
		this.x = lerp(this.x, this.targetX, PERSON_LERP);
		this.y = lerp(this.y, this.targetY, PERSON_LERP);

		// Update refresh score
		this.refreshScore *= REFRESH_DECAY;
	}
}

class PersonMasterNode extends PersonNode {
	public PersonMasterNode(String name) {
		super(name);

		// Actually don't hide the name
		this.name = name;
	}

	@Override
	protected void drawNode(PGraphics pg) {
		pg.pushMatrix();
		pg.translate(this.x, this.y);
			
		// Draw circle outline
		pg.strokeWeight(4);
		pg.stroke(50);

		// Draw inner circle
		pg.fill(255, 230, 64);
		pg.ellipse(0, 0, PERSON_MASTER_NODE_SIZE, PERSON_MASTER_NODE_SIZE);

		// Draw name tag
		pg.textAlign(CENTER, CENTER);
		pg.fill(255);
		pg.textSize(PERSON_NAME_TEXT_SIZE);
		pg.text(this.name, 0, PERSON_MASTER_NODE_SIZE);

		// Done
		pg.popMatrix();
	}
}
