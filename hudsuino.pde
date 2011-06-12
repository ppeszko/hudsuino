#include <SPI.h>

#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>



const unsigned int HUDSON_PORT = 8080;
const unsigned int BAUD_RATE = 9600;
const unsigned int LED_PIN = 13;
const unsigned int MATCHING_CHAR_LENGTH = 10;

byte mac[]         = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte my_ip[]       = { 
  192, 168, 1, 120 };
byte hudson_server[] = { 
  192, 168, 1, 6 };

char data_start[MATCHING_CHAR_LENGTH] = "\"color\":\"";
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
    delay(1000);

    readData();

    client.flush();
    Serial.println("buffenring done");
    Serial.flush();

    Serial.println("Disconnecting.");
    client.stop();
  }
}

void readData() {
  boolean started = false;
  int i = 0;

  while (client.available()) {
    char c = client.read();
    if (started) {
      if (c == 'r') {
        Serial.println("build broken");
      } else {
        Serial.println("build successful");
      }
      Serial.print(c);
    }

    // scanning for the beginning of build status
    if (!started && c == data_start[i]) {
      i++;
      if (i == MATCHING_CHAR_LENGTH - 1) { // trailing \0 not needed
        started = true;
        Serial.println("--------------------started");
      }
    // scanninig for the end of data
    } else if (started && c == data_end) {
      started = false;
    } else {
      i = 0;
    }
  }
}

