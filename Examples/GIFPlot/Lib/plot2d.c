/* ----------------------------------------------------------------------------- 
 * plot2d.c
 *
 *     2-Dimensional plotting
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 * Copyright (C) 1995-1996
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define PLOT2D

#include "gifplot.h"

/* ------------------------------------------------------------------------
   Plot2D *new_Plot2D(FrameBuffer *frame, xmin, ymin, xmax, ymax)

   Create a new 2D plot with given minimum and maximum coordinates.
   ------------------------------------------------------------------------ */
Plot2D  *new_Plot2D(FrameBuffer *frame,double xmin,double ymin,double xmax,double ymax) {
  Plot2D  *p2;
  if (frame) {
    if (xmax <= xmin) return (Plot2D *) 0;
    if (ymax <= ymin) return (Plot2D *) 0;
    p2 = (Plot2D *) malloc(sizeof(Plot2D));
    p2->frame = frame;
    p2->xmin = xmin;
    p2->ymin = ymin;
    p2->xmax = xmax;
    p2->ymax = ymax;
    p2->view_xmin = 0;
    p2->view_xmax = frame->width;
    p2->view_ymin = 0;
    p2->view_ymax = frame->height;
    p2->xscale = LINEAR;
    p2->yscale = LINEAR;
    p2->dx = (p2->view_xmax - p2->view_xmin)/(p2->xmax - p2->xmin);
    p2->dy = (p2->view_ymax - p2->view_ymin)/(p2->ymax - p2->ymin);
    return p2;
  }
  return (Plot2D *) 0;
}

/* ----------------------------------------------------------------------------
   delete_Plot2D(Plot2D *p2)

   Delete a 2D plot
   ---------------------------------------------------------------------------- */
void
delete_Plot2D(Plot2D *p2) {
  if (p2)
    free((char *) p2);
}

/* -----------------------------------------------------------------------------
   Plot2D *Plot2D_copy(Plot2D *p2)

   Makes a copy of the Plot2D data structure.
   ----------------------------------------------------------------------------- */

Plot2D *Plot2D_copy(Plot2D *p2) {
  Plot2D *c2;
  if (p2) {
    c2 = (Plot2D *) malloc(sizeof(Plot2D));
    if (c2) {
      c2->frame = p2->frame;
      c2->view_xmin = p2->view_xmin;
      c2->view_ymin = p2->view_ymin;
      c2->view_xmax = p2->view_xmax;
      c2->view_ymax = p2->view_ymax;
      c2->xmin = p2->xmin;
      c2->ymin = p2->ymin;
      c2->xmax = p2->xmax;
      c2->ymax = p2->ymax;
      c2->xscale = p2->xscale;
      c2->yscale = p2->yscale;
      c2->dx = p2->dx;
      c2->dy = p2->dy;
    }
    return c2;
  } else {
    return (Plot2D *) 0;
  }
}

/* -----------------------------------------------------------------------------
   Plot2D_clear(Plot2D *p2, Pixel c)

   Clear the region assigned to this plot to the given color.
   -------------------------------------------------------------------------- */

void Plot2D_clear(Plot2D *p2, Pixel c) {
  int i,j;
  for (i = p2->view_xmin; i < p2->view_xmax; i++)
    for (j = p2->view_ymin; j < p2->view_ymax; j++) {
      p2->frame->pixels[j][i] = c;
    }
}

/* ------------------------------------------------------------------------------
   Plot2D_setview

   Sets the plot region on the framebuffer
   ------------------------------------------------------------------------------ */

void
Plot2D_setview(Plot2D *p2, int vxmin, int vymin, int vxmax, int vymax) {
  if (p2) {
    p2->view_xmin = vxmin;
    p2->view_ymin = vymin;
    p2->view_xmax = vxmax;
    p2->view_ymax = vymax;
    p2->dx = (p2->view_xmax - p2->view_xmin)/(p2->xmax - p2->xmin);
    p2->dy = (p2->view_ymax - p2->view_ymin)/(p2->ymax - p2->ymin);
    FrameBuffer_setclip(p2->frame,vxmin,vymin,vxmax,vymax);
  }
}

/* -------------------------------------------------------------------------------
   Plot2D_setrange(Plot2D *p2, double xmin, double ymin, double xmax, double ymax)

   Sets the plotting range.
   ------------------------------------------------------------------------------- */

void
Plot2D_setrange(Plot2D *p2, double xmin, double ymin, double xmax, double ymax) {
  if (p2) {
    p2->xmin = xmin;
    p2->ymin = ymin;
    p2->xmax = xmax;
    p2->ymax = ymax;
    p2->dx = (p2->view_xmax - p2->view_xmin)/(p2->xmax - p2->xmin);
    p2->dy = (p2->view_ymax - p2->view_ymin)/(p2->ymax - p2->ymin);
  }
}

/* -------------------------------------------------------------------------------
   Plot2D_setscale(Plot2D *p2, int xscale, int yscale)

   Sets the plotting scaling method
   ------------------------------------------------------------------------------- */

void
Plot2D_setscale(Plot2D *p2, int xscale, int yscale) {
  if (p2) {
    p2->xscale = xscale;
    p2->yscale = yscale;
  }
}

/* ----------------------------------------------------------------------------
   Plot2D_transform(Plot2D *p2, double x, double y, int *px, int *py)
   
   Transforms x,y into screen coordinates px and py.  Result is returned
   in px and py.  Rounds to the nearest pixel instead of truncating.
   ----------------------------------------------------------------------------- */

void
Plot2D_transform(Plot2D *p2, double x, double y, int *px, int *py) {
  if (p2) {
    *px = p2->view_xmin + (int) (p2->dx*(x-p2->xmin) + 0.5);
    *py = p2->view_ymin + (int) (p2->dy*(y-p2->ymin) + 0.5);
  }
}

/* -------------------------------------------------------------------------------
   Plot2D_plot(Plot2D *p2, double x, double y, Pixel color)

   Plot a 2D Point of a given color
   ------------------------------------------------------------------------------- */
void
Plot2D_plot(Plot2D *p2, double x, double y, Pixel color) {
  int px, py;

  Plot2D_transform(p2,x,y,&px,&py);
  FrameBuffer_plot(p2->frame, px, py, color);
}

/* -------------------------------------------------------------------------------
   Plot2D_box(Plot2D *p2, double x1, double y1, double x2, double y2, Pixel Color)

   Plot an outline box on the 2D plot
   ------------------------------------------------------------------------------- */
void
Plot2D_box(Plot2D *p2, double x1, double y1,double x2, double y2, Pixel color) {
  int ix1, ix2,iy1, iy2;

  Plot2D_transform(p2,x1,y1,&ix1,&iy1);
  Plot2D_transform(p2,x2,y2,&ix2,&iy2);
  FrameBuffer_box(p2->frame,ix1,iy1,ix2,iy2,color);
}

/* -------------------------------------------------------------------------------
   Plot2D_solidbox(Plot2D *p2, double x1, double y1, double x2, double y2, Pixel Color)

   Plot a solid box box on the 2D plot
   ------------------------------------------------------------------------------- */
void
Plot2D_solidbox(Plot2D *p2, double x1, double y1,double x2, double y2, Pixel color) {
  int ix1, ix2,iy1, iy2;

  Plot2D_transform(p2,x1,y1,&ix1,&iy1);
  Plot2D_transform(p2,x2,y2,&ix2,&iy2);
  FrameBuffer_solidbox(p2->frame,ix1,iy1,ix2,iy2,color);
}

/* -------------------------------------------------------------------------------
   Plot2D_interpbox(Plot2D *p2, double x1, double y1, double x2, double y2,
                    Pixel c1, Pixel c2, Pixel c3, Pixel c4)

   Plot a color-interpolated box on the 2D plot
   ------------------------------------------------------------------------------- */
void
Plot2D_interpbox(Plot2D *p2, double x1, double y1,double x2, double y2,
		 Pixel c1, Pixel c2, Pixel c3, Pixel c4) {
  int ix1, ix2,iy1, iy2;

  Plot2D_transform(p2,x1,y1,&ix1,&iy1);
  Plot2D_transform(p2,x2,y2,&ix2,&iy2);
  FrameBuffer_interpbox(p2->frame,ix1,iy1,ix2,iy2,c1,c2,c3,c4);
}

/* -------------------------------------------------------------------------------
   Plot2D_circle(Plot2D *p2, double x, double y, double radius, Pixel color)

   Make an outline circle on the 2D plot.
   ------------------------------------------------------------------------------- */
void
Plot2D_circle(Plot2D *p2, double x, double y, double radius, Pixel color) {
  int ix, iy, ir;

  Plot2D_transform(p2,x,y,&ix,&iy);
  ir = p2->dx * radius;        /* This is really incorrect. Will need ellipse */
  if (ir > 1) 
    FrameBuffer_circle(p2->frame,ix,iy,ir,color);
  else
    FrameBuffer_plot(p2->frame,ix,iy,color);
  
}
  
/* -------------------------------------------------------------------------------
   Plot2D_solidcircle(Plot2D *p2, double x, double y, double radius, Pixel color)

   Make an solid circle on the 2D plot.
   ------------------------------------------------------------------------------- */
void
Plot2D_solidcircle(Plot2D *p2, double x, double y, double radius, Pixel color) {
  int ix, iy, ir;

  Plot2D_transform(p2,x,y,&ix,&iy);
  ir = p2->dx * radius;        /* This is really incorrect. Will need ellipse */
  if (ir > 1) 
    FrameBuffer_solidcircle(p2->frame,ix,iy,ir,color);
  else
    FrameBuffer_plot(p2->frame,ix,iy,color);
}

/* -------------------------------------------------------------------------------
   Plot2D_line(Plot2D *p2, double x1, double y1, double x2, double y2, Pixel color)

   Draw a line
   ------------------------------------------------------------------------------- */

void
Plot2D_line(Plot2D *p2, double x1, double y1, double x2, double y2, Pixel color) {
  int ix1, ix2, iy1, iy2;

  Plot2D_transform(p2,x1,y1,&ix1,&iy1);
  Plot2D_transform(p2,x2,y2,&ix2,&iy2);
  FrameBuffer_line(p2->frame,ix1,iy1,ix2,iy2,color);
}



/* -------------------------------------------------------------------------------
   Plot2D_start(Plot2D *p2)

   This should be called before starting to make a 2D plot. It will change
   the viewport coordinates for the framebuffer and do other stuff.
   ------------------------------------------------------------------------------- */

void Plot2D_start(Plot2D *p2) {
  if (p2) {
    FrameBuffer_setclip(p2->frame, p2->view_xmin,p2->view_ymin,p2->view_xmax, p2->view_ymax);
    p2->dx = (p2->view_xmax - p2->view_xmin)/(p2->xmax - p2->xmin);
    p2->dy = (p2->view_ymax - p2->view_ymin)/(p2->ymax - p2->ymin);
  }
}

/* --------------------------------------------------------------------------
   void Plot2D_drawpixmap(Plot2D *p2, PixMap *pm, double x, double y, Pixel color, Pixel bgcolor)

   Draw a pixel map at the given coordinates.  (Used for putting symbols on 2D
   plots).
   -------------------------------------------------------------------------- */
void
Plot2D_drawpixmap(Plot2D *p2, PixMap *pm, double x, double y, Pixel color, Pixel bgcolor) {
  int ix, iy;

  Plot2D_transform(p2,x,y,&ix,&iy);
  FrameBuffer_drawpixmap(p2->frame,pm,ix,iy,color,bgcolor);
}

/* ----------------------------------------------------------------------------
   void Plot2D_xaxis(Plot2D *p2, double x, double y, double xtick, int ticklength, Pixel color)

   Draw an X axis bar at location x,y with ticks spaced every xtick units.
   Ticks are spaced starting at "x"
   ----------------------------------------------------------------------------- */

void Plot2D_xaxis(Plot2D *p2, double x, double y, double xtick, int ticklength, Pixel color) {
  int ix, iy,iy2;
  double xt;

  /* Draw a line fox the axis */
  
  Plot2D_line(p2,p2->xmin,y,p2->xmax,y,color);
  xt = x;
  while (xt >= p2->xmin) {
    Plot2D_transform(p2,xt,y,&ix,&iy);
    iy2 = iy+ticklength;
    iy = iy-ticklength;
    FrameBuffer_line(p2->frame,ix,iy,ix,iy2,color);
    xt = xt - xtick;
  }
  xt = x + xtick;
  while (xt < p2->xmax) {
    Plot2D_transform(p2,xt,y,&ix,&iy);
    iy2 = iy+ticklength;
    iy = iy-ticklength;
    FrameBuffer_line(p2->frame,ix,iy,ix,iy2,color);
    xt = xt + xtick;
  }
}


/* ----------------------------------------------------------------------------
   void Plot2D_yaxis(Plot2D *p2, double x, double y, double ytick, int ticklength, Pixel c)

   Draw an Y axis bar at location x,y with ticks spaced every xtick units.
   Ticks are spaced starting at "y"
   ----------------------------------------------------------------------------- */

void Plot2D_yaxis(Plot2D *p2, double x, double y, double ytick, int ticklength, Pixel color) {
  int ix, iy, ix2;
  double yt;

  /* Draw a line fox the axis */
  
  Plot2D_line(p2,x,p2->ymin,x,p2->ymax,color);
  yt = y;
  while (yt >= p2->ymin) {
    Plot2D_transform(p2,x,yt,&ix,&iy);
    ix2 = ix+ticklength;
    ix = ix-ticklength;
    FrameBuffer_line(p2->frame,ix,iy,ix2,iy,color);
    yt = yt - ytick;
  }
  yt = y + ytick;
  while (yt < p2->ymax) {
    Plot2D_transform(p2,x,yt,&ix,&iy);
    ix2 = ix+ticklength;
    ix = ix-ticklength;
    FrameBuffer_line(p2->frame,ix,iy,ix2,iy,color);
    yt = yt + ytick;
  }
}


/* -------------------------------------------------------------------------
   Plot2D_triangle(Plot2D *p2, double x1, double y1, 
                               double x2, double y2, 
			       double x3, double y3, 
			       Pixel fillcolor)

   This function draws a 2D outline triangle.
   -------------------------------------------------------------------------- */

void Plot2D_triangle(Plot2D *p2, double x1, double y1,
		     double x2, double y2, 
		     double x3, double y3, Pixel color) {

  Plot2D_line(p2,x1,y1,x2,y2,color);
  Plot2D_line(p2,x2,y2,x3,y3,color);
  Plot2D_line(p2,x3,y3,x1,y1,color);

}


/* -------------------------------------------------------------------------
   Plot2D_solidtriangle(Plot2D *p2, double x1, double y1, 
                               double x2, double y2, 
			       double x3, double y3, 
			       Pixel color)

   This function draws a 2D filled triangle.    Can be used to
   draw other primitives such as quadralaterals, etc...

   -------------------------------------------------------------------------- */

void Plot2D_solidtriangle(Plot2D *p2, double x1, double y1, 

			  double x2, double y2, 
			  double x3, double y3, Pixel color) {

  int        tx1, tx2, tx3, ty1, ty2, ty3;
  
  /* Transform the three points into screen coordinates */

  Plot2D_transform(p2,x1,y1,&tx1,&ty1);
  Plot2D_transform(p2,x2,y2,&tx2,&ty2);
  Plot2D_transform(p2,x3,y3,&tx3,&ty3);

  FrameBuffer_solidtriangle(p2->frame,tx1,ty1,tx2,ty2,tx3,ty3,color);
  
}    

/* -------------------------------------------------------------------------
   Plot2D_interptriangle(Plot2D *p2, double x1, double y1, Pixel c1,
                               double x2, double y2, Pixel c2,
			       double x3, double y3, Pixel c3);

   This function draws a 2D filled triangle with color interpolation.
   Can be used to draw other primitives such as quadralaterals, etc...
   -------------------------------------------------------------------------- */

void Plot2D_interptriangle(Plot2D *p2, double x1, double y1, Pixel c1,
			   double x2, double y2, Pixel c2,
			   double x3, double y3, Pixel c3) {

  int        tx1, tx2, tx3, ty1, ty2, ty3;
  
  /* Transform the three points into screen coordinates */

  Plot2D_transform(p2,x1,y1,&tx1,&ty1);
  Plot2D_transform(p2,x2,y2,&tx2,&ty2);
  Plot2D_transform(p2,x3,y3,&tx3,&ty3);

  FrameBuffer_interptriangle(p2->frame,tx1,ty1,c1,tx2,ty2,c2,tx3,ty3,c3);
  
}    
  
  

