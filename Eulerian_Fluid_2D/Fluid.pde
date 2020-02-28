int to1X(int x, int y) {
  return x + (y * N);
}

class Fluid {
  int size;
  float dt;
  float diff;
  float visc;

  float[] s;
  float[] density;

  float[] Vx;
  float[] Vy;

  float[] Vx0;
  float[] Vy0;

  Fluid(float dt, float diffusion, float viscosity) {

    this.size = N;
    this.dt = dt;
    this.diff = diffusion;
    this.visc = viscosity;

    this.s = new float[N*N];
    this.density = new float[N*N];

    this.Vx = new float[N*N];
    this.Vy = new float[N*N];

    this.Vx0 = new float[N*N];
    this.Vy0 = new float[N*N];
  }

  void step() {
    int N          = this.size;
    float visc     = this.visc;
    float diff     = this.diff;
    float dt       = this.dt;
    float[] Vx      = this.Vx;
    float[] Vy      = this.Vy;
    float[] Vx0     = this.Vx0;
    float[] Vy0     = this.Vy0;
    float[] s       = this.s;
    float[] density = this.density;

    diffuse(1, Vx0, Vx, visc, dt);
    diffuse(2, Vy0, Vy, visc, dt);

    project(Vx0, Vy0, Vx, Vy);

    advect(1, Vx, Vx0, Vx0, Vy0, dt);
    advect(2, Vy, Vy0, Vx0, Vy0, dt);

    project(Vx, Vy, Vx0, Vy0);

    diffuse(0, s, density, diff, dt);
    advect(0, density, s, Vx, Vy, dt);
  }

  void addD(int x, int y, float amount) {
    int index = to1X(x, y);
    this.density[index] += amount;
  }

  void addV(int x, int y, float amountX, float amountY) {
    int index = to1X(x, y);
    this.Vx[index] += amountX;
    this.Vy[index] += amountY;
  }

  void render() {
    colorMode(HSB, 255);
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        float x = i * SCALE;
        float y = j * SCALE;
        float d = this.density[to1X(i, j)];
        fill((d + 50) % 255,0,d);
        noStroke();
        rect(x, y, SCALE, SCALE);
      }
    }
  }
  
  void diffuse(int b, float[] x, float[] x0, float diff, float dt) {
    float a = dt * diff * (N - 2) * (N - 2);
    linear_solve(b, x, x0, a, 1 + 6 * a);
  }

  void linear_solve(int b, float[] x, float[] x0, float a, float c) {
    float cRecip = 1.0 / c;
    for (int k = 0; k < iter; k++) {
      for (int j = 1; j < N - 1; j++) {
        for (int i = 1; i < N - 1; i++) {
          x[to1X(i, j)] =
            (x0[to1X(i, j)]
            + a*(    x[to1X(i+1, j)]
            +x[to1X(i-1, j)]
            +x[to1X(i, j+1)]
            +x[to1X(i, j-1)]
            )) * cRecip;
        }
      }  
      set_boundary(b, x);
    }
  }
  
  void project(float[] velocX, float[] velocY, float[] p, float[] div) {
    for (int j = 1; j < N - 1; j++) {
      for (int i = 1; i < N - 1; i++) {
        div[to1X(i, j)] = -0.5f*(
          velocX[to1X(i+1, j)]
          -velocX[to1X(i-1, j)]
          +velocY[to1X(i, j+1)]
          -velocY[to1X(i, j-1)]
          )/N;
        p[to1X(i, j)] = 0;
      }
    }
  
    set_boundary(0, div); 
    set_boundary(0, p);
    linear_solve(0, p, div, 1, 6);
  
    for (int j = 1; j < N - 1; j++) {
      for (int i = 1; i < N - 1; i++) {
        velocX[to1X(i, j)] -= 0.5f * (  p[to1X(i+1, j)]
          -p[to1X(i-1, j)]) * N;
        velocY[to1X(i, j)] -= 0.5f * (  p[to1X(i, j+1)]
          -p[to1X(i, j-1)]) * N;
      }
    }
    set_boundary(1, velocX);
    set_boundary(2, velocY);
  }
  
  
  void advect(int b, float[] d, float[] d0, float[] velocX, float[] velocY, float dt) {
    float i0, i1, j0, j1;  
    float dtx = dt * (N - 2);
    float dty = dt * (N - 2);  
    float s0, s1, t0, t1;
    float temp1, temp2, x, y;  
    float Nfloat = N;
    float ifloat, jfloat;
    int i, j;
  
    for (j = 1, jfloat = 1; j < N - 1; j++, jfloat++) { 
      for (i = 1, ifloat = 1; i < N - 1; i++, ifloat++) {
        temp1 = dtx * velocX[to1X(i, j)];
        temp2 = dty * velocY[to1X(i, j)];
        x    = ifloat - temp1; 
        y    = jfloat - temp2;
  
        if (x < 0.5f) 
          x = 0.5f; 
        if (x > Nfloat + 0.5f) 
          x = Nfloat + 0.5f; 
        i0 = floor(x); 
        i1 = i0 + 1.0f;
        if (y < 0.5f) 
          y = 0.5f; 
        if (y > Nfloat + 0.5f) 
          y = Nfloat + 0.5f; 
        j0 = floor(y);
        j1 = j0 + 1.0f; 
  
        s1 = x - i0; 
        s0 = 1.0f - s1; 
        t1 = y - j0; 
        t0 = 1.0f - t1;
  
        int i0i = int(i0);
        int i1i = int(i1);
        int j0i = int(j0);
        int j1i = int(j1);
  
        d[to1X(i, j)] = 
          s0 * (t0 * d0[to1X(i0i, j0i)] + t1 * d0[to1X(i0i, j1i)]) +
          s1 * (t0 * d0[to1X(i1i, j0i)] + t1 * d0[to1X(i1i, j1i)]);
      }
    }  
    set_boundary(b, d);
  }
    
  void set_boundary(int b, float[] x) {
    for (int i = 1; i < N - 1; i++) {
      x[to1X(i, 0  )] = b == 2 ? -x[to1X(i, 1  )] : x[to1X(i, 1 )];
      x[to1X(i, N-1)] = b == 2 ? -x[to1X(i, N-2)] : x[to1X(i, N-2)];
    }
    for (int j = 1; j < N - 1; j++) {
      x[to1X(0, j)] = b == 1 ? -x[to1X(1, j)] : x[to1X(1, j)];
      x[to1X(N-1, j)] = b == 1 ? -x[to1X(N-2, j)] : x[to1X(N-2, j)];
    }
  
    x[to1X(0, 0)] = 0.5f * (x[to1X(1, 0)] + x[to1X(0, 1)]);
    x[to1X(0, N-1)] = 0.5f * (x[to1X(1, N-1)] + x[to1X(0, N-2)]);
    x[to1X(N-1, 0)] = 0.5f * (x[to1X(N-2, 0)] + x[to1X(N-1, 1)]);
    x[to1X(N-1, N-1)] = 0.5f * (x[to1X(N-2, N-1)] + x[to1X(N-1, N-2)]);
  }

}
