/* ----------------------------------------------------------------------------- 
 * pixmap.c
 *
 *     Pixel maps (i.e., bitmaps)
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 * Copyright (C) 1995-1996
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define PIXMAP
#include "gifplot.h"

/* -----------------------------------------------------------------------
   PixMap *new_PixMap(int width, int height, int centerx, int centery)

   Create a new pixmap of given size
   ----------------------------------------------------------------------- */
PixMap *new_PixMap(int width, int height, int centerx, int centery) {
  PixMap *pm;
  if ((width > 0) && (height > 0)) {
    pm = (PixMap *) malloc(sizeof(PixMap));
    pm->width = width;
    pm->height = height;
    pm->centerx = centerx;
    pm->centery = centery;
    pm->map = (int *) malloc(height*width*sizeof(int));
    return pm;
  }
  return (PixMap *) 0;
}

/* --------------------------------------------------------------------------
   void delete_PixMap(PixMap *pm)

   Destroy a pixmap
   -------------------------------------------------------------------------- */

void delete_PixMap(PixMap *pm) {
  if (pm) {
    free((char *) pm->map);
    free((char *) pm);
  }
}

/* ---------------------------------------------------------------------------
   void PixMap_set(PixMap *pm, int x, int y, int pix)

   Set a pixel in the bitmap
   --------------------------------------------------------------------------- */
void
PixMap_set(PixMap *pm, int x, int y, int pix) {
  if ((x < 0) || (x>=pm->width)) return;
  if ((y < 0) || (y>=pm->height)) return;

  pm->map[pm->width*y + x] = pix;
}

/* -----------------------------------------------------------------------------
   void FrameBuffer_drawpixmap(FrameBuffer *f, PixMap *pm, int x, int y, int fgcolor, int bgcolor) 

   Draw a pixmap onto the framebuffer.   This is somewhat optimized for speed.
   ------------------------------------------------------------------------------ */

void
FrameBuffer_drawpixmap(FrameBuffer *f, PixMap *pm, int x, int y, int fgcolor, int bgcolor) {

  int startx, starty;         /* Starting location on framebuffer */
  int startpixx = 0, startpixy = 0;   /* Starting location in pixmap      */
  int endx, endy;             /* Ending location on framebuffer   */
  int i,j, px, py;
  int c;
  
  startx = x - pm->centerx;
  starty = y + pm->centery;
  endx = startx + pm->width;
  endy = starty - pm->height;

  /* Figure out if we need to clip */

  if (startx < f->xmin) {
    startpixx = f->xmin - startx;
    startx = f->xmin;
  }
  if (starty >= f->ymax) {
    startpixy = starty - f->ymax;
    starty = f->ymax-1;
  }
  if (endx >= f->xmax) {
    endx = f->xmax-1;
  }
  if (endy < f->ymin) {
    endy = f->ymin;
  }
  py = startpixy;
  for (j = starty; j >= endy; j--) {
    px = startpixx;
    for (i = startx; i < endx; i++) {
      c = pm->map[py*pm->width + px];
      switch (c) {
      case GIFPLOT_FOREGROUND:
	f->pixels[j][i] = fgcolor;
	break;
      case GIFPLOT_BACKGROUND:
	f->pixels[j][i] = bgcolor;
	break;
      default:
	break;
      }
      px++;
    }
    py++;
  }
}

/**************************************************************************
 * Some common PixMaps  (for plotting)
 *
 **************************************************************************/

int _SQUARE_MAP[] = {
  0,1,1,1,1,1,1,1,
  0,1,1,1,1,1,1,1,
  0,1,1,1,1,1,1,1,
  0,1,1,1,1,1,1,1,
  0,1,1,1,1,1,1,1,
  0,1,1,1,1,1,1,1,
  0,1,1,1,1,1,1,1,
  0,0,0,0,0,0,0,0 };

PixMap  PixMap_SQUARE = { 8,8,4,4, _SQUARE_MAP};

int _TRIANGLE_MAP[] = {
  0,0,0,1,0,0,0,0,
  0,0,0,1,0,0,0,0,
  0,0,1,1,1,0,0,0,
  0,0,1,1,1,0,0,0,
  0,1,1,1,1,1,0,0,
  0,1,1,1,1,1,0,0,
  1,1,1,1,1,1,1,0,
  0,0,0,0,0,0,0,0 };

PixMap  PixMap_TRIANGLE = { 8,8,4,4,_TRIANGLE_MAP};

int _CROSS_MAP[] = {
  0,0,0,1,0,0,0,0,
  0,0,0,1,0,0,0,0,
  0,0,0,1,0,0,0,0,
  1,1,1,1,1,1,1,0,
  0,0,0,1,0,0,0,0,
  0,0,0,1,0,0,0,0,
  0,0,0,1,0,0,0,0,
  0,0,0,0,0,0,0,0 };

PixMap  PixMap_CROSS = { 8,8,4,4,_CROSS_MAP};

  
      
