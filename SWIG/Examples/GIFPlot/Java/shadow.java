import gifplot;

public class shadow {

  static {
    System.loadLibrary("jgifplot");
  }

  public static void main(String argv[]) {
    FrameBuffer fb = new FrameBuffer(300, 300);
    ColorMap cm = new ColorMap("cmap");
    
    fb.clear(gifplot.BLACK);
    fb.drawstring(50, 50, gifplot.WHITE, gifplot.BLACK, "Hello world", gifplot.VERTICAL);
    fb.solidbox(200, 200, 220, 240, gifplot.BLUE);
    fb.line(0, 290, 293, 50, gifplot.RED);
    fb.circle(100, 100, 10, gifplot.YELLOW);
    fb.writeGIF(cm, "plot.gif");

    System.out.println("Image written to 'plot.gif'");
  }
}
