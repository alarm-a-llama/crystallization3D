/**
 * A crystallisation simulation
 * by Jakob Abu Hamdan
 *
 * keys:
 * n = show attraction vectors
 * m = show moving particles
 * l = different lighting
 * r = reset - start new crystal
 * c = change color
 * drag the mouse for camera rotation
 **/

//dont tweak here
public final static byte FROZEN = 0;
public final static byte MOVING = 1;
particle[] allParticles = new particle[1];
long mainTime, initTime, finTime = 0;
float currentCrystalSize = 0;
boolean fin = false;
PVector lightVector;
int particleLength = allParticles.length;
int currentCamRotation = 0;

//tweak here
final static int movingParticles = 2500; //choose fewer for less lag but slower growth
public final static int particleSize = 12; 
final static int finalCrystalSize = particleSize * 60;

final static int attractionDistance = particleSize * 30;  //at which distance do particles get attracted and frozen to crystal
final static int earlySpawnDistance = particleSize * 20;  //min spawn distance when crystal small
final static int lateSpawnDistance = particleSize * 20;  //min spawn distance when crystal is big (choose smaller if growth slows too much with increasing crystal size)
final static int spawnRange = particleSize * 15;  //size of spawn "belt" (max spawn distance)
final static int maxParticleDistance = particleSize * 20; //distance at which a particle is considered rogue and replaced

final static float restrictAngle = PI / 180 * 60; //from 0(not restricted= to 180(only straight/make sea urchin) or inverse if you change from > to < in freezecheck code below
final static long finWait = 1000; //currently not in use, reset timing depends on camera rotation
final static int endCamRotation = 360; //in degrees

boolean showAttractors = false;
boolean showMovingParticles = false;
boolean altLighting = false;

public int crystalColor = 0;

void setup() {  
  //size (800, 600, P3D);
  fullScreen(P3D);
  colorMode(HSB, 255);
  noSmooth();
  noStroke();
  reset();
}

//new particles are placed outside the crystal but not too far
particle createParticle() {
  return(new particle(PVector.random3D().setMag(map(currentCrystalSize, 0, finalCrystalSize, earlySpawnDistance + currentCrystalSize, lateSpawnDistance + currentCrystalSize) + random(spawnRange)), MOVING));
}

void reset () {
  currentCrystalSize = 0;
  mainTime = 0;
  initTime = 0;
  allParticles = new particle[1]; 
  allParticles[0] = new particle(new PVector(1, 5, 10), FROZEN); //this offset from origin is necessary for angle calculation
  allParticles[0].freeze();
  for (int i = 0; i<movingParticles; i++) {
    allParticles = (particle[])append(allParticles, createParticle());
  }
  camera(1, 5, (height / 2.0) / tan(PI * 30.0 / 180.0), 1, 5, 10, 0, 1, 0);
  beginCamera();  
  rotateX(TWO_PI / random(TWO_PI));
  endCamera();
  initTime = millis();
  fin = false;
  particleLength = allParticles.length;  
  currentCamRotation = 0;
}

void draw() {
  ambientLight(0, 0, 255);
  if (altLighting) {
    noLights();
    ambientLight(0, 0, 55);
    pointLight(0, 0, 200, lightVector.x, lightVector.y, lightVector.x);
  }

  background(51);
  particleLength = allParticles.length;
  if (!fin) {
    mainTime = millis();
    for (int i = 0; i < particleLength; i++) {
      if (allParticles[i].state == MOVING) {
        allParticles[i].move();
        //check if there's a frozen particle in attraction range:
        for (int j = 0; j < particleLength; j++) {
          if (PVector.dist(allParticles[i].position, allParticles[j].position) <= attractionDistance && allParticles[j].state == FROZEN && PVector.angleBetween(allParticles[i].position, PVector.sub(allParticles[j].position, allParticles[i].position)) > restrictAngle) {// && PVector.angleBetween(allParticles[i].position,PVector.sub(allParticles[j].position,allParticles[i].position)) <3.15  ){                       
            allParticles[i].freeze(allParticles[j]);
            currentCrystalSize = max(currentCrystalSize, allParticles[i].position.mag());
            //replace frozen particle         
            allParticles = (particle[])append(allParticles, createParticle());           
            break; //don't freeze twice
          }
        }
        //check for max crystal size
        if (allParticles[i].position.mag() >= finalCrystalSize) {
          if (allParticles[i].state == FROZEN) {           
            fin = true;
            finTime = mainTime;
          }
          //replace rogue particles
          if (allParticles[i].position.mag() >= currentCrystalSize + maxParticleDistance) { 
            allParticles[i] = createParticle();
          }
        }
      }
    }
    beginCamera();  
    rotateY(TWO_PI /360 * 1);
    endCamera();
  }

  //rotato that potato
  else if (fin) {
    if (currentCamRotation<=endCamRotation) {
      beginCamera();  
      rotateY(TWO_PI / 360.0);
      endCamera();
      currentCamRotation++;
    } else {
      reset();
    }
  }

  for (int i = 0; i<particleLength; i++) {
    if (allParticles[i].state == FROZEN) {
      allParticles[i].show();
    } else if (showMovingParticles) {
      allParticles[i].show();
    }
  }
}

void mouseDragged() {
  beginCamera();  
  rotateY(TWO_PI/width*(mouseX-pmouseX));
  rotateX(TWO_PI/height*(pmouseY-mouseY)); 
  endCamera();
}

void keyPressed() {
  if (key == 'm' || key == 'M') {
    showMovingParticles = !showMovingParticles;
  }
  if (key == 'l' || key == 'L') {
    altLighting = !altLighting;
    lightVector = PVector.random3D().setMag(finalCrystalSize * 1.5);
  }
  if (key == 'n' || key == 'N') {
    showAttractors = !showAttractors;
  }
  if (key == 'r' || key == 'R') {
    reset();
  }
  if (key == 'c' || key == 'C') {
    crystalColor = (crystalColor + 8) % 256;
  }
}