
//Create Window

ArrayList<Thread> Threads;

//Simulation Parameters
float floor = 800;
float gravity = 500;
float radius = 10;
float anchorY = 50;
float restLen = 60;
float mass = 50; //TRY-IT: How does changing mass affect resting length?
float k = 200; //TRY-IT: How does changing k affect resting length?
float kv = 100;

int iter = 0;

float start;

void setup() {
  size(1000, 800, P3D);
  surface.setTitle("Ball on Spring!");
  start = millis();
  
  

 Threads = new ArrayList<Thread>();
 Threads.add(new Thread(200,0,6));
 Threads.add(new Thread(800,0,5));
 Threads.add(new Thread(500,0,3));
}




//Draw the scene: one sphere per mass, one line connecting each pair
void draw() {
  iter ++;
  
  background(255,255,255);
  
  
  float anchorX = 200;
  
  int numT =2;
  
  float now = millis();
  for(int i = 0; i < 3; i++){
    updateSingleThread((now-start)/80,i);
    drawSingleThread(i);
  }

  start = millis();
  if(iter > 2){
  //noLoop();
  }
  
  if(keyPressed  && keyCode == UP){
    stop();
  }
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
     stringTop = new PVector(0,0);
     lastVel = new PVector(0,0);
   }
  
    pos = curr.posList.get(i);
    vel = curr.velList.get(i);
    
    println(pos + " " + stringTop);
    
    PVector s = PVector.sub(pos,stringTop);

    float stringLen = sqrt(s.x*s.x + s.y*s.y);

  
  //Compute (damped) Hooke's law for the spring
   float stringF = -k*(stringLen - restLen);
  
  //Apply force in the direction of the spring
    PVector dir = PVector.div(s,stringLen);

    float projVel = PVector.dot(vel,dir);
    float projLastVel = PVector.dot(lastVel,dir);
    float dampF = -kv*(projVel  - projLastVel);
    
    
    float forceY = 0.5* ((stringF + dampF)* dir.y - lastForce.y);
    float forceX =  0.5* ((stringF + dampF) * dir.x - lastForce.x);

    vel.x += (forceX/mass)*dt;
    vel.y += ((forceY + gravity)/mass)*dt;
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
    
    
    float f = stringF + dampF;
    lastForce = new PVector(f* dir.x, f* dir.y );
    
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
    translate(pos.x,pos.y);
    sphere(radius);
    translate(- pos.x, -pos.y);
    topX = pos.x;
    topY = pos.y;
  }
  popMatrix();

}
