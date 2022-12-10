// Helper functions for geometry
PVector cart2sph(PVector v) {
    float r = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    float theta = acos(v.z / r);
    float phi = atan2(v.y, v.x);

    return new PVector(r, theta, phi);
}

PVector sph2cart(PVector v) {
    float x = v.x * sin(v.y) * cos(v.z);
    float y = v.x * sin(v.y) * sin(v.z);
    float z = v.x * cos(v.y);

    return new PVector(x, y, z);
}

// Generate a list of points on a sphere
PVector[] genPts3DSphere(int n, float sphereRadius) {
    PVector[] points = new PVector[n];
    float phi = PI * (3 - sqrt(5));
    for (int i = 0; i < n; i++) {
        float theta = phi * i;
        float y = 1 - (i / (float) (n - 1)) * 2;
        float radius = sqrt(1 - y * y);
        float x = cos(theta) * radius;
        float z = sin(theta) * radius;

        points[i] = new PVector(x * sphereRadius, y * sphereRadius, z * sphereRadius);
    }

    return points;
}

PVector[] genPts2DSpiral(int n, float radius) {

    if (n > 0) {
        n += 1;
    }

    PVector[] points = new PVector[n];
    for (int i = 0; i < n; i++) {
        final float a = 2.4 * i;
        final float r = radius * sqrt(i);
        final float x = r * cos(a);
        final float y = r * sin(a);

        points[i] = new PVector(x, y);
    }

    return points;
}

PVector[] genPts2DPackedSpiral(int n, float radius) {
    PVector[] points = new PVector[n];

    float power = 0.07;
    float baseCoeff = 0.3;
    float fanoutOffsetMult = 1.001;
    float r;

    for (int i = 0; i < n; i++) {
        r = -1 * pow(radius, pow(baseCoeff * i, power));
        float x = r * cos(i * fanoutOffsetMult);
        float y = r * sin(i * fanoutOffsetMult);

        points[i] = new PVector(x, y);
    }

    return points;
}