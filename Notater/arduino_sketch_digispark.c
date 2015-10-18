
#include "DigiKeyboard.h" 

// note to self, analog pins: 
// a0=p5 ; suspect (usb?)
// a1=p2 ; this is the one
// a2=p4 ; usb ..
// a3=p3 ; usb ..

#define voltage 1 // on pin 2

int current;
int t;
int wheel ;
int looper;

void setup() {
  pinMode(voltage, INPUT);
  looper = 0; 
  DigiKeyboard.update(); 
  current = 255; // make sure first reading is "different"
}

void loop() {
  // refresh keyboard
  DigiKeyboard.update();
  
  // if looper hits 9, read sensor settings
  if(looper==9)
  {
    t = analogRead(voltage);
    t = t + 31 ; // make threshould values, add one half step
    wheel = t >> 6 ; // get 4 most significant bits (of 10) 
    if(wheel != current)
    {
      current = wheel;
      DigiKeyboard.sendKeyStroke(KEY_A+current);
    }
  }
  // every loop, increase counter 0-9, wait a bit
  looper ++;  // next iteration 
  looper = looper % 10; // keep in range 0-9
  delay(50);
}

