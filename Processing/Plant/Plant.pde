//// A Plant class

//class Plant {
//  float x,y;
//  float light;
//  String touch;
  
//  boolean over = false;
  
//  // Create  the Plant
//  Plant(float x_, float y_, float l, String t) {
//    x = x_;
//    y = y_;
//    light= l;
//    touch = t;
//  }
  
//  // CHecking if mouse is over the Plant
//  void rollover(float px, float py) {
//    float d = dist(px,py,x,y);
//    if (d < light/2) {
//      over = true; 
//    } else {
//      over = false;
//    }
//  }
  
//  // Display the Plant
//  void display() {
//    stroke(0);
//    strokeWeight(2);
//    noFill();
//    ellipse(x,y,light,light);
//    if (over) {
//      fill(0);
//      textAlign(CENTER);
//      text(touch,x,y+light/2+20);
//    }
//  }
//}
