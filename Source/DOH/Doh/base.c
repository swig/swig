/* -----------------------------------------------------------------------------
 * base.c 
 *
 *     This file contains the function entry points for dispatching methods on
 *     DOH objects.  A number of small utility functions are also included.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "dohint.h"

static DohObjInfo DohBaseType = {
  "Base",           /* objname */
  sizeof(DohBase),  /* objsize */
  0,                /* doh_del */
  0,                /* doh_copy */
  0,                /* doh_clear */
  0,                /* doh_str */
  0,                /* doh_data */
  0,                /* doh_dump */
  0,                /* doh_load */
  0,                /* doh_len     */
  0,                /* doh_hash    */
  0,                /* doh_cmp     */
  0,                /* doh_mapping */
  0,                /* doh_list    */
  0,                /* doh_file    */
  0,                /* doh_string  */
  0,                /* reserved1   */
  0,                /* reserved2   */
};

/* -----------------------------------------------------------------------------
 * DohDelete()
 * ----------------------------------------------------------------------------- */

void
DohDelete(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return;
  if (b->flags & DOH_FLAG_INTERN) return;
  b->refcount--;
  if (b->refcount <= 0) {
    if (b->objinfo->doh_del) (b->objinfo->doh_del)(obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohIntern()
 * ----------------------------------------------------------------------------- */

void
DohIntern(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  b->flags = b->flags | DOH_FLAG_INTERN;
}

/* -----------------------------------------------------------------------------
 * DohCopy()
 * ----------------------------------------------------------------------------- */

DOH *
DohCopy(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_copy)
    return (b->objinfo->doh_copy)(b);
}

/* -----------------------------------------------------------------------------
 * DohClear()
 * ----------------------------------------------------------------------------- */

void
DohClear(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_clear)
    (b->objinfo->doh_clear)(obj);
}

/* -----------------------------------------------------------------------------
 * DohStr()
 * ----------------------------------------------------------------------------- */

DOH *
DohStr(const DOH *obj) {
  char buffer[512];
  DohBase *b = (DohBase *) obj;
  if (DohCheck(b)) {
    if (b->objinfo->doh_str) {
      return (b->objinfo->doh_str)(b);
    }
    sprintf(buffer,"<Object '%s' at %x>", b->objinfo->objname, b);
    return NewString(buffer);
  } else {
    return NewString(obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohDump()
 * ----------------------------------------------------------------------------- */

int
DohDump(const DOH *obj, DOH *out) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_dump) {
    return (b->objinfo->doh_dump)(b,out);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohLen()
 * ----------------------------------------------------------------------------- */
int
DohLen(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!b) return 0;
  if (DohCheck(b)) {
    if (b->objinfo->doh_len) {
      return (b->objinfo->doh_len)(b);
    }
    return 0;
  } else {
    return strlen((char *) obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohHashVal()
 * ----------------------------------------------------------------------------- */

int
DohHashval(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(b)) {
    if (b->objinfo->doh_hash) {
      return (b->objinfo->doh_hashval)(b);
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohData()
 * ----------------------------------------------------------------------------- */

void *
DohData(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if (b->objinfo) {
      if (b->objinfo->doh_data) {
	return (b->objinfo->doh_data)(b);
      }
    }
    return 0;
  }
  return (void *) obj;
}

/* -----------------------------------------------------------------------------
 * DohCmp()
 * ----------------------------------------------------------------------------- */

int
DohCmp(const DOH *obj1, const DOH *obj2) {
  DohBase *b1, *b2;
  b1 = (DohBase *) obj1;
  b2 = (DohBase *) obj2;
  if ((!DohCheck(b1)) || (!DohCheck(b2))) {
    return strcmp((char *) DohData(b1),(char *) DohData(b2));
  }
  if (b1->objinfo->doh_cmp) {
    return (b1->objinfo->doh_cmp)(b1,b2);
  }
  return 1;
}

/* -----------------------------------------------------------------------------
 * DohIsMapping()
 * ----------------------------------------------------------------------------- */

int
DohIsMapping(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_hash) return 1;
  else return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetattr()
 * ----------------------------------------------------------------------------- */

DOH *
DohGetattr(DOH *obj, const DOH *name) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_hash->doh_getattr) {
    return (b->objinfo->doh_hash->doh_getattr)(b,(DOH *) name);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohSetattr()
 * ----------------------------------------------------------------------------- */

int
DohSetattr(DOH *obj, const DOH *name, const DOH *value) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_hash->doh_setattr) {
    return (b->objinfo->doh_hash->doh_setattr)(b,(DOH *) name,(DOH *) value);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohDelattr()
 * ----------------------------------------------------------------------------- */

void
DohDelattr(DOH *obj, const DOH *name) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_hash->doh_delattr) {
    (b->objinfo->doh_hash->doh_delattr)(b,(DOH *) name);
  }
}

/* -----------------------------------------------------------------------------
 * DohFirstkey()
 * ----------------------------------------------------------------------------- */

DOH *
DohFirstkey(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_hash->doh_firstkey) {
    return (b->objinfo->doh_hash->doh_firstkey)(obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohNextkey()
 * ----------------------------------------------------------------------------- */

DOH *
DohNextkey(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_hash->doh_nextkey) {
    return (b->objinfo->doh_hash->doh_nextkey)(obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetInt()
 * ----------------------------------------------------------------------------- */

int
DohGetInt(DOH *obj, const DOH *name) {
  DOH *val;
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  if (DohIsString(val)) {
    return atoi((char *) Data(val));
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetDouble()
 * ----------------------------------------------------------------------------- */

double
DohGetDouble(DOH *obj, const DOH *name) {
  DOH *val;
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  if (DohIsString(val)) {
    return atof((char *) Data(val));
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetChar()
 * ----------------------------------------------------------------------------- */

char *
DohGetChar(DOH *obj, const DOH *name) {
  DOH *val;
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  if (DohIsString(val)) {
    return (char *) Data(val);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetVoid()
 * ----------------------------------------------------------------------------- */

void *
DohGetVoid(DOH *obj, const DOH *name) {
  DOH *val;
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  return (void *) Data(val);
}

/* -----------------------------------------------------------------------------
 * DohSetInt()
 * ----------------------------------------------------------------------------- */

void
DohSetInt(DOH *obj, const DOH *name, int value) {
  DOH *temp;
  temp = NewString("");
  Printf(temp,"%d",value);
  Setattr(obj,(DOH *) name,temp);
}

/* -----------------------------------------------------------------------------
 * DohSetDouble()
 * ----------------------------------------------------------------------------- */

void
DohSetDouble(DOH *obj, const DOH *name, double value) {
  DOH *temp;
  temp = NewString("");
  Printf(temp,"%0.17f",value);
  Setattr(obj,(DOH *) name,temp);
}

/* -----------------------------------------------------------------------------
 * DohSetChar()
 * ----------------------------------------------------------------------------- */

void
DohSetChar(DOH *obj, const DOH *name, char *value) {
  DOH *temp;
  temp = NewString(value);
  Setattr(obj,(DOH *) name,temp);
}

/* -----------------------------------------------------------------------------
 * DohSetVoid()
 * ----------------------------------------------------------------------------- */

void
DohSetVoid(DOH *obj, const DOH *name, void *value) {
  DOH *temp;
  temp = NewVoid(value,0);
  Setattr(obj,(DOH *) name,temp);
}

/* -----------------------------------------------------------------------------
 * DohIsSequence()
 * ----------------------------------------------------------------------------- */

int
DohIsSequence(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_list) return 1;
  else return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetitem()
 * ----------------------------------------------------------------------------- */

DOH *
DohGetitem(DOH *obj, int index) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_list->doh_getitem) {
    return (b->objinfo->doh_list->doh_getitem)(obj,index);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohSetitem()
 * ----------------------------------------------------------------------------- */

int
DohSetitem(DOH *obj, int index, const DOH *value) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_list->doh_setitem) {
    return (b->objinfo->doh_list->doh_setitem)(obj,index,(DOH *) value);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohDelitem()
 * ----------------------------------------------------------------------------- */

int
DohDelitem(DOH *obj, int index) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_list->doh_delitem) {
    return (b->objinfo->doh_list->doh_delitem)(obj,index);
  }
}

/* -----------------------------------------------------------------------------
 * DohInsertitem()
 * ----------------------------------------------------------------------------- */

int
DohInsertitem(DOH *obj, int index, const DOH *value) {
  int  no = 0;
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_list->doh_insitem) {
    return (b->objinfo->doh_list->doh_insitem)(obj,index,(DOH *) value);
  }
}

/* -----------------------------------------------------------------------------
 * DohFirstitem()
 * ----------------------------------------------------------------------------- */

DOH *
DohFirstitem(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_list->doh_firstitem) {
    return (b->objinfo->doh_list->doh_firstitem)(obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohNextitem()
 * ----------------------------------------------------------------------------- */

DOH *
DohNextitem(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (b->objinfo->doh_list->doh_nextitem) {
    return (b->objinfo->doh_list->doh_nextitem)(obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohIsFile()
 * ----------------------------------------------------------------------------- */

int
DohIsFile(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_file) return 1;
  else return 0;
}

/* -----------------------------------------------------------------------------
 * DohRead()
 * ----------------------------------------------------------------------------- */

int
DohRead(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if ((b->objinfo->doh_file) && (b->objinfo->doh_file->doh_read)) {
      return (b->objinfo->doh_file->doh_read)(obj,buffer,length);
    }
    return -1;
  }
  /* Hmmm.  Not a file.  Maybe it's a real FILE */
  return fread(buffer,1,length,(FILE *) b);
}

/* -----------------------------------------------------------------------------
 * DohWrite()
 * ----------------------------------------------------------------------------- */

int
DohWrite(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if ((b->objinfo->doh_file) && (b->objinfo->doh_file->doh_write)) {
      return (b->objinfo->doh_file->doh_write)(obj,buffer,length);
    }
    return -1;
  }
  /* Hmmm.  Not a file.  Maybe it's a real FILE */
  return fwrite(buffer,1,length,(FILE *) b);
}

/* -----------------------------------------------------------------------------
 * DohSeek()
 * ----------------------------------------------------------------------------- */

int
DohSeek(DOH *obj, long offset, int whence) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if ((b->objinfo->doh_file) && (b->objinfo->doh_file->doh_seek)) {
      return (b->objinfo->doh_file->doh_seek)(obj,offset,whence);
    }
    return -1;
  }
  return fseek((FILE *) b, offset, whence);
}

/* -----------------------------------------------------------------------------
 * DohTell()
 * ----------------------------------------------------------------------------- */

long
DohTell(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if ((b->objinfo->doh_file) && (b->objinfo->doh_file->doh_tell)) {
      return (b->objinfo->doh_file->doh_tell)(obj);
    }
    return -1;
  }
  return ftell((FILE *) b);
}

/* -----------------------------------------------------------------------------
 * DohGetc()
 * ----------------------------------------------------------------------------- */

int
DohGetc(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if (b->objinfo->doh_file->doh_getc) {
      return (b->objinfo->doh_file->doh_getc)(obj);
    }
    return EOF;
  }
  return fgetc((FILE *) b);
}

/* -----------------------------------------------------------------------------
 * DohPutc()
 * ----------------------------------------------------------------------------- */

int
DohPutc(int ch, DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if (b->objinfo->doh_file->doh_putc) {
      return (b->objinfo->doh_file->doh_putc)(obj,ch);
    }
    return EOF;
  }
  return fputc(ch,(FILE *) b);
}

/* -----------------------------------------------------------------------------
 * DohUngetc()
 * ----------------------------------------------------------------------------- */

int
DohUngetc(int ch, DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if (b->objinfo->doh_file->doh_ungetc) {
      return (b->objinfo->doh_file->doh_ungetc)(obj,ch);
    }
    return EOF;
  }
  return ungetc(ch,(FILE *) b);
}

/* -----------------------------------------------------------------------------
 * DohClose()
 * ----------------------------------------------------------------------------- */

int
DohClose(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if (b->objinfo->doh_file->doh_close) {
      return (b->objinfo->doh_file->doh_close)(obj);
    }
    return 0;
  }
  return fclose((FILE *) obj);
}

/* -----------------------------------------------------------------------------
 * DohIsString()
 * ----------------------------------------------------------------------------- */

int
DohIsString(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_string) return 1;
  else return 0;
}

/* -----------------------------------------------------------------------------
 * DohReplace()
 * ----------------------------------------------------------------------------- */

int
DohReplace(DOH *src, const DOH *token, const DOH *rep, int flags) {
  DohBase *b = (DohBase *) src;
  if (DohIsString(src)) {
    if (b->objinfo->doh_string->doh_replace) {
      return (b->objinfo->doh_string->doh_replace)(src,(DOH *) token, (DOH *) rep,flags);
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohChop()
 * ----------------------------------------------------------------------------- */

void
DohChop(DOH *src) {
  DohBase *b = (DohBase *) src;
  if (DohIsString(src)) {
    if (b->objinfo->doh_string->doh_chop) {
      (b->objinfo->doh_string->doh_chop)(src);
    }
  }
}

/* -----------------------------------------------------------------------------
 * DohInit()
 * ----------------------------------------------------------------------------- */

void
DohInit(DOH *b) {
  DohBase *bs = (DohBase *) b;
  bs->refcount = 1;
  bs->objinfo = &DohBaseType;
  bs->flags = 0;
  bs->file = 0;
  bs->line = 0;
}

/* -----------------------------------------------------------------------------
 * DohSetFile()
 * ----------------------------------------------------------------------------- */
void
DohSetfile(DOH *ho, DOH *file) {
  DohBase *h = (DohBase *) ho;
  if (!h) return;
  if (!DohCheck(file)) file = NewString(file);
  h->file = file;
  Incref(h->file);
}

/* -----------------------------------------------------------------------------
 * DohGetFile()
 * ----------------------------------------------------------------------------- */
DOH *
DohGetfile(DOH *ho) {
  if (!ho) return 0;
  return ((DohBase *)ho)->file;
}

/* -----------------------------------------------------------------------------
 * DohSetLine()
 * ----------------------------------------------------------------------------- */
void
DohSetline(DOH *ho, int l) {
  if (!ho) return;
  ((DohBase *) ho)->line = l;
}

/* -----------------------------------------------------------------------------
 * DohGetLine()
 * ----------------------------------------------------------------------------- */
int
DohGetline(DOH *ho) {
  if (!ho) return 0;
  return ((DohBase *)ho)->line;
}




