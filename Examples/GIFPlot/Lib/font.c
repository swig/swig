/* ----------------------------------------------------------------------------- 
 * font.c
 *
 *     Some basic fonts.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 * Copyright (C) 1995-1996
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#define FONT
#include "gifplot.h"

static char Char_A[80] = "\
...x....\
...x....\
..x.x...\
..x.x...\
.x...x..\
.xxxxx..\
x.....x.\
x.....x.\
x.....x.\
........";

static char Char_B[80] = "\
xxxxxx..\
x.....x.\
x.....x.\
x.....x.\
xxxxxx..\
x.....x.\
x.....x.\
x.....x.\
xxxxxx..\
........";

static char Char_C[80] = "\
..xxxx..\
.x....x.\
x.......\
x.......\
x.......\
x.......\
x.......\
.x....x.\
..xxxx..\
........";

static char Char_D[80] = "\
xxxxx...\
x....x..\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x....x..\
xxxxx...\
........";
static char Char_E[80] = "\
xxxxxxx.\
x.......\
x.......\
x.......\
xxxxx...\
x.......\
x.......\
x.......\
xxxxxxx.\
........";
static char Char_F[80] = "\
xxxxxxx.\
x.......\
x.......\
x.......\
xxxxx...\
x.......\
x.......\
x.......\
x.......\
........";
static char Char_G[80] = "\
.xxxxx..\
x.....x.\
x.......\
x.......\
x...xxx.\
x.....x.\
x.....x.\
x.....x.\
.xxxxx..\
........";
static char Char_H[80] = "\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
xxxxxxx.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
........";
static char Char_I[80] = "\
xxxxxxx.\
...x....\
...x....\
...x....\
...x....\
...x....\
...x....\
...x....\
xxxxxxx.\
........";
static char Char_J[80] = "\
......x.\
......x.\
......x.\
......x.\
......x.\
......x.\
x.....x.\
.x...x..\
..xxx...\
........";
static char Char_K[80] = "\
x.....x.\
x....x..\
x...x...\
x..x....\
xxx.....\
x..x....\
x...x...\
x....x..\
x.....x.\
........";
static char Char_L[80] = "\
x.......\
x.......\
x.......\
x.......\
x.......\
x.......\
x.......\
x.......\
xxxxxxx.\
........";
static char Char_M[80] = "\
x.....x.\
xx...xx.\
xx...xx.\
x.x.x.x.\
x.x.x.x.\
x..x..x.\
x..x..x.\
x.....x.\
x.....x.\
........";
static char Char_N[80] = "\
x.....x.\
xx....x.\
x.x...x.\
x.x...x.\
x..x..x.\
x...x.x.\
x...x.x.\
x....xx.\
x.....x.\
........";
static char Char_O[80] = "\
.xxxxx..\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
.xxxxx..\
........";
static char Char_P[80] = "\
xxxxxx..\
x.....x.\
x.....x.\
x.....x.\
xxxxxx..\
x.......\
x.......\
x.......\
x.......\
........";
static char Char_Q[80] = "\
.xxxxx..\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x...x.x.\
x....x..\
.xxxx.x.\
........";
static char Char_R[80] = "\
xxxxxx..\
x.....x.\
x.....x.\
x.....x.\
xxxxxx..\
x..x....\
x...x...\
x....x..\
x.....x.\
........";
static char Char_S[80] = "\
.xxxxx..\
x.....x.\
x.......\
x.......\
.xxxxx..\
......x.\
......x.\
x.....x.\
.xxxxx..\
........";
static char Char_T[80] = "\
xxxxxxx.\
...x....\
...x....\
...x....\
...x....\
...x....\
...x....\
...x....\
...x....\
........";
static char Char_U[80] = "\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
.xxxxx..\
........";
static char Char_V[80] = "\
x.....x.\
x.....x.\
.x...x..\
.x...x..\
..x.x...\
..x.x...\
...x....\
...x....\
...x....\
........";
static char Char_W[80] = "\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x.....x.\
x..x..x.\
x..x..x.\
x.x.x.x.\
.x...x..\
........";
static char Char_X[80] = "\
x.....x.\
x.....x.\
.x...x..\
..x.x...\
...x....\
..x.x...\
.x...x..\
x.....x.\
x.....x.\
........";
static char Char_Y[80] = "\
x.....x.\
x.....x.\
.x...x..\
..x.x...\
...x....\
...x....\
...x....\
...x....\
...x....\
........";
static char Char_Z[80] = "\
xxxxxxx.\
......x.\
.....x..\
....x...\
...x....\
..x.....\
.x......\
x.......\
xxxxxxx.\
........";
static char Char_0[80] = "\
.xxxxx..\
x....xx.\
x...x.x.\
x..x..x.\
x..x..x.\
x.x...x.\
x.x...x.\
xx....x.\
.xxxxx..\
........";
static char Char_1[80] = "\
...x....\
..xx....\
...x....\
...x....\
...x....\
...x....\
...x....\
...x....\
..xxx...\
........";
static char Char_2[80] = "\
..xxxx..\
.x....x.\
x.....x.\
.....x..\
....x...\
...x....\
..x.....\
.x......\
xxxxxxx.\
........";
static char Char_3[80] = "\
.xxxxx..\
x.....x.\
......x.\
......x.\
...xxx..\
......x.\
......x.\
x.....x.\
.xxxxx..\
........";
static char Char_4[80] = "\
....xx..\
...x.x..\
..x..x..\
.x...x..\
xxxxxxx.\
.....x..\
.....x..\
.....x..\
.....x..\
........";
static char Char_5[80] = "\
xxxxxxx.\
x.......\
x.......\
x.......\
xxxxxx..\
......x.\
......x.\
x.....x.\
.xxxxx..\
........";
static char Char_6[80] = "\
....xxx.\
..xx....\
.x......\
x.......\
x.xxx...\
xx...x..\
x.....x.\
.x...x..\
..xxx...\
........";
static char Char_7[80] = "\
xxxxxxx.\
x.....x.\
.....x..\
....x...\
...x....\
..x.....\
.x......\
x.......\
x.......\
........";
static char Char_8[80] = "\
.xxxxx..\
x.....x.\
x.....x.\
x.....x.\
.xxxxx..\
x.....x.\
x.....x.\
x.....x.\
.xxxxx..\
........";
static char Char_9[80] = "\
..xxxx..\
.x....x.\
x.....x.\
x....xx.\
.xxxx.x.\
......x.\
......x.\
....xx..\
.xxx....\
........";
static char Char_MINUS[80] = "\
........\
........\
........\
........\
.xxxxxx.\
........\
........\
........\
........\
........";
static char Char_PLUS[80] = "\
........\
........\
...x....\
...x....\
.xxxxx..\
...x....\
...x....\
........\
........\
........";
static char Char_EQUAL[80] = "\
........\
........\
........\
.xxxxx..\
........\
.xxxxx..\
........\
........\
........\
........";
static char Char_LPAREN[80] = "\
....x...\
...x....\
..x.....\
.x......\
.x......\
.x......\
..x.....\
...x....\
....x...\
........";
static char Char_RPAREN[80] = "\
...x....\
....x...\
.....x..\
......x.\
......x.\
......x.\
.....x..\
....x...\
...x....\
........";
static char Char_QUOTE[80] = "\
..x.x...\
..x.x...\
........\
........\
........\
........\
........\
........\
........\
........";
static char Char_COLON[80] = "\
........\
........\
...xx...\
...xx...\
........\
...xx...\
...xx...\
........\
........\
........";
static char Char_PERIOD[80] = "\
........\
........\
........\
........\
........\
........\
........\
...xx...\
...xx...\
........";
static char Char_COMMA[80] = "\
........\
........\
........\
........\
........\
........\
...xx...\
...xx...\
....x...\
...x....";

static char Char_SLASH[80] = "\
........\
......x.\
.....x..\
....x...\
...x....\
..x.....\
.x......\
x.......\
........\
........";

static char Char_SPACE[80] = "\
........\
........\
........\
........\
........\
........\
........\
........\
........\
........";

static char  *GP_Font[128];
static int    InitGP_Font = 0;

static void initGP_Fonts(void) {

  int i;
  for (i = 0; i < 128; i++)
    GP_Font[i] = (char *) 0;
  
  GP_Font['A'] = GP_Font['a'] = Char_A;
  GP_Font['B'] = GP_Font['b'] = Char_B;
  GP_Font['C'] = GP_Font['c'] = Char_C;
  GP_Font['D'] = GP_Font['d'] = Char_D;
  GP_Font['E'] = GP_Font['e'] = Char_E;
  GP_Font['F'] = GP_Font['f'] = Char_F;
  GP_Font['G'] = GP_Font['g'] = Char_G;
  GP_Font['H'] = GP_Font['h'] = Char_H;
  GP_Font['I'] = GP_Font['i'] = Char_I;
  GP_Font['J'] = GP_Font['j'] = Char_J;
  GP_Font['K'] = GP_Font['k'] = Char_K;
  GP_Font['L'] = GP_Font['l'] = Char_L;
  GP_Font['M'] = GP_Font['m'] = Char_M;
  GP_Font['N'] = GP_Font['n'] = Char_N;
  GP_Font['O'] = GP_Font['o'] = Char_O;
  GP_Font['P'] = GP_Font['p'] = Char_P;
  GP_Font['Q'] = GP_Font['q'] = Char_Q;
  GP_Font['R'] = GP_Font['r'] = Char_R;
  GP_Font['S'] = GP_Font['s'] = Char_S;
  GP_Font['T'] = GP_Font['t'] = Char_T;
  GP_Font['U'] = GP_Font['u'] = Char_U;
  GP_Font['V'] = GP_Font['v'] = Char_V;
  GP_Font['W'] = GP_Font['w'] = Char_W;
  GP_Font['X'] = GP_Font['x'] = Char_X;
  GP_Font['Y'] = GP_Font['y'] = Char_Y;
  GP_Font['Z'] = GP_Font['z'] = Char_Z;
  GP_Font['0'] = Char_0;
  GP_Font['1'] = Char_1;
  GP_Font['2'] = Char_2;
  GP_Font['3'] = Char_3;
  GP_Font['4'] = Char_4;
  GP_Font['5'] = Char_5;
  GP_Font['6'] = Char_6;
  GP_Font['7'] = Char_7;
  GP_Font['8'] = Char_8;
  GP_Font['9'] = Char_9;
  GP_Font['.'] = Char_PERIOD;
  GP_Font[','] = Char_COMMA;
  GP_Font['='] = Char_EQUAL;
  GP_Font['-'] = Char_MINUS;
  GP_Font['+'] = Char_PLUS;
  GP_Font['\"'] = Char_QUOTE;
  GP_Font['('] = Char_LPAREN;
  GP_Font[')'] = Char_RPAREN;
  GP_Font[':'] = Char_COLON;
  GP_Font['/'] = Char_SLASH;
  GP_Font[' '] = Char_SPACE;
  InitGP_Font = 1;
}

/* -----------------------------------------------------------------------
   void FrameBuffer_drawchar(FrameBuffer *f, int x, int y, Pixel fgcolor, Pixel bgcolor, char chr, int orientation)

   Draws a character at location x, y with given color and orientation parameters.
   Orientation can either be HORIZONTAL or VERTICAL
   ----------------------------------------------------------------------- */
void FrameBuffer_drawchar(FrameBuffer *f, int x, int y, int fgcolor,
			  int bgcolor, char chr, int orientation) {

  Pixel c, bc,*p,*p1;
  char *ch;
  int i,j;
  int xpixels,ypixels;

  if (!InitGP_Font) initGP_Fonts();
  
  c =  (Pixel) fgcolor;
  bc = (Pixel) bgcolor;
  xpixels = f->width;
  ypixels = f->height;

  if (orientation == HORIZONTAL) {
    if ((x < f->xmin) || (x > f->xmax-8) ||
	(y < f->ymin) || (y > f->ymax-10)) return;
  
    ch = GP_Font[(int) chr];
    if (!ch) return;
    p = &f->pixels[y+9][x];
    for (i = 0; i < 10; i++) {
      p1 = p;
      for (j = 0; j< 8; j++) {
	if (*(ch++) == 'x') *p= c;
	else if (bgcolor >= 0)
	  *p = bc;
	p++;
      }
      p = (p1 - xpixels);
    }
  } else {
    if ((x < f->xmin+10) || (x >= f->xmax) ||
	(y < f->ymin) || (y > f->ymax-8)) return;
  
    ch = GP_Font[(int) chr];
    if (!ch) return;
    p = &f->pixels[y][x-9];
    for (i = 0; i < 10; i++) {
      p1 = p;
      for (j = 0; j< 8; j++) {
	if (*(ch++) == 'x') *p= c;
	else if (bgcolor >= 0)
	  *p = bc;
	p+=xpixels;
      }
      p = p1 + 1;
    }
  }    
}

/* ----------------------------------------------------------------------
   void FrameBuffer_drawstring(FrameBuffer *f, int x, int y, int fgcolor,
                               int bgcolor, char *text, int orientation)

   Draws an ASCII string on the framebuffer.   Can be oriented either horizontally
   or vertically.  
   ---------------------------------------------------------------------- */

void FrameBuffer_drawstring(FrameBuffer *f, int x, int y, int fgcolor, int bgcolor, char *text, int orientation) {

  char *c;
  int  x1, y1;
  int xpixels, ypixels;
  
  x1 = x;
  y1 = y;
  xpixels = f->width;
  ypixels = f->height;
  c = text;
  while (*c) {
    if (*c == '\n') {
      if (orientation == HORIZONTAL) {
	x1 = x; y1= y1- 10*xpixels;
      } else {
	y1 = y; x1= x1 + 10*ypixels;
      }
    } else {
      FrameBuffer_drawchar(f, x1,y1,fgcolor, bgcolor,*c, orientation);
      if (orientation == HORIZONTAL) {
	x1+=8;
	if (x1 >= (xpixels-8)) {
	  x1 = x; y1= y1- 10;}
	if (y1 < 0) return;
      } else {
	y1 += 8;
	if (y1 >= (ypixels-8)) {
	  y1 = y; x1 = x1 + 10;}
	if (x1 > (xpixels-10)) return;
      }
    }
    c++;
  }
}


  
  
  
  
  

