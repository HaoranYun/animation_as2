class Thread{
  
  ArrayList<PVector> posList;
  ArrayList<PVector> velList;
  PVector anchor;
  int len;
  Thread(float X, float Y, int l){
    posList = new ArrayList<PVector>();
    velList = new ArrayList<PVector> ();
    anchor = new PVector(X,Y,0);
    len = l;
    initialize();
  }
  
  void initialize(){
    float offsetX = 30;
    for(int i = 0; i < len; i ++){
      velList.add(new PVector(0,0,0));
      posList.add(new PVector(i * 10 + 50,i * 10 + 100,0));
    }
  }
  
}
