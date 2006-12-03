/* This example shows a very simple interface wrapping a few 
   primitive declarations */

%module simple
%{
#include "gifplot.h"
%}

typedef unsigned char Pixel;

/* Here are a few useful functions */

ColorMap    *new_ColorMap(char *filename = 0);
void         delete_ColorMap(ColorMap *cmap);

FrameBuffer *new_FrameBuffer(unsigned int width, unsigned int height);
void         delete_FrameBuffer(FrameBuffer *frame);
void         FrameBuffer_clear(FrameBuffer *frame, Pixel color);
void         FrameBuffer_line(FrameBuffer *frame, int x1, int y1, int x2, int y2, Pixel color);
void         FrameBuffer_box(FrameBuffer *frame, int x1, int y1, int x2, int y2, Pixel color);
void         FrameBuffer_circle(FrameBuffer *frame, int x1, int y1, int radius, Pixel color);
int          FrameBuffer_writeGIF(FrameBuffer *f, ColorMap *c, char *filename);

/* And some useful constants */

#define BLACK   0
#define WHITE   1
#define RED     2
#define GREEN   3
#define BLUE    4
#define YELLOW  5
#define CYAN    6
#define MAGENTA 7





