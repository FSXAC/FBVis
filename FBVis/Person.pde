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
		this.reset();
	}

	public void reset() {
		msgReceived = 0;
		msgSent = 0;
		lastInteractTimestamp = 0;
	}
}

class Node {
	PVector pos;
	PVector targetPos;
	
	String name;
	int id;

	float NODE_RESPONSIVENESS = 0.2;

	public Node(String name, PVector initPos, PVector targetPos) {
		this.pos = initPos;
		this.targetPos = targetPos;
		this.name = name;
	}

	public void setPos(PVector pos) {
		this.targetPos = pos;
	}

	private void update() {
		this.pos.lerp(this.targetPos, NODE_RESPONSIVENESS);
	}

	private void drawNode(PGraphics pg) {
		pg.sphere(5);
	}

	public void draw(PGraphics pg) {
		pg.pushMatrix();
		pg.translate(this.pos.x, this.pos.y, this.pos.z);
		this.drawNode(pg);
		pg.popMatrix();

		this.update();
	}
}

class PersonNode extends Node {

	// Display properties
	float refreshScore = 1.0;

	// Stats
	PersonStat stats;
	
	public PersonNode(String name) {
		super(name, new PVector(0, 0, 0), new PVector(0, 0, 0));

		// Set name
		if (CONFIG.hideRealNames) {
			this.name = CONFIG.hideNameReplacement;
		} else {
			this.name = name;
		}

		this.stats = new PersonStat();
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

	private void drawNode(PGraphics pg) {
		if (this.refreshScore < REFRESH_THRES) {
			return;
		}

		// Ignore mouse focus for now
		// FIXME:

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
	}



	// public void draw(PGraphics pg) {
	// 	// If mouse position is over the person, change UI
	// 	if (abs(mouseXSpace() - this.x) < PERSON_HITBOX_R && abs(mouseYSpace() - this.y) < PERSON_HITBOX_R) {
	// 		this.drawNodeInFocus(pg);
	// 	} else if (this.refreshScore < REFRESH_THRES) {
	// 		return;
	// 	} else {
	// 		this.drawNode(pg);
	// 	}
	// }

	// protected void drawNodeInFocus(PGraphics pg) {
	// 	pg.pushMatrix();
	// 	pg.translate(this.x, this.y);

	// 	// Draw circle outline
	// 	pg.strokeWeight(4);
	// 	pg.stroke(50);

	// 	// Draw inner circle
	// 	pg.fill(50, 255, 50);
	// 	pg.ellipse(0, 0, PERSON_NODE_SIZE, PERSON_NODE_SIZE);

	// 	// Draw name tag
	// 	pg.textAlign(CENTER, CENTER);
	// 	pg.fill(255);
	// 	pg.textSize(PERSON_NAME_TEXT_SIZE);
	
	// 	pg.text(this.name, 0, PERSON_NODE_SIZE);

	// 	// Done
	// 	pg.popMatrix();

	// 	// Set hover state for UI (todo: add mutex lock so only one hover is possible and mouse input is consumed)
	// 	statcardHover.person = this;
	// 	statcardHover.show = true;
	// }

	// protected void drawNode(PGraphics pg) {
	// 	pg.pushMatrix();
	// 	pg.translate(this.x, this.y);

	// 	float fillScore = map(this.refreshScore, 0, 1, 0, 245);
	// 	float strokeFillScore = map(this.refreshScore, 0, 1, 5, 50);
			
	// 	// Draw circle outline
	// 	pg.strokeWeight(4);
	// 	pg.stroke(strokeFillScore);

	// 	// Draw inner circle
	// 	pg.fill(10 + fillScore);
	// 	pg.ellipse(0, 0, PERSON_NODE_SIZE, PERSON_NODE_SIZE);

	// 	// Draw name tag
	// 	pg.textAlign(CENTER, CENTER);
	// 	pg.fill(255, fillScore);
	// 	pg.textSize(PERSON_NAME_TEXT_SIZE);
	// 	pg.text(this.name, 0, PERSON_NODE_SIZE);

	// 	// Done
	// 	pg.popMatrix();
	// }

	private void update() {
		// Super update
		super.update();

		// Update refresh score
		this.refreshScore *= REFRESH_DECAY;
	}
}

class GroupNode extends Node {
	
	// Contains either PersonNode or GroupNode
	ArrayList<Node> nodes = new ArrayList<Node>();

	// Display properties
	float groupRadius = 100;

	public GroupNode(String name) {
		super(name, new PVector(0, 0, 0), new PVector(0, 0, 0));
	}

	public void addNode(Node node) {
		this.nodes.add(node);
		this.reposition();
	}

	public void removeNode(Node node) {
		this.nodes.remove(node);
		this.reposition();
	}

	public void reposition() {
		final int N = this.nodes.size();
		
		// Calculate new position for all nodes, +1 offset
		PVector[] points = genPts3DSphere(N + 1, this.groupRadius);

		// Set new positions
		for (int i = 0; i < N; i++) {
			this.nodes.get(i).setPos(points[i + 1].add(this.pos));
		
			if (this.nodes.get(i) instanceof GroupNode) {
				
				// Push group nodes away
				PVector deltaPos = points[i + 1].copy().normalize().mult(2 * this.groupRadius);
				this.nodes.get(i).setPos(points[i + 1].add(deltaPos));

				// Recursively reposition group nodes
				((GroupNode) this.nodes.get(i)).reposition();
			}
		}
	}

	private void update() {
		// Super update
		super.update();

		// Update all nodes
		for (Node node : this.nodes) {
			node.update();
		}
	}

	private void drawNode(PGraphics pg) {
		super.drawNode(pg);

		// Draw lines to all nodes
		for (Node node : this.nodes) {
			pg.line(this.pos.x, this.pos.y, this.pos.z, node.pos.x, node.pos.y, node.pos.z);
		}

		// Draw all nodes
		for (Node node : this.nodes) {
			node.draw(pg);
		}
	}
}

// Singleton class for the master person node (root)
class MasterPersonNode extends GroupNode {
	private MasterPersonNode(String name) {
		super(name);
	}
}
