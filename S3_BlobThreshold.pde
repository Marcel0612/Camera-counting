/*
 * Takes the delta pixel image and performs some optimizations on it
 * The final 1-bit image is then generated through thresholding
 */

void S3_blobs_threshold() {
  // First blur the delta image
  fastblur(frameDelta, 14);

  // Store a thresholded version of the delta difference
  for (int p = 0; p < videoPixels; p++) {
    deltaPixels.set(p, frameDelta.pixels[p] > deltaThreshold);
  }
}


//int[] Xcoordinate; 
int[] Ycoordinate = new int[20]; 
int[] Xcoordinate = new int[20];

int[] Remember = new int[20];
int counter = 0;

void fastblur(PGrayImage img, int radius) {

  if (radius<1) {
    return;
  }
  int[] pix = new int[img.pixels.length];
  for (int i = 0; i < pix.length; i++) {
    pix[i] = (int) (img.pixels[i] * 255.0F);
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;

  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, yp, yi, yw;
  int vmin[] = new int[max(w, h)];

  int divsum=(div+1)>>1;
  divsum*=divsum;
  int dv[]=new int[256*divsum];
  for (i=0; i<256*divsum; i++) {
    dv[i]=(i/divsum);
  }

  yw=yi=0;

  int[][] stack=new int[div][3];
  int stackpointer;
  int stackstart;
  int[] sir;
  int rbs;
  int r1=radius+1;
  int routsum, goutsum, boutsum;
  int rinsum, ginsum, binsum;

  for (y=0; y<h; y++) {
    rinsum=ginsum=binsum=routsum=goutsum=boutsum=rsum=gsum=bsum=0;
    for (i=-radius; i<=radius; i++) {
      p=pix[yi+min(wm, max(i, 0))];
      sir=stack[i+radius];
      sir[0]=p;
      rbs=r1-abs(i);
      rsum+=sir[0]*rbs;
      if (i>0) {
        rinsum+=sir[0];
      } else {
        routsum+=sir[0];
      }
    }
    stackpointer=radius;

    for (x=0; x<w; x++) {

      r[yi]=dv[rsum];

      rsum-=routsum;
      gsum-=goutsum;
      bsum-=boutsum;

      stackstart=stackpointer-radius+div;
      sir=stack[stackstart%div];

      routsum-=sir[0];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
      }
      p=pix[yw+vmin[x]];

      sir[0]=p;

      rinsum+=sir[0];

      rsum+=rinsum;

      stackpointer=(stackpointer+1)%div;
      sir=stack[(stackpointer)%div];

      routsum+=sir[0];

      rinsum-=sir[0];

      yi++;
    }
    yw+=w;
  }
  for (x=0; x<w; x++) {
    rinsum=ginsum=binsum=routsum=goutsum=boutsum=rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius; i<=radius; i++) {
      yi=max(0, yp)+x;

      sir=stack[i+radius];

      sir[0]=r[yi];

      rbs=r1-abs(i);

      rsum+=r[yi]*rbs;

      if (i>0) {
        rinsum+=sir[0];
      } else {
        routsum+=sir[0];
      }

      if (i<hm) {
        yp+=w;
      }
    }
    yi=x;
    stackpointer=radius;
    for (y=0; y<h; y++) {
      pix[yi]=dv[rsum];

      rsum-=routsum;

      stackstart=stackpointer-radius+div;
      sir=stack[stackstart%div];

      routsum-=sir[0];

      if (x==0) {
        vmin[y]=min(y+r1, hm)*w;
      }
      p=x+vmin[y];

      sir[0]=r[p];

      rinsum+=sir[0];

      rsum+=rinsum;

      stackpointer=(stackpointer+1)%div;
      sir=stack[stackpointer];

      routsum+=sir[0];

      rinsum-=sir[0];

      yi+=w;
    }
  }

  for (int d = 0; d < pix.length; d++) {
    img.pixels[d] = (float) pix[d] / 255.0F;
  }
}

