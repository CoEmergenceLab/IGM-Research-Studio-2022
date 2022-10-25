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

//Text Log
StringList textLog;
String keyboardInput = "";
char letter;
String words = "";
int count;

//Sentiment values
float stars;
float circles;
float anothers;

void setup() {
  size(1000, 800);
   //fullScreen(); 
  
  //Connect to serial port
  println(Serial.list());
  //plantPort = new Serial(this, Serial.list()[1], 9600);
  
  textLog = new StringList();
  count=0;
  
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
  d=new Drops[500];  //Replace 500 with moisture
  for(int i=0; i<500;i++){//Replace 500 with moisture
    d[i]=new Drops();
  }
}

void draw() {
  background(0);
  
  //if(plantPort.available() > 0){
  //  val = plantPort.readStringUntil('\n');
  //  //println(val);
  //  if(val != null){
  //     loadData();
  //  }
  //}
  
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
    if(d[i].y>height){
      d[i]=new Drops();
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
    float y = map(noise(xoff, yoff), 0, 1, 700, 800); // Option #1: 2D Noise
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
  
  //Light - Draw flashing/glowing and slowly fading lights
  
  //Touch
  //Text 
  if(touch>0){
    fill(255);
    textSize(24);
    //text("Number of Times Touched: " + touch, width*.9, height*.05);
    text("Number of Times Touched: " + touch, 200, 300);
  }//text
  
  //Smears
  
  //Positive Emotion
  
  //Neutral Emotion
  
  
  //Negative Emotion
  if(stars>0){
    fill(255,0,0);
    Random rand = new Random();
    for(int i=0; i<=stars; i++) {
    
      int randX = rand.nextInt(1920);
      int randY = rand.nextInt(1080);
      
      pushMatrix();
      translate(width*0.2, height*0.5);
      rotate(frameCount / 200.0);
      star(0,0,5,70, 3); 
      popMatrix();
    }
  }//Negative
}

// Load JSON file 
void loadData() {
  //parse JsonObject
  json = parseJSONObject(val);
  
  //Get and print values
  //moisture = json.getFloat("moisture")*100;
  //println("Moisture Level: " + moisture);
  //light = json.getFloat("light")*100;
  //println("Light Intensity: " + light);
  //touch = json.getInt("touch");
  //println("Number of Times Touched: " + touch);  //Touch counter = number of smears
  
  //Moisture
  //d=new Drops[moisture];
  //for(int i=0; i<moisture;i++){
  //  d[i]=new Drops();
  //}
  
  //Light Intensity
  if(light<=33){  //Low light
    
  }else if(light>66) {  //Bright light
  
  }else{   //Normal light
    
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
      circles = Float.parseFloat(pos)*10;
      anothers = Float.parseFloat(neu)*10;
      stars = Float.parseFloat(neg)*10;
      
      //Text entered
      String input = jsonSenti.getString("input");
      
      //Add new input to textlog
      textLog.append(input);
      count += 1;
      
      return;
    }  
  } 
}

// Negative Emotions Visuals
void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

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
    endPos = height+100-(random(300)); 
  }//init
  
  //Change raining speed based on Moisture data
  void update(){
    //Rain faster when 70% moisture
    //if(moisture>=66){
    //   y+=speed;
    //}else if(moisture<=33) {
    //   y+=speed;
    //}else{
      y+=speed;
    //}
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
