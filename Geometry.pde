final boolean USE_ARCHIMEDEAN_SPIRAL = true;

// Function that gives a vector around a point 
PVector spiral(int n, float centerX, float centerY) {
    float x, y;
    if (USE_ARCHIMEDEAN_SPIRAL) {
        float a = (n + 0) * 137.5;
        float r = 30 * sqrt(n + 0);
        x = r * cos(a) + centerX;
        y = r * sin(a) + centerY;
    } else {
        x = (100 + 6 * n) * sin(n * PI/5) + centerX;
        y = (100 + 6 * n) * cos(n * PI/5) + centerY;
    }

    return new PVector(x, y);
}