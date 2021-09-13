
final int SPIRAL_ARCHIMEDEAN = 0;
final int SPIRAL_QUADRATIC = 1;
final int SPIRAL_NOTSPIRAL = 2;
final int SPIRAL_CUSTOM = 3;
final float SPIRAL_ARCHIMEDEAN_R = 30;

final int SPIRAL_SELECT = SPIRAL_CUSTOM;

// Function that gives a vector around a point 
PVector spiral(int n, float centerX, float centerY) {
    float x = 0, y = 0;

    switch (SPIRAL_SELECT) {
        case SPIRAL_ARCHIMEDEAN:
            if (n > 0) {
                n += 1;
            }

            float a = (n) * 2.4;
            float r = SPIRAL_ARCHIMEDEAN_R * sqrt(n);
            x = r * cos(a) + centerX;
            y = r * sin(a) + centerY;
            break;
        case SPIRAL_QUADRATIC:
            float sqrtn = sqrt(n);
            x = 30 * sqrtn * cos(TWO_PI * sqrtn) + centerX;
            y = 30 * sqrtn * sin(TWO_PI * sqrtn) + centerY;
            break;
        case SPIRAL_NOTSPIRAL:
            if (n == 0) {
                x = centerX;
                y = centerY;
            } else {
                float dx = (width - 50) / 20;
                float dy = (height - 50) / 10;
                x = (n % 20) * dx + 25;
                y = floor(n / 20) * dy + 25;
            }
            break;
        case SPIRAL_CUSTOM:
            r = -1 * pow(70, pow(0.3 * n, 0.07));
            float m = 1.001;
            x = width/2 + r * cos(n * m);
            y = height/2 + r * sin(n * m);
    }

    return new PVector(x, y);
}
