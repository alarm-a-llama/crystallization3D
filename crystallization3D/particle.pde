class particle {
  PVector position;
  int state;
  long freezeTime = 0;

  particle(PVector position_, int state_) {
    position = position_;
    state = state_;
  }

  void freeze() {
    state = FROZEN;
    freezeTime = millis();
  }

  // freeze particle to the crystal - move it along its path of attraction
  void freeze(particle frozenTo) {    
    if (showAttractors) {
      stroke(255, 160);
      strokeWeight(3);
      line(frozenTo.position.x, frozenTo.position.y, frozenTo.position.z, position.x, position.y, position.z);
    }
    position = PVector.add(frozenTo.position, PVector.sub(position, frozenTo.position).setMag(particleSize));
    line(frozenTo.position.x, frozenTo.position.y, frozenTo.position.z, position.x, position.y, position.z);
    noStroke();
    state = FROZEN;
    freezeTime = millis();
  }
  
  // simulate brownian motion   
  void move() {
    PVector rndOffset = new PVector(((int)(random(3))-1)*particleSize, ((int)(random(3))-1)*particleSize, ((int)(random(3))-1)*particleSize);
    position.add(rndOffset);
  }

  void show() {
    int colVal = (int)map(freezeTime, initTime, mainTime, 10, 255);
    color boxColor = color(crystalColor, colVal, colVal);

    if (state==MOVING) {
      boxColor = color(crystalColor + 8, 255, 255, 50);
    }

    fill(boxColor);
    pushMatrix();
    translate(position.x, position.y, position.z );
    if (state==MOVING) {
      box((int)particleSize/2);
    } else {
      box(particleSize);
    }
    popMatrix();
  }
}