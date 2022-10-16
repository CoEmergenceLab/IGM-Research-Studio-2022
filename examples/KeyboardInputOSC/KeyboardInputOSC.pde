/**
Sends keyboard input via OSC
works with python-processing-osc.py
*/


import oscP5.*;  
import netP5.*;

// see https://sojamo.de/libraries/oscp5/ for more on OSCP5
OscP5 oscP5;
NetAddress myRemoteLocation;
static final String ip = "127.0.0.1";
static final int sendPort = 57000;
static final int receivePort = 57001;

String keyboardInput = "";
static final String oscAddress = "/keyboard";

void setup() {
  size(1280, 720);
  textSize(36);
  
  /* start oscP5, listening for incoming messages at port 57001 */
  oscP5 = new OscP5(this, receivePort);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application.
   */
  myRemoteLocation = new NetAddress(ip, sendPort);
}

void draw() {
  background(53);
  text(keyboardInput, 25, 50);
}

void keyTyped() {
  keyboardInput += key;               // get keyboard input
  if(key == RETURN || key == ENTER) { // if return key is pressed send OSC and clear keyboard input
    sendOSC(keyboardInput);           // send the OSC message
    keyboardInput = "";
  }
}

void sendOSC(String s) {
  OscMessage msg = new OscMessage(oscAddress);
  msg.add(s);
  /* send the message */
  oscP5.send(msg, myRemoteLocation);
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
      String s0 = theOscMessage.get(0).stringValue();
      print(s0);
      String s1 = theOscMessage.get(1).stringValue();
      println(" " + s1);
      return;
    }  
  } 
}
