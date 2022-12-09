class LayoutGenerator {
    float centerX;
    float centerY;

    public LayoutGenerator(float centerX, float centerY) {
        this.centerX = centerX;
        this.centerY = centerY;
    }

    public PVector pos(int n) {
        if (n == 0) {
            return new PVector(width/2, height/2);
        } else {
            final float x = (n % 20) * ((width - 50) / 20) + 25;
            final float y = floor(n / 20) * ((height - 50) / 10) + 25;
            return new PVector(x, y);
        }
    }
}

class Spiral extends LayoutGenerator {

    float radius;

    public Spiral(float radius, float centerX, float centerY) {
        super(centerX, centerY);
        this.radius = radius;
    }

    @Override
    public PVector pos(int n) {
        if (n > 0) {
            n += 1;
        }

        final float a = 2.4 * n;
        final float r = this.radius * sqrt(n);
        final float x = r * cos(a) + this.centerX;
        final float y = r * sin(a) + this.centerY;

        return new PVector(x, y);
    }
}

class PackedSpiral extends Spiral {

    float power = 0.07;
    float baseCoeff = 0.3;
    float fanoutOffsetMult = 1.001;
    float r;

    public PackedSpiral(float radius, float centerX, float centerY) {
        super(radius, centerX, centerY);
    }

    @Override
    public PVector pos(int n) {
        this.r = -1 * pow(this.radius, pow(this.baseCoeff * n, this.power));
        final float x = width/2 + this.r * cos(n * this.fanoutOffsetMult);
        final float y = height/2 + this.r * sin(n * this.fanoutOffsetMult);

        return new PVector(x, y);
    }
}