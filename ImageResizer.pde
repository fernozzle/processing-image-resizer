/*
 * Just plop this PDE into your sketch folder.
 * WARNING: Very slow.
 * 
 * Usage:
 * ImageResizer resizer = new ImageResizer();
 * resizer.image(img, 0, 0, 50, 50);
 *
 * https://github.com/fernozzle/processing-image-resizer
 * zlib License. Copyright (c) 2014 Michael Huang.
 */

public class ImageResizer {

  public void image(PImage img, float imgX, float imgY, float imgWidth, float imgHeight) {
    
    loadPixels();
    img.loadPixels();
    
    // Coordinates of the affected pixels of the target image
    int minTargetX = Math.max(floor(imgX            ), 0         );
    int maxTargetX = Math.min(ceil (imgX + imgWidth ), width  - 1);
    int minTargetY = Math.max(floor(imgY            ), 0         );
    int maxTargetY = Math.min(ceil (imgY + imgHeight), height - 1);
    
    // These ratios will be used for converting coordinate systems.
    float xScale = imgWidth  / img.width;
    float yScale = imgHeight / img.height;
    
    // Iterate through the aforementioned affected pixels of the target image.
    for(int targetY = minTargetY; targetY <= maxTargetY; targetY++)
    for(int targetX = minTargetX; targetX <= maxTargetX; targetX++) {
      
      float targetR = 0;
      float targetG = 0;
      float targetB = 0;
      float targetA = 0;
      
      // Coordinates of the pixels to sample from the source image
      float minSourceX = (targetX - imgX) / xScale;
      float maxSourceX = minSourceX + (1 / xScale);
      float minSourceY = (targetY - imgY) / yScale;
      float maxSourceY = minSourceY + (1 / yScale);
      
      // Iterate through the aforementioned sampled pixels of the source image.
      for(int sourceX = Math.max((int) minSourceX, 0); sourceX <= Math.min((int) maxSourceX, img.width  - 1); sourceX++)
      for(int sourceY = Math.max((int) minSourceY, 0); sourceY <= Math.min((int) maxSourceY, img.height - 1); sourceY++) {
        // Coordinates of the source pixel according to the target image
        float sourcePixelTargetMinX = sourceX * xScale + imgX;
        float sourcePixelTargetMaxX = sourcePixelTargetMinX + xScale;
        float sourcePixelTargetMinY = sourceY * yScale + imgY;
        float sourcePixelTargetMaxY = sourcePixelTargetMinY + yScale;
        
        // Crop this source pixel to the dimensions of the target pixel
        sourcePixelTargetMinX = Math.max(sourcePixelTargetMinX, targetX    );
        sourcePixelTargetMaxX = Math.min(sourcePixelTargetMaxX, targetX + 1);
        sourcePixelTargetMinY = Math.max(sourcePixelTargetMinY, targetY    );
        sourcePixelTargetMaxY = Math.min(sourcePixelTargetMaxY, targetY + 1);
        
        float sourcePixelTargetArea =
          (sourcePixelTargetMaxX - sourcePixelTargetMinX) *
          (sourcePixelTargetMaxY - sourcePixelTargetMinY);
        
        int sourceIndex = indexFromCoords(sourceX, sourceY, img.width);
        color sourceColor = img.pixels[sourceIndex];
        targetR += red  (sourceColor) * sourcePixelTargetArea;
        targetG += green(sourceColor) * sourcePixelTargetArea;
        targetB += blue (sourceColor) * sourcePixelTargetArea;
        targetA += alpha(sourceColor) * sourcePixelTargetArea;
      }
      
      color targetColor = color(targetR, targetG, targetB);
      int targetIndex = indexFromCoords(targetX, targetY, width);
      
      pixels[targetIndex] = lerpColor(pixels[targetIndex], targetColor, targetA / 255);
    }
    updatePixels();
  }
  
  private int indexFromCoords(int x, int y, int width) {
    return (y * width) + x;
  }
}
