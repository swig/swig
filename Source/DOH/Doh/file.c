/* ----------------------------------------------------------------------------- 
 * file.c
 *
 *     This file implements a file-like object that can be built around an 
 *     ordinary FILE * or integer file descriptor.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"
#include <unistd.h>

typedef struct {
  DOHCOMMON;
  FILE     *filep;       
  int       fd;
  int closeondel;
} DohFile;

/* -----------------------------------------------------------------------------
 * DelFile()
 *
 * Delete a file.  Closes the file if the closeondel flag is set.
 * ----------------------------------------------------------------------------- */

static void
DelFile(DOH *so) {
  DohFile *f = (DohFile *) so;
  assert(f->refcount <= 0);
  if (f->closeondel)
    fclose(f->filep);
  DohObjFree(f);
}

/* -----------------------------------------------------------------------------
 * File_read()
 * 
 * Reads data from a file into a buffer.
 * ----------------------------------------------------------------------------- */

static int
File_read(DOH *so, void *buffer, int len) {
  DohFile *s = (DohFile *) so;
  if (s->filep) 
    return fread(buffer,1,len,s->filep);
  else 
    return read(s->fd,buffer,len);
}

/* -----------------------------------------------------------------------------
 * File_write()
 * 
 * Write data from a buffer to a file.
 * ----------------------------------------------------------------------------- */

static int
File_write(DOH *so, void *buffer, int len) {
  DohFile *s = (DohFile *) so;
  if (s->filep) 
    return fwrite(buffer,1,len,s->filep);
  else
    return write(s->fd, buffer, len);
}

/* -----------------------------------------------------------------------------
 * File_seek()
 * 
 * Seek to a new file position.
 * ----------------------------------------------------------------------------- */

static int
File_seek(DOH *so, long offset, int whence) {
  DohFile *s = (DohFile *) so;
  if (s->filep) 
    return fseek(s->filep,offset,whence);
  else
    return lseek(s->fd,offset,whence);
}

/* -----------------------------------------------------------------------------
 * File_tell()
 * 
 * Return current file pointer.
 * ----------------------------------------------------------------------------- */

static long
File_tell(DOH *so) {
  DohFile *s = (DohFile *) so;
  if (s->filep) 
    return ftell(s->filep);
  else
    return lseek(s->fd,0,SEEK_CUR);
}

/* -----------------------------------------------------------------------------
 * File_putc()
 *
 * Put a character on the output
 * ----------------------------------------------------------------------------- */

static int 
File_putc(DOH *obj, int ch) {
  DohFile *s = (DohFile *) obj;
  if (s->filep) 
    return fputc(ch,s->filep);
  return EOF;
}

/* -----------------------------------------------------------------------------
 * File_getc()
 *
 * Get a character
 * ----------------------------------------------------------------------------- */

static int 
File_getc(DOH *obj) {
  DohFile *s = (DohFile *) obj;
  if (s->filep)
    return fgetc(s->filep);
  return EOF;
}

/* -----------------------------------------------------------------------------
 * File_ungetc()
 *
 * Put a character back onto the input
 * ----------------------------------------------------------------------------- */

static int 
File_ungetc(DOH *obj, int ch) {
  DohFile *s = (DohFile *) obj;
  if (s->filep)
    return ungetc(ch, s->filep);
  return EOF;
}

static DohFileMethods FileFileMethods = {
  File_read, 
  File_write,
  File_putc,
  File_getc,
  File_ungetc,
  File_seek,
  File_tell,
  0,              /* close */
};

static DohObjInfo DohFileType = {
    "DohFile",          /* objname      */
    sizeof(DohFile),    /* objsize      */
    DelFile,         /* doh_del      */
    0,               /* doh_copy     */
    0,               /* doh_clear    */
    0,               /* doh_str      */
    0,               /* doh_data     */
    0,               /* doh_dump     */
    0,               /* doh_load     */
    0,               /* doh_len      */
    0,               /* doh_hash     */
    0,               /* doh_cmp      */
    0,               /* doh_mapping  */
    0,               /* doh_sequence */
    &FileFileMethods,/* doh_file     */
    0,               /* doh_string   */
    0,               /* doh_callable */
    0,               /* doh_position */
};

/* -----------------------------------------------------------------------------
 * NewFile()
 *
 * Create a new file from a given filename and mode.
 * ----------------------------------------------------------------------------- */

DOH *
NewFile(DOH *fn, char *mode)
{
  DohFile *f;
  FILE *file;
  char *filename;

  filename = Char(fn);
  file = fopen(filename,mode);
  if (!file) return 0;

  f = (DohFile *) DohObjMalloc(sizeof(DohFile));
  if (!f) {
    fclose(file);
    return 0;
  }
  f->objinfo = &DohFileType;
  f->filep = file;
  f->fd = fileno(file);
  f->closeondel = 1;
  return (DOH *) f;
}

/* -----------------------------------------------------------------------------
 * NewFileFromFile()
 *
 * Create a file object from an already open FILE *.
 * ----------------------------------------------------------------------------- */

DOH *
NewFileFromFile(FILE *file) 
{
  DohFile *f;
  f = (DohFile *) DohObjMalloc(sizeof(DohFile));
  if (!f) return 0;
  f->objinfo = &DohFileType;
  f->filep = file;
  f->fd = fileno(file);
  f->closeondel = 0;
  return (DOH *) f;
}

/* -----------------------------------------------------------------------------
 * NewFileFromFd()
 *
 * Create a file object from an already existing integer file descriptor.
 * ----------------------------------------------------------------------------- */

DOH *
NewFileFromFd(int fd)
{
  DohFile *f;
  f = (DohFile *) DohObjMalloc(sizeof(DohFile));
  if (!f) return 0;
  f->objinfo = &DohFileType;
  f->filep = 0;
  f->fd = fd;
  f->closeondel = 0;
  return (DOH *) f;
}
    

/* -----------------------------------------------------------------------------
 * File_check()
 *
 * Check if an object is a file.
 * ----------------------------------------------------------------------------- */
int
File_check(DOH *f) 
{
  DohFile *df;
  if (!DohCheck(f)) return 0;
  df = (DohFile *) f;
  if (df->objinfo == &DohFileType) return 1;
  return 0;
}






