// Plot a 3D function

import java.lang.Math;

public class main {

  static {
    try {
        System.loadLibrary("gifplot");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    
    // Here are some plotting parameters
    double xmin = -5.0;
    double xmax =  5.0;
    double ymin = -5.0;
    double ymax =  5.0;
    double zmin = -5.0;
    double zmax =  5.0;
    
    // Grid resolution
    int nxpoints =  60;
    int nypoints =  60;
    
    ColorMap cmap = new ColorMap("cmap");
    FrameBuffer frame = new FrameBuffer(500,500);
    frame.clear((short)gifplot.BLACK);
    
    Plot3D p3 = new Plot3D(frame,xmin,ymin,zmin,xmax,ymax,zmax);
    p3.lookat(2*(zmax-zmin));
    p3.autoperspective(40);
    p3.rotu(60);
    p3.rotr(30);
    p3.rotd(10);
    
    System.out.println( "Making a nice 3D plot..." );
    p3.clear((short)gifplot.BLACK);
    p3.start();
    double dx = 1.0*(xmax-xmin)/nxpoints;
    double dy = 1.0*(ymax-ymin)/nypoints;
    double cscale = 240.0/(zmax-zmin);
    double x = xmin;
    for (int i = 0; i < nxpoints; i++) {
      double y = ymin;
      for (int j = 0; j < nypoints; j++) {
        double z1 = func(x,y);
        double z2 = func(x+dx,y);
        double z3 = func(x+dx,y+dy);
        double z4 = func(x,y+dy);
        double c1 = cscale*(z1-zmin);
        double c2 = cscale*(z2-zmin);
        double c3 = cscale*(z3-zmin);
        double c4 = cscale*(z4-zmin);
        double c = (c1+c2+c3+c4)/4;
        if (c < 0) c = 0;
        if (c > 239) c = 239;
        p3.solidquad(x,y,z1,x+dx,y,z2,x+dx,y+dy,z3,x,y+dy,z4,(short)(c+16));
        y = y + dy;
      }
      x = x + dx;
    }

    frame.writeGIF(cmap,"image.gif");
    System.out.println( "Wrote image.gif" );
  } 

  // Here is the function to plot
  public static double func(double x, double y) {
    return 5*java.lang.Math.cos(2*java.lang.Math.sqrt(x*x+y*y))*java.lang.Math.exp(-0.3*java.lang.Math.sqrt(x*x+y*y));
  }
}
