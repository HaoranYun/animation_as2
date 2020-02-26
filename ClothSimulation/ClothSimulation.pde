//features
boolean textured = true;
boolean wind = false;
boolean tear = false;
boolean fixRow = true;


// parameters 
float floor = 50;
float radius = 50;
PVector spherePos = new PVector(0, 0, 0);
PVector sphereMove = new PVector(0,0,0);

// tuning parameters 
float restLen = 10;
float stepX = 10; // the initial horizontal distance between springs
float stepY = 10;  // the initial vertical distance between springs
float mass = 20; 
float ks = 600; 
float kd = 500;
PVector G = new PVector(0,0.001,0);
int drawPerframe = 100; //100
float maxLen = 20;
float maxF = 2000;
float cd = 0.0005;

//wind
PVector LW = new PVector(-1,1,0);
PVector RW = new PVector(1,1,0);
PVector FW = new PVector(0,1,1);
PVector BW = new PVector(0,1,-1);
PVector windF = LW;


Camera camera;
PImage textureImg;

// time
float start;
float now ;


// the number of springs in horizontal(nx), vertical(ny)
int nx= 30;
int ny =30;

// the most left-top point of the cloth
float anchorX = -150;
float anchorY = -300;


int iter;

Spring[][] Springs = new Spring[nx][ny];

void setup() {
  size(1000, 800, P3D);

  textSize(32);
  camera = new Camera();
  
  textureImg = loadImage("myTexture.jpg");
  
  
  for(int i = 0; i < nx; i ++){
    for (int j = 0; j < ny; j ++){
      
      Springs[i][j] = new Spring(anchorX+j*stepX, anchorY, i * stepY);

      Springs[i][j].isLive = true;
    }
  }

  if(fixRow){
    for(int j = 0; j < nx; j+= 4){
      Springs[0][j].fixed = true;
    }
  }
 
  start = millis();
}


void draw() {
  
  iter++;
  
  background(255,255,255);
  now = millis();
  camera.Update( 1.0/frameRate );
  for (int i = 0; i < drawPerframe; i++){
    updateSprings(0.01);
    checkCollision();
  }

  translate(0, 200, -800);
  text("FrameRate: " + frameRate,-200,-400);
  stroke(155);
  drawStrings();
  lights();
  drawSphere();

  start = millis();


}


void updateSprings(float dt){
  
  //if(iter > 3) return;

  
  //dt = 0.01;
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
      
      if(Springs[i+1][j].isLive == false) continue;
      
      e = PVector.sub(Springs[i+1][j].pos, Springs[i][j].pos);
      stringLen = e.mag();

      
      e.normalize();
      v1 = PVector.dot(e, Springs[i][j].vel);
      v2 = PVector.dot(e, Springs[i+1][j].vel);
      f = -ks *(restLen - stringLen) - kd * (v1- v2);
      
      if(f > maxF) f = maxF;
      
      
      velBuffer[i][j].add(PVector.mult(e,f*dt/mass));
      velBuffer[i + 1][j].add(PVector.mult(e,-f*dt/mass));
      
    }
  }
    
    
  for(int i = 0; i < nx; i++){    
    for (int j = 0; j < ny - 1 ; j ++){
      
      if(Springs[i][j+1].isLive == false) continue;
      
      e = PVector.sub(Springs[i][j + 1].pos, Springs[i][j].pos);
      stringLen = e.mag();
      
      
      e.normalize();
      v1 = PVector.dot(e, Springs[i][j].vel);
      v2 = PVector.dot(e, Springs[i][j + 1].vel);
      f = -ks *( restLen - stringLen) - kd * (v1- v2);

      if(f > maxF) f = maxF;
      velBuffer[i][j].add(PVector.mult(e,f*dt/mass));
      velBuffer[i][j + 1].add(PVector.mult(e,-f*dt/mass));
      

    }
   
  }
  

  for(int i = 0; i < nx; i++){
    for (int j = 0; j < ny; j ++){

      velBuffer[i][j].add(G);
      if(!Springs[i][j].fixed){
        if(wind && i < nx -1 && j < ny -1 ) {
            applyWind(i,j);
        }
        Springs[i][j].vel.add(velBuffer[i][j]);
        Springs[i][j].pos.add(PVector.mult(Springs[i][j].vel,dt));    
      }     
    }
  }
}

void drawStrings(){
  PVector pos;
  pushMatrix();
  if(textured){
   beginShape(QUAD);
   texture(textureImg);
   noStroke();
    for(int i = 0; i < nx - 1; i++){
      for (int j = 0; j < ny -1; j ++){
        
        if(!Springs[i+1][j].isLive || !Springs[i][j+1].isLive
        || !Springs[i+1][j+1].isLive) continue;
        
        
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
  popMatrix();
}


void drawSphere(){
  pushMatrix();
  noStroke();
  fill(155,100,80);
  translate(spherePos.x,spherePos.y,spherePos.z);
  sphere(radius);
  popMatrix();
  
}


void applyWind(int i, int j){

 PVector n_star,v,pos,pos_r,pos_d, pos_rd, f_aero;
 if(!Springs[i+1][j].isLive|| !Springs[i][j+1].isLive|| !Springs[i+1][j+1].isLive) return;
            pos = Springs[i][j].pos;
            pos_r = Springs[i+1][j].pos;
            pos_d = Springs[i][j+1].pos;

            n_star = PVector.sub(pos_r,pos).cross(PVector.sub(pos_d,pos));
            //PVector.cross(PVector.sub(pos_r,pos),PVector.sub(pos_d,pos),n_star);
            v = new PVector(0,0,0);
            v.add(Springs[i][j].vel).add(Springs[i+1][j].vel).add(Springs[i][j+1].vel);
            v.div(3).sub(windF);
            
  
            f_aero =  PVector.mult(n_star, (v.mag()*PVector.dot(v, n_star))/(2*n_star.mag()));
            f_aero.mult((-0.5)*cd).div(3);
            

            Springs[i][j].vel.add(f_aero);
            Springs[i+1][j].vel.add(f_aero);
            Springs[i][j+1].vel.add(f_aero);
  
            pos_rd = Springs[i+1][j+1].pos;
            PVector.cross(PVector.sub(pos_d,pos_r),PVector.sub(pos_rd,pos_r),n_star);
            v = new PVector(0,0,0);
            v.add(Springs[i+1][j].vel).add(Springs[i][j+1].vel).add(Springs[i+1][j+1].vel);
            v.div(3).sub(windF);

            f_aero =  PVector.mult(n_star, (v.mag()*PVector.dot(v, n_star))/(2*n_star.mag()));
            f_aero.mult((-0.5)*cd).div(3);

            Springs[i+1][j].vel.add(f_aero);
            Springs[i][j+1].vel.add(f_aero);
            Springs[i+1][j+1].vel.add(f_aero);
}



void mouseDragged() {
  if(mouseButton == LEFT){
    float dx = mouseX - pmouseX;
    float dy = mouseY - pmouseY;
    spherePos.x +=dx;
    spherePos.y +=dy;
  }
  else{
    
    for(int i = 0; i < nx; i++){
      for(int j = 0; j < ny; j++){
        PVector pos = Springs[i][j].pos;
        if(tear){
          if( abs(mouseX- 470-pos.x)<10 && abs(mouseY- 600-pos.y)<10){
            Springs[i][j].isLive = false;
            println("tear!");
          }
        }
        else{
          Springs[i][j].vel.add(new PVector(0.01*(mouseX - pmouseX), 0.01*(mouseY-pmouseY), 0));
        }
      }
    }
  }
  
}

void checkCollision(){
  float d_mag;
  PVector d,pos,norm,bounce;
   for(int i = 0; i < nx; i++)
    {
      for (int j = 0; j < ny; j ++)
      {
        if(Springs[i][j].fixed) continue;
        pos = Springs[i][j].pos;
        d = PVector.sub(pos,spherePos);
        d_mag = d.mag();

        if (d_mag < radius +1 ){
          d.normalize();
          bounce = PVector.mult(d,Springs[i][j].vel.dot(d));
          bounce.mult(1.5);
          Springs[i][j].vel.sub(bounce);
          Springs[i][j].pos.add(PVector.mult(d,  (50 - d_mag + 1 )));
        }
        
          if (pos.y + 1 > floor){
            Springs[i][j].vel= new PVector(0,0,0);
            Springs[i][j].pos.y = floor;
          }
      }
    }
}


void keyPressed()
{
  if(!tear)
  camera.HandleKeyPressed();
  
  if(key == 'l') windF = LW;
  if(key == 'r') windF = RW;
  if(key == 'f') windF = FW;
  if(key == 'b') windF = BW;
  if(keyCode == 32) wind = !wind;
  if(key == 't') tear = !tear;
}

void keyReleased()
{
  if(!tear)
  camera.HandleKeyReleased();
}
