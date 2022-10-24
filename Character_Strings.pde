///*
//  TEXT
//*/

//StringList inventory;

//char letter;
//String words = "";
//int count;

//void setup() {
//  size(2000, 1000);
//  inventory = new StringList();
//  //noLoop();
//  //fill(0);
//  //textAlign(CENTER);
  
//  count=0;
//}

//void draw() {
//  background(0); // Set background to black

//  // Draw the letter to the center of the screen
//  textSize(14);
//  text("Current key: " + letter, 1600, 700);
//  text("The String is " + words.length() +  " characters long", 1600, 730);
  
//  textSize(24);
//  text(words, 800, 660);
  
//  if(count>0){
//    for(int i = 0; i<count; i++) {
//      String item = inventory.get(i);
//      if(inventory.size() > 5) {
//        inventory.remove(0);
//        count -= 1;
//      }
//      text(item, 1600, 760 + (i * 30 ));
//    }
//  }
//}

//void keyTyped() {
//  // The variable "key" always contains the value 
//  // of the most recent key pressed.
//  if ((key >= 'A' && key <= 'z') || key == ' ') {
//    letter = key;
//    words = words + key;
//    // Write the letter to the console
//    println(key);
//  }
  
//  // Save the message to log
//  if(key == ENTER) {
//    count += 1;
//    inventory.append(words);
//    words = "";
//  }
//}
