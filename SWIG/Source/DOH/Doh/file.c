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

typedef struct {
  FILE     *filep;       
  int       closeondel;
} DohFile;

/* -----------------------------------------------------------------------------
 * DelFile()
 * ----------------------------------------------------------------------------- */

static void
DelFile(DOH *fo) {
  DohFile *f = (DohFile *) ObjData(fo);
  if (f->closeondel)
    fclose(f->filep);
}

/* -----------------------------------------------------------------------------
 * File_read()
 * ----------------------------------------------------------------------------- */

static int
File_read(DOH *fo, void *buffer, int len) {
  DohFile *f = (DohFile *) ObjData(fo);
  return fread(buffer,1,len,f->filep);
}

/* -----------------------------------------------------------------------------
 * File_write()
 * ----------------------------------------------------------------------------- */

static int
File_write(DOH *fo, void *buffer, int len) {
  DohFile *f = (DohFile *) ObjData(fo);
  return fwrite(buffer,1,len,f->filep);
}

/* -----------------------------------------------------------------------------
 * File_seek()
 * ----------------------------------------------------------------------------- */

static int
File_seek(DOH *fo, long offset, int whence) {
  DohFile *f = (DohFile *) ObjData(fo);
  return fseek(f->filep,offset,whence);
}

/* -----------------------------------------------------------------------------
 * File_tell()
 * ----------------------------------------------------------------------------- */

static long
File_tell(DOH *fo) {
  DohFile *f = (DohFile *) ObjData(fo);
  return ftell(f->filep);
}

/* -----------------------------------------------------------------------------
 * File_putc()
 * ----------------------------------------------------------------------------- */

static int 
File_putc(DOH *fo, int ch) {
  DohFile *f = (DohFile *) ObjData(fo);
  return fputc(ch,f->filep);
}

/* -----------------------------------------------------------------------------
 * File_getc()
 * ----------------------------------------------------------------------------- */

static int 
File_getc(DOH *fo) {
  DohFile *f = (DohFile *) ObjData(fo);
  return fgetc(f->filep);
}

/* -----------------------------------------------------------------------------
 * File_ungetc()
 *
 * Put a character back onto the input
 * ----------------------------------------------------------------------------- */

static int 
File_ungetc(DOH *fo, int ch) {
  DohFile *f = (DohFile *) ObjData(fo);
  return ungetc(ch, f->filep);
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
    DelFile,         /* doh_del      */
    0,               /* doh_copy     */
    0,               /* doh_clear    */
    0,               /* doh_str      */
    0,               /* doh_data     */
    0,               /* doh_dump     */
    0,               /* doh_len      */
    0,               /* doh_hash     */
    0,               /* doh_cmp      */
    0,               /* doh_setfile  */
    0,               /* doh_getfile  */
    0,               /* doh_setline  */
    0,               /* doh_getline  */
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
  static int init = 0;

  if (!init) {
    DohRegisterType(DOHTYPE_FILE, &DohFileType);
    init = 1;
  }

  filename = Char(fn);
  file = fopen(filename,mode);
  if (!file) return 0;

  f = (DohFile *) DohMalloc(sizeof(DohFile));
  if (!f) {
    fclose(file);
    return 0;
  }
  f->filep = file;
  f->closeondel = 1;
  return DohObjMalloc(DOHTYPE_FILE,f);
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
  static int init = 0;
  if (!init) {
    DohRegisterType(DOHTYPE_FILE, &DohFileType);
    init = 1;
  }
  f = (DohFile *) DohMalloc(sizeof(DohFile));
  if (!f) return 0;
  f->filep = file;
  f->closeondel = 0;
  return DohObjMalloc(DOHTYPE_FILE,f);
}
