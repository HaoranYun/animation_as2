
//features
import peasy.*;
PeasyCam cam;





int iter;


int dx = 5;

float w = 200;
int num = 60;

float left = -150;
float right = dx*(num-1);
float top = -400;
float bottom = 100;

float initH = 100;


float start,now;
int drawPerframe = 30;
float damp = 0.1;


float[] h = new float[num];
float[] hm = new float[num];

float[] uh = new float[num];
float[] uhm = new float[num];

float g = 2;
Camera camera;

void setup() {
  size(1000, 800, P3D);
  camera = new Camera();
  //cam = new PeasyCam(this, (num/2) * dx, 100, 0, 800); //centered around water
  //cam.setYawRotationMode();
  
  for(int i = 0; i < num; i ++){
    h[i] = initH;


    
    uh[i] = 0;

  }
  
  
  h[1] = 280;
  h[2] = 250;
  
  textSize(32);
  start = millis();
}


void draw() {
  
  iter++;
  
  background(255,255,255);
  now = millis();
  camera.Update( 1.0/frameRate );
  // draw six cubes surrounding the origin (front, back, left, right, top, bottom)
 
  float small_dt = 0.001;
  for (int i = 0; i < drawPerframe; i++){
    updateFluid((now-start)/1000);
  }
  

  drawFluid();
  drawBox();

  start = millis();
  

}

void drawBox(){
  strokeWeight(100);
  point(0,0,-10);
  translate(0, 230, -600);
  
  noFill();
  stroke(0);
  strokeWeight(2);
  pushMatrix();
  translate(left+right/2, -100, -w/2);
  box(right,200,w);
  text("Frame Rate:" + (int)frameRate,-200,-200);
  popMatrix();
  

}

void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

void updateFluid(float dt){
  
  

  //if(iter> 300) return;
  
  //h[0] = h[1];
  //h[num -1] = h[num -2];
  //uh[0] = uh[1];
  //uh[num -1] = uh[num -2];
  //print(dt);
  //dt = 0.002;
  for(int i = 0; i < num-1 ; i ++){
    hm[i] = (h[i] + h[i + 1])/2.0 - (dt/2.0) * (uh[i+1]- uh[i])/dx;
    uhm[i] = (uh[i] + uh[i+1])/2.0 - (dt/2.0)*(
    sq(uh[i+1])/ h[i+1] + 0.5*g*sq(h[i+1])
    -sq(uh[i])/h[i]- 0.5*g* sq(h[i]))/dx;
    
    
    //print((dt/2.0)*(sq(uh[i+1])/ h[i+1] + 0.5*g*sq(h[i+1])
    //-sq(uh[i])/h[i]- 0.5*g* sq(h[i])));

    //println("i = "+i + "  "+ hm[i] + " " +uhm[i]);
  }
  
   for(int i = 0; i < num-2 ; i ++){
     
     h[i+1] -=dt*(uhm[i+1] - uhm[i])/dx;
     uh[i+1] -=dt*(damp*uh[i+1] + 
     sq(uhm[i+1])/hm[i+1]+0.5* g*sq(hm[i+1]) 
     - sq(uhm[i+1])/hm[i]- 0.5*g*sq(hm[i]))/dx;
     //println("full step i= "+i +" "+h[i] + " " +uh[i]);
   }
  
  h[0] = h[1];
  uh[0] = -uh[1];
  h[num-1] = h[num -2];
  uh[num-1] = -uh[num -2];
}


void drawFluid(){
  pushMatrix();
  translate(0, 230, -600);
  float x1,x2;
  PVector v1,v2,n;
  n = new PVector();
  //beginShape(QUAD);
  for(int i = 0; i < num-1; i++){
    x1 = left + i* dx;
    x2 = left + (i + 1) * dx;
    v1 = new PVector (x2, h[i + 1],0).sub(new PVector(x1,h[i],0));
    v2 = new PVector(x1, h[i + 1],-1).sub(new PVector(x1,h[i],0));
    PVector.cross(v1,v2,n);
    
    fill(80,100,200);
    noStroke();
    beginShape(QUAD);
    normal(n.x,n.y,n.z);

    
    vertex(x1,-h[i],0);
    vertex(x2,-h[i +1],0);
    fill(80,100,255);
    vertex(x2,-h[i+1],-w);
    //fill(80,100,200);
    vertex(x1,-h[i],-w);
    
    //fill(80,100,200);
    vertex(x1,-h[i],0);
    vertex(x2,-h[i +1],0);
    fill(80,100,150);
    vertex(x2,0,0);
    vertex(x1,0,0);
    
    fill(80,100,255);
    vertex(x1,-h[i],-w);
    vertex(x2,-h[i +1],-w);
    fill(80,100,200);
    vertex(x2,0,-w);
    vertex(x1,0,-w);
    
    endShape();
    
    
  }
  
  
  beginShape(QUAD);
  vertex(left,-h[0],0);
  vertex(left,0,0);
  vertex(left,0,-w);
  vertex(left,-h[0],-w);

  vertex(left+right,-h[0],0);
  vertex(left+right,0,0);
  vertex(left+right,0,-w);
  vertex(left+right,-h[0],-w);
  
  endShape();
  
  
  popMatrix();
}
