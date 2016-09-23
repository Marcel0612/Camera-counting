/*
 * Reads new frames from a video source and keeps track of a previous frame accordingly
 */

// Variables are initialized at runtime
Capture capture;
Movie movie;
boolean firstFrame;

// Initializes the source video
void S1_initialize() {
  // Open the source movie or camera feed
  if (useMovieFile) {
    movie = new Movie(this, movieFilePath);
    movie.play();
    //movie.speed(0.5);
    //  movie.jump(movieStartTime);
  } else {
    // List all available cameras
    String[] cameras = Capture.list();
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    capture = new Capture(this, videoWidth, videoHeight, webcamName);
    capture.start();
  }

  // First frame sets the previous frame to the current
  firstFrame = true;
}

// Gathers the next source video frame, returns false if no frame is available
boolean S1_source_nextFrame() {
  // Refresh video data
  color newFramePixels[] = null;
  if (useMovieFile) {
    if (movie.available()) {
      movie.read();
      newFramePixels = movie.pixels;
    }
  } else {
    if (capture.available()) {
      capture.read();
      newFramePixels = capture.pixels;
    }
  }

  // Only perform operations if a new frame is made available
  if (newFramePixels == null) {
    return false;
  }

  // Store the previous frame if available
  if (!firstFrame) {
    copyPixels(frame.pixels, framePrev);
  }

  copyPixels(newFramePixels, frame);    // Store color data

  // If the first frame, the previous frame is set to the current one
  if (firstFrame) {
    copyPixels(frame.pixels, framePrev);
    firstFrame = false;
  }
  return true;   // Frame available
}

void copyPixels(color pixels[], PImage imageTo) {
  System.arraycopy(pixels, 0, imageTo.pixels, 0, pixels.length);
}

