
//Create Window

ArrayList<Thread> Threads;

//Simulation Parameters
float floor = 800;
float gravity = 500;
float radius = 10;
float anchorY = 50;
float restLen = 10;
float mass = 80; //TRY-IT: How does changing mass affect resting length?
float k = 200; //TRY-IT: How does changing k affect resting length?
float kv = 100;

int iter = 0;

float start;
int horizontalNum = 20;
int verticalNum = 15;

PVector G = new PVector(0,500,0);

void setup() {
  size(1000, 800, P3D);
  surface.setTitle("Balls on Spring!");
  start = millis();
  
  

 Threads = new ArrayList<Thread>();
 float startX = 100;
 for (int i = 0; i < horizontalNum; i ++){
   Threads.add(new Thread(startX,0,verticalNum));
   startX +=30;
 }

}




//Draw the scene: one sphere per mass, one line connecting each pair
void draw() {
  iter ++;
  
  background(255,255,255);
  
  

  

  
  float now = millis();
  
  for(int i = 0; i < horizontalNum; i++){
    updateSingleThread(( millis()-start)/80,i);
    drawSingleThread(i);

  }
  
  for (int j = 1; j < horizontalNum; j ++){
    drawHorizontalLink(j);
  }


  start = millis();
  if(iter > 2){
  //noLoop();
  }

 println("Frame rate: " + int(frameRate));
}



void updateSingleThread(float dt, int idx){
  
  PVector stringTop,pos,vel,lastVel, lastForce;
  
  lastForce = new PVector(0,0,0);
  Thread curr = Threads.get(idx);
 
  
  for (int i = curr.len - 1; i > -1; i--){
    
   if(i > 0){
     stringTop = curr.posList.get(i - 1);
     lastVel = curr.velList.get(i - 1);
   }
   else {
     stringTop = new PVector(0,0,0);
     lastVel = new PVector(0,0,0);
   }
  
    pos = curr.posList.get(i);
    vel = curr.velList.get(i);
    
    //println(pos + " " + stringTop);
    
    PVector s = PVector.sub(pos,stringTop);

    float stringLen = sqrt(PVector.dot(s,s));

  
  //Compute (damped) Hooke's law for the spring
   float stringF = -k*(stringLen - restLen);
  
  //Apply force in the direction of the spring
    PVector dir = PVector.div(s,stringLen);

    float projVel = PVector.dot(vel,dir);
    float projLastVel = PVector.dot(lastVel,dir);
    float dampF = -kv*(projVel  - projLastVel);
    
    PVector force = PVector.mult(dir,(stringF + dampF)).sub(lastForce).add(G).mult(0.5);
    
    vel.add(PVector.div(force,mass).mult(dt));
    pos.add(PVector.mult(vel,dt));

    
    float f = stringF + dampF;
    lastForce = PVector.mult(dir,f);
    
  //Collision detection and response
    if (pos.y+radius > floor){
      vel.y *= -.9;
      pos.y = floor - radius;
    }
   
   curr.posList.set(i,pos);
   curr.velList.set(i,vel);
   
  }  
  
}
void drawSingleThread(int idx){
  Thread curr = Threads.get(idx);
  float topX = 0;
  float topY = 0;
  pushMatrix();
  translate(curr.anchor.x,curr.anchor.y);
  for(int i = 0; i < curr.len; i ++){

    PVector pos = curr.posList.get(i);
    line(topX,topY, pos.x,pos.y);
    //translate(pos.x,pos.y);
    //sphere(radius);
    //translate(- pos.x, -pos.y);
    topX = pos.x;
    topY = pos.y;
  }
  popMatrix();

}

void drawHorizontalLink(int idx){
    Thread prev = Threads.get(idx -1);
    Thread curr = Threads.get(idx);
    
    PVector acPrev = prev.anchor;
    PVector acCurr = curr.anchor;
    
    for(int i = 0; i < verticalNum; i++){

      PVector posPrev = PVector.add(acPrev, prev.posList.get(i));
      PVector posCurr = PVector.add(acCurr, curr.posList.get(i));
      line(posPrev.x,posPrev.y,posCurr.x,posCurr.y);
    }
}
