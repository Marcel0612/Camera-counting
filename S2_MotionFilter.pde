/*
 * This part of the process takes care of comparing the old and new frame and calculating a difference in pixels
 * The difference is smoothened to lenghten their time of survival and keep a moving target well populated.
 * It is then enlarged (bleeded) to fully cover the moving object.
 * With the movement marked, it is possible to procedurally generate a background image - a motion filter.
 *
 * At the same time the background image and current frame is compared.
 * If a pixel difference is close within the sensitivity range, it is cleared.
 * This eventually generates a raw difference map between the background and the current frame.
 */

void S2_motion_calc() {
  changedPixels.clear();

  for (int p = 0; p < frame.pixels.length; p++) {
    color new_color = frame.pixels[p];
    float motionDiff = getColorDiff(new_color, framePrev.pixels[p]);
    float deltaDiff = getColorDiff(frame.pixels[p], background.pixels[p]);

    // Apply smoothing while storing the frame pixel difference
    if (motionDiff > frameDifference.pixels[p]) {
      frameDifference.pixels[p] = motionDiff;
    } else {
      frameDifference.pixels[p] += (1.0F - motionSmoothening) * (motionDiff - frameDifference.pixels[p]);
    }

    // Clear frame difference if the difference between background and frame is within threshold
    if (deltaDiff <= sensitivity) {
      frameDifference.pixels[p] = 0.0F;
      deltaDiff = 0.0F;
    }

    // Store the delta difference
    frameDelta.pixels[p] = deltaDiff;

    // Mark areas changed if significant difference is observed
    int x = p % videoWidth;
    int y = p / videoWidth;
    if (isDifferential(x, y)) {
      // Do not mark changed if pixel neighbor is already marked
      boolean c = isDifferential(x-1, y) && isDifferential(x+1, y) &&
        isDifferential(x, y-1) && isDifferential(x, y+1);

      if (!c) {
        markAreaChanged(x, y);
      }
    }
  }

  // Update the background image of non-changed pixels
  for (int p = 0; p < videoPixels; p++) {
    if (!changedPixels.get(p)) {
      background.pixels[p] = frame.pixels[p];
    }
  }
}

/* Checks if a pixel has seen a significant difference */
boolean isDifferential(int x, int y) {
  if (x < 0 || y < 0 || x >= videoWidth || y >= videoHeight) {
    return false;
  }
  return frameDifference.pixels[x + y*videoWidth] >= 0.5F;
}

void markAreaChanged(int x, int y) {
  // Pixels are stored in horizontal rows
  // For each row, find the start-index and end-index
  // Fill the line in between

  int xmin = x - motionBleed;
  int xmax = x + motionBleed;
  if (xmin < 0) xmin = 0;
  if (xmax >= videoWidth) xmax = videoWidth-1;

  int idx_a, idx_b;
  for (int line = (y-motionBleed); line <= (y+motionBleed); line++) {
    if (line < 0 || line >= videoHeight) {
      continue;
    }
    idx_a = line*videoWidth + xmin;
    idx_b = line*videoWidth + xmax;
    for (int p = idx_a; p <= idx_b; p++) {
      changedPixels.set(p, true);
    }
  }
}

