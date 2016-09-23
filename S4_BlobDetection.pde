/*
 * Performs blob detection on the produced delta threshold image
 */

void S4_blobs_detect() {
  // Perform blob detection using the produced delta threshold image
  Detector bd = new Detector(this, deltaPixels.color0);
  bd.findBlobs(deltaPixels.image.pixels, videoWidth, videoHeight);
  bd.loadBlobsFeatures(); 
  bd.findCentroids();
  bd.weightBlobs(false);
  bd.findCentroids();
  bd.drawSelectBox(400, color(255, 0, 0), 1);
  bd.imageFindBlobs(deltaPixels.image);

  // Draw rectangles around found blobs
  if (bd.getBlobsNumber() >= 1) {
    for (int i = 0; i < bd.getBlobsNumber (); i++) {
      if ( bd.getBlobWeight(i) > 500) {
        stroke(0, 255, 0);
        strokeWeight(5);

        //...computes and prints the centroid coordinates x y to the console...
        Xcoordinate[i] = int(bd.getBoxCentX(i));
        Ycoordinate[i]= int(bd.getBoxCentY(i));
        //print( + (i+1) + "," + int(bd.getCentroidX(i)));
        //println("," + int(bd.getCentroidY(i)));

        //...and draws a point to their location. 
        point(bd.getCentroidX(i), bd.getCentroidY(i));

        //Write coordinate next to the object.
        fill(255, 0, 0);
        text("x-> " + bd.getCentroidX(i) + "\n" + "y-> " + bd.getCentroidY(i), bd.getCentroidX(i), bd.getCentroidY(i)-7);

        // Counting the people
        if (Xcoordinate[i] <  20 ||  Xcoordinate[i] >  300 && Remember[i] == 1) {
          Remember[i] = 0;
        }

        if (Xcoordinate[i] >  160 &&   Xcoordinate[i] < 170 && Remember[i] == 0) {
          counter+=1;
          Remember[i] = 1;
        }

        print((i+1) + "," + Xcoordinate[0]);
        print("," + Ycoordinate[0]);
        println("       counter= " + counter);
      }
    }
  }
}

