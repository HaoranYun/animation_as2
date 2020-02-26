class Spring{
  
  PVector pos;
  PVector vel;
  boolean isLive;
  boolean fixed;
  
  Spring(float X, float Y, float Z){
    pos = new PVector(X,Y,Z);
    vel = new PVector(0,0,0);
    isLive = true;
  }

}
