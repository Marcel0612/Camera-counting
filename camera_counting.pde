//This program takes video input and counts the number of blobs that go over the centre counting line. 

// Calling the needed libraries
import processing.video.*;
import blobscanner.*;
import controlP5.*;

// Video source
int videoWidth = 320;
int videoHeight = 180;
int videoPixels = videoWidth * videoHeight;
String webcamName = "FaceTime HD Camera";
String movieFilePath = "/Users/Desktop/github/camera_counting/myvid10.mp4";
float movieStartTime = 40.0F;
boolean useMovieFile = true;

// Image results for all stages to use
PImage frame = new PImage(videoWidth, videoHeight);
PImage framePrev = new PImage(videoWidth, videoHeight);
PImage background = new PImage(videoWidth, videoHeight);
PGrayImage frameDifference = new PGrayImage(videoWidth, videoHeight);
PBitImage changedPixels = new PBitImage(videoWidth, videoHeight, color(255, 0, 0, 64));
PGrayImage frameDelta = new PGrayImage(videoWidth, videoHeight);
PBitImage deltaPixels = new PBitImage(videoWidth, videoHeight, color(255, 0, 0, 128));

// Slider options
float amplification = 8.0F;
float sensitivity = 0.4F;
float motionSmoothening = 0.85F;
float motionThreshold = 0.5F;
int   motionBleed = 20;
float deltaThreshold = 0.2F;

// Image view options
boolean showSourceVideo = true;
boolean showBackground = false;
boolean showMotion = false;
boolean showDelta = true;
boolean showDeltaBlob = true;

// Displays UI
ControlP5 cp5;

void setup() {
  size(videoWidth, videoHeight);
  S1_initialize(); // Initialize source video feed
  initUI();  // Initialize UI
}

void draw() {
  fill(200, 0, 0);
  strokeWeight(1);
  rect(160, 0, 10, 180);

  // Perform all stages of operation
  if (!S1_source_nextFrame()) {
    return;
  }

  S2_motion_calc();   // Calculate frame differences
  S3_blobs_threshold();   // Also performs thesholding/bleeding

  if (showSourceVideo) {
    frame.updatePixels();
    image(frame, 0.0F, 0.0F);
  } else if (showBackground) {
    background.updatePixels();
    image(background, 0.0F, 0.0F);
  } else {
    // Black background
    background(0);
  }

  if (showMotion) {
    frameDifference.draw(color(0, 255, 0));
    changedPixels.draw();
  }
  if (showDelta) {
    frameDelta.draw(color(255, 255, 255));
    deltaPixels.draw();
  }
  if (showDeltaBlob) {
    S4_blobs_detect();
  }

  // Display a frame rate in the bottom-right corner
  fill(0);
  text(Integer.toString((int) frameRate) + " FPS", videoWidth - 50, videoHeight - 15);
}

float getColorDiff(color c1, color c2) {
  float r1 = red(c1); 
  float g1 = green(c1); 
  float b1 = blue(c1);
  float r2 = red(c2); 
  float g2 = green(c2); 
  float b2 = blue(c2);
  float dist = amplification * dist(r1, g1, b1, r2, g2, b2) / 255.0F;
  if (dist > 1.0F) dist = 1.0F;
  return dist;
}

void initUI() {
  // Control P5 object for HUD
  cp5 = new ControlP5(this);

  // Switch between processed frame data results
  cp5.addToggle("showSourceVideo")
    .setLabel("Source")
      .setPosition(20, 20)
        .setSize(10, 10);
  cp5.addToggle("showBackground")
    .setLabel("Background")
      .setPosition(80, 20)
        .setSize(10, 10);
  cp5.addToggle("showMotion")
    .setLabel("Motion")
      .setPosition(140, 20)
        .setSize(10, 10);
  cp5.addToggle("showDelta")
    .setLabel("Delta")
      .setPosition(200, 20)
        .setSize(10, 10);
  cp5.addToggle("showDeltaBlob")
    .setLabel("DeltaBlob")
      .setPosition(260, 20)
        .setSize(10, 10);

  // This slider changes how pixel differences are factored in, affecting motion and delta detection
  // If a lot of noise is observed, lowering the amplification might help
  cp5.addSlider("amplification")
    .setPosition(0, 60)
      .setRange(0.0F, 10.00F)
        .setSize(40, 10);

  // This slider sets how much change in pixel data is required to count as a valid difference
  // This is 
  cp5.addSlider("sensitivity")
    .setPosition(0, 75)
      .setRange(0.0F, 1.0F)
        .setSize(40, 10);

  // This slider changes the rate at which the differential is smoothened
  // A higher value causes more smoothening but also prolonged background errors
  cp5.addSlider("motionSmoothening")
    .setPosition(0, 90)
      .setRange(0.5F, 1.0F)
        .setSize(40, 10);

  // This slider sets the bleeding of pixels - creates cubes around pixels of motion
  cp5.addSlider("motionBleed")
    .setPosition(0, 105)
      .setRange(0, 200)
        .setSize(40, 10);

  // This slider sets the delta image threshold - this image is bled and then fed to blob detection
  cp5.addSlider("deltaThreshold")
    .setPosition(0, 120)
      .setRange(0.0F, 1.0F)
        .setSize(40, 10);
}

