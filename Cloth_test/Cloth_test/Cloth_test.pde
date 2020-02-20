
//features
boolean textured = true;
boolean wind = false;
boolean bend = false;
boolean fixRow = true;

// parameters 
float floor = 800;
float gravity = 500;
float radius = 10;

// tuning parameters 
float restLen = 10;
float stepX = 10; // the initial horizontal distance between springs
float stepY = 10;  // the initial vertical distance between springs
float mass = 20; 
float ks = 500; 
float kd = 20;
PVector G = new PVector(0,-0.01,0);
int drawPerframe = 30;



PImage textureImg;


float start;
float now ;
// the number of springs in horizontal(nx), vertical(ny)
int nx= 30;
int ny =30;

float anchorX = 300;
float anchorY = 100;


int iter;

Spring[][] Springs = new Spring[nx][ny];

void setup() {
  size(1000, 800, P3D);

  

  
  textureImg = loadImage("t2.jpg");
  
  
  for(int i = 0; i < nx; i ++){
    for (int j = 0; j < ny; j ++){
      
      Springs[i][j] = new Spring(300+j*stepX + i * 5, 100, i * stepY);
      Springs[i][j].isLive = true;
    }
  }

  if(fixRow){
    for(int j = 0; j < nx; j++){
      Springs[0][j].fixed = true;
    }
  }
   else{
     Springs[0][0].fixed = true;
     Springs[0][ny-1].fixed = true;
   }

  
  
  start = millis();
}


void draw() {
  
  iter++;
  background(255,255,255);
  now = millis();
  for (int i = 0; i < drawPerframe; i++){
    updateSprings((now-start)/1000);
  }
  
  stroke(155);
  drawStrings();

  start = millis();

}


void updateSprings(float dt){
  
 
  PVector[][] velBuffer = new PVector[nx][ny];
  PVector e;
  float stringLen,v1, v2,f;
  
  
  for(int i = 0; i < nx; i++){
    for (int j = 0; j < ny; j ++){
      velBuffer[i][j] = new PVector(0,0,0);
    }
  }
  
  
  for(int i = 0; i < nx-1; i++){
    for (int j = 0; j < ny; j ++){   
      e = PVector.sub(Springs[i+1][j].pos, Springs[i][j].pos);
      stringLen = sqrt(PVector.dot(e,e));
      e.normalize();
      v1 = PVector.dot(e, Springs[i][j].vel);
      v2 = PVector.dot(e, Springs[i+1][j].vel);
      f = -ks *(restLen - stringLen) - kd * (v1- v2);
      
      velBuffer[i][j].add(PVector.mult(e,f*dt/mass));
      velBuffer[i + 1][j].add(PVector.mult(e,-f*dt/mass));
      
    }
  }
    
    
  for(int i = 0; i < nx; i++){    
    for (int j = 0; j < ny - 1 ; j ++){
      
      e = PVector.sub(Springs[i][j + 1].pos, Springs[i][j].pos);
      stringLen = sqrt(PVector.dot(e,e));
      e.normalize();
      v1 = PVector.dot(e, Springs[i][j].vel);
      v2 = PVector.dot(e, Springs[i][j + 1].vel);
      f = -ks *( restLen - stringLen) - kd * (v1- v2);
 
      velBuffer[i][j].add(PVector.mult(e,f*dt/mass));
      velBuffer[i][j + 1].add(PVector.mult(e,-f*dt/mass));
      
    }
    
  }
  
  
  for(int i = 0; i < nx; i++){
    for (int j = 0; j < ny; j ++){
      velBuffer[i][j].sub(G);
      if(!Springs[i][j].fixed){
      Springs[i][j].vel.add(velBuffer[i][j]);
      Springs[i][j].pos.add(PVector.mult(Springs[i][j].vel,dt));
      }
    }
  }
  
 
}

void drawStrings(){
  PVector pos;
  
  if(textured){
   beginShape(QUAD);
   texture(textureImg);
   noStroke();
    for(int i = 0; i < nx - 1; i++){
      for (int j = 0; j < ny -1; j ++){
        pos = Springs[i][j].pos;
        vertex(pos.x, pos.y, pos.z, textureImg.width*i/nx, textureImg.height*j /ny );
        pos = Springs[i + 1][j ].pos;
        vertex(pos.x, pos.y, pos.z,textureImg.width*(i + 1)/nx, textureImg.height*j /ny);
        pos = Springs[i + 1][j + 1 ].pos;
        vertex(pos.x, pos.y, pos.z,textureImg.width*(i + 1)/nx, textureImg.height*(j + 1) /ny );
        pos = Springs[i][j + 1].pos;
        vertex(pos.x, pos.y, pos.z, textureImg.width*i /nx, textureImg.height*(j + 1) /ny);
      }
     
    }
    
    endShape();
  }
  else{
    
    PVector below, right;
    for(int i = 0; i < nx; i++){
      for (int j = 0; j < ny; j ++){
        pos = Springs[i][j].pos;

        //stroke(abs(pos.x), abs(pos.x), abs(pos.y));
//  top row 
         if(i == nx - 1 && j < ny-1) {
           stroke(155);
           below = Springs[i][j + 1].pos;
           line(pos.x, pos.y, pos.z, below.x, below.y,below.z);
           
         } else if (j == ny-1 && i < nx-1){
           stroke(80);
           right = Springs[i + 1][j].pos;
           line(pos.x, pos.y, pos.z, right.x, right.y,right.z);
           
         } else if (j == ny-1 &&i == nx-1){
           //stroke(1);
           //strokeWeight(10);
           //point(pos.x,pos.y,pos.z);
         }
         else{
           stroke(230);
           below = Springs[i][j + 1].pos;
           right = Springs[i + 1][j].pos;
           line(pos.x, pos.y, pos.z, below.x, below.y,below.z);
           line(pos.x, pos.y, pos.z, right.x, right.y,right.z);
         }
      }
    }
  }
 
}
