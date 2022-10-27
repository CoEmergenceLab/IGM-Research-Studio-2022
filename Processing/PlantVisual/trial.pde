///*
//  MAIN
//*/

//import processing.serial.*;
//import oscP5.*;
//import netP5.*;
//import java.util.Random;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Scanner;

//Serial plantPort;
//String val;

////A JSON object
//JSONObject json;
//JSONObject jsonSenti;

////see https://sojamo.de/libraries/oscp5/ for more on OSCP5
//OscP5 oscP5;
//NetAddress myRemoteLocation;
//static final String ip = "127.0.0.1";
//static final int receivePort = 57000;
//static final String oscAddress = "/sentiment";

//float moisture;
//float light;
//int touch;

////Moisture
//Drops d[];
//float yoff = 0.0;

////Light
//Glow g[];
//float intensity;
//int glowCount;

////Touch
//int prev;
//ArrayList<Shape> shapes;
//PShape smear;
//int loaded;

////Text Log
//StringList textLog;
//int count;

////Sentiment values
//float circles;
//float blocks;
//float stars;

////Positive - Circles
//float spring = 0.01;
//Circle[] circle = new Circle[int(circles)];

////Neutral - Blocks
//float springB = 0.01;
//Block[] block = new Block[int(blocks)];

////Negative - Stars
//float springS = 0.01;
//Star[] star = new Star[int(stars)];
////ArrayList star;

////Keeping track of all data coming in for "end-of-day" printout
//ArrayList<int[]> compA;//All data from Arduino
//ArrayList<Integer> compS; //All data from Sentiment Analysis
//int read;

//void setup() {
//  //size(1000, 800);
//  //1920X1080p
//  fullScreen(P2D);
//  smooth();

//  //Connect to serial port
//  println(Serial.list()); //This may need to be changed depending on the computer used!!!!!
//  plantPort = new Serial(this, Serial.list()[0], 9600);

//  textLog = new StringList();
//  count=0;

//  glowCount = 0;
  
//  loaded = 0;

//  /* start oscP5, listening for incoming messages at port 57001 */
//  oscP5 = new OscP5(this, receivePort);

//  //Moisture
//  //Text and data 1-100
//  //stroke(255);
//  fill(255);
//  textSize(24);
  
//   //text("HERE", width*0.2, height*0.2);
//  //for(int i=0; i<11; i++) {
//  //  //rect(0, height-(i*10), 530, 430);
//  //  text("HERE" + i*10, width*0.2, height-height*(i*10));
//  //  println("INSIDE");
//  //}
  
//  d = new Drops[500];
//  for (int i=0; i<500; i++) {
//    d[i] = new Drops();
//  }

//  //Light
//  g = new Glow[16];

//  //Touch
//  prev = 0;
//  shapes = new ArrayList<Shape>();
//  smear = loadShape("smear.svg");

//  fill(255);
//  textSize(24);
//  text("Number of Times Touched: 0", width*0.8, height*0.05);
  
//  //stars
//  //star = new ArrayList();
  
//  //Compile data
//  compA = new ArrayList<int[]>();
//  compS = new ArrayList<>();
//  read = 0;
//}//setup

//void draw() {
//  background(0);

//  if(plantPort.available() > 0){
//    val = plantPort.readStringUntil('\n');
//    //println(val);
//    if(val != null){
//       loadData();
//    }
//  }//plantPort

//  noStroke();
//  fill(255);
//  textSize(24);  

//  text("100", width*0.01, height*0.01+10);
//  rect(0, height*0.01-5, 15, 2);
//  text("90", width*0.01, height*0.1+10);
//  rect(0, height*0.1, 15, 2);
//  text("80", width*0.01, height*0.2+10);
//  rect(0, height*0.2, 15, 2);
//  text("70", width*0.01, height*0.3+10);
//  rect(0, height*0.3, 15, 2);
//  text("60", width*0.01, height*0.4+10);
//  rect(0, height*0.4, 15, 2);
//  text("50", width*0.01, height*0.5+10);
//  rect(0, height*0.5, 15, 2);
//  text("40", width*0.01, height*0.6+10);
//  rect(0, height*0.6, 15, 2);
//  text("30", width*0.01, height*0.7+10);
//  rect(0, height*0.7, 15, 2);
//  text("20", width*0.01, height*0.8+10);
//  rect(0, height*0.8, 15, 2);
//  text("10", width*0.01, height*0.9+10);
//  rect(0, height*0.9, 15, 2);
//  text("0", width*0.01, height-4);
//  rect(0, height-5, 15, 2);

//  ///Draw Text Log
//  // Borderbox
//  stroke(255);
//  fill(0);
//  rect(width*.8-20, height*.75-80, 530, 430);

//  //Text
//  textSize(30);
//  fill(255);
//  text("Text Log", width*.8, height*.75-40);

//  //Messages
//  if (count>0) {
//    textSize(24);
//    fill(255, 180);

//    for (int i = 0; i < count; i++) {
//      String item = textLog.get(i);
//      if (textLog.size() > 11) {
//        textLog.remove(0);
//        count -= 1;
//      }
//      if (item.length() <= 70) {
//         //if(item.length() > 25){
//        //  char[] c = item.toCharArray();
//        //  if(item.length()>50){
//        //    text(item, width*.8, height*.75+(i*30));
//        //  }else{
//            text(item, width*.8, height*.75+(i*30));
//            touch=1;
//        //  }
//      } else {
//        println("Too Long, Try Again.");
//      }
//    }//for count>0
//  }//if count

//  //Moisture - Draw rain drops
//  fill(0, 50);
//  rect(0, 0, width, height);

//  for (int i=0; i<500; i++) {
//     //d[i] = new Drops();
//    if (d[i].y>d[i].endPos) {
//      //println("End rain: " + d[i]);
//      d[i].end();
//    } else {
//      d[i].display();
//      //println("Display rain: " + d[i]);
//    }
//  }//for
//  fill(255);

//  //Wave
//  beginShape();
//  float xoff = 0;       // 2D Noise
//  // Iterate over horizontal pixels
//  for (float x = 0; x <= width; x += 8) {
//    // Calculate a y value according to noise, map to
//    float range = (height*(100-moisture)/100);
//    float y = map(noise(xoff, yoff), 0, 1, range-100, range); // Option #1: 2D Noise
//    stroke(0, 0, 255);
//    strokeWeight(4);
//    //fill(40,80,245);
//    noFill();
//    vertex(x, y);  //Set the vertex
//    xoff += 0.02;  //Increment x dimension for noise
//  }//for
//  //Increment y dimension for noise
//  yoff += 0.01;
//  vertex(width, height);
//  vertex(0, height);
//  endShape(CLOSE);

//  //Light - Draw flashing/glowing and slowly fading light
//  for (int i=0; i<16; i++) {
//    g[i] = new Glow(random(width), random(height), random(1));
//    glowCount+=1;
//    //println(g[i]);
//    g[i].display();
//  }//for

//  //Touch
//  //touch = 2;//test
//  fill(255);
//  textSize(24);

//  text("Number of Times Touched: " + touch, width*0.8, height*0.05);

//  //Touch Text - getting smear svg to stay in place when they are created based on number of times touched
//  if (touch>0 ){
//    //Create a new shape list when the touch is increased
//    if(touch != prev) {

//      //Smear s = new Smear(random(width), random(height), 100, 50);
//      //shape.add(smear);
//  //ArrayList<Shape> shapes;
//  //shapes = new ArrayList<Shape>();
//      //Shape s = new Shape;
//    //{smear, random(width), random(height), 100, 50};
//      //shape.add(s);
//      prev = touch;
//      text("Number of Times Touched: " + touch, width*0.8, height*0.05);
//    }
    
//    //Get and draw new
//    //for(int i=0; i<shapes.size(); i++){
//    //  //Get values from each list in arraylist
//    //  //shape(shape.get(i)[0], shape.get(i)[1], shape.get(i)[2], shape.get(i)[3], shape.get(i)[4]);
//    //  //shapes.display();

      
//    //  //shape(temp.get(i), random(width), random(height), 100, 50);
//    //}
    
//      ////Display each smear
//      //for (Shape s : touch) {
//      //  s.display();
//      //}
    
    
//  }//touch

//  //Positive Emotion
//  if (circle != null) {
//    for (Circle c : circle) {
//      c.collide();
//      c.move();
//      c.display();
//    }
//  }

//  //Neutral Emotion
//  if (block != null) {
//    for (Block b : block) {
//      b.collide();
//      b.move();
//      b.display();
//    }
//  }

//  //Negative Emotion
//  if (star != null) {
//    for (Star s : star) {
//      s.display();
//      s.move();
//    }
//  }

//  //Check if messaging conditions are met
//  for(int i=0; i<loaded; i++){
//    //for(int j=0; j<3, j++) {
//      //Moisture
//      if(compA.get(i)[0] > 5){
      
//        print();
//      }
//    //}
//  }
//}//draw

//// Load JSON file
//void loadData() {
//  //parse JsonObject
//  json = parseJSONObject(val);

//  //Get and print values
//  moisture = json.getFloat("moisture");
//  //println("Moisture Level: " + moisture);
//  light = json.getFloat("light");
//  //println("Light Intensity: " + light);
//  ////values mostly in the range of 200-1000
//  touch = json.getInt("touch");
//  //println("Number of Times Touched: " + touch);  //Touch counter = number of smears

//  //Light Intensity
//  if (light<=333) {  //Low light
//    intensity = 10;
//  } else if (light>666) {  //Bright light
//    intensity = 50;
//  } else {   //Normal light
//    intensity = 30;
//  }//light
  
//  //A
//  if(moisture > 70){  //High moisture
//    if (light<333){  //Low light
//      compA.add(new int[]{1, -1}); 
//    } else if (light>666){  //High light
//      compA.add(new int[]{1, 1}); 
//    } 
//  }else if(moisture<30){  //Low moisture
//    if (light<=333) {  //Low light
//      compA.add(new int[]{-1, -1}); 
//    } else if (light>666){  //High light
//      compA.add(new int[]{-1, 1});
//    } 
//  }
  
//  //Touch
//  loaded += 1;
//}//loadData

///* incoming osc message are forwarded to the oscEvent method. */
//void oscEvent(OscMessage theOscMessage) {
//    print("### received an osc message.");
//    print(" addrpattern: " + theOscMessage.addrPattern());
//    println(" typetag: " + theOscMessage.typetag());
  
//    /* check if theOscMessage has the address pattern we are looking for. */
//    if (theOscMessage.checkAddrPattern("/sentiment") == true) {
//      /* check if the typetag is the right one.
//       "ifs" means integer, float, string respectively
//       https://sojamo.de/libraries/oscp5/examples/oscP5parsing/oscP5parsing.pde
//       */
//      if (theOscMessage.checkTypetag("s")) {
//        // parse theOscMessage and extract the values from the osc message arguments.
//        String s = theOscMessage.get(0).stringValue();
//        println(s);
  
//        //split string into values
//        jsonSenti = parseJSONObject(s);
//        println(jsonSenti);
  
//        //Getting positive, neutral, negative sentiments
//        String pos = jsonSenti.getString("POS");
//        String neu = jsonSenti.getString("NEU");
//        String neg = jsonSenti.getString("NEG");
  
//        //Parse strings to float
//        circles = Float.parseFloat(pos)*100;
//        blocks = Float.parseFloat(neu)*100;
//        stars = Float.parseFloat(neg)*100;
        
//        println("C: " + circles + " S: " + stars);
//        //Test
//        //circles = 70;
//        //blocks = 20;
//        //stars = 10;
  
//        //Add read data to compile arrayList
//       if(circles>60 && stars<15){  
//            compS.add(int(1)); 
//        }
        
//        if(circles<15 && stars>60){  
//            compS.add(-1); 
//        }
      
//        read += 0;
  
//        //Positive
//        circle = new Circle[int(circles)];
//        for (int i=0; i< circles - 1; i++) {
//          circle[i] = new Circle(random(width), random(height), random(30, 70), i, circle);
//        }
//        fill(255, 255, 0, 204);
  
//        //Neutral
//        block = new Block[int(blocks)];
//        for (int i=0; i< blocks - 1; i++) {
//          block[i] = new Block(random(width), random(height), random(30, 70), i, block);
//        }
//        fill(0, 255, 0, 204);
  
//        //Negative
//        star = new Star[int(stars)];
//        fill(255, 0, 0, 204);
//        for (int i=0; i< stars - 1; i++) {
//          float num = random(10, 20);
//          star[i] = new Star(random(width), random(height), num, num+65, 3);
//        }
//        fill(255);
        
//        //Text entered
//        String input = jsonSenti.getString("input");
  
//        //Add new input to textlog
//        textLog.append(input);
//        count += 1;
  
//        return;
//      }  //check tag
//    } //check pattern
//}//osc

////Moisture - Drops Class
//class Drops {
//  float x, y, speed;
//  float ellipseX, ellipseY, endPos;

//  Drops() {
//    init();
//  }//Drops Constructor

//  void init() {
//    x = random(width);
//    y = random(-300, 0);
//    speed = random (1, 4) * 2;
//    ellipseX  = 0;
//    ellipseY  = 0;
//    //println("Moisture: " + moisture);
//    endPos = (height*((100-moisture)/100))-100+random(250);
//  }//init

//  //Change raining speed based on Moisture data
//  void update() {
//    //Rain faster when 70% moisture
//    if (moisture>=66) {
//      y+=speed;
//    } else if (moisture<=33) {
//      y+=speed;
//    } else {
//      y+=speed;
//    }
//  }//update

//  void display() {
//    fill(0, 0, 255);
//    noStroke();
//    rect(x, y, 2, 15);
//    update();
//  }//display

//  //Remove raindrop when it touches the surface
//  void end() {
//    stroke(0, 0, 255);
//    noFill();
//    ellipse(x, y, ellipseX, ellipseY);

//    ellipseX += speed*0.5;
//    ellipseY += speed*0.2;

//    if (ellipseX>30) {
//      init();
//    }
//  }//end
//}//Drops

////Light - Glow
//class Glow {
//  PVector loc;
//  boolean glowing;

//  Glow(float x, float y, float gl) {
//    loc = new PVector(x, y);
//    //println("G: " + gl);
//    if (gl==0) {
//      glowing = false;
//    } else {
//      glowing = true;
//    }
//  }//Glow Contruct

//  void init() {
//    glowCount=0;
//  }//init

//  void display() {
//    if (glowing) {
//      float glowRadius = intensity + 10 * sin(frameCount*(intensity)/(2*frameRate)*TWO_PI);
//      strokeWeight(2);
//      fill(255, 0);
//      for (int i = 2; i < glowRadius; i++) {
//        stroke(255, 255.0*(1-i/glowRadius));
//        ellipse(loc.x, loc.y, i, i);
//      }
//    }
//  }//Display

//  void end() {
//    noFill();
//    if (glowCount>60) {
//      init();
//    }
//  }//end
//}//Glow

////Touch
//class Shape{
//  float x,y,w,h;
  
//  Shape(float xin, float yin, float win, float hin){
//    x = xin;
//    y = yin;
//    w = win;
//    h = hin;
//  }//Smear Constructor
  
//  void display(){
//    //shape(pshape name, x, y, width, height)
//    shape(smear,x,y,w,h);
//  }
//}//Shape

////Positive Emotions Visuals
//class Circle {
//  float x, y, d, r;
//  float vx, vy;
//  int id;
//  Circle[] others;

//  Circle(float xin, float yin, float diameter, int idin, Circle[] oin) {
//    x = xin;
//    y = yin;
//    d = diameter;
//    r = d/2;
//    id =idin;
//    others = oin;
    
//    vy += random(-2,2);
//    vx += random(-2,2);
//  }//Circle Construct

//  void collide() {
//    for (int i=id+1; i<others.length - 1; i++) {
//      float dx = others[i].x - x;
//      float dy = others[i].y - y;
//      float distance = sqrt(dx*dx + dy*dy);
//      float minDist = others[i].r + r;
//      if (distance < minDist) {
//        float angle = atan2(dy, dx);
//        float targetX = x + cos(angle) * minDist;
//        float targetY = y + sin(angle) * minDist;
//        float ax = (targetX - others[i].x) * spring;
//        float ay = (targetY - others[i].y) * spring;
//        vx -= ax;
//        vy -= ay;
//        others[i].vx += ax;
//        others[i].vy += ay;
//      }
//      //if (x<=0) {
//      //  float ax = 0.05 * spring;
//      //  vx += ax;
//      //}
//      //if (x>=width) {
//      //  float ax = 0.05 * spring;
//      //  vx -= ax;
//      //}
//      //if (y<=0) {
//      //  float ay = 0.05 * spring;
//      //  vy += ay;
//      //}
//      //if (y>=height) {
//      //  float ay = 0.05 * spring;
//      //  vy -= ay;
//      //}
      
//      //Slowly bounce off wall
//      if (x<d+1) {
//        float ax = 0.05 * spring;
//        vx += ax;
//      }
//      if (x>width-d-1) {
//        float ax = 0.05 * spring;
//        vx -= ax;
//      }
//      if (y<d+1) {
//        float ay = 0.05 * spring;
//        vy += ay;
//      }
//      if (y>height-d-1) {
//        float ay = 0.05 * spring;
//        vy -= ay;
//      }
//    }//for
//  }//collide

//  void move() {
//    x += vx;
//    y += vy;
//    if (x + r > width) {
//      x = width - r;
//    } else if (x - r < 0) {
//      x = r;
//    }
//    if (y + r > height) {
//      y = height - r;
//    } else if (y - r < 0) {
//      y = r;
//    }
//  }//move

//  void display() {
//    fill(255,255,0);
//    stroke(255,255,0);
//    ellipse(x, y, d, d);
//  }//display
//}//Circle

////Neutral Emotions Visuals
//class Block {
//  float x, y, d, r;
//  float vx, vy;
//  int id;
//  Block[] others;

//  Block(float xin, float yin, float diameter, int idin, Block[] oin) {
//    x = xin;
//    y = yin;
//    d = diameter;
//    r = d/2;
//    id =idin;
//    others = oin;
    
//    vy += random(-1,1);
//    vx += random(-1,1);
//    //springB = random(-0.1,0.1);
    
//  }//Block Construct

//  void collide() {
//    for (int i=id+1; i<others.length; i++) {
//      float dx = others[i].x - x;
//      float dy = others[i].y - y;
//      float distance = sqrt(dx*dx + dy*dy);
//      float minDist = others[i].r + r;
//      if (distance < minDist) {
//        float angle = atan2(dy, dx);
//        float targetX = x + cos(angle) * minDist;
//        float targetY = y + sin(angle) * minDist;
//        float ax = (targetX - others[i].x) * springB;
//        float ay = (targetY - others[i].y) * springB;
//        vx -= ax;
//        vy -= ay;
//        others[i].vx += ax;
//        others[i].vy += ay;
//      }
      
//      //Going under and right teleports to the other side
//      //if (x+d<d || x>width-d) {
//      //  x = -vx/2;
//      //}
     
//      //if (y-d<d|| y>height-d) {
//      //  y = -vy/2;
//      //}
      
//      //Slowly bounce off wall
//      if (x<d+1) {
//        float ax = 0.05 * spring;
//        vx += ax;
//      }
//      if (x>width-d-1) {
//        float ax = 0.05 * spring;
//        vx -= ax;
//      }
//      if (y<d+1) {
//        float ay = 0.05 * spring;
//        vy += ay;
//      }
//      if (y>height-d-1) {
//        float ay = 0.05 * spring;
//        vy -= ay;
//      }
//    }//for
//  }//collide

//  void move() {
//    x += vx;
//    y += vy;
//    if (x + r > width) {
//      x = width - r;
//    } else if (x - r < 0) {
//      x = r;
//    }
//    if (y + r > height) {
//      y = height - r;
//    } else if (y - r < 0) {
//      y = r;
//    }
//  }//move

//  void display() {
//    stroke(0,255,0);
//    fill(0,255,0);
//    rect(x, y, d, d, 10); //Rounded Rect
//  }//display
//}//Block

////Negative Emotions Visuals
//class Star {
//  float x, y, r1, r2;
//  float vx, vy;
//  float angle;
//  float halfAngle;

//  Star(float xin, float yin, float radius1, float radius2, int npoints) {
//    x = xin;
//    y = yin;
//    r1 = radius1;
//    r2 = radius2;
//    angle = TWO_PI / npoints;
//    halfAngle = angle/2.0;
//  }//Star Construct
  
//  void move() {
//    translate(width*0.1, height*0.1);
//    rotate(frameCount/300.0); 
//  }
  
//  void display(){
//    stroke(255,0,0);
//    fill(255,0,0);
    
//    //build shape
//    pushMatrix();
//    beginShape();
//    for (float a = 0; a < TWO_PI; a += angle) {
//      float sx = x + cos(a) * r2;
//      float sy = y + sin(a) * r2;
//      vertex(sx, sy);
//      sx = x + cos(a+halfAngle) * r1;
//      sy = y + sin(a+halfAngle) * r1;
//      vertex(sx, sy);
//    }
//    endShape(CLOSE);
//    popMatrix();
//  }
//}//Star
