///*
//  KEYBOARD INPUT OSC
//*/

///**
//Sends keyboard input via OSC
//works with python-processing-osc.py
//*/

//import oscP5.*;  
//import netP5.*;

//// see https://sojamo.de/libraries/oscp5/ for more on OSCP5
//OscP5 oscP5;
//NetAddress myRemoteLocation;
//static final String ip = "127.0.0.1";
//static final int sendPort = 57000;
//static final int receivePort = 57001;

//String keyboardInput = "";
//static final String oscAddress = "/sentiment";

//Spot[] spots; // Declare array
//int counter;
//int num = 50;
//int[] x = new int[num];
//int[] y = new int[num];
//int indexPos = 0;

//void setup() {
//  size(1280, 720);
//  textSize(36);
  
//  /* start oscP5, listening for incoming messages at port 57001 */
//  oscP5 = new OscP5(this, receivePort);
  
//  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
//   * an ip address and a port number. myRemoteLocation is used as parameter in
//   * oscP5.send() when sending osc packets to another computer, device, 
//   * application.
//   */
//  myRemoteLocation = new NetAddress(ip, sendPort);
//  counter = 0;
  
//  int numSpots = 25; // Number of objects
//  int dia = width/numSpots; // Calculate diameter
//  spots = new Spot[numSpots]; // Create array
//  for (int i = 0; i < spots.length; i++) {
//    float x = dia/2 + i*dia;
//    float rate = random(0.1, 2.0);
//    // Create each object
//    spots[i] = new Spot(x, 50, dia, rate);
//  }
//   noStroke();
//}

//void draw() {
//  background(53);
//  text(keyboardInput, 25, 50);
  
//  //spots
//  fill(0, 12);
//  rect(0, 0, width, height);
//  fill(0, 255, 0);//color
//  for (int i=0; i < spots.length; i++) {
//    spots[i].move(); // Move each object
//    spots[i].display(); // Display each object
//  }
  
//  ////dots
//  //x[indexPos] = mouseX;
//  //y[indexPos] = mouseY;
  
//  //fill(255);//color
//  //indexPos = (indexPos + 1)% num;
//  //for (int i = 0; i <num; i++){
//  //  int pos = (indexPos + i) % num;
//  //  float radius = (num-i)/2.0;
//  //  ellipse (x[pos], y[pos], radius, radius);
//  //}
  
//  //Negative
//  fill(255,0,0);//color
//  pushMatrix();
//  translate(width*0.2, height*0.5);
//  rotate(frameCount / 200.0);
//  star(0, 0, 5, 70, 3); 
//  popMatrix();
//}

//class Spot {
//  float x, y;         // X-coordinate, y-coordinate
//  float diameter;     // Diameter of the circle
//  float speed;        // Distance moved each frame
//  int direction = 1;  // Direction of motion (1 is down, -1 is up)

//  // Constructor
//  Spot(float xpos, float ypos, float dia, float sp) {
//    x = xpos;
//    y = ypos;
//    diameter = dia;
//    speed = sp;
//  }

//  void move() {
//    y += speed * direction;
//    //x += speed * -direction;
//    //y += speed * random(-1,1);
//    //x += speed * random(-1,1);
//    if ((y > (height - diameter/2)) || (y < diameter/2) || (x > (width - diameter/2)) || (x < diameter/2)) {
//      direction *= -1;
//    }
//  }

//  void display() {
//    ellipse(x, y, diameter, diameter);
//  }
//}

////negative emotions
//void star(float x, float y, float radius1, float radius2, int npoints) {
//  float angle = TWO_PI / npoints;
//  float halfAngle = angle/2.0;
//  beginShape();
//  for (float a = 0; a < TWO_PI; a += angle) {
//    float sx = x + cos(a) * radius2;
//    float sy = y + sin(a) * radius2;
//    vertex(sx, sy);
//    sx = x + cos(a+halfAngle) * radius1;
//    sy = y + sin(a+halfAngle) * radius1;
//    vertex(sx, sy);
//  }
//  endShape(CLOSE);
//}

//// We'll only be recieving data 
////void keyTyped() {
////  keyboardInput += key;               // get keyboard input
////  if(key == RETURN || key == ENTER) { // if return key is pressed send OSC and clear keyboard input
////    sendOSC(keyboardInput);           // send the OSC message
////    println(" Sending message: " + keyboardInput);
////    keyboardInput = "";
////  }
////}

////void sendOSC(String s) {
////  OscMessage msg = new OscMessage(oscAddress);
////  msg.add(s);
////  /* send the message */
////  oscP5.send(msg, myRemoteLocation);
////}

///* incoming osc message are forwarded to the oscEvent method. */
//void oscEvent(OscMessage theOscMessage) {
//  print("### received an osc message.");
//  print(" addrpattern: " + theOscMessage.addrPattern());
//  println(" typetag: " + theOscMessage.typetag());
  
//  /* check if theOscMessage has the address pattern we are looking for. */
//  if(theOscMessage.checkAddrPattern("/sentiment") == true) {
//    /* check if the typetag is the right one. 
//       "ifs" means integer, float, string respectively
//       we are expecting a two strings in this case, so it's "ss"
//       more info here:
//       https://sojamo.de/libraries/oscp5/examples/oscP5parsing/oscP5parsing.pde
//    */
//    if(theOscMessage.checkTypetag("ss")) {
//      /* parse theOscMessage and extract the values from the osc message arguments. */
//     //positive, neutral, negative sentiments
//      String s = theOscMessage.get(0).stringValue();
//      print(s); 
      
//      // Get sentiments and strength values
//      String[] anac = s.split(",");
//      //int pos = s.get(1);
//      //int neu = s.charAt();
//      //int neg = s.charAt();
     
//      //return;
//      //
//    }  
//  } 
//}
