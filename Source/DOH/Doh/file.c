/****************************************************************************
 * DOH (Dynamic Object Hack)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

#include "doh.h"

/* ---------------------------------------------------------------------------
 * $Header$
 * string.c
 *
 * String support.
 * --------------------------------------------------------------------------- */

typedef struct File {
    DOHCOMMON;
    FILE     *filep;       
    int closeondel;
} File;

/* Forward references */

void    DelFile(DOH *s);
int     File_read(DOH *s, void *buffer, int length);
int     File_write(DOH *s, void *buffer, int length);
int     File_putc(DOH *s, int ch);
int     File_getc(DOH *s);
int     File_ungetc(DOH *s, int ch);
int     File_seek(DOH *s, long offset, int whence);
long    File_tell(DOH *s);


static DohFileMethods FileFileMethods = {
  File_read, 
  File_write,
  File_putc,
  File_getc,
  File_ungetc,
  File_seek,
  File_tell,
  0,
};

static DohObjInfo FileType = {
    "File",          /* objname */
    sizeof(File),    /* objsize */
    DelFile,         /* sm_del */
    0,               /* sm_copy */
    0,               /* sm_clear */
    0,               /* sm_str */
    0,               /* doh_data */
    0,               /* doh_dump */
    0,               /* sm_len */
    0,               /* sm_hash    */
    0,               /* doh_cmp */
    0,                 /* doh_mapping */
    0, /* doh_sequence */
    &FileFileMethods,/* doh_file */
    0,
    0,
    0,
    0,
};

DohObjInfo *File_type() {
  return &FileType;
}

/* -----------------------------------------------------------------------------
 * NewFile(char *filename, char *mode)
 * ----------------------------------------------------------------------------- */
DOH *
NewFile(char *filename, char *mode)
{
  File *f;
  FILE *file;
  file = fopen(filename,mode);
  if (!file) return 0;

  f = (File *) DohMalloc(sizeof(File));
  if (!f) {
    fclose(file);
    return 0;
  }
  DohInit(f);
  f->objinfo = &FileType;
  f->filep = file;
  f->closeondel = 1;
  return (DOH *) f;
}

/* -----------------------------------------------------------------------------
 * NewFileFromFile(FILE *f)
 * ----------------------------------------------------------------------------- */

DOH *
NewFileFromFile(FILE *file) 
{
  File *f;
  f = (File *) DohMalloc(sizeof(File));
  if (!f) return 0;
  DohInit(f);
  f->objinfo = &FileType;
  f->filep = file;
  f->closeondel = 0;
  return (DOH *) f;
}

/* -----------------------------------------------------------------------------
 * DelFile(DOH *s) - Delete a file
 * ----------------------------------------------------------------------------- */
void
DelFile(DOH *so) {
  File *f = (File *) so;
  assert(f->refcount <= 0);
  if (f->closeondel)
    fclose(f->filep);
  DohFree(f);
}

/* -----------------------------------------------------------------------------
 * int File_check(DOH *f) - Check if f is a file
 * ----------------------------------------------------------------------------- */
int
File_check(DOH *f) 
{
  File *df;
  if (!DohCheck(f)) return 0;
  
  df = (File *) f;
  if (df->objinfo == &FileType) return 1;
  return 0;
}

/* -----------------------------------------------------------------------------
 * int File_read(DOH *so, void *buffer, int len)
 * 
 * Read data from the File
 * ----------------------------------------------------------------------------- */
int
File_read(DOH *so, void *buffer, int len) {
  File *s = (File *) so;
  return (size_t) fread(buffer,1,len,s->filep);
}

/* -----------------------------------------------------------------------------
 * int File_write(DOH *so, void *buffer, int len)
 * 
 * Write data to the File
 * ----------------------------------------------------------------------------- */
int
File_write(DOH *so, void *buffer, int len) {
  File *s = (File *) so;
  return (size_t) fwrite(buffer,1,len,s->filep);
}

/* -----------------------------------------------------------------------------
 * int File_seek(DOH *so, long offset, int whence)
 * 
 * Seek to a new position
 * ----------------------------------------------------------------------------- */
int
File_seek(DOH *so, long offset, int whence) {
  File *s = (File *) so;
  return fseek(s->filep,offset,whence);
}

/* -----------------------------------------------------------------------------
 * long File_tell(DOH *so)
 * 
 * Return current position
 * ----------------------------------------------------------------------------- */
long
File_tell(DOH *so) {
  File *s = (File *) so;
  return ftell(s->filep);
}

/* -----------------------------------------------------------------------------
 * int File_putc(DOH *obj, int ch)
 *
 * Put a character on the output
 * ----------------------------------------------------------------------------- */

int File_putc(DOH *obj, int ch) {
  File *s = (File *) obj;
  return fputc(ch,s->filep);
}

/* -----------------------------------------------------------------------------
 * int File_getc(DOH *obj)
 *
 * Get a character
 * ----------------------------------------------------------------------------- */

int File_getc(DOH *obj) {
  File *s = (File *) obj;
  return fgetc(s->filep);
}

/* -----------------------------------------------------------------------------
 * int File_ungetc(DOH *obj, int ch)
 *
 * Put a character back onto the input
 * ----------------------------------------------------------------------------- */

int File_ungetc(DOH *obj, int ch) {
  File *s = (File *) obj;
  return ungetc(ch, s->filep);
}

    






