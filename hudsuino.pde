#include <SPI.h>

#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>

const unsigned int BAUD_RATE = 9600;

const unsigned int GREEN_PIN = 4;
const unsigned int RED_PIN = 8;
const unsigned int YELLOW_PIN = 7;

byte MAC[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte MY_IP[] = { 192, 168, 1, 120 };
byte HUDSON_SERVER[] = { 192, 168, 1, 7 };
const unsigned int HUDSON_PORT = 8080;
const char DATA_BEGINNING[] = "\"color\":\"blue\"";

const unsigned int POLLING_INTERVAL = 1000;

Client client(HUDSON_SERVER, HUDSON_PORT);
boolean buildGreen = false;

void setup() {
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(RED_PIN, OUTPUT);
  Serial.begin(BAUD_RATE);
  Serial.println("finishing setup");

  Ethernet.begin(MAC, MY_IP);
}

void loop() { 
  if (buildGreen) {
    digitalWrite(GREEN_PIN, HIGH);
    digitalWrite(RED_PIN, LOW);
  } else {
    digitalWrite(GREEN_PIN, LOW);
    digitalWrite(RED_PIN, HIGH);
  }
  
  Serial.print("Connecting...");

  if (!client.connect()) {
    Serial.println("connection failed.");
  } else {
    Serial.println("connected.");
    delay(1000);
    client.println("GET /job/arduino/api/json HTTP/1.1");
    client.println();
    delay(1000);

    readData();

    Serial.println("buffenring done");
    Serial.flush();

    Serial.println("Disconnecting.");
    client.stop();
  }
  delay(POLLING_INTERVAL);
}

void readData() {
  digitalWrite(YELLOW_PIN, HIGH);
  int numberOfBytes = client.available();
  Serial.println(numberOfBytes);
  if (numberOfBytes <= 0) {
    return;
  }
  
  int i = 0;
  boolean found = false;
  boolean potentialMatch = false;
  char c;
  while ((c = client.read()) != -1 && !found) {
    // without delay ethernet shield was returning garabage from time to time
    // 3 is the smallest working delay
    delay(3);
    
    if (potentialMatch && i == strlen(DATA_BEGINNING)) {
      // whole string found
      found = true;
      Serial.println("found");
    } else if (c == DATA_BEGINNING[i]) {
      potentialMatch = true;
      i++;
    } else {
      //no match
      i = 0;
      potentialMatch = false;
    }
  }
  
  Serial.println("");
  
  if (found) {
    buildGreen = true;
    Serial.println("----------- build green ------------");
  } else {
    buildGreen = false;
    Serial.println("----------- build red --------------");
  }
  digitalWrite(YELLOW_PIN, LOW);
}

