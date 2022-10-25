/*
  MAIN
*/

import processing.serial.*;
import oscP5.*;  
import netP5.*;
import java.util.Random;

Serial plantPort;
String val;

//A JSON object
JSONObject json;
JSONObject jsonSenti;

//see https://sojamo.de/libraries/oscp5/ for more on OSCP5
OscP5 oscP5;
NetAddress myRemoteLocation;
static final String ip = "127.0.0.1";
//static final int sendPort = 57000;
static final int receivePort = 57000;
static final String oscAddress = "/sentiment";

float moisture;
float light;
int touch;

//Moisture
Drops d[];
float yoff = 0.0;  

//Light
Glow g[];
float intensity;
int glowCount;

//Touch
int prev;
ArrayList<PShape> smears;
PShape smear;

//Text Log
StringList textLog;
String keyboardInput = "";
char letter;
String words = "";
int count;

//Sentiment values
float circles;
float blocks;
float stars;

//Positive - Circles
float spring = 0.01;
Circle[] circle;

//Neutral - Blocks
float springB = 0.01;
Block[] block;

//Negative - Stars
float springS = 0.01;
Star[] star;

void setup() {
  //size(1000, 800);
  //1920X1080p
   fullScreen(); 
  
  //Connect to serial port
  println(Serial.list());
  plantPort = new Serial(this, Serial.list()[1], 9600);
  
  textLog = new StringList();
  count=0;
  
  //Testing
  //moisture = 0.40;
  //light = 0.8;
  
  glowCount = 0;
  
  /* start oscP5, listening for incoming messages at port 57001 */
  oscP5 = new OscP5(this, receivePort);
  
  //Moisture texts
  //Text and data 1-100 
  stroke(255);
  fill(0);
  for(int i=0; i<11; i++) {
    //rect(0, height-(i*10), 530, 430);
    text("-" + i*10, 10, height-(i+10));
  }
  
  ///////////////////Moved to loadJson when connected to arduino
  //d = new Drops[500];  //Replace 500 with moisture
  //for(int i=0; i<500;i++){//Replace 500 with moisture
  //  d[i] = new Drops();
  //}
  
  //Light
  g = new Glow[16];
  
  //Touch
  prev = 0;
  smears = new ArrayList<PShape>();
  smear = loadShape("smear.svg");
  
  fill(255);
  textSize(24);
  //text("Number of Times Touched: 0", 200, 300);
  text("Number of Times Touched: 0", width*0.8, height*0.05);
}

void draw() {
  background(0);
  
  if(plantPort.available() > 0){
    val = plantPort.readStringUntil('\n');
    //println(val);
    if(val != null){
       loadData();
    }
  }
  
  ///Draw Text Log  
  // Borderbox
  stroke(255);
  fill(0);
  rect(width*.8-20, height*.75-80, 530, 430);
  
  //Text
  textSize(30);
  fill(255);
  text("Text Log", width*.8, height*.75-40);
  
  //Messages
  if(count>0){
    textSize(24);
    fill(255,180);
      
    for(int i = 0; i < count; i++) {
      String item = textLog.get(i);
      if(textLog.size() > 11) {
        textLog.remove(0);
        count -= 1;
      }
      
      if(item.length() > 70){
        //if(item.length() > 25){//mmmmmmmmmm
        //  char[] c = item.toCharArray();
        //  if(item.length()>50){
        //    text(item, width*.8, height*.75+(i*30));
        //  }else{
        //    text(item, width*.8, height*.75+(i*30));
        //  }
        }else{
          text(item, width*.8, height*.75+(i*30));
        }
      //}//if length
    }//if count>0
  }//draw
  
  //Moisture - Draw rain drops
  fill(0,50);
  rect(0,0,width,height);
  for(int i=0; i<500; i++){    
  //for(int i=0; i<moisture; i++){    
    if(d[i].y>d[i].endPos){
      //d[i]=new Drops();
      d[i].end();
    }else{
      d[i].display();
    }
  }
  fill(255);
  
  //Wave
  beginShape(); 
  float xoff = 0;       // 2D Noise  
  // Iterate over horizontal pixels
  for (float x = 0; x <= width; x += 8) {
    // Calculate a y value according to noise, map to 
    float range = (height*(100-moisture)/100);
    float y = map(noise(xoff, yoff), 0, 1, range-100, range); // Option #1: 2D Noise
    stroke(0,0,255);
    strokeWeight(4);
    //fill(40,80,245);
    noFill();    
    vertex(x, y);  //Set the vertex  
    xoff += 0.02;  //Increment x dimension for noise
  }
  //Increment y dimension for noise
  yoff += 0.01;
  vertex(width, height);
  vertex(0, height);
  endShape(CLOSE);
  
  //Light - Draw flashing/glowing and slowly fading light
  for(int i=0; i<16;i++){
    g[i] = new Glow(random(width), random(height), random(1));
    glowCount+=1;
    //println(g[i]);
    g[i].display();
  }
  
  //Touch
  //touch = 2;//test
  fill(255);
  textSize(24);
    
  text("Number of Times Touched: " + touch, width*0.8, height*0.05);
 
  //Text 
  if(touch>0 &&touch != prev){
    //Smears - Static
      smears.add(smear);
      //shape(pshape name, x, y, width, height)
      shape(smear,random(width), random(height),50,40);
      //text("Number of Times Touched: " + touch, 200, 300;
      text("Number of Times Touched: " + touch, width*0.8, height*0.05);
      prev = touch;
  }//text
  
  //Positive Emotion
  if(circle != null){
    for(Circle c: circle) {
      c.collide();
      c.move();
      c.display();
    }
  }
  
  //Neutral Emotion
  if(block != null){
    for(Block b: block) {
      b.collide();
      b.move();
      b.display();
    }
  }
  
  //Negative Emotion
  if(star != null){
    for(Star s: star) {
      s.collide();
      s.move();
      s.display();
    }
  }
  //if(stars>0){
  //  fill(255,0,0);
  //  //Random rand = new Random();
  //  for(int i=0; i<=stars; i++) {     
  //    pushMatrix();
  //    translate(width*0.2, height*0.5);
  //    rotate(frameCount / 200.0);
  //    star(0,0,5,70, 3); 
  //    popMatrix();
  //  }
  //}//Negative
}

// Load JSON file 
void loadData() {
  //parse JsonObject
  json = parseJSONObject(val);
  
  //Get and print values
  moisture = json.getFloat("moisture")*100;
  //println("Moisture Level: " + moisture);
  light = json.getFloat("light")*100;
  println("Light Intensity: " + light);
  touch = json.getInt("touch");
  println("Number of Times Touched: " + touch);  //Touch counter = number of smears
  
  //Moisture
  d=new Drops[int(moisture)];
  for(int i=0; i<moisture;i++){
    d[i]=new Drops();
  }
  
  //Light Intensity
  if(light<=33){  //Low light
    intensity = 10;
  }else if(light>66) {  //Bright light
    intensity = 50;
  }else{   //Normal light
    intensity = 30;
  }//light
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(" addrpattern: " + theOscMessage.addrPattern());
  println(" typetag: " + theOscMessage.typetag());
  
  /* check if theOscMessage has the address pattern we are looking for. */
  if(theOscMessage.checkAddrPattern("/sentiment") == true) {
    /* check if the typetag is the right one. 
       "ifs" means integer, float, string respectively
       https://sojamo.de/libraries/oscp5/examples/oscP5parsing/oscP5parsing.pde
    */
    if(theOscMessage.checkTypetag("s")) {
      // parse theOscMessage and extract the values from the osc message arguments. 
      String s = theOscMessage.get(0).stringValue();
      println(s);
      
      //split string into values
      jsonSenti = parseJSONObject(s);
      println(jsonSenti);
       
      // Getting positive, neutral, negative sentiments
      String pos = jsonSenti.getString("POS");
      String neu = jsonSenti.getString("NEU");
      String neg = jsonSenti.getString("NEG");
      
      //Parse strings to float
      circles = Float.parseFloat(pos)*100;
      blocks = Float.parseFloat(neu)*100;
      stars = Float.parseFloat(neg)*10;
      
      //Test
      //circles = 70;
      //blocks = 20;
      //stars = 10;
      
      //Positive
      circle = new Circle[int(circles)];
      for(int i=0; i< circles; i++){
         circle[i] = new Circle(random(width), random(height), random(30,70),i,circle);
      }
      fill(255,255,0,204);
      
      //Neutral
      block = new Block[int(blocks)];
      for(int i=0; i< blocks; i++){
         block[i] = new Block(random(width), random(height), random(30,70),i,block);
      }
      fill(0,255,0,204);
      
      //Negative
      star = new Star[int(stars)];
      for(int i=0; i< stars; i++){
         star[i] = new Star(random(width), random(height), random(30,70),i,star,3);
      }
      fill(255,0,0,204);
      
      //Text entered
      String input = jsonSenti.getString("input");
      
      //Add new input to textlog
      textLog.append(input);
      count += 1;
      
      return;
    }  
  } 
}

//Light - Glow
class Glow{
  PVector loc;
  boolean glowing;
  
  Glow(float x, float y, float gl){
    loc = new PVector(x,y);
    //println("G: " + gl);
    if(gl==0){
       glowing = false;
    }else{
      glowing = true;
    }
  }
  
  void init(){
    glowCount=0;  
  }
  
  void display(){
    if(glowing){
      float glowRadius = intensity + 15 * sin(frameCount/(2*frameRate)*TWO_PI); 
      strokeWeight(2);
      fill(255,0);
      for(int i = 0; i < glowRadius; i++){
        stroke(255,255.0*(1-i/glowRadius));
        ellipse(loc.x,loc.y,i,i);
      }
    }
  }//Display
  
  void end(){
    noFill();
    if(glowCount>60){
      init();
    }
  }//end
}//Glow

//Moisture - Drops Class
class Drops{
  float x,y,speed;
  float ellipseX,ellipseY,endPos;
  
  Drops(){
   init();
  }//Drops init
  
  void init(){
    x = random(width);
    y = random(-300,0);
    speed = random (1,4) * 2;
    ellipseX  = 0;
    ellipseY  = 0;
    endPos = (height*(100-moisture)/100)-random(50); 
  }//init
  
  //Change raining speed based on Moisture data
  void update(){
    //Rain faster when 70% moisture
    if(moisture>=66){
       y+=speed;
    }else if(moisture<=33) {
       y+=speed;
    }else{
      y+=speed;
    }
  }//update
  
  void display(){
    fill(0,0,255);
    noStroke();
    rect(x,y,2,15);
    update();
  }//display
  
  //Remove raindrop when it touches the surface
  void end(){
    stroke(0,0,255);
    noFill();
    ellipse(x,y,ellipseX,ellipseY);
    
    ellipseX += speed*0.5;
    ellipseY += speed*0.2;
    
    if(ellipseX>30){
      init();
    }
  }//end
}//Drops

//Positive Emotions Visuals
class Circle{
 float x,y,d,r;
 float vx,vy;
 int id;
 Circle[] others;
 
 Circle(float xin, float yin, float diameter, int idin, Circle[] oin){
   x = xin;
   y = yin;
   d = diameter;
   r = d/2;
   id =idin;
   others = oin;
 }//Circle Construct
 
 void collide() {
  for(int i=id+1; i<circles; i++){
    float dx = others[i].x - x;
    float dy = others[i].y - y;
    float distance = sqrt(dx*dx + dy*dy);
    float minDist = others[i].r + r;
    if (distance < minDist) { 
      float angle = atan2(dy, dx);
      float targetX = x + cos(angle) * minDist;
      float targetY = y + sin(angle) * minDist;
      float ax = (targetX - others[i].x) * spring;
      float ay = (targetY - others[i].y) * spring;
      vx -= ax;
      vy -= ay;
      others[i].vx += ax;
      others[i].vy += ay;
    }
    if(x<=0){
       float ax = 0.05 * spring;
       vx += ax;
     }
     if(x>=width){
       float ax = 0.05 * spring;
       vx -= ax;
     }
     if(y<=0){
       float ay = 0.05 * spring;
       vy += ay;
     }
     if(y>=height){
       float ay = 0.05 * spring;
       vy -= ay;
     }
   }
  }//collide
  
  void move() {
    x += vx;
    y += vy;
    if (x + r > width) {
      x = width - r;
    }
    else if (x - r < 0) {
      x = r;
    }
    if (y + r > height) {
      y = height - r;
    } 
    else if (y - r < 0) {
      y = r;
    }
  }//move
  
  void display() {
    ellipse(x, y, d, d);
  }
}//Circle

//Neutral Emotions Visuals
class Block{
 float x,y,d,r;
 float vx,vy;
 int id;
 Block[] others;
 
 Block(float xin, float yin, float diameter, int idin, Block[] oin){
   x = xin;
   y = yin;
   d = diameter;
   r = d/2;
   id =idin;
   others = oin;
 }//Block Construct
 
 void collide() {
  for(int i=id+1; i<blocks; i++){
    float dx = others[i].x - x;
    float dy = others[i].y - y;
    float distance = sqrt(dx*dx + dy*dy);
    float minDist = others[i].r + r;
    if (distance < minDist) { 
      float angle = atan2(dy, dx);
      float targetX = x + cos(angle) * minDist;
      float targetY = y + sin(angle) * minDist;
      float ax = (targetX - others[i].x) * spring;
      float ay = (targetY - others[i].y) * spring;
      vx -= ax;
      vy -= ay;
      others[i].vx += ax;
      others[i].vy += ay;
    }
    if(x<=0){
       float ax = 0.05 * springB;
       vx += ax;
     }
     if(x>=width){
       float ax = 0.05 * springB;
       vx -= ax;
     }
     if(y<=0){
       float ay = 0.05 * springB;
       vy += ay;
     }
     if(y>=height){
       float ay = 0.05 * springB;
       vy -= ay;
     }
   }
  }//collide
  
  void move() {
    x += vx;
    y += vy;
    if (x + r > width) {
      x = width - r;
    }
    else if (x - r < 0) {
      x = r;
    }
    if (y + r > height) {
      y = height - r;
    } 
    else if (y - r < 0) {
      y = r;
    }
  }//move
  
  void display() {
    rect(x,y,d,d,28); //Rounded Rectangle
  }
}//Block

//Negative Emotions Visuals
class Star{
 float x,y,d,r;
 float vx,vy;
 int id;
 Star[] others;
 float angle;
 float halfAngle;
 
 Star(float xin, float yin, float diameter, int idin, Star[] oin, int npoints){
   x = xin;
   y = yin;
   d = diameter;
   r = d/2;
   id =idin;
   others = oin;
   angle = TWO_PI / npoints;
   halfAngle = angle/2.0;
   
   //Build shape and rotate
   beginShape();
   for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * r;
    float sy = y + sin(a) * r;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * r;
    sy = y + sin(a+halfAngle) * r;
    vertex(sx, sy);
  }
  endShape(CLOSE);
 }//Star Construct
 
 void collide() {
  for(int i=id+1; i<stars; i++){
    float dx = others[i].x - x;
    float dy = others[i].y - y;
    float distance = sqrt(dx*dx + dy*dy);
    float minDist = others[i].r + r;
    if (distance < minDist) { 
      float angle = atan2(dy, dx);
      float targetX = x + cos(angle) * minDist;
      float targetY = y + sin(angle) * minDist;
      float ax = (targetX - others[i].x) * springS;
      float ay = (targetY - others[i].y) * springS;
      vx -= ax;
      vy -= ay;
      others[i].vx += ax;
      others[i].vy += ay;
    }
    if(x<=0){
       float ax = 0.05 * springS;
       vx += ax;
     }
     if(x>=width){
       float ax = 0.05 * springS;
       vx -= ax;
     }
     if(y<=0){
       float ay = 0.05 * springS;
       vy += ay;
     }
     if(y>=height){
       float ay = 0.05 * springS;
       vy -= ay;
     }
   }
  }//collide
  
  void move() {
    x += vx;
    y += vy;
    if (x + r > width) {
      x = width - r;
    } else if (x - r < 0) {
      x = r;
    }
    if (y + r > height) {
      y = height - r;
    } else if (y - r< 0) {
      y = r;
    }
  }//move
  
  void display() {
    //Build shape and rotate
   beginShape();
   for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * d/2;
    float sy = y + sin(a) * d/2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * d/2;
    sy = y + sin(a+halfAngle) * d/2;
    vertex(sx, sy);
  }
  endShape(CLOSE);
  }
}//Star
