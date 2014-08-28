import processing.opengl.*;
import saito.objloader.*;
import processing.serial.*;

float[][] lines_direction;
float[] lines_length;
float[] lines_life;
int nextLine;

int dieSpeed= 1;
int lines = 500;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

// some serial processing from : http://wiring.org.co/learning/libraries/sendingmultipledata.html
int linefeed = 10;   // Linefeed in ASCII
int numSensors = 3;  // we will be expecting for reading data from four sensors
float angles[];       // array to read the 4 values

// model
OBJModel model;

void setup() {
  size(700, 700, OPENGL);

  model = new OBJModel(this, "m.obj", "relative", QUADS);
  model.enableDebug();

  model.scale(100);
  model.translateToCenter();

  setupLines();
  noStroke();
  //sphereDetail(12);
  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
  // choose port
  String portName = "COM42";
  myPort = new Serial(this, portName, 9600);
}

void setupLines() {
  lines_direction = new float[lines][3];
  lines_length = new float[lines];
  lines_life = new float[lines];
  nextLine = 0;

  for (int i = 0; i < lines; i++) {
    lines_direction[i][0] = 0f;
    lines_direction[i][1] = 0f;
    lines_direction[i][2] = 0f;
    lines_length[i] = 0f;
    lines_life[i] = 0f;
  }

  lines_direction[0][0] = 0;
  lines_direction[0][1] = 0;
  lines_direction[0][2] = 0;
  lines_length[0] = 400;
  lines_life[0] = 200;
}

void drawLines() {
  for (int i = 0; i < lines; i++) {
    if (lines_life[i] > 0.1) { 
      pushMatrix();
      rotateX(lines_direction[i][0]);
      rotateZ(lines_direction[i][1]);
      rotateY(lines_direction[i][2]);
      stroke(255, lines_life[i]);
      lines_life[i] -= dieSpeed;
      line(0, 0, 0, lines_length[i], 0, 0);
      popMatrix();
    }
  }
}

void addLine(float a, float b, float c, float volume) {

  nextLine = (nextLine+1) % lines;

  lines_direction[nextLine][0] = a;
  lines_direction[nextLine][1] = b;
  lines_direction[nextLine][2] = c;
  lines_life[nextLine] = map(volume, 0, 1024, 0, 255);
  lines_length[nextLine] = map(volume, 0, 1024, 100, 500);
} 

void draw() {
  if (angles != null) { 
    lights();
    background(0);
    translate(width / 2, height / 2, -200);
    drawLines();
    float a = map(angles[0], -180, 180, -PI, PI);
    float b = map(angles[1], -180, 180, -PI, PI);
    float c = map(-angles[2], -180, 180, -PI, PI);

    addLine(a, b, c, angles[3]);


    rotateX(a);
    rotateZ(b);
    rotateY(c);
    
    noStroke();
    noFill();
    //stroke(150, 50);
    model.draw();
    // box(200,100,170);
  }
}




void serialEvent(Serial myPort) {

  // read the serial buffer:
  String myString = myPort.readStringUntil(linefeed);

  // if you got any bytes other than the linefeed:
  if (myString != null) {

    myString = trim(myString);

    // split the string at the commas
    // and convert the sections into integers:
    String[] parts = split(myString, ':');
    if (parts.length > 1) {
      println("New string: " + parts[1]);
      angles = float(split(parts[1], ','));

      // print out the values you got:

      for (int sensorNum = 0; sensorNum < angles.length; sensorNum++) {
        print("Angles " + sensorNum + ": " + angles[sensorNum] + "\t");
      }

      // add a linefeed after all the sensor values are printed:
      println();
    }
  }
}

