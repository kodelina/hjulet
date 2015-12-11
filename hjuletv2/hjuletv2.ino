// hjulet v2 - les inn fire bits som verdi, og sammenlign med forrige
// dersom endring, send bokstaven som tastetrykk
//#define DEBUG

#include <Keyboard.h>

#define FILTER_COUNT 3
#define KEY_A 97

typedef unsigned char byte;

byte lastValue, filter, current, sent;

const char *lookup = "abcdefghijklllaa";
#ifdef DEBUG
// special care in debug mode
#endif
void setup() {
  #ifdef DEBUG
  Serial.begin(9600);
  #endif
  lastValue = 255 ; // gi oss en tast første gang vi kjører
  filter = FILTER_COUNT ;
  sent = 0 ;
  Keyboard.begin();
  pinMode(0, INPUT_PULLUP);
  pinMode(1, INPUT_PULLUP);
  pinMode(2, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
}

void loop() {
  // put your main code here, to run repeatedly:
 current = digitalRead(0) + 2*digitalRead(1) + 4*digitalRead(2) + 8*digitalRead(3);
 #ifdef DEBUG
 Serial.write("Read val = ");
 Serial.print(current);
 Serial.print("\n");
 #endif
 if(current != lastValue)
 {
    filter = FILTER_COUNT ;
    lastValue = current ;
    sent = 0 ;
 }
 else
 {
    if(filter > 0)
    {
      filter-- ;
      #ifdef DEBUG
        Serial.write("Decrementing : ");
        Serial.print(filter);
        Serial.print("\n");
      #endif
    }
    else
      if(!sent)
      {
        sent = 1;
        Keyboard.write(current + KEY_A);
        // Keyboard.write(lookup[current]);
      #ifdef DEBUG
        Serial.write("printing : ");
        Serial.print(current + KEY_A);
        Serial.print("\n");
      #endif

      }
 }
 delay(50); 
}
