// Person class is a person node
// where messages and other information can travel to and from

final float PERSON_LERP = 0.5;
final float PERSON_HITBOX_R = 15;
final float PERSON_NODE_SIZE = 15;
final float PERSON_MASTER_NODE_SIZE = 20;
final float PERSON_NAME_TEXT_SIZE = 12;

final float REFRESH_DECAY = 0.99;
final float REFRESH_THRES = 0.001;

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

	public Node(int id, String name, PVector initPos, PVector targetPos) {
		this.id = id;
		this.pos = initPos;
		this.targetPos = targetPos;
		this.name = name;
	}

	public void setPos(PVector pos) {
		this.targetPos = pos;
	}

	public void update() {
		this.pos.lerp(this.targetPos, NODE_RESPONSIVENESS);
	}
}

class PersonNode extends Node {

	// Display properties
	float refreshScore = 1.0;

	// Stats
	PersonStat stats;
	
	public PersonNode(int id, String name) {
		super(id, name, new PVector(0, 0, 0), new PVector(0, 0, 0));

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

	@Override
	public void update() {
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

	boolean refreshNeeded = false;

	public GroupNode(int id, String name) {
		super(id, name, new PVector(0, 0, 0), new PVector(0, 0, 0));
	}

	public void addNode(Node node) {
		this.nodes.add(node);
		this.reposition();
		this.refreshNeeded = true;
	}

	public void removeNode(Node node) {
		this.nodes.remove(node);
		this.reposition();
		this.refreshNeeded = true;
	}

	public void reposition() {
		final int N = this.nodes.size();
		
		// Calculate new position for all nodes, +1 offset
		PVector[] points;
		if (RENDERER == P3D) {
			points = genPts3DSphere(N + 1, this.groupRadius);
		} else {
			points = genPts2DPackedSpiral(N + 1, this.groupRadius);
		}

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

	@Override
	public void update() {
		// Super update
		super.update();

		// Update all nodes
		for (Node node : this.nodes) {
			node.update();
		}
	}

	// Recursively get all nodes in this group
	public ArrayList<Node> getAllNodes() {
		ArrayList<Node> allNodes = new ArrayList<Node>();
		for (Node node : this.nodes) {
			allNodes.add(node);
			if (node instanceof GroupNode) {
				allNodes.addAll(((GroupNode) node).getAllNodes());
			}
		}
		// add self
		allNodes.add(this);
		return allNodes;
	}
}

// Singleton class for the master person node (root)
class MasterPersonNode extends GroupNode {
	private MasterPersonNode(int id, String name) {
		super(id, name);
	}
}
