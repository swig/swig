/******************************************************************************
 * DOH 
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 ******************************************************************************/

static char cvsroot[] = "$Header$";

/* ---------------------------------------------------------------------------
 * file.c
 *
 * This file implements a DOH file-like object.
 * --------------------------------------------------------------------------- */

#include "dohint.h"
#include <unistd.h>

typedef struct {
  DOHCOMMON;
  FILE     *filep;       
  int       fd;
  int closeondel;
} DohFile;

/* -----------------------------------------------------------------------------
 * DelFile(DOH *s) - Delete a file
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
 * int File_read(DOH *so, void *buffer, int len)
 * 
 * Read data from the File
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
 * int File_write(DOH *so, void *buffer, int len)
 * 
 * Write data to the File
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
 * int File_seek(DOH *so, long offset, int whence)
 * 
 * Seek to a new position
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
 * long File_tell(DOH *so)
 * 
 * Return current position
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
 * int File_putc(DOH *obj, int ch)
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
 * int File_getc(DOH *obj)
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
 * int File_ungetc(DOH *obj, int ch)
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
    0,               /* doh_scope    */
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
 * NewFile(DOH *filename, char *mode)
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
 * NewFileFromFile(FILE *f)
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
 * NewFileFromFd(int fd)
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
 * int File_check(DOH *f) - Check if f is a file
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






