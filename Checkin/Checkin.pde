//Triple Spring (damped) - 1D Motion
//CSCI 5611 Thread Sample Code
// Stephen J. Guy <sjguy@umn.edu>

//Create Window
ArrayList<ArrayList<Float>> ballsX;
ArrayList<ArrayList<Float>> ballsY;
ArrayList<ArrayList<Float>> ballsVx;
ArrayList<ArrayList<Float>> ballsVy;


float start;

void setup() {
  size(800, 500, P3D);
  surface.setTitle("Ball on Spring!");
  start = millis();
  
  ballsX = new ArrayList<ArrayList<Float>>();
  ballsY = new ArrayList<ArrayList<Float>>();
  ballsVx = new ArrayList<ArrayList<Float>>();
  ballsVy = new ArrayList<ArrayList<Float>>();
  
  ArrayList<Float> ballsX1 = new ArrayList<Float>();
  ArrayList<Float> ballsX2 = new ArrayList<Float>();
  ArrayList<Float> ballsX3 = new ArrayList<Float>();
  ballsX.add(ballsX1);
  ballsX1.add(300f);
  ballsX1.add(330f);
  ballsX1.add(360f);
  
  ballsX.add(ballsX2);
  ballsX2.add(600f);
  ballsX2.add(630f);
  ballsX2.add(660f);
  
  ArrayList<Float> ballsY1 = new ArrayList<Float>();
  ArrayList<Float> ballsY2 = new ArrayList<Float>();
  ArrayList<Float> ballsY3 = new ArrayList<Float>();
  ballsY.add(ballsY1);
  ballsY1.add(200f);
  ballsY1.add(250f);
  ballsY1.add(300f);
  
  ballsY.add(ballsY2);
  ballsY2.add(200f);
  ballsY2.add(250f);
  ballsY2.add(300f);
  
  ArrayList<Float> ballsVx1 = new ArrayList<Float>();
  ArrayList<Float> ballsVx2 = new ArrayList<Float>();
  ArrayList<Float> ballsVx3 = new ArrayList<Float>();
  ballsVx.add(ballsVx1);
  ballsVx1.add(0f);
  ballsVx1.add(0f);
  ballsVx1.add(0f);
  
  ballsVx.add(ballsVx2);
  ballsVx2.add(0f);
  ballsVx2.add(0f);
  ballsVx2.add(0f);
  
  ArrayList<Float> ballsVy1 = new ArrayList<Float>();
  ArrayList<Float> ballsVy2 = new ArrayList<Float>();
  ArrayList<Float> ballsVy3 = new ArrayList<Float>();
  ballsVy.add(ballsVy1);
  ballsVy1.add(0f);
  ballsVy1.add(0f);
  ballsVy1.add(0f);
  
  ballsVy.add(ballsVy2);
  ballsVy2.add(0f);
  ballsVy2.add(0f);
  ballsVy2.add(0f);

}

//Simulation Parameters
float floor = 500;
float gravity = 9.8;
float radius = 10;
float anchorY = 50;
float restLen = 40;
float mass = 30; //TRY-IT: How does changing mass affect resting length?
float k = 30; //TRY-IT: How does changing k affect resting length?
float kv = 10;

//Inital positions and velocities of masses




void update(float dt,ArrayList<Float> ballsXi, ArrayList<Float> ballsYi, ArrayList<Float> ballsVxi, ArrayList<Float> ballsVyi, float anchorX){
  //Compute (damped) Hooke's law for each spring
  
 
  float stringTopY, stringTopX, lastVelX, lastVelY;
  float ballY, ballX, velX, velY; //200
  
  float lastForceX = 0;
  float lastForceY = 0;

  

  
  for (int i = 2; i > -1; i--){
    
   if(i != 0){
     stringTopY = ballsYi.get(i - 1);
     stringTopX = ballsXi.get(i - 1);
     lastVelX = ballsVxi.get(i - 1);
     lastVelY = ballsVyi.get(i - 1);
   }
   else {
     stringTopY = anchorY;
     stringTopX = anchorX;
     lastVelX = 0;
     lastVelY = 0;
   }
    
    ballY = ballsYi.get(i); //200
    ballX = ballsXi.get(i); //200
    velY = ballsVyi.get(i);
    velX = ballsVxi.get(i);
    
    float sx = (ballX - stringTopX);
    float sy = (ballY - stringTopY);
    float stringLen = sqrt(sx*sx + sy*sy);
    println(stringLen, " ", restLen);
  
  //Compute (damped) Hooke's law for the spring
    float stringF = -k*(stringLen - restLen);
  
  //Apply force in the direction of the spring
    float dirX = sx/stringLen;
    float dirY = sy/stringLen;
    float dampFX = -kv*(velX - lastVelX);
    float dampFY = -kv*(velY - lastVelY);
    
    
    float forceY = gravity + 0.5*(stringF*dirY + dampFY - lastForceY)/mass;
    float forceX =  0.5*(stringF*dirX + dampFX - lastForceX)/mass;
    
    velX += forceX*dt;
    velY += forceY*dt;
    
    
    ballX += velX*dt;
    ballY += velY*dt;
    
    
    lastForceX = stringF*dirX + dampFX;
    lastForceY = stringF*dirY + dampFY;
    
  
  //Collision detection and response
    if (ballY+radius > floor){
      velY *= -.9;
      ballY = floor - radius;
    }
   
   
   ballsXi.set(i,ballX);
   ballsYi.set(i,ballY);
   ballsVxi.set(i,velX);
   ballsVyi.set(i,velY);
   
  }  
  
 
  
  
}

//Draw the scene: one sphere per mass, one line connecting each pair
void draw() {
  
  
  background(255,255,255);
  
  
  float anchorX = 200;
  
  for(int i = 0; i<2; i++){
    
    update((millis()-start)/1000, ballsX.get(i),ballsY.get(i), ballsVx.get(i), ballsVy.get(i),anchorX); //We're using a fixed, large dt -- this is a bad idea!!
    fill(0,0,0);
    drawChain(ballsX.get(i),ballsY.get(i),anchorX);
    anchorX+= 300;
  }


  start = millis();
  
}

void drawChain(ArrayList<Float> ballsXi,ArrayList<Float> ballsYi,float anchorX){
  float topX = anchorX;
  float topY = anchorY;
  float x,y;
  for(int i = 0; i<3; i++){
    x = ballsXi.get(i);
    y = ballsYi.get(i);
    pushMatrix();
    line(topX,topY,x,y);
    translate(x,y);
    sphere(radius);
    popMatrix();
    topX = x;
    topY = y;
  }

}
