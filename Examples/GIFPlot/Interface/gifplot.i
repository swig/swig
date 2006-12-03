//
// Graphics module
//
%module gifplot
%{
#include "gifplot.h"
%}

#if defined(SWIGJAVA ) || defined(SWIGPHP)
  %rename(make_default) ColorMap::default();
#endif

%rename(__getitem__)  ColorMap::getitem(int index);
%rename(__setitem__)  ColorMap::setitem(int index, int value);

/* Pixel is 8-bits */

typedef unsigned char Pixel;
typedef float Zvalue;

/* ------------------------------------------------------------------------
   ColorMap

   Definition and methods for colormaps
   ------------------------------------------------------------------------ */

typedef struct ColorMap {
  char          *name;

//
// %extend adds some C methods to this structure to make it
// look like a C++ class in Python.
// These are really named things like ColorMap_default, ColorMap_assign, etc...

  %extend {
    ColorMap(char *filename);
    ~ColorMap();
    void        default();
    void        assign(int index,int r, int g, int b);
    int getitem(int index);
    void setitem(int index, int value);
    int         write(char *filename);
  }
} ColorMap;

/* Some default colors */

#define BLACK   0
#define WHITE   1
#define RED     2
#define GREEN   3
#define BLUE    4
#define YELLOW  5
#define CYAN    6
#define MAGENTA 7

/*-------------------------------------------------------------------------
  FrameBuffer

  This structure defines a simple 8 bit framebuffer.  
  ------------------------------------------------------------------------- */

typedef struct FrameBuffer {
  unsigned int    height;
  unsigned int    width;
  int             xmin;      /* These are used for clipping */
  int             ymin;
  int             xmax;
  int             ymax;
  %extend {
    FrameBuffer(unsigned int width, unsigned int height);
    ~FrameBuffer();
    void resize(int width, int height);
    void clear(Pixel color);
    void plot(int x, int y, Pixel color);
    void horizontal(int xmin, int xmax, int y, Pixel color);
    void horizontalinterp(int xmin, int xmax, int y,  Pixel c1, Pixel c2);
    void vertical(int ymin, int ymax, int x, Pixel color);
    void box(int x1, int y1,  int x2, int y2, Pixel color);
    void solidbox(int x1, int y1, int x2, int y2, Pixel color);
    void interpbox(int x1, int y1, int x2, int y2, Pixel c1, Pixel c2, Pixel c3, Pixel c4);
    void circle(int x1, int y1, int radius, Pixel color);
    void solidcircle(int x1, int y1, int radius, Pixel color);
    void line(int x1, int y1, int x2, int y2, Pixel color);
    void setclip(int xmin, int ymin, int xmax, int ymax);
    void noclip();
    int  makeGIF(ColorMap *cmap, void *buffer, unsigned int maxsize);
    void zresize(int width, int height);
    void zclear();
    void drawchar(int x, int y, int fgcolor, int bgcolor, char chr, int orientation);
    void drawstring(int x, int y, int fgcolor, int bgcolor, char *text, int orientation);
    void drawpixmap(PixMap *pm, int x, int y, int fgcolor, int bgcolor);
    int  writeGIF(ColorMap *cmap, char *filename);	
  }
} FrameBuffer;

#define  HORIZONTAL  1
#define  VERTICAL    2

/* --------------------------------------------------------------------------
   PixMap

   The equivalent of "bit-maps".
   -------------------------------------------------------------------------- */

/* PIXMAP methods */

extern PixMap   *new_PixMap(int width, int height, int centerx, int centery);
extern void      delete_PixMap(PixMap *pm);
extern void      PixMap_set(PixMap *pm, int x, int y, int pix);

#define   GIFPLOT_TRANSPARENT  0
#define   GIFPLOT_FOREGROUND   1
#define   GIFPLOT_BACKGROUND   2

/* --------------------------------------------------------------------------
   Plot2D

   Definition and methods for 2D plots.
   --------------------------------------------------------------------------- */

typedef struct Plot2D {
  FrameBuffer     *frame;
  int             view_xmin;    /* Minimum coordinates of view region */
  int             view_ymin;    
  int             view_xmax;    /* Maximum coordinates of view region */
  int             view_ymax;    
  double          xmin;         /* Minimum coordinates of plot region */
  double          ymin;
  double          xmax;         /* Maximum coordinates of plot region */
  double          ymax;
  int             xscale;       /* Type of scaling (LINEAR, LOG, etc..) */
  int             yscale;       
  %extend {
       Plot2D(FrameBuffer *frame,double xmin,double ymin,  double xmax, double ymax);
       ~Plot2D();
       Plot2D  *copy();
       void     clear(Pixel c);
       void     setview(int vxmin, int vymin, int vxmax, int vymax);
       void     setrange(double xmin, double ymin, double xmax, double ymax);
       void     setscale(int xscale, int yscale);
       void     plot(double x, double y, Pixel color);
       void     box(double x1, double y1, double x2, double y2, Pixel color);
       void     solidbox(double x1, double y1,	double x2, double y2, Pixel color);
       void     interpbox(double x1, double y1, double x2, double y2, Pixel c1, Pixel c2, Pixel c3, Pixel c4);

       void     circle(double x, double y, double radius, Pixel color);
       void     solidcircle(double x, double y,  double radius, Pixel color);
       void     line(double x1, double y1,  double x2, double y2, Pixel color);
       void     start();
       void     drawpixmap(PixMap *pm, double x, double y, Pixel color, Pixel bgcolor);
       void     xaxis(double x, double y, double xtick, int ticklength, Pixel color);
       void     yaxis(double x, double y, double ytick, int ticklength, Pixel color);
       void     triangle(double x1, double y1, double x2, double y2, double x3, double y3, Pixel c);

       void     solidtriangle(double x1, double y1, double x2, double y2, double x3, double y3, Pixel c);

       void     interptriangle(double x1, double y1, Pixel c1,
			   double x2, double y2, Pixel c2,
			   double x3, double y3, Pixel c3);

  }
} Plot2D;

#define LINEAR     10
#define LOG        11

/* ------------------------------------------------------------------------------
   Plot3D

   Data Structure for 3-D plots
   ------------------------------------------------------------------------------ */

typedef struct Plot3D {
  FrameBuffer    *frame;
  int            view_xmin;  /* Viewing region */
  int            view_ymin;
  int            view_xmax;
  int            view_ymax;
  double         xmin;       /* Bounding box */
  double         ymin;
  double         zmin;
  double         xmax;
  double         ymax;
  double         zmax;
  double         xcenter;    /* Center point */
  double         ycenter;
  double         zcenter;
  double         fovy;       /* Field of view */
  double         aspect;     /* Aspect ratio  */
  double         znear;      /* near "clipping" plane */
  double         zfar;       /* far "clipping" plane */
  double         lookatz;    /* Where is the z-lookat point */
  double         xshift;     /* Used for translation and stuff */
  double         yshift;
  %extend {
    Plot3D(FrameBuffer *frame, double xmin, double ymin, double zmin, double xmax, double ymax, double zmax);
    ~Plot3D();
    Plot3D *copy();
    void   clear(Pixel bgcolor);
    void   perspective( double fovy, double znear, double zfar);
    void   lookat( double z);
    void   autoperspective( double fovy);
    void   ortho(double left, double right, double bottom, double top);
    void   autoortho();
    void   rotx( double deg);
    void   roty( double deg);
    void   rotz( double deg);
    void   rotl( double deg);
    void   rotr( double deg);
    void   rotd( double deg);
    void   rotu( double deg);
    void   rotc( double deg);
    void   zoom( double percent);
    void   left( double percent);
    void   right( double percent);
    void   down( double percent);
    void   up( double percent);
    void   center( double cx, double cy);
    void   plot( double x, double y, double z, Pixel Color);
    void   setview( int vxmin, int vymin, int vxmax, int vymax);
    void   start();
    void   line( double x1, double y1, double z1,
		 double x2, double y2, double z2, Pixel color);
    void   triangle( double x1, double y1, double z1,
		     double x2, double y2, double z2,
		     double x3, double y3, double z3, Pixel color);
    void   solidtriangle( double x1, double y1, double z1,
			  double x2, double y2, double z2,
			  double x3, double y3, double z3, Pixel color);
    void interptriangle(double x1, double y1, double z1, Pixel c1,
			double x2, double y2, double z2, Pixel c2,
			double x3, double y3, double z3, Pixel c3);
    void   quad( double x1, double y1, double z1,
		 double x2, double y2, double z2,
		 double x3, double y3, double z3,
		 double x4, double y4, double z4,
		 Pixel color);
    void   solidquad( double x1, double y1, double z1,
		      double x2, double y2, double z2,
		      double x3, double y3, double z3,
		      double x4, double y4, double z4,
		      Pixel color);
    void   interpquad( double x1, double y1, double z1, Pixel c1,
		       double x2, double y2, double z2, Pixel c2,
		       double x3, double y3, double z3, Pixel c3,
		       double x4, double y4, double z4, Pixel c4);
    void   solidsphere( double x, double y, double z, double radius,Pixel c);
    void   outlinesphere( double x, double y, double z, double radius,Pixel c, Pixel bc);
  }
} Plot3D;

#ifndef SWIGJAVA
/* These directives create constants of a specific type.  They
   do not correspond to any C variable or declared constant in the
   header file */
%constant PixMap * SQUARE = &PixMap_SQUARE;
%constant PixMap * TRIANGLE = &PixMap_TRIANGLE;
%constant PixMap * CROSS = &PixMap_CROSS;
#endif




