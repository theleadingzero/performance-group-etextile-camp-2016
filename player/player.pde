/** 
 * Player for E-Textile Skirt
 * by Becky Stewart
 * E-Textile Summer Camp 2016
 */


import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

import ddf.minim.*;

Minim minim;
AudioPlayer violin;
AudioSample bells;

int loopBegin;
int loopEnd;

void setup()
{
  // set up window
  size(512, 200, P3D);
  minim = new Minim(this);
  
  // set up audio
  violin = minim.loadFile("violin.wav");
  bells = minim.loadSample("bells.wav");
  bells.setVolume(0.7);

  textFont(loadFont("ArialMT-14.vlw"));
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

void mousePressed()
{
  int ms = (int)map(mouseX, 0, width, 0, violin.length());
  if ( mouseButton == RIGHT )
  {
    violin.setLoopPoints(loopBegin, ms);
    loopEnd = ms;
  } else
  {
    violin.setLoopPoints(ms, loopEnd);
    loopBegin = ms;
  }
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
  }
}

void startViolin() {
  // check if not playing
  if ( !violin.isPlaying()) {
    // start audio
    violin.loop();
  }
}

void stopViolin() {
  violin.pause();
}

void setLoop() {
  // set loop points to right now
  // and N seconds before now
  // check more than N into audio file
  if ( violin.position() > 1800 ) {
    println("setting loop points");
    violin.setLoopPoints((violin.position() - 1800), violin.position()+30 );
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