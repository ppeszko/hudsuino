#include <SPI.h>

#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>



const unsigned int HUDSON_PORT = 8080;
const unsigned int BAUD_RATE = 9600;

byte mac[]         = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte my_ip[]       = { 192, 168, 1, 120 };
byte time_server[] = { 192, 168, 1, 7 };

Client client(time_server, HUDSON_PORT);

void setup() {
  Ethernet.begin(mac, my_ip);
  Serial.begin(BAUD_RATE);
}

void loop() {
  delay(5000);
  Serial.print("Connecting...");
  
  if (!client.connect()) {
    Serial.println("connection failed.");
  } else {
    Serial.println("connected.");
    delay(1000);
    client.println("GET /job/arduino/api/json HTTP/1.1");
    client.println();
    
    delay(1000);
    while (client.available()) {
      char c = client.read();
      Serial.print(c);
    }
    
    Serial.println("Disconnecting.");
    client.stop();
  }
}
