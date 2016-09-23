/*
 * An image that only shows two possible colors
 */

public class PBitImage {
  public int width;
  public int height;
  public PImage image;
  public color color0;
  public color color1;

  public PBitImage(int width, int height, color color1) {
    this(width, height, color(0, 1), color1);
  }

  public PBitImage(int width, int height, color color0, color color1) {
    this.width = width;
    this.height = height;
    this.color0 = color0;
    this.color1 = color1;
    this.image = new PImage(width, height);
  }

  public void clear() {
    for (int i = 0; i < this.image.pixels.length; i++) {
      this.image.pixels[i] = color0;
    }
  }

  public void set(int pixelIdx, boolean value) {
    this.image.pixels[pixelIdx] = value ? color1 : color0;
  }

  public boolean get(int pixelIdx) {
    return this.image.pixels[pixelIdx] == color1;
  }

  public void draw() {
    this.image.updatePixels();
    image(this.image, 0, 0);
  }
}

