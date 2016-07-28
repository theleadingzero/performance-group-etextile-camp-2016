/** 
 * Player for E-Textile Skirt
 * by Becky Stewart
 * E-Textile Summer Camp 2016
 *  
 * Watches for 5 Outputs from Wekinator
 *   - each output has 5 classifications
 *   
 *   outputs-1: handles violin macro start/stop
 *              1 - start
 *              2 - stop
 *   outputs-2: handles violin loop set/release
 *              1 - nothing
 *              2 - set
 *              3 - release
 *   outputs-3: handles sample triggers
 *              1 - nothing
 *              2 - trigger bell
 *              3 - trigger vibraslap
 */


import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

import ddf.minim.*;

// audio variables
Minim minim;
AudioPlayer violin;
AudioSample bells;
AudioSample vibra;

int loopBegin;
int loopEnd;

// debounce timers
long lastStart = 0;
long lastStop = 0;

void setup()
{
  // set up window
  size(512, 200, P3D);
  minim = new Minim(this);

  // set up audio
  violin = minim.loadFile("violin.wav");
  bells = minim.loadSample("bells.wav");
  vibra = minim.loadSample("vibraslap.wav");

  // load font
  textFont(loadFont("ArialMT-14.vlw"));

  // set up OSC
  // start oscP5, listening for incoming messages at port 12000 
  oscP5 = new OscP5(this, 12000);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void draw()
{
  background(0);
  fill(255);  
  text("Playing: " + violin.isPlaying(), 5, 60);
  int p = violin.position();
  int l = violin.length();
  text("Position: " + p, 5, 80);
  text("Length: " + l, 5, 100);
  float x = map(p, 0, l, 0, width);
  stroke(255);
  line(x, height/2 - 50, x, height/2 + 50);
  float lbx = map(loopBegin, 0, violin.length(), 0, width);
  float lex = map(loopEnd, 0, violin.length(), 0, width);
  stroke(0, 255, 0);
  line(lbx, 0, lbx, height);
  stroke(255, 0, 0);
  line(lex, 0, lex, height);
}

void keyPressed()
{
  switch (key) {
  case 's':
    startViolin();
    break;

  case 't':
    stopViolin();
    break;

  case 'l':
    setLoop();
    break;

  case 'r':
    releaseLoop();
    break;

  case 'b':
    playBells();
    break;
    
    case 'v':
    playVibraslap();
    break;
  }
}

void startViolin() {
  // check if not playing and debounce
  if ( !violin.isPlaying() && ((millis() - lastStart) > 1500) ) {
    // start audio
    violin.loop();
    lastStart = millis();
  }
}

void stopViolin() {
  // debounce
  if ( (millis() - lastStop) > 1500 ) {
    violin.pause();
  }
}

void setLoop() {
  // set loop points to right now
  // and N seconds before now
  // check more than N into audio file
  if ( violin.position() > 1000 ) {
    println("setting loop points");
    violin.setLoopPoints((violin.position() - 1000), violin.position()+30 );
    //violin.loop();
  }
}

void releaseLoop() {
  // clear loop points and allow to play on
  violin.setLoopPoints(0, violin.length());
}

void playBells() {
  bells.trigger();
}

void playVibraslap() {
  vibra.trigger();
}


void oscEvent(OscMessage theOscMessage) {
  // check if theOscMessage has the address pattern we are looking for

  if (theOscMessage.checkAddrPattern("/wek/outputs") == true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("fffff")) {
      // parse theOscMessage 
      float firstValue = theOscMessage.get(0).floatValue();  
      float secondValue = theOscMessage.get(1).floatValue();
      float thirdValue = theOscMessage.get(2).floatValue();
      float fourthValue = theOscMessage.get(3).floatValue();
      float fifthValue = theOscMessage.get(4).floatValue();
      println(" values: " + firstValue + ", " + secondValue + ", " + thirdValue + ", " + thirdValue + ", " + fourthValue + ", " + fifthValue);

      // start violin
      if ( firstValue == 1 ) startViolin();
      // stop violin
      if ( firstValue == 2 ) stopViolin();

      // drop loop
      if ( secondValue == 2) setLoop();
      // release loop
      if ( secondValue == 3) setLoop();

      // trigger samples
      if ( thirdValue == 2 ) playBells();
      if ( thirdValue == 3 ) playVibraslap();
      return;
    }
  } 
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
  println(theOscMessage.typetag());
}