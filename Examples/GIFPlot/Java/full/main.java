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
    
    SWIGTYPE_p_ColorMap cmap  = gifplot.new_ColorMap("cmap");
    SWIGTYPE_p_FrameBuffer frame = gifplot.new_FrameBuffer(500,500);
    gifplot.FrameBuffer_clear(frame,(short)gifplot.BLACK);
    
    SWIGTYPE_p_Plot3D p3    = gifplot.new_Plot3D(frame,xmin,ymin,zmin,xmax,ymax,zmax);
    gifplot.Plot3D_lookat(p3,2*(zmax-zmin));
    gifplot.Plot3D_autoperspective(p3,40);
    gifplot.Plot3D_rotu(p3,60);
    gifplot.Plot3D_rotr(p3,30);
    gifplot.Plot3D_rotd(p3,10);
    
    System.out.println( "Making a nice 3D plot..." );
    gifplot.Plot3D_clear(p3,(short)gifplot.BLACK);
    gifplot.Plot3D_start(p3);
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
        gifplot.Plot3D_solidquad(p3,x,y,z1,x+dx,y,z2,x+dx,y+dy,z3,x,y+dy,z4,(short)(c+16));
        y = y + dy;
      }
      x = x + dx;
    }

    gifplot.FrameBuffer_writeGIF(frame,cmap,"image.gif");
    System.out.println( "Wrote image.gif" );
  } 

  // Here is the function to plot
  public static double func(double x, double y) {
    return 5*java.lang.Math.cos(2*java.lang.Math.sqrt(x*x+y*y))*java.lang.Math.exp(-0.3*java.lang.Math.sqrt(x*x+y*y));
  }
}
