/* ----------------------------------------------------------------------------- 
 * frame.c
 *
 *     Frame buffer management
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 * Copyright (C) 1995-1996
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define FRAME
#include "gifplot.h"
#include <float.h>

/* ------------------------------------------------------------------------
   FrameBuffer *new_FrameBuffer(int width, int height)

   Creates a new framebuffer for storing data.
   ------------------------------------------------------------------------ */

FrameBuffer *new_FrameBuffer(unsigned int width, unsigned int height) {

  FrameBuffer *f;
  int  FrameBuffer_resize(FrameBuffer *f, int width, int height);

  /* Create a new frame buffer */
  
  f = (FrameBuffer *) malloc(sizeof(FrameBuffer));
  f->pixels = (Pixel **) 0;
  f->zbuffer = (Zvalue **) 0;
  /* Set its size */
  
  if (FrameBuffer_resize(f, width, height) == -1) {
    free((char *) f);
    return (FrameBuffer *) 0;
  }

  f->xmin = 0;
  f->ymin = 0;
  f->xmax = width;
  f->ymax = height;
  return f;
}

/* ------------------------------------------------------------------------
   void delete_FrameBuffer(FrameBuffer *f)

   Destroys the given framebuffer
   ------------------------------------------------------------------------ */

void delete_FrameBuffer(FrameBuffer *f) {

  if (f) {
    if (f->pixels) {
      free((char *) f->pixels[0]);
      free((char *) f->pixels);
    }
    if (f->zbuffer) {
      free((char *) f->zbuffer[0]);
      free((char *) f->zbuffer);
    }
    free((char *)f);
  }
}

/* ------------------------------------------------------------------------
   int *FrameBuffer_resize(FrameBuffer *f, int width, int height)

   Resize the given framebuffer. Returns 0 on success, -1 on failure.
   ------------------------------------------------------------------------ */

int FrameBuffer_resize(FrameBuffer *f, int width, int height) {
  int i;
  if ((f) && (width > 0) && (height > 0)) {
    if (f->pixels) {
      free((char *)f->pixels[0]);
      free((char *)f->pixels);
    }
    f->pixels = (Pixel **) malloc (height*sizeof(Pixel *));
    if (!f->pixels) return -1;
    f->pixels[0] = (Pixel *) malloc(height*width*sizeof(Pixel));
    if (!f->pixels[0]) {
      free((char *)f->pixels);
      return -1;
    }
    for (i = 0; i < height; i++) 
      f->pixels[i] = f->pixels[0] + i*width;
    f->width = width;
    f->height = height;
    if (f->zbuffer) {
      FrameBuffer_zresize(f,width,height);
    }
    return 0;
  } else {
    return -1;
  }
}

/* ------------------------------------------------------------------------
   void FrameBuffer_clear(FrameBuffer *f, Pixel color)

   Clears the current FrameBuffer
   ------------------------------------------------------------------------ */

void FrameBuffer_clear(FrameBuffer *f, Pixel color) {
  Pixel *p;
  unsigned int i;
  p = &f->pixels[0][0];

  for (i = 0; i < f->width*f->height; i++, p++)
    *p = color;
}

/* ------------------------------------------------------------------------
   void FrameBuffer_plot(FrameBuffer *f, int x1, int y1, Pixel color)

   Plots a point and does a bounds check.
   ------------------------------------------------------------------------ */

void FrameBuffer_plot(FrameBuffer *f, int x1, int y1, Pixel color) {

  if ((x1 < f->xmin) || (x1 >= f->xmax) || (y1 < f->ymin) || (y1 >= f->ymax))
    return;
  f->pixels[y1][x1] = color;

}

/* ------------------------------------------------------------------------
   FrameBuffer_horizontal(Framebuffer *f, int xmin, int xmax, int y, Pixel color)

   Draw a horizontal line (clipped)
   ------------------------------------------------------------------------ */

void FrameBuffer_horizontal(FrameBuffer *f, int xmin, int xmax, int y, Pixel color) {
  
  Pixel *p;
  int    i;
  
  if ((y < f->ymin) || (y >= f->ymax)) return;
  if (xmin < f->xmin) xmin = f->xmin;
  if (xmax >= f->xmax) xmax = f->xmax - 1;

  p = &f->pixels[y][xmin];
  for (i = xmin; i <= xmax; i++, p++)
    *p = color;

}

/* ------------------------------------------------------------------------
   FrameBuffer_horizontalinterp(Framebuffer *f, int xmin, int xmax, int y,
                                Pixel c1, Pixel c2)

   Draw a horizontal line (clipped) with color interpolation.
   ------------------------------------------------------------------------ */

void FrameBuffer_horizontalinterp(FrameBuffer *f, int xmin, int xmax, int y,
				  Pixel c1, Pixel c2) {
  
  Pixel *p;
  int    i;
  double mc;
  int    x1;
  if ((y < f->ymin) || (y >= f->ymax)) return;

  x1 = xmin;
  if (xmin < f->xmin) xmin = f->xmin;
  if (xmax >= f->xmax) xmax = f->xmax - 1;
  if (xmax < f->xmin) return;
  if (xmin >= f->xmax) return;

  if (xmin != xmax)
    mc = (double)(c2 - c1)/(double) (xmax - xmin);
  else
    mc = 0.0;

  p = &f->pixels[y][xmin];
  for (i = xmin; i <= xmax; i++, p++) 
    *p = (Pixel) (mc*(i-x1) + c1);
  
}


/* ------------------------------------------------------------------------
   FrameBuffer_vertical(Framebuffer *f, int xmin, int xmax, int y, Pixel color)

   Draw a Vertical line (clipped)
   ------------------------------------------------------------------------ */

void FrameBuffer_vertical(FrameBuffer *f, int ymin, int ymax, int x, Pixel color) {
  
  Pixel *p;
  int    i;
  
  if ((x < f->xmin) || (x >= f->xmax)) return;
  if (ymax < f->ymin) return;
  if (ymin > f->ymax) return;
  if (ymin < f->ymin) ymin = f->ymin;
  if (ymax >= f->ymax) ymax = f->ymax - 1;

  p = &f->pixels[ymin][x];
  for (i = 0; i <= (ymax - ymin); i++, p+=f->width)
    *p = color;

}
  
/* ------------------------------------------------------------------------
   void FrameBuffer_box(FrameBuffer *f, int x1, int y1, int x2, int y2, Pixel color)

   Makes an outline box.
   ------------------------------------------------------------------------ */

void FrameBuffer_box(FrameBuffer *f, int x1, int y1, int x2, int y2, Pixel color) {

  int  xt, yt;

  /* Make sure points are in correct order */

  if (x2 < x1) {
    xt = x2;
    x2 = x1;
    x1 = xt;
  }
  if (y2 < y1) {
    yt = y2;
    y2 = y1;
    y1 = yt;
  }

  /* Draw lower edge */

  FrameBuffer_horizontal(f,x1,x2,y1,color);

  /* Draw upper edge */

  FrameBuffer_horizontal(f,x1,x2,y2,color);

  /* Draw left side */

  FrameBuffer_vertical(f,y1,y2,x1,color);

  /* Draw right side */

  FrameBuffer_vertical(f,y1,y2,x2,color);
  
}

/* ------------------------------------------------------------------------
   void FrameBuffer_solidbox(FrameBuffer *f, int x1, int y1, int x2, int y2, Pixel color)

   Makes an solid box.
   ------------------------------------------------------------------------ */

void FrameBuffer_solidbox(FrameBuffer *f, int x1, int y1, int x2, int y2, Pixel color) {

  int  xt, yt;

  /* Make sure points are in correct order */

  if (x2 < x1) {
    xt = x2;
    x2 = x1;
    x1 = xt;
  }
  if (y2 < y1) {
    yt = y2;
    y2 = y1;
    y1 = yt;
  }

  /* Now perform some clipping */

  if (y1 < f->ymin) y1 = f->ymin;
  if (y2 >= f->ymax) y2 = f->ymax - 1;

  /* Fill it in using horizontal lines */
  
  for (yt = y1; yt <= y2; yt++)
    FrameBuffer_horizontal(f,x1,x2,yt,color);

}

/* ------------------------------------------------------------------------
   void FrameBuffer_interpbox(FrameBuffer *f, int x1, int y1, int x2, int y2
                              Pixel c1, Pixel c2, Pixel c3, Pixel c4)

   Makes a box with interpolated color.   Colors are assigned as follows :
   (x1,y1) = c1
   (x1,y2) = c2
   (x2,y1) = c3
   (x2,y2) = c4
   ------------------------------------------------------------------------ */

void FrameBuffer_interpbox(FrameBuffer *f, int x1, int y1, int x2, int y2,
			   Pixel c1, Pixel c2, Pixel c3, Pixel c4) {

  int  xt, yt;
  Pixel ct;
  double  mc1,mc2;
  int  ystart;
  /* Make sure points are in correct order */

  if (x2 < x1) {
    xt = x2;
    x2 = x1;
    x1 = xt;
    ct = c1;
    c1 = c3;
    c3 = ct;
    ct = c2;
    c2 = c4;
    c4 = ct;
  }
  if (y2 < y1) {
    yt = y2;
    y2 = y1;
    y1 = yt;
    ct = c1;
    c1 = c2;
    c2 = ct;
    ct = c3;
    c3 = c4;
    c4 = ct;
  }

  /* Now perform some clipping */

  ystart = y1;
  mc1 = (double) (c2 - c1)/(double) (y2 - y1);
  mc2 = (double) (c4 - c3)/(double) (y2 - y1);
  if (y1 < f->ymin) y1 = f->ymin;
  if (y2 >= f->ymax) y2 = f->ymax - 1;

  /* Fill it in using horizontal lines */
  
  for (yt = y1; yt <= y2; yt++)
    FrameBuffer_horizontalinterp(f,x1,x2,yt,(Pixel) ((mc1*(yt - ystart)) + c1),
				  (Pixel) ((mc2*(yt-ystart))+c3));

}

/* ---------------------------------------------------------------------------
   FrameBuffer_line(FrameBuffer *f, int x1, int y1, int x2, int y2, color)

   Draws a line on the framebuffer using the Bresenham line algorithm.  The
   line is clipped to fit within the current view window.
   ---------------------------------------------------------------------------- */

void FrameBuffer_line(FrameBuffer *f, int x1, int y1, int x2, int y2, Pixel c) {

  int  dx,dy,dxneg,dyneg, inc1,inc2,di;
  int  x, y, xpixels, ypixels, xt, yt;
  Pixel *p;
  double m;
  int  end1 = 0, end2 = 0;
  
  /* Need to figure out where in the heck this line is */

  dx = x2 - x1;
  dy = y2 - y1;

  if (dx == 0) {
    /* Draw a Vertical Line */
    if (y1 < y2)
      FrameBuffer_vertical(f,y1,y2,x1,c);
    else
      FrameBuffer_vertical(f,y2,y1,x1,c);
    return;
  }
  if (dy == 0) {
    /* Draw a Horizontal Line */
    if (x1 < x2)
      FrameBuffer_horizontal(f,x1,x2,y1,c);
    else
      FrameBuffer_horizontal(f,x2,x1,y1,c);
    return;
  }

  /* Figure out where in the heck these lines are using the
     Cohen-Sutherland Line Clipping Scheme. */

  end1 = ((x1 - f->xmin) < 0) |
    (((f->xmax- 1 - x1) < 0) << 1) |
    (((y1 - f->ymin) < 0) << 2) |
    (((f->ymax-1 - y1) < 0) << 3);

  end2 = ((x2 - f->xmin) < 0) |
    (((f->xmax-1 - x2) < 0) << 1) |
    (((y2 - f->ymin) < 0) << 2) |
    (((f->ymax-1 - y2) < 0) << 3);

  if (end1 & end2) return;      /* Nope : Not visible */

  /* Make sure points have a favorable orientation */
  
  if (x1 > x2) {
    xt = x1;
    x1 = x2;
    x2 = xt;
    yt = y1;
    y1 = y2;
    y2 = yt;
  }
  
  /* Clip against the boundaries */
  m = (y2 - y1)/(double) (x2-x1);
  if (x1 < f->xmin) {
    y1 = (int) ((f->xmin - x1)*m + y1);
    x1 = (int) f->xmin;
  }
  if (x2 >= f->xmax) {
    y2 = (int) ((f->xmax -1 -x1)*m + y1);
    x2 = (int) (f->xmax - 1);
  }

  if (y1 > y2) {
    xt = x1;
    x1 = x2;
    x2 = xt;
    yt = y1;
    y1 = y2;
    y2 = yt;
  }

  m = 1/m;
  if (y1 < f->ymin) {
    x1 = (int) ((f->ymin - y1)*m + x1);
    y1 = (int) f->ymin;
  }
  if (y2 >= f->ymax) {
    x2 = (int) ((f->ymax-1-y1)*m + x1);
    y2 = (int) (f->ymax-1);
  }

  if ((x1 < f->xmin) || (x1 >= f->xmax) || (y1 < f->ymin) || (y1 >= f->ymax) ||
      (x2 < f->xmin) || (x2 >= f->xmax) || (y2 < f->ymin) || (y2 >= f->ymax)) return;

  dx = x2 - x1;
  dy = y2 - y1;
  xpixels = f->width;
  ypixels = f->height;
  
  dxneg = (dx < 0) ? 1 : 0;
  dyneg = (dy < 0) ? 1 : 0;
  
  dx = abs(dx);
  dy = abs(dy);
  if (dx >= dy) {
    /* Slope between -1 and 1. */
    if (dxneg) {
      x = x1;
      y = y1;
      x1 = x2;
      y1 = y2;
      x2 = x;
      y2 = y;
      dyneg = !dyneg;
    }
    inc1 = 2*dy;
    inc2 = 2*(dy-dx);
    di = 2*dy-dx;

    /* Draw a line using x as independent variable */
    
    p = &f->pixels[y1][x1];
    x = x1;
    while (x <= x2) {
      *(p++) = c;
      if (di < 0) {
	di = di + inc1;
      } else {
	if (dyneg) {
	  p = p - xpixels;
	  di = di + inc2;
	} else {
	  p = p + xpixels;
	  di = di + inc2;
	}
      }
      x++;
    }
  } else {
    /* Slope < -1 or > 1 */
    if (dyneg) {
      x = x1;
      y = y1;
      x1 = x2;
      y1 = y2;
      x2 = x;
      y2 = y;
      dxneg = !dxneg;
    }
    inc1 = 2*dx;
    inc2 = 2*(dx-dy);
    di = 2*dx-dy;

    /* Draw a line using y as independent variable */
    
    p = &f->pixels[y1][x1];
    y = y1;
    while (y <= y2) {
      *p = c;
      p = p + xpixels;
      if (di < 0) {
	di = di + inc1;
      } else {
	if (dxneg) {
	  p = p - 1;
	  di = di + inc2;
	} else {
	  p = p + 1;
	  di = di + inc2;
	}
      }
      y++;
    }
  }    
}


/* -------------------------------------------------------------------------
   FrameBuffer_circle(FrameBuffer f, int xc, int yc, int radius, Pixel c)

   Create an outline circle
   ------------------------------------------------------------------------- */

#define plot_circle(x,y,c) \
   if ((x >= xmin) && (x < xmax) && \
       (y >= ymin) && (y < ymax)) \
        pixels[y][x] = c;
	
void FrameBuffer_circle(FrameBuffer *f, int xc, int yc, int radius, Pixel c) {

  int xpixels, ypixels, x, y, p;
  int xmin, ymin, xmax, ymax;
  Pixel **pixels;

  if (radius <= 0) return;
  xpixels = f->width;
  ypixels = f->height;
  pixels = f->pixels;
  xmin = f->xmin;
  ymin = f->ymin;
  xmax = f->xmax;
  ymax = f->ymax;
  x = 0;
  y = radius;
  p = 3-2*radius;
  while (x <= y) {
    plot_circle(xc+x,yc+y,c);
    plot_circle(xc-x,yc+y,c);
    plot_circle(xc+x,yc-y,c);
    plot_circle(xc-x,yc-y,c);
    plot_circle(xc+y,yc+x,c);
    plot_circle(xc-y,yc+x,c);
    plot_circle(xc+y,yc-x,c);
    plot_circle(xc-y,yc-x,c);
    if (p < 0) p = p + 4*x + 6;
    else {
      p = p + 4*(x-y) + 10;
      y = y -1;
    }
    x++;
  }
}


/* -------------------------------------------------------------------------
   FrameBuffer_solidcircle(FrameBuffer f, int xc, int yc, int radius, Pixel c)

   Create an filled circle
   ------------------------------------------------------------------------- */

       
#define fill_circle(x,y,c) \
       x1 = xc - x; \
       x2 = xc + x; \
       FrameBuffer_horizontal(f,x1,x2,y,c);
	
void FrameBuffer_solidcircle(FrameBuffer *f, int xc, int yc, int radius, Pixel c) {

  int xpixels, ypixels, x, y, p;
  int x1,x2;
  int xmin, ymin, xmax, ymax;
  Pixel **pixels;

  if (radius <= 0) return;
  xpixels = f->width;
  ypixels = f->height;
  pixels = f->pixels;
  xmin = f->xmin;
  ymin = f->ymin;
  xmax = f->xmax;
  ymax = f->ymax;
  x = 0;
  y = radius;
  p = 3-2*radius;
  while (x <= y) {
    fill_circle(x,yc+y,c);
    fill_circle(x,yc-y,c);
    fill_circle(y,yc+x,c);
    fill_circle(y,yc-x,c);
    if (p < 0) p = p + 4*x + 6;
    else {
      p = p + 4*(x-y) + 10;
      y = y -1;
    }
    x++;
  }
}

/* ------------------------------------------------------------------------
   void FrameBuffer_setclip(f,xmin,ymin,xmax,ymax)

   Set clipping region for plotting
   ------------------------------------------------------------------------ */

void FrameBuffer_setclip(FrameBuffer *f, int xmin, int ymin, int xmax, int ymax) {

  if (xmin >= xmax) return;
  if (ymin >= ymax) return;

  if (xmin < 0) xmin = 0;
  if (ymin < 0) ymin = 0;
  if (xmax > (int) f->width) xmax = f->width;
  if (ymax > (int) f->height) ymax = f->height;

  f->xmin = xmin;
  f->ymin = ymin;
  f->xmax = xmax;
  f->ymax = ymax;
}

/* ------------------------------------------------------------------------
   void FrameBuffer_noclip(f)

   Disable clipping region
   ------------------------------------------------------------------------ */

void FrameBuffer_noclip(FrameBuffer *f) {
  f->xmin = 0;
  f->ymin = 0;
  f->xmax = f->width;
  f->ymax = f->height;
}


/* ------------------------------------------------------------------------
   FrameBuffer_zresize(FrameBuffer *f, int width, int height)

   This function resizes the framebuffer's zbuffer.  If none exist, it
   creates a new one.
   ------------------------------------------------------------------------ */

void FrameBuffer_zresize(FrameBuffer *f, int width, int height) {
  int i;

  if (f->zbuffer) {
    free((char *)f->zbuffer[0]);
    free((char *)f->zbuffer);
  }
  f->zbuffer = (Zvalue **) malloc(height*sizeof(Zvalue *));
  f->zbuffer[0] = (Zvalue *) malloc(height*width*sizeof(Zvalue));
  for (i = 0; i < height; i++)
    f->zbuffer[i] = f->zbuffer[0]+i*width;
}

/* ------------------------------------------------------------------------
   FrameBuffer_zclear(FrameBuffer *f)

   Clears the z-buffer for a particular frame.   Sets all of the z-values to
   ZMIN.
   ------------------------------------------------------------------------- */

void FrameBuffer_zclear(FrameBuffer *f) {
  unsigned int i,j;
  if (f) {
    if (f->zbuffer) {
      for (i = 0; i < f->width; i++)
	for (j = 0; j < f->height; j++)
	  f->zbuffer[j][i] = ZMIN;
    }
  }
}
   


/* -------------------------------------------------------------------------
   FrameBuffer_solidtriangle(FrameBuffer *f, int tx1, int ty2, 
                                 int tx2, int ty2, 
				 int tx3, int ty3, Pixel color) 

   This function draws a 2D filled triangle.   

   General idea :
         1.   Transform the three points into screen coordinates
	 2.   Order three points vertically on screen.
	 3.   Check for degenerate cases (where 3 points are colinear).
	 4.   Fill in the resulting triangle using horizontal lines.
   -------------------------------------------------------------------------- */

void FrameBuffer_solidtriangle(FrameBuffer *f, int tx1, int ty1, 
			       int tx2, int ty2,
			       int tx3, int ty3, Pixel color) {
  int        tempx, tempy;
  double     m1,m2,m3;
  int        y;
  int        ix1, ix2;

  /* Figure out which point has the greatest "y" value */

  if (ty2 > ty1) {   /* Swap points 1 and 2 if 2 is higher */
    tempx = tx1;
    tempy = ty1;
    tx1 = tx2;
    ty1 = ty2;
    tx2 = tempx;
    ty2 = tempy;
  }
  if (ty3 > ty1) {  /* Swap points 1 and 3 if 3 is higher */
    tempx = tx1;
    tempy = ty1;
    tx1 = tx3;
    ty1 = ty3;
    tx3 = tempx;
    ty3 = tempy;
  }
  if (ty3 > ty2) { /* Swap points 2 and 3 if 3 is higher */ 
    tempx = tx2;
    tempy = ty2;
    tx2 = tx3;
    ty2 = ty3;
    tx3 = tempx;
    ty3 = tempy;
  }

  /* Points are now order so that t_1 is the highest point, t_2 is the
     middle point, and t_3 is the lowest point */

  /* Check for degenerate cases here */

  if ((ty1 == ty2) && (ty2 == ty3)) {

    /* Points are aligned horizontally.   Handle as a special case */
    /* Just draw three lines using the outline color */

    FrameBuffer_line(f,tx1,ty1,tx2,ty2,color);
    FrameBuffer_line(f,tx1,ty1,tx3,ty3,color);
    FrameBuffer_line(f,tx2,ty2,tx3,ty3,color);

  } else {

    if (ty2 < ty1) {
      /* First process line segments between (x1,y1)-(x2,y2)
	 And between (x1,y1),(x3,y3) */

      m1 = (double) (tx2 - tx1)/(double) (ty2 - ty1);
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);

      y = ty1;
      while (y >= ty2) {
	/* Calculate x values from slope */
	ix1 = (int) (m1*(y-ty1)+0.5) + tx1;
	ix2 = (int) (m2*(y-ty1)+0.5) + tx1;
	if (ix1 > ix2) 
	  FrameBuffer_horizontal(f,ix2,ix1,y,color);
	else
	  FrameBuffer_horizontal(f,ix1,ix2,y,color);
	y--;
      }
    }
    if (ty3 < ty2) {
      /* Draw lower half of the triangle */
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      m3 = (double) (tx3 - tx2)/(double)(ty3 - ty2);
      y = ty2;
      while (y >= ty3) {
	ix1 = (int) (m3*(y-ty2)+0.5)+tx2;
	ix2 = (int) (m2*(y-ty1)+0.5)+tx1;
	if (ix1 > ix2)
	  FrameBuffer_horizontal(f,ix2,ix1,y,color);
	else
	  FrameBuffer_horizontal(f,ix1,ix2,y,color);
	y--;
      }
    }
  }
}

/* -------------------------------------------------------------------------
   FrameBuffer_interptriangle(FrameBuffer *f,
   int tx1, int ty2, Pixel c1,
   int tx2, int ty2, Pixel c2,
   int tx3, int ty3, Pixel c3)

   This function draws a filled triangle with color
   interpolation.  

   General idea :
         1.   Transform the three points into screen coordinates
	 2.   Order three points vertically on screen.
	 3.   Check for degenerate cases (where 3 points are colinear).
	 4.   Fill in the resulting triangle using horizontal lines.
	 5.   Colors are interpolated between end points
   -------------------------------------------------------------------------- */

void FrameBuffer_interptriangle(FrameBuffer *f,
				int tx1, int ty1, Pixel c1,
				int tx2, int ty2, Pixel c2,
				int tx3, int ty3, Pixel c3) {
  int        tempx, tempy;
  double     m1,m2,m3;
  double     mc1,mc2,mc3;
  Pixel      ic1,ic2,tempc;
  int        y;
  int        ix1, ix2;

  /* Figure out which point has the greatest "y" value */

  if (ty2 > ty1) {   /* Swap points 1 and 2 if 2 is higher */
    tempx = tx1;
    tempy = ty1;
    tempc = c1;
    tx1 = tx2;
    ty1 = ty2;
    c1 = c2;
    tx2 = tempx;
    ty2 = tempy;
    c2 = tempc;
  }
  if (ty3 > ty1) {  /* Swap points 1 and 3 if 3 is higher */
    tempx = tx1;
    tempy = ty1;
    tempc = c1;
    tx1 = tx3;
    ty1 = ty3;
    c1 = c3;
    tx3 = tempx;
    ty3 = tempy;
    c3 = tempc;
  }
  if (ty3 > ty2) { /* Swap points 2 and 3 if 3 is higher */ 
    tempx = tx2;
    tempy = ty2;
    tempc = c2;
    tx2 = tx3;
    ty2 = ty3;
    c2 = c3;
    tx3 = tempx;
    ty3 = tempy;
    c3 = tempc;
  }

  /* Points are now order so that t_1 is the highest point, t_2 is the
     middle point, and t_3 is the lowest point */

  /* Check for degenerate cases here */

  if ((ty1 == ty2) && (ty2 == ty3)) {

    /* Points are aligned horizontally.   Handle as a special case */
    /* Just draw three lines using the outline color */

    if (tx2 > tx1)
      FrameBuffer_horizontalinterp(f,tx1,tx2,ty1,c1,c2);
    else
      FrameBuffer_horizontalinterp(f,tx2,tx1,ty1,c2,c1);
    if (tx3 > tx1)
      FrameBuffer_horizontalinterp(f,tx1,tx3,ty1,c1,c3);
    else
      FrameBuffer_horizontalinterp(f,tx3,tx1,ty1,c3,c1);
    if (tx3 > tx2)
      FrameBuffer_horizontalinterp(f,tx2,tx3,ty2,c2,c3);
    else
      FrameBuffer_horizontalinterp(f,tx3,tx2,ty2,c3,c2);
    
  } else {

    /* First process line segments between (x1,y1)-(x2,y2)
       And between (x1,y1),(x3,y3) */

    if (ty2 < ty1) {
      m1 = (double) (tx2 - tx1)/(double) (ty2 - ty1);
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      mc1 = (c2 - c1)/(double) (ty2 - ty1);
      mc2 = (c3 - c1)/(double) (ty3 - ty1);

      y = ty1;
      while (y >= ty2) {
	/* Calculate x values from slope */
	ix1 = (int) (m1*(y-ty1)+0.5) + tx1;
	ix2 = (int) (m2*(y-ty1)+0.5) + tx1;
	ic1 = (int) (mc1*(y-ty1) + c1);
	ic2 = (int) (mc2*(y-ty1) + c1);
	if (ix1 > ix2) 
	  FrameBuffer_horizontalinterp(f,ix2,ix1,y,ic2,ic1);
	else
	  FrameBuffer_horizontalinterp(f,ix1,ix2,y,ic1,ic2);
	y--;
      }
    }
    if (ty3 < ty2) {
      /* Draw lower half of the triangle */
      m2 = (double) (tx3 - tx1)/(double) (ty3 - ty1);
      mc2 = (c3 - c1)/(double) (ty3 - ty1);
      m3 = (double) (tx3 - tx2)/(double)(ty3 - ty2);
      mc3 = (c3 - c2)/(double) (ty3 - ty2);
      y = ty2;
      while (y >= ty3) {
	ix1 = (int) (m3*(y-ty2)+0.5)+tx2;
	ix2 = (int) (m2*(y-ty1)+0.5)+tx1;
	ic1 = (int) (mc3*(y-ty2)+c2);
	ic2 = (int) (mc2*(y-ty1)+c1);
	if (ix1 > ix2)
	  FrameBuffer_horizontalinterp(f,ix2,ix1,y,ic2,ic1);
	else
	  FrameBuffer_horizontalinterp(f,ix1,ix2,y,ic1,ic2);
	y--;
      }
    }
  }
}


