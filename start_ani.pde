// Declare variables for animation
float angle = 0;
float maxDiameter = 100; // Maximum size of the circles
int numCircles = 8; // Number of circles to animate
PFont oldenglish;
PVector[] circlePositions = new PVector[3*numCircles];
float[] circleSizes = new float[3*numCircles];
int[] circleColors = new int[3*numCircles];
boolean animationDone = false;
boolean titledone = false;

void drawCircles() {
  for (int i = 0; i < numCircles; i++) {
    fill(circleColors[i]);
    noStroke();
    float x = lerp(circlePositions[i].x, width / 2, 0.05);
    float y = lerp(circlePositions[i].y, height / 2, 0.05);
    circlePositions[i].set(x, y);
    ellipse(x, y, circleSizes[i], circleSizes[i]);
  }
  for (int i = numCircles; i < 2*numCircles; i++) {
    fill(circleColors[i]);
    noStroke();
    float x = lerp(circlePositions[i].x, width / 2+200, 0.05);
    float y = lerp(circlePositions[i].y, height / 2, 0.05);
    circlePositions[i].set(x, y);
    ellipse(x, y, circleSizes[i], circleSizes[i]);
  }
  for (int i = 2*numCircles; i < 3*numCircles; i++) {
    fill(circleColors[i]);
    noStroke();
    float x = lerp(circlePositions[i].x, width / 2-200, 0.05);
    float y = lerp(circlePositions[i].y, height / 2, 0.05);
    circlePositions[i].set(x, y);
    ellipse(x, y, circleSizes[i], circleSizes[i]);
  }
  // Check if the animation is done
  if (frameCount > 200) {
    animationDone = true;
  }
}


void displayTitle() {
  fill(255);
  textSize(64);
  textFont(oldenglish);
  text("Circle Meal", width / 2, height / 2-50);
  textSize(48);
  text("Presented By Group 1:\nGroup Leader: Buffett",width / 2, height / 2+30);
  if(frameCount>500){titledone=true;}
}
