#include <ArduinoJson.h>
#include <CapacitiveSensor.h>
#include <RunningAverage.h>

const int moisture = A0, light = A1;
CapacitiveSensor touch = CapacitiveSensor(2,3);

//needs to be 180 for hourly average but that breaks things? is currently 20 min average
RunningAverage raLightHour(60); 
RunningAverage raTouchHour(60);

StaticJsonDocument<1000> doc;

unsigned long lastDebounce = 0;
unsigned long debounceDelay = 3000;
bool beenTouched = false;

void setup() {
  pinMode(moisture, INPUT);
  pinMode(light, INPUT);
  Serial.begin(9600);
  raLightHour.clear();
  raTouchHour.clear();
  raTouchHour.addValue(0); //so that value isn't null
}

void loop() {
  
  //if moisture sensor is touching plant, default reading is 200-300 range
  //if sensor not touching, usually <10
  //decent finger to plant contact usually reads >700
  if(touch.capacitiveSensor(30) > 500){
    beenTouched = true; 
  }

  //automatically updates hourly average & sends readings every 3 seconds
  if((millis() - lastDebounce) > debounceDelay){
    //light value not reading correctly here, but does down in sendReadings, moved code below
    //float light = analogRead(light);
    //raLightHour.addValue(light);

    if(beenTouched){
      raTouchHour.addValue(1);
      beenTouched = false;
    }

    sendReadings();
    lastDebounce = millis();
  }
}

void sendReadings(){
  JsonObject data = doc.to<JsonObject>();
  
  raLightHour.addValue(analogRead(light)); //moved this down here so that the analog value reads correctly

  data["moisture"] = analogRead(moisture); //according to carlos, should be a val between 0-100. please alter as you see fit to get that format of value
  data["light"] = round(raLightHour.getAverage()); //returns average light over the past hour
  data["touch"] = raTouchHour.getAverage()*raTouchHour.getCount(); //returns times touched in the last hour

  serializeJson(doc, Serial);
  Serial.println();
}
