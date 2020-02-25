
//features
int drawPerframe = 10;
float damp = 0.1;
float start;
float now ;

boolean rain = false;
int rainDropNum = 1;



int iter;


int dx = 5;
int dy = 5;

float w = 500;
int num = 100;

float left = -250;
float right = dx*(num-1);
float top = -400;
float bottom = 100;

float initH = 200;



float h[][] = new float[num][num];
float hm_x[][] = new float[num][num];
float hm_y[][] = new float[num][num];

float uh[][] = new float[num][num];
float uhm_x[][] = new float[num][num];
float uhm_y[][] = new float[num][num];

float vh[][] = new float[num+1][num];
float vhm_x[][] = new float[num][num];
float vhm_y[][] = new float[num][num];





float g = 1;
Camera camera;

void setup() {
  size(1000, 800, P3D);
  camera = new Camera();
  
  for(int i = 0; i < num; i ++){
    for(int j = 0; j < num; j ++){
      h[i][j] = initH;
      hm_x[i][j] = 0;
      hm_y[i][j] = 0;
      uh[i][j] = 0;
      uhm_x[i][j] = 0;
      uhm_y[i][j] = 0;
      vh[i][j] = 0;
      vhm_x[i][j] = 0;
      vhm_y[i][j] = 0;
      
    }
  }
  
  textSize(32);
  //h[95][95] = 150;
  start = millis();

}


void draw() {
  
  iter++;
  lights();
  println(frameRate);
  background(255,255,255);
  now = millis();
  camera.Update( 1.0/frameRate );
  
  // draw six cubes surrounding the origin (front, back, left, right, top, bottom)
 
  for (int i = 0; i < drawPerframe; i++){
    updateFluid((now-start)/1000);
  }
  
  if(rain) updateRain();
  
  //if(iter%600 == 0) h[95][95] = 150;
  translate(0, 100, -400);
  drawFluid();
  drawBox();

  start = millis();
  

}

void drawBox(){

  
  noFill();
  stroke(0);
  strokeWeight(2);
  pushMatrix();
  
 
  
  translate(left+right+dx/2, -250, w/2);
  box(right,200,w);
  text("Frame Rate:" + (int)frameRate,-100,-100);

  popMatrix();
  

}

void keyPressed()
{
  camera.HandleKeyPressed();
  
  if(key == 'r'){
    rain = !rain;
  }
  
  if(key == '1'){
    rainDropNum =1;
  }
  
  if(key == '3'){
    rainDropNum =3;
  }
  
  if(key == '5'){
    rainDropNum =5;
  }
}

void keyReleased()
{
  camera.HandleKeyReleased();
}


void updateRain(){
  
  for(int i = 0; i < rainDropNum; i ++){
    int x = (int)random(0,num);
    int y = (int)random(0,num);
    h[x][y] = random(100,initH);
  }
  rain = false;
}




void updateFluid(float dt){
  
  

  //if(iter> 1000) return;
  
  dt = 0.02;
  
  for(int i = 0; i < num - 1 ; i ++){
    for(int j = 0; j < num - 1; j ++){
      hm_x[i][j] = (h[i][j+ 1] + h[i + 1][j+ 1])/2.0 - (dt/2.0) * (uh[i+1][j+ 1]- uh[i][j+ 1])/dx;
      
      uhm_x[i][j] = (uh[i][j+ 1] + uh[i+1][j+ 1])/2.0 - (dt/2.0)*(
      sq(uh[i+1][j+ 1])/ h[i+1][j+ 1] + 0.5*g*sq(h[i+1][j+ 1])
      -sq(uh[i][j+ 1])/h[i][j+ 1]- 0.5*g* sq(h[i][j+ 1]))/dx;

      
      
      uhm_y[i][j] = (vh[i][j+ 1] + vh[i+1][j+ 1])/2.0 - (dt/2.0)*(
      (uh[i+1][j+1]*vh[i+1][j+1])/h[i+1][j+1] 
      -(uh[i][j+1]*vh[i][j+1])/h[i][j+1])/dx;
      
    }
  }
  
  for(int i = 0; i < num - 1 ; i ++){
    for(int j = 0; j < num - 1; j ++){
      hm_y[i][j] = (h[i+ 1][j] + h[i+ 1 ][j + 1])/2.0 - (dt/2.0) * (vh[i+ 1][j + 1]- vh[i+ 1][j])/dy;
      
      
      vhm_y[i][j] = (vh[i+ 1][j] + vh[i+ 1][j + 1])/2.0 - (dt/2.0)*(
      sq(vh[i+ 1][j + 1])/ h[i+ 1][j + 1] + 0.5*g*sq(h[i+ 1][j+1])
      -sq(vh[i+ 1][j])/h[i+ 1][j]- 0.5*g* sq(h[i+ 1][j]))/dy;
      
      vhm_x[i][j] = (uh[i+1][j] + uh[i+1][j+1])/2.0 - (dt/2.0)*(
      (uh[i+1][j+1]*vh[i+1][j+1])/h[i+1][j+1] 
      -(uh[i+1][j]*vh[i+1][j])/h[i+1][j])/dy ;
            
    }
  } 
  
  for(int i = 0; i < num - 2; i ++){
    for(int j = 0; j < num - 2; j ++){
      
      h[i+1][j+1] -= (dt* ((uhm_x[i+1][j] - uhm_x[i][j])/dx + (vhm_y[i][j+1] - vhm_y[i][j])/dy ));
      
      
      uh[i+1][j+1] -= dt* (damp*uh[i+1][j+1] + 
      (sq(uhm_x[i+1][j])/hm_x[i+1][j] + 0.5* g*sq(hm_x[i+1][j])
      -sq(uhm_x[i][j])/hm_x[i][j] - 0.5* g*sq(hm_x[i][j]))/dx
      +((vhm_x[i][j+1]*vhm_y[i][j+1])/hm_y[i][j+1] 
      -(vhm_x[i][j]*vhm_y[i][j])/hm_y[i][j])/dy);
      
      
      
      vh[i+1][j+1] -= dt* (damp*vh[i+1][j+1] + 
      ((uhm_x[i+1][j]*uhm_y[i+1][j])/hm_x[i+1][j] 
      -(uhm_x[i][j]*uhm_y[i][j])/hm_x[i][j])/dx
      +(sq(vhm_y[i][j+1])/hm_y[i][j+1] + 0.5* g*sq(hm_y[i][j+1])
      -sq(vhm_y[i][j])/hm_y[i][j] - 0.5* g*sq(hm_y[i][j]))/dy);
      
    }
  }

  
  for(int i = 0; i< num; i++){
    
   h[i][0] = h[i][1];
   h[0][i] = h[1][i];
   h[i][num -1 ] = h[i][num-2];
   h[num - 1][i] = h[num-2][i];
   
   uh[i][0] = uh[i][1];
   uh[0][i] = -uh[1][i];
   uh[i][num -1 ] = uh[i][num-2];
   uh[num - 1][i] = -uh[num-2][i];
   
   vh[i][0] =-vh[i][1];
   vh[0][i] = vh[1][i];
   vh[i][num -1 ] = -vh[i][num-2];
   vh[num - 1][i] = vh[num-2][i];
   
  }
  
  
}


void drawFluid(){
  noStroke();
  translate(-250, 400, -800);
  //fill(0);
  fill(80 ,100, 200,255);
  for(int i = 0; i < num - 1; i ++){
    beginShape(TRIANGLE_STRIP);
    for(int j = 0; j < num - 1; j ++){
      vertex(i*dx, -h[i][j], j * dy);
      vertex((i+1)*dx, -h[i+1][j+1], (j+1) * dy);
    }
    endShape();
  }
  
  

}
