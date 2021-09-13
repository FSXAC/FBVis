
class SpeedControl {

	int state;
	PImage imgSpeed1, imgSpeed2, imgSpeed3;

	// TODO: put this in config
	final int SPEED_MULTIPLIER_LOW = 1;
	final int SPEED_MULTIPLIER_MED = 4;
	final int SPEED_MULTIPLIER_HIGH = 16;

	public SpeedControl() {
		state = 0;

		imgSpeed1 = loadImage("img/speed1.png");
		imgSpeed2 = loadImage("img/speed2.png");
		imgSpeed3 = loadImage("img/speed3.png");
	}

	public void incrementSpeed() {
		if (state < 2) {
			state++;
		}
	}

	public void decrementSpeed() {
		if (state > 0) {
			state--;
		}
	}

	public PImage getSpeedIcon() {
		switch (state) {
			case 0: return this.imgSpeed1;
			case 1: return this.imgSpeed2;
			case 2: return this.imgSpeed3;
			default: return null;
		}
	}

	public int getSpeed() {
		switch (state) {
			case 0: return this.SPEED_MULTIPLIER_LOW;
			case 1: return this.SPEED_MULTIPLIER_MED;
			case 2: return this.SPEED_MULTIPLIER_HIGH;
			default: return 0;
		}
	}
}
