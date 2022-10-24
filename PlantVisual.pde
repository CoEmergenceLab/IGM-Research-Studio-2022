/*
  MAIN
*/

import processing.serial.*;
import oscP5.*;  
import netP5.*;

Serial plantPort;
String val;
String valSenti;

// A JSON object
JSONObject json;
JSONObject jsonSenti;

int moisture;
int light;
int touch;

// see https://sojamo.de/libraries/oscp5/ for more on OSCP5
OscP5 oscP5;
NetAddress myRemoteLocation;
static final String ip = "127.0.0.1";
static final int sendPort = 57000;
static final int receivePort = 57001;

static final String oscAddress = "/sentiment";

//Text Log
StringList textLog;
String keyboardInput = "";
char letter;
String words = "";
int count;

Spot[] spots; // Declare array
int counter;
int num = 50;
int[] x = new int[num];
int[] y = new int[num];
int indexPos = 0;

int xspacing = 8;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
int maxwaves = 4;   // total # of waves to add together

float theta = 0.0;
float[] amplitude = new float[maxwaves];   // Height of wave
float[] dx = new float[maxwaves];          // Value for incrementing X, to be calculated as a function of period and xspacing
float[] yvalues;  

void setup() {
  //size(1000, 800);
   fullScreen(); 
  
  //Connect to serial port
  println(Serial.list());
  plantPort = new Serial(this, Serial.list()[1], 9600);
  
  textLog = new StringList();
  count=0;
  
  /* start oscP5, listening for incoming messages at port 57001 */
  oscP5 = new OscP5(this, receivePort);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application.
   */
  myRemoteLocation = new NetAddress(ip, sendPort);
  counter = 0;
  
  int numSpots = 25; // Number of objects
  int dia = width/numSpots; // Calculate diameter
  spots = new Spot[numSpots]; // Create array
  for (int i = 0; i < spots.length; i++) {
    float x = dia/2 + i*dia;
    float rate = random(0.1, 2.0);
    // Create each object
    spots[i] = new Spot(x, 50, dia, rate);
  }
   noStroke();
  
  //Moisture
  frameRate(30);
  colorMode(RGB, 255, 0, 0, 100);
  w = width + 16;

  for (int i = 0; i < maxwaves; i++) {
    amplitude[i] = moisture;
    float period = random(100,300); // How many pixels before the wave repeats
    dx[i] = (TWO_PI / period) * xspacing;
  }

  yvalues = new float[w/xspacing];
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
  
  //text(keyboardInput, 25, 50);
  // Draw the letter to the center of the screen
  textSize(14);
  text("Current key: " + letter, 1600, 700);
  text("The String is " + words.length() +  " characters long", 1600, 730);
  
  textSize(24);
  text(words, 800, 660);
  
  if(count>0){
    for(int i = 0; i<count; i++) {
      String item = textLog.get(i);
      if(textLog.size() > 5) {
        textLog.remove(0);
        count -= 1;
      }
      text(item, 1600, 760 + (i * 30 ));
    }
  }
  
  //spots
  fill(0, 12);
  rect(0, 0, width, height);
  fill(0, 0, 255);//color
  for (int i=0; i < spots.length; i++) {
    spots[i].move(); // Move each object
    spots[i].display(); // Display each object
  }
  
  x[indexPos] = mouseX;
  y[indexPos] = mouseY;
  
  //Negative emotion
  fill(255);//color
  indexPos = (indexPos + 1)% num;
  for (int i = 0; i <num; i++){
    int pos = (indexPos + i) % num;
    float radius = (num-i)/2.0;
    ellipse (x[pos], y[pos], radius, radius);
  }
  
  pushMatrix();
  translate(width*0.2, height*0.5);
  rotate(frameCount / 200.0);
  star(0, 0, 5, 70, 3); 
  popMatrix();
  
  // Additive Wave
  calculateWave();
  renderWave();
}

// Load JSON file 
void loadData() {
  //parse JsonObject
  json = parseJSONObject(val);
  jsonSenti = parseJSONObject(val);
  
  //Get and print values
  moisture = json.getInt("moisture");
  println("Moisture Level: " + moisture);
  light = (int)json.get("light");
  println("Light Intensity: " + light);
  touch = (int)json.get("touch");
  println("Number of Times Touched: " + touch);
  
}

void keyTyped() {
  // The variable "key" always contains the value 
  // of the most recent key pressed.
  if ((key >= 'A' && key <= 'z') || key == ' ') {
    letter = key;
    words = words + key;
    // Write the letter to the console
    println(key);
  }
  
  // Save the message to log
  if(key == ENTER) {
    count += 1;
    textLog.append(words);
    words = "";
  }
}

class Spot {
  float x, y;         // X-coordinate, y-coordinate
  float diameter;     // Diameter of the circle
  float speed;        // Distance moved each frame
  int direction = 1;  // Direction of motion (1 is down, -1 is up)

  // Constructor
  Spot(float xpos, float ypos, float dia, float sp) {
    x = xpos;
    y = ypos;
    diameter = dia;
    speed = sp;
  }

  void move() {
    y += (speed * direction);
    if ((y > (height - diameter/2)) || (y < diameter/2)) {
      direction *= -1;
    }
  }

  void display() {
    ellipse(x, y, diameter, diameter);
  }
}

//negative emotions
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

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(" addrpattern: " + theOscMessage.addrPattern());
  println(" typetag: " + theOscMessage.typetag());
  
  /* check if theOscMessage has the address pattern we are looking for. */
  if(theOscMessage.checkAddrPattern("/sentiment") == true) {
    /* check if the typetag is the right one. 
       "ifs" means integer, float, string respectively
       we are expecting a two strings in this case, so it's "ss"
       more info here:
       https://sojamo.de/libraries/oscp5/examples/oscP5parsing/oscP5parsing.pde
    */
    if(theOscMessage.checkTypetag("ss")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
     //positive, neutral, negative sentiments
      String s0 = theOscMessage.get(0).stringValue();
      print(s0);
      
      //split string into values
      
      
      return;
    }  
  } 
}

//Calculate height and frequency of wave
void calculateWave() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

  // Set all height values to zero
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = 0;
  }
 
  // Accumulate wave height values
  for (int j = 0; j < maxwaves; j++) {
    float x = theta;
    for (int i = 0; i < yvalues.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  yvalues[i] += sin(x)*amplitude[j];
      //else yvalues[i] += cos(x)*amplitude[j];
      x+=dx[j];
    }
  }
}

//draw the wave
void renderWave() {
  // A simple way to draw the wave with an ellipse at each location
  noStroke();
  fill(255,50);
  ellipseMode(CENTER);
  for (int x = 0; x < yvalues.length; x++) {
    ellipse(x*xspacing,height/2+yvalues[x],16,16);
  }
}
