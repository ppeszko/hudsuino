#include <SPI.h>

#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>



const unsigned int HUDSON_PORT = 8080;
const unsigned int BAUD_RATE = 9600;
const unsigned int LED_PIN = 13;

byte mac[]         = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte my_ip[]       = { 
  192, 168, 1, 120 };
byte hudson_server[] = { 
  192, 168, 1, 7 };

// +1 for \0 byte
char data_start[] = "\"color\":\"blue\"";
char data_end = '"';

Client client(hudson_server, HUDSON_PORT);

void setup() {
  pinMode(LED_PIN, OUTPUT);
  Serial.begin(BAUD_RATE);
  Serial.println("finishing setup");

  Ethernet.begin(mac, my_ip);
}

void loop() {
  digitalWrite(LED_PIN, LOW);
  delay(2000);
  digitalWrite(LED_PIN, HIGH);
  Serial.print("Connecting...");

  if (!client.connect()) {
    Serial.println("connection failed.");
  } else {
    Serial.println("connected.");
    delay(1000);
    client.println("GET /job/arduino/api/json HTTP/1.1");
    client.println();
    delay(10000);

    readData();

    //client.flush();
    Serial.println("buffenring done");
    Serial.flush();

    Serial.println("Disconnecting.");
    client.stop();
  }
}

void readData() {
  //boolean started = false;
  int i = 0;
  boolean found = false;
  boolean potentialMatch = false;

  while (client.available() && !found) {
    char c = client.read();
    
    if (potentialMatch && i == strlen(data_start)) {
      // all found
      found = true;
      Serial.println("found");
    } else if (c == data_start[i]) {
      Serial.print(c);
      potentialMatch = true;
      i++;
    } else {
      //no match
      Serial.println("");
      i = 0;
      potentialMatch = false;
    } 
  }
  
  if (found) {
    Serial.println("----------- build green ------------");
  } else {
    Serial.println("----------- build red --------------");
  }
}

