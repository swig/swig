import gifplot;

public class ortho {

  static {
    System.loadLibrary("jgifplot");
  };

  public static double func(double x, double y) {
    double r;
    double f;
    r = Math.sqrt(x*x + y*y);

    f = (Math.sin(0.30*r*x)+Math.cos(0.30*r*y))/(1.0+r);
    return f;
  }

  public static void main(String argv[]) {

    FrameBuffer f;
    Plot3D      p3;
    ColorMap    cm;
    
    double      x,y;
    double      dx,dy;
    double      z1,z2,z3,z4;
    int         c1,c2,c3,c4;
    
    /* Create a framebuffer */

    f = new FrameBuffer(700,400);

    /* Load a colormap */

    cm = new ColorMap("cm15");

    /* Create a new 2D image */

    f.clear(gifplot.BLACK);
    p3 = new Plot3D(f,-6.3,-6.3,-1.5,6.3,6.3,1.5);

    /* Set viewing region in 2D plot */
    
    p3.setview(50,50,650,350);

    /* Set how far away from the image we are */
    p3.lookat(20);

    /* Set the field of view for the perspective */
    

//    Plot3D_autoperspective(p3,40);

    p3.autoortho();
    
    /* Now make a plot of a 3D function */
    
    /* Make a frame */

    f.noclip();
    f.box(49,49,650,350,gifplot.WHITE);
    p3.start();   /* Always call this prior to making an image */
    p3.clear(gifplot.BLACK);
    p3.rotu(60);
    p3.rotz(40);
    x = -6.3;
    dx = 0.25;
    while (x < 6.3) {
	y = -6.3;
	dy = 0.25;
	while (y < 6.3) {
	    z1 = func(x,y);
	    z2 = func(x+dx,y);
	    z3 = func(x+dx,y+dy);
	    z4 = func(x,y+dy);
	    c1 = (int) ((z1 + 1.0)*120) + 16;
	    if (c1 < 16) c1 = 16;
	    if (c1 > 254) c1 = 254;

	    c2 = (int) ((z2 + 1.0)*120) + 16;
	    if (c2 < 16) c2 = 16;
	    if (c2 > 254) c2 = 254;

	    c3 = (int) ((z3 + 1.0)*120) + 16;
	    if (c3 < 16) c3 = 16;
	    if (c3 > 254) c3 = 254;

	    c4 = (int) ((z4 + 1.0)*120) + 16;
	    if (c4 < 16) c4 = 16;
	    if (c4 > 254) c4= 254;

	    p3.interpquad(x,y,z1,(byte) c1,
			      x+dx,y,z2,(byte) c2,
			      x+dx,y+dy,z3,(byte) c3,
			      x,y+dy,z4,(byte) c4);
	    y = y + dy;
	}
	x = x + dx;
    }
    
    /* Make a GIF file */

    f.writeGIF(cm,"plot.gif");

    System.out.println("Image written to 'plot.gif'");
  }
}
