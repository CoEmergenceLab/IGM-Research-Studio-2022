/*
  LOAD JSON
*/

//import processing.serial.*;

//Serial plantPort;
//String val;

//// An Array of plant objects
////Plant[] plant;
//// A JSON object
//JSONObject json;

//void setup() {
//  size(1000, 800);
//  println(Serial.list());
//  plantPort = new Serial(this, Serial.list()[1], 9600);
//}

//void draw() {
//  background(255);
  
//  if(plantPort.available() > 0){
//    val = plantPort.readStringUntil('\n');
//    //println(val);
//    if(val != null){
//       loadData();
//    }
//  }
//}

//// Load JSON file 
//void loadData() {
//  //parse JsonObject
//  json = parseJSONObject(val);
  
//  //Get and print values
//  int moisture = json.getInt("moisture");
//  println(moisture);
//  int light = (int)json.get("light");
//  println("light " + light);
//  int touch = (int)json.get("touch");
//  println("Touch " + touch);
        
  
  
//  //// The size of the array of Plant objects is determined by the total XML elemeplantnts named "plant"
//  //plant = new Plant[plantData.size()]; 

//  //for (int i = 0; i < plantData.size(); i++) {
//  //  // Get each object in the array
//  //  JSONObject plant = plantData.getJSONObject(i); 
//  //  // Get a position object
//  //  JSONObject moisture = plant.getJSONObject("moisture");
//  //  // Get x,y from position
//  //  int x = moisture.getInt("x");
//  //  int y = moisture.getInt("y");
    
//  //  // Get diamter and label
//  //  float light = plant.getInt("light");
//  //  float touch = plant.getInt("touch");

//    // Put object in array
//    //plant[i] = new Plant(x, y, light, touch);
//  //}
//}

//// void mousePressed() {
////  // Create a new JSON plant object
////  JSONObject newPlant = new JSONObject();

////  // Create a new JSON position object
////  JSONObject moisture = new JSONObject();
////  moisture.setInt("x", mouseX);
////  moisture.setInt("y", mouseY);

////  // Add position to plant
////  newPlant.setJSONObject("moisture", moisture);

////  // Add diamater and label to plant
////  newPlant.setFloat("diameter", random(40, 80));
////  newPlant.setString("label", "New label");

////  // Append the new JSON plant object to the array
////  JSONArray plantData = json.getJSONArray("plants");
////  plantData.append(newPlant);

////  if (plantData.size() > 10) {
////    plantData.remove(0);
////  }

////  // Save new data
////  saveJSONObject(json,"data/data.json");
////  loadData();
////}
