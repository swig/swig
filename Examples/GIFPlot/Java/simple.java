import gifplot;

public class simple {

  static {
    System.loadLibrary("jgifplot");
  }

  public static void main(String argv[]) {
    long f = gifplot.new_FrameBuffer(300, 300);
    long c = gifplot.new_ColorMap("cmap");

    gifplot.FrameBuffer_clear(f, gifplot.BLACK);
    gifplot.FrameBuffer_drawstring(f, 50, 50, gifplot.WHITE, gifplot.BLACK, "Hello world", gifplot.HORIZONTAL);
    gifplot.FrameBuffer_solidbox(f, 200, 200, 220, 240, gifplot.BLUE);
    gifplot.FrameBuffer_line(f, 0, 290, 293, 50, gifplot.RED);
    gifplot.FrameBuffer_circle(f, 100, 100, 10, gifplot.YELLOW);
    gifplot.FrameBuffer_writeGIF(f, c, "plot.gif");

    System.out.println("Image written to 'plot.gif'");
  }
}
