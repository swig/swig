int main()
{
  // Draw some simple shapes
  write("Drawing some basic shapes\n");

   .simple.ColorMap cmap = .simple.new_ColorMap();
   .simple.FrameBuffer f = .simple.new_FrameBuffer(400, 400);

  // Clear the picture
  .simple.FrameBuffer_clear(f, .simple.BLACK);

  // Make a red box
  .simple.FrameBuffer_box(f, 40, 40, 200, 200, .simple.RED);

  // Make a blue circle
  .simple.FrameBuffer_circle(f, 200, 200, 40, .simple.BLUE);

  // Make green line
  .simple.FrameBuffer_line(f, 10, 390, 390, 200, .simple.GREEN);

  // Write an image out to disk
  .simple.FrameBuffer_writeGIF(f, cmap, "image.gif");
  write("Wrote image.gif\n");

  .simple.delete_FrameBuffer(f);
  .simple.delete_ColorMap(cmap);
  
  return 0;
}

