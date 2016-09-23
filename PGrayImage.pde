/*
 * Stores grayscale (black-white) image data
 */

public class PGrayImage {
  public int width;
  public int height;
  public float[] pixels;
  private PImage draw_buff;

  public PGrayImage(int width, int height) {
    this.width = width;
    this.height = height;
    this.pixels = new float[width * height];
  }

  public void load(color colorPixels[]) {
    for (int i = 0; i < pixels.length; i++) {
      color c = colorPixels[i];
      pixels[i] = (float) (red(c) + green(c) + blue(c)) / 765.0F;
    }
  }

  public void load(PGrayImage image) {
    System.arraycopy(image.pixels, 0, this.pixels, 0, pixels.length);
  }

  public float getPixel(int x, int y) {
    return pixels[x + y * width];
  }

  public void setPixel(int x, int y, float value) {
    pixels[x + y * width] = value;
  }

  public void draw(color overlayColor) {
    if (draw_buff == null) {
      draw_buff = new PImage(width, height);
    }

    float r = red(overlayColor);
    float g = green(overlayColor);
    float b = blue(overlayColor);
    float a = alpha(overlayColor);
    for (int i = 0; i < pixels.length; i++) {
      float f = a * pixels[i];
      if (f <= 1F) f = 1F;

      draw_buff.pixels[i] = color(r, g, b, f);
    }
    draw_buff.updatePixels();
    image(draw_buff, 0.0F, 0.0F);
  }

  public void drawTo(PImage destImage, color overlayColor) {
    float fr = (float) red(overlayColor);
    float fg = (float) green(overlayColor);
    float fb = (float) blue(overlayColor);
    float fa = (float) alpha(overlayColor) / 255.0F;
    fr *= fa;
    fg *= fa;
    fb *= fa;

    color oldPixel;
    float r, g, b, a;
    for (int i = 0; i < pixels.length; i++) {
      oldPixel = destImage.pixels[i];
      r = red(oldPixel);
      g = green(oldPixel);
      b = blue(oldPixel);
      r += (pixels[i] * fr);
      g += (pixels[i] * fg);
      b += (pixels[i] * fb);
      if (r > 255.0F) r = 255.0F;
      if (g > 255.0F) g = 255.0F;
      if (b > 255.0F) b = 255.0F;
      destImage.pixels[i] = color(r, g, b);
    }
  }
}

