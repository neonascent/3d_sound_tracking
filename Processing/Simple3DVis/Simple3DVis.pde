import processing.opengl.*;
import processing.serial.*;
import toxi.geom.*;
import toxi.processing.*;

float[][] lines_direction;
float[] lines_length;
float[] lines_life;
int nextLine;

int dieSpeed= 1;
int lines = 500;

Quaternion q;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

// some serial processing from : http://wiring.org.co/learning/libraries/sendingmultipledata.html
int linefeed = 10;   // Linefeed in ASCII
int numSensors = 3;  // we will be expecting for reading data from four sensors
float angles[];       // array to read the 4 values

Quaternion setup;


void setup() {
  size(1280, 800, OPENGL);


  q = new Quaternion();
  setup = new Quaternion(Quaternion.createFromEuler( radians(90), radians(180), radians(90)));

  setupLines();
  noStroke();
  //sphereDetail(12);
  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
  // choose port
  // String portName = "/dev/tty.HC-06-DevB"; // mac
  String portName = "COM42";
  myPort = new Serial(this, portName, 9600);
}

void setupLines() {
  lines_direction = new float[lines][4];
  lines_length = new float[lines];
  lines_life = new float[lines];
  nextLine = 0;

  for (int i = 0; i < lines; i++) {
    lines_direction[i][0] = 0f;
    lines_direction[i][1] = 0f;
    lines_direction[i][2] = 0f;
    lines_direction[i][3] = 0f;
    lines_length[i] = 0f;
    lines_life[i] = 0f;
  }
}

void drawLines() {
  int offset = 0; // -20
  for (int i = 0; i < lines; i++) {
    if (lines_life[i] > 0.1) { 
      pushMatrix();
      rotate(lines_direction[i][0], lines_direction[i][1], lines_direction[i][2], lines_direction[i][3]);
      noStroke();
      //stroke(255, lines_life[i]);
      fill(255, lines_life[i]);
      lines_life[i] -= dieSpeed;
      

      beginShape(TRIANGLES);
      vertex(85, 0, offset);
      vertex(85+lines_length[i], 0, offset-20);
      vertex(85+lines_length[i], 0, offset+20);
      endShape();     


       //line(0, 0, offset, lines_length[i], 0, offset);
      popMatrix();
    }
  }
}



void addLine(float a, float b, float c, float d, float volume) {

  nextLine = (nextLine+1) % lines;

  lines_direction[nextLine][0] = a;
  lines_direction[nextLine][1] = b;
  lines_direction[nextLine][2] = c;
  lines_direction[nextLine][3] = d;
  lines_life[nextLine] = map(volume, 0, 1024, 0, 255);
  lines_length[nextLine] = map(volume, 0, 1024, 100, 500);
} 

void draw() {
  if (angles != null) { 
    lights();
    background(0);
    translate(width / 2, height / 2, -200);

    drawLines();

    q = new Quaternion(angles[0], angles[1], angles[2], angles[3]);


    float o[] = setup.multiply(q).toAxisAngle();

    // add sound line
    addLine(o[0], o[1], o[2], o[3], angles[4]);    

    pushMatrix();
    rotate(o[0], o[1], o[2], o[3]);

    fill(180, 255);
    stroke(255, 255);
    float size = angles[4]/10;
    box(size,size,size);
   //  box(170,100,50);
    popMatrix();
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

