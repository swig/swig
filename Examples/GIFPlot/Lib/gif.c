
/**********************************************************************
 * GIFPlot 0.0
 * 
 * Dave Beazley
 * 
 * Department of Computer Science        Theoretical Division (T-11)        
 * University of Utah                    Los Alamos National Laboratory     
 * Salt Lake City, Utah 84112            Los Alamos, New Mexico  87545      
 * beazley@cs.utah.edu                   beazley@lanl.gov                   
 *
 * Copyright (c) 1996
 * The Regents of the University of California and the University of Utah
 * All Rights Reserved
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and its documentation for any purpose, provided that 
 * (1) The above copyright notice and the following two paragraphs
 * appear in all copies of the source code and (2) redistributions
 * including binaries reproduces these notices in the supporting
 * documentation.   Substantial modifications to this software may be
 * copyrighted by their authors and need not follow the licensing terms
 * described here, provided that the new terms are clearly indicated in
 * all files where they apply.
 * 
 * IN NO EVENT SHALL THE AUTHOR, THE UNIVERSITY OF CALIFORNIA, THE 
 * UNIVERSITY OF UTAH OR DISTRIBUTORS OF THIS SOFTWARE BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF THE AUTHORS OR ANY OF THE ABOVE PARTIES HAVE BEEN ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHOR, THE UNIVERSITY OF CALIFORNIA, AND THE UNIVERSITY OF UTAH
 * SPECIFICALLY DISCLAIM ANY WARRANTIES,INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND 
 * THE AUTHORS AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE,
 * SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 **************************************************************************/

/*******************************************************************
 * Creates a GIF format file.  
 *
 * Dave Beazley (T-11)
 * August 11, 1995
 *
 * Rather than writing directly to files, this module fills out
 * output buffer.
 * 
 * Note : To save memory, this routine uses approximately 50K of the
 * output buffer as temporary storage (for hash tables and compression codes).
 * The remainder of the output buffer is used to store the final image.
 * This feature allows GIF images to be created with no additional
 * memory overhead.
 *
 * -- Revision History 
 * $Log$
 * Revision 1.2  2003/09/01 16:23:31  beazley
 * Restored the 'mojo'.
 *
 * Revision 1.2  1996/09/25 22:39:30  dmb
 * Fixed prototypes and use of void pointers for compatibility with the Cray T3D
 *
 * Revision 1.1  1996/09/10 17:44:00  dmb
 * Initial revision
 *
 * Revision 1.2  1995/08/31 14:46:07  beazley
 * Minor changes to support comments and a few bug fixes.
 *
 *
 ******************************************************************/


/*
 * xvgifwr.c  -  handles writing of GIF files.  based on flgife.c and
 *               flgifc.c from the FBM Library, by Michael Maudlin
 *
 * Contains: 
 *   WriteGIF(fp, pic, ptype, w, h, rmap, gmap, bmap, numcols, colorstyle,
 *            comment)
 *
 * Note: slightly brain-damaged, in that it'll only write non-interlaced 
 *       GIF files (in the interests of speed, or something)
 *
 */



/*****************************************************************
 * Portions of this code Copyright (C) 1989 by Michael Mauldin.
 * Permission is granted to use this file in whole or in
 * part for any purpose, educational, recreational or commercial,
 * provided that this copyright notice is retained unchanged.
 * This software is available to all free of charge by anonymous
 * FTP and in the UUNET archives.
 *
 *
 * Authors:  Michael Mauldin (mlm@cs.cmu.edu)
 *           David Rowley (mgardi@watdcsu.waterloo.edu)
 *
 * Based on: compress.c - File compression ala IEEE Computer, June 1984.
 *
 *	Spencer W. Thomas       (decvax!harpo!utah-cs!utah-gr!thomas)
 *	Jim McKie               (decvax!mcvax!jim)
 *	Steve Davies            (decvax!vax135!petsd!peora!srd)
 *	Ken Turkowski           (decvax!decwrl!turtlevax!ken)
 *	James A. Woods          (decvax!ihnp4!ames!jaw)
 *	Joe Orost               (decvax!vax135!petsd!joe)
 *****************************************************************/

#include "gifplot.h"
#include <string.h> 
typedef long int        count_int;
typedef unsigned char   byte;

static int  gif_error;
static unsigned char *op;
static int  Width, Height;
static int  curx, cury;
static int  Interlace;

static void putgifword(int);
static void compress(int, byte **, int);
static void output_GIF(int);
static void cl_block(void);
static void cl_hash(count_int);
static void char_init(void);
static void char_out(int);
static void flush_char(void);
static void *OutBuffer;
static int   OutBufSize;
static FrameBuffer *GIF_frame;

static unsigned char pc2nc[256],r1[256],g1[256],b1[256];

/*************************************************************/
int FrameBuffer_makeGIF(FrameBuffer *f, ColorMap *c, void *outbuffer, unsigned int outbufsize)
{
  int   RWidth, RHeight;
  int   LeftOfs, TopOfs;
  int   ColorMapSize, InitCodeSize, Background, BitsPerPixel;
  int   i,j,nc;
  char *rmap, *gmap, *bmap;
  char *cmap;
  int   count;

  Interlace = 0;
  Background = 0;
  OutBuffer = outbuffer;
  OutBufSize = outbufsize;
  GIF_frame = f;
  cmap = (char *) c->cmap;
  
  op = (unsigned char *) outbuffer;
  gif_error = 0;
  for (i=0; i<256; i++) { pc2nc[i] = r1[i] = g1[i] = b1[i] = 0; }

  /* compute number of unique colors */
  nc = 0;
  rmap = &cmap[0];
  gmap = &cmap[256];
  bmap = &cmap[512];

  for (i=0; i<256; i++) {
    /* see if color #i is already used */
    for (j=0; j<i; j++) {
      if (rmap[i] == rmap[j] && gmap[i] == gmap[j] && 
	  bmap[i] == bmap[j]) break;
    }

    if (j==i) {  /* wasn't found */
      pc2nc[i] = nc;
      r1[nc] = rmap[i];
      g1[nc] = gmap[i];
      b1[nc] = bmap[i];
      nc++;
    }
    else pc2nc[i] = pc2nc[j];
  }

  /* figure out 'BitsPerPixel' */
  for (i=1; i<8; i++)
    if ( (1<<i) >= nc) break;
  
  BitsPerPixel = i;

  ColorMapSize = 1 << BitsPerPixel;
	
  RWidth  = Width  = f->width;
  RHeight = Height = f->height;
  LeftOfs = TopOfs = 0;

  if (BitsPerPixel <= 1) InitCodeSize = 2;
                    else InitCodeSize = BitsPerPixel;

  curx = 0;
  cury = f->height - 1;

  strcpy((char *) op,"GIF89a");        /* Put in GIF magic number */
  op+=6;
  putgifword(RWidth);           /* screen descriptor */
  putgifword(RHeight);

  i = 0x80;	                 /* Yes, there is a color map */
  i |= (8-1)<<4;                 /* OR in the color resolution (hardwired 8) */
  i |= (BitsPerPixel - 1);       /* OR in the # of bits per pixel */
  *(op++) = i;
  *(op++) = Background;          /* background color */
  *(op++) = 0;
  for (i=0; i<ColorMapSize; i++) {       /* write out Global colormap */
    *(op++) = r1[i];
    *(op++) = g1[i];
    *(op++) = b1[i];
  }

  *(op++) = ',';                /* image separator */

  /* Write the Image header */
  putgifword(LeftOfs);
  putgifword(TopOfs);
  putgifword(Width);
  putgifword(Height);
  *(op++) = 0;
  *(op++) = InitCodeSize;

  compress(InitCodeSize+1, f->pixels, f->width*f->height);

  *(op++) = 0;
  *(op++) = ';';
  
  count = (op - (unsigned char *) OutBuffer);
  if (gif_error) return -1;
  else return count;
}

/******************************/
static void putgifword(w)
int w;
{
  /* writes a 16-bit integer in GIF order (LSB first) */
  *(op++) = w & 0xff;
  *(op++) = (w>>8)&0xff;
}

/***********************************************************************/


static unsigned long cur_accum = 0;
static int           cur_bits = 0;




#define GP_BITS	12    /* BITS was already defined on some systems */

#define HSIZE  5003            /* 80% occupancy */

typedef unsigned char   char_type;

static int n_bits;                    /* number of bits/code */
static int maxbits = GP_BITS;         /* user settable max # bits/code */
static int maxcode;                   /* maximum code, given n_bits */
static int maxmaxcode = 1 << GP_BITS; /* NEVER generate this */

#define MAXCODE(n_bits)     ( (1 << (n_bits)) - 1)

static  count_int      *htab;
static  unsigned short *codetab;
static  int GIFOutBufSize;

/* static  count_int      htab [HSIZE];
static  unsigned short codetab [HSIZE]; */

#define HashTabOf(i)   htab[i]
#define CodeTabOf(i)   codetab[i]

static int hsize = HSIZE;            /* for dynamic table sizing */

/*
 * To save much memory, we overlay the table used by compress() with those
 * used by decompress().  The tab_prefix table is the same size and type
 * as the codetab.  The tab_suffix table needs 2**BITS characters.  We
 * get this from the beginning of htab.  The output stack uses the rest
 * of htab, and contains characters.  There is plenty of room for any
 * possible stack (stack used to be 8000 characters).
 */

#define tab_prefixof(i) CodeTabOf(i)
#define tab_suffixof(i)        ((char_type *)(htab))[i]
#define de_stack               ((char_type *)&tab_suffixof(1<<GP_BITS))

static int free_ent = 0;                  /* first unused entry */

/*
 * block compression parameters -- after all codes are used up,
 * and compression rate changes, start over.
 */
static int clear_flg = 0;

static long int out_count = 0;           /* # of codes output (for debugging) */

/*
 * compress stdin to stdout
 *
 * Algorithm:  use open addressing double hashing (no chaining) on the 
 * prefix code / next character combination.  We do a variant of Knuth's
 * algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime
 * secondary probe.  Here, the modular division first probe is gives way
 * to a faster exclusive-or manipulation.  Also do block compression with
 * an adaptive reset, whereby the code table is cleared when the compression
 * ratio decreases, but after the table fills.  The variable-length output
 * codes are re-sized at this point, and a special CLEAR code is generated
 * for the decompressor.  Late addition:  construct the table according to
 * file size for noticeable speed improvement on small files.  Please direct
 * questions about this implementation to ames!jaw.
 */

static int g_init_bits;

static int ClearCode;
static int EOFCode;


/********************************************************/
static void compress(init_bits, data, len)
         int   init_bits;
         unsigned char **data;
         int   len;
{
  register long fcode;
  register int i = 0;
  register int c;
  register int ent;
  register int disp;
  register int hsize_reg;
  register int hshift;
  int      code_count = 0;

  /* Use the output buffer as temporary storage for GIF data */

  if (OutBufSize < HSIZE*(sizeof(count_int) + sizeof(unsigned short))) {
    gif_error =1;
    return;
  }

  /* Put htab and codetab arrays into the output buffer */

  GIFOutBufSize = OutBufSize - HSIZE*(sizeof(count_int) + sizeof(unsigned short)) - 16;
  GIFOutBufSize = GIFOutBufSize & (~0x3);       /* Make sure it's double word alligned */

  htab = (count_int *) ((char *) OutBuffer + GIFOutBufSize);
  codetab = (unsigned short *) ((char *) OutBuffer + GIFOutBufSize + HSIZE*sizeof(count_int));

  /*
   * Set up the globals:  g_init_bits - initial number of bits
   *                      g_outfile   - pointer to output file
   */
  g_init_bits = init_bits;


  /* initialize 'compress' globals */
  maxbits = GP_BITS;
  maxmaxcode = 1<<GP_BITS;
  memset(htab,0,sizeof(htab));
  memset(codetab,0,sizeof(codetab));
  hsize = HSIZE;
  free_ent = 0;
  clear_flg = 0;
  out_count = 0;
  cur_accum = 0;
  cur_bits = 0;

  /*
   * Set up the necessary values
   */
  out_count = 0;
  clear_flg = 0;
  maxcode = MAXCODE(n_bits = g_init_bits);

  ClearCode = (1 << (init_bits - 1));
  EOFCode = ClearCode + 1;
  free_ent = ClearCode + 2;

  char_init();
  ent = pc2nc[data[cury][curx]];
  curx++;
  if (curx >= GIF_frame->width) {
    curx = 0;
    cury--;
  }
  len--;

  hshift = 0;
  for ( fcode = (long) hsize;  fcode < 65536L; fcode *= 2L )
    hshift++;
  hshift = 8 - hshift;                /* set hash code range bound */

  hsize_reg = hsize;
  cl_hash( (count_int) hsize_reg);            /* clear hash table */

  output_GIF(ClearCode);
  while (len) {
    c = pc2nc[data[cury][curx]];
    curx++;
    if (curx >= GIF_frame->width) {
      curx = 0;
      cury--;
    }
    len--;

    fcode = (long) ( ( (long) c << maxbits) + ent);
       i = (((int) c << hshift) ^ ent);    /* xor hashing */

    if ( HashTabOf (i) == fcode ) {
      ent = CodeTabOf (i);
      continue;
    }

    if ( (long)HashTabOf (i) < 0 )      /* empty slot */
      goto nomatch;

    disp = hsize_reg - i;           /* secondary hash (after G. Knott) */
    if ( i == 0 )
      disp = 1;

probe:
    if ( (i -= disp) < 0 )
      i += hsize_reg;

    if ( HashTabOf (i) == fcode ) {
      ent = CodeTabOf (i);
      continue;
    }

    if ( (long)HashTabOf (i) >= 0 ) 
      goto probe;

nomatch:
    output_GIF(ent);
    out_count++;
    ent = c;

    if ( free_ent < maxmaxcode ) {
      CodeTabOf (i) = free_ent++; /* code -> hashtable */
      HashTabOf (i) = fcode;
    }
    else
      cl_block();

  }
  /* Put out the final code */
  output_GIF(ent);
  output_GIF(EOFCode);
}


/*****************************************************************
 * TAG( output_GIF )
 *
 * Output the given code.
 * Inputs:
 *      code:   A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *              that n_bits =< (long)wordsize - 1.
 * Outputs:
 *      Outputs code to the file.
 * Assumptions:
 *      Chars are 8 bits long.
 * Algorithm:
 *      Maintain a BITS character long buffer (so that 8 codes will
 * fit in it exactly).  Use the VAX insv instruction to insert each
 * code in turn.  When the buffer fills up empty it and start over.
 */

static
unsigned long masks[] = { 0x0000, 0x0001, 0x0003, 0x0007, 0x000F,
                                  0x001F, 0x003F, 0x007F, 0x00FF,
                                  0x01FF, 0x03FF, 0x07FF, 0x0FFF,
                                  0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF };

static void output_GIF(code)
int code;
{
  cur_accum &= masks[cur_bits];

  if (cur_bits > 0)
    cur_accum |= ((long)code << cur_bits);
  else
    cur_accum = code;
	
  cur_bits += n_bits;

  while( cur_bits >= 8 ) {
    char_out( (int) (cur_accum & 0xff) );
    cur_accum >>= 8;
    cur_bits -= 8;
  }

  /*
   * If the next entry is going to be too big for the code size,
   * then increase it, if possible.
   */

  if (free_ent > maxcode || clear_flg) {

    if( clear_flg ) {
      maxcode = MAXCODE (n_bits = g_init_bits);
      clear_flg = 0;
    }
    else {
      n_bits++;
      if ( n_bits == maxbits )
	maxcode = maxmaxcode;
      else
	maxcode = MAXCODE(n_bits);
    }
  }
	
  if( code == EOFCode ) {
    /* At EOF, write the rest of the buffer */
    while( cur_bits > 0 ) {
      char_out( (int)(cur_accum & 0xff) );
      cur_accum >>= 8;
      cur_bits -= 8;
    }

    flush_char();
  }
}


/********************************/
static void cl_block ()             /* table clear for block compress */
{
  /* Clear out the hash table */

  cl_hash ( (count_int) hsize );
  free_ent = ClearCode + 2;
  clear_flg = 1;

  output_GIF(ClearCode);
}


/********************************/
static void cl_hash(hsize)          /* reset code table */
register count_int hsize;
{
  register count_int *htab_p = htab+hsize;
  register long i;
  register long m1 = -1;

  i = hsize - 16;
  do {                            /* might use Sys V memset(3) here */
    *(htab_p-16) = m1;
    *(htab_p-15) = m1;
    *(htab_p-14) = m1;
    *(htab_p-13) = m1;
    *(htab_p-12) = m1;
    *(htab_p-11) = m1;
    *(htab_p-10) = m1;
    *(htab_p-9) = m1;
    *(htab_p-8) = m1;
    *(htab_p-7) = m1;
    *(htab_p-6) = m1;
    *(htab_p-5) = m1;
    *(htab_p-4) = m1;
    *(htab_p-3) = m1;
    *(htab_p-2) = m1;
    *(htab_p-1) = m1;
    htab_p -= 16;
  } while ((i -= 16) >= 0);

  for ( i += 16; i > 0; i-- )
    *--htab_p = m1;
}


/******************************************************************************
 *
 * GIF Specific routines
 *
 ******************************************************************************/

/*
 * Number of characters so far in this 'packet'
 */
static int a_count;

/*
 * Set up the 'byte output' routine
 */
static void char_init()
{
	a_count = 0;
}

/*
 * Define the storage for the packet accumulator
 */
static char accum[ 256 ];

/*
 * Add a character to the end of the current packet, and if it is 254
 * characters, flush the packet to disk.
 */
static void char_out(c)
int c;
{
  accum[ a_count++ ] = c;
  if( a_count >= 254 ) 
    flush_char();
}

/*
 * Flush the packet to disk, and reset the accumulator
 */
static void flush_char()
{
  if (gif_error) return;
  if( a_count > 0 ) {
    *(op++) = a_count;
    memcpy(op,accum,a_count);
    op+=a_count;
    a_count = 0;
    
    if (op > (unsigned char *) ((char *) OutBuffer + (GIFOutBufSize - 2048))) {
      gif_error = 1;
    }
  } 
}	


/* ----------------------------------------------------------------------
   int FrameBuffer_writeGIF(char *filename)
   
   Write a GIF file to filename
   ----------------------------------------------------------------------- */

int FrameBuffer_writeGIF(FrameBuffer *f, ColorMap *c, char *filename) {

  FILE *file;
  void *buffer;
  int nbytes;
  int bufsize;

  file = fopen(filename,"wb");
  if (file == NULL) return -1;

  bufsize = (f->width*f->height*3)/2;
  buffer = (void *) malloc(bufsize);
  nbytes = FrameBuffer_makeGIF(f,c,buffer,bufsize);
  if (nbytes == -1) { 
    free(buffer);
    fclose(file);
    return -1;
  }
  if (fwrite(buffer,nbytes,1,file) != 1) {
    free(buffer);
    fclose(file);
    return -1;
  }
  fclose(file);
  free(buffer);
  return 0;
}

    
  
  
  
