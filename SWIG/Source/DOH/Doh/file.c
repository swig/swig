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
int     File_seek(DOH *s, long offset, int whence);
long    File_tell(DOH *s);
int     File_printf(DOH *s, char *fmt, va_list ap);

static DohFileMethods FileFileMethods = {
  File_read,
  File_write,
  File_seek,
  File_tell,
  File_printf,
};

static DohObjInfo FileType = {
    "File",          /* objname */
    sizeof(File),    /* objsize */
    DelFile,         /* sm_del */
    0,               /* sm_copy */
    0,               /* sm_clear */
    0,               /* sm_str */
    0,               /* doh_data */
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
  return (size_t) fread(buffer,len,1,s->filep);
}

/* -----------------------------------------------------------------------------
 * int File_write(DOH *so, void *buffer, int len)
 * 
 * Write data to the File
 * ----------------------------------------------------------------------------- */
int
File_write(DOH *so, void *buffer, int len) {
  File *s = (File *) so;
  return (size_t) fwrite(buffer,len,1,s->filep);
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
 * int File_printf(DOH *so, char *format, ...)
 *
 * ----------------------------------------------------------------------------- */

int
File_printf(DOH *so, char *format, va_list ap) 
{
  int len, wlen;
  DOH    *nso;
  File *s = (File *) so;
  nso = NewString("");
  vAppendf(nso,format,ap);
  len = Len(nso);
  wlen = File_write(so,Data(nso),len);
  Delete(nso);
  return wlen;
}

    






