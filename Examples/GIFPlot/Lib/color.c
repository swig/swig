/* ----------------------------------------------------------------------------- 
 * color.c
 *
 *     Colormaps
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 * Copyright (C) 1995-1996
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define COLORMAP
#include "gifplot.h"
#include <string.h>

/* ------------------------------------------------------------------------
   ColorMap *new_ColorMap(char *filename)

   Read a colormap from a file.
   ------------------------------------------------------------------------ */

ColorMap *new_ColorMap(char *filename) {
  ColorMap *c;
  FILE *cm;
  void ColorMap_default(ColorMap *);
  
  if (!filename) {
    c = (ColorMap *) malloc(sizeof(ColorMap));
    c->cmap = (unsigned char *) malloc(768*sizeof(char));
    c->name = 0;
    ColorMap_default(c);
    return c;
  }
  if (strlen(filename) == 0) {
    c = (ColorMap *) malloc(sizeof(ColorMap));
    c->cmap = (unsigned char *) malloc(768*sizeof(char));
    ColorMap_default(c);
    return c;
  }
  if ((cm = fopen(filename,"rb")) == NULL) {
    return (ColorMap *) 0;
  }
  c = (ColorMap *) malloc(sizeof(ColorMap));
  c->cmap = (unsigned char *) malloc(768*sizeof(char));
  if (fread(c->cmap, 768, 1, cm) != 1) {
    free((char *)c->cmap);
    free((char *)c);
    fclose(cm);
    return (ColorMap *) 0;
  }
  fclose(cm);
  c->name = (char *) malloc(strlen(filename)+1);
  strcpy(c->name, filename);
  ColorMap_default(c);
  return c;
}

/* --------------------------------------------------------------------------
   delete_ColorMap(ColorMap *cm)

   Destroy a ColorMap
   -------------------------------------------------------------------------- */

void delete_ColorMap(ColorMap *cm) {
  if (cm) {
    free((char *)cm->cmap);
    if (cm->name)
      free((char *)cm->name);
    free((char *)cm);
  }
}

/* --------------------------------------------------------------------------
   ColorMap_default(ColorMap *cm)

   This function fills in default values for the first 8 entries of the
   colormap.  These are *fixed* values---used internally.
   -------------------------------------------------------------------------- */

void ColorMap_default(ColorMap *cm) {
  unsigned char *r,*g,*b;
  if (cm) {
    r = cm->cmap;
    g = cm->cmap+256;
    b = cm->cmap+512;

    r[0] = 0;   g[0] = 0;   b[0] = 0;      /* BLACK */
    r[1] = 255; g[1] = 255; b[1] = 255;    /* WHITE */
    r[2] = 255; g[2] = 0;   b[2] = 0;      /* RED   */
    r[3] = 0;   g[3] = 255; b[3] = 0;      /* GREEN */
    r[4] = 0;   g[4] = 0;   b[4] = 255;    /* BLUE  */
    r[5] = 255; g[5] = 255; b[5] = 0;      /* YELLOW */
    r[6] = 0;   g[6] = 255; b[6] = 255;    /* CYAN   */
    r[7] = 255; g[7] = 0;   b[7] = 255;    /* MAGENTA */
  }
}

void ColorMap_assign(ColorMap *cm, int index, int r, int g, int b) {
  unsigned char *rb,*gb,*bb;

  rb = cm->cmap;
  gb = cm->cmap+256;
  bb = cm->cmap+512;

  rb[index] = r;
  gb[index] = g;
  bb[index] = b;
}

int ColorMap_getitem(ColorMap *cm, int index) {
  if ((index < 0) && (index >= 768)) return -1;
  return cm->cmap[index];
}

void ColorMap_setitem(ColorMap *cm, int index, int value) {
  if ((index < 0) && (index >= 768)) return;
  cm->cmap[index]=value;
}  

/* --------------------------------------------------------------------
   ColorMap_write(ColorMap *cm, char *filename)

   Write out a colormap to disk.
   -------------------------------------------------------------------- */

int ColorMap_write(ColorMap *cm, char *filename) {

  FILE *f;
  if (!cm) return -1;
  if (!filename) return -1;
  if (strlen(filename) == 0) return -1;

  f = fopen(filename,"w");
  
  fwrite(cm->cmap,768,1,f);
  fclose(f);
  return 0;
}

#undef COLORMAP
