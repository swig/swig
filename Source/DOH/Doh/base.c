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

/*******************************************************************************
 * $Header$
 *
 * File : base.c
 *
 * Methods for base objects
 *******************************************************************************/

#include "doh.h"

static DohObjInfo DohBaseType = {
  "Base",     /* objname */
  0,          /* objsize */
  0,          /* doh_del */
  0,          /* doh_copy */
  0,          /* doh_clear */
  0,          /* doh_str */
  0,          /* doh_data */
  0,          /* doh_len */
  0,          /* doh_hash    */
  0,          /* doh_cmp */
  0,          /* doh_mapping */
  0,          /* doh_sequence */
  0,          /* doh_file  */
  0,          /* reserved2 */
  0,          /* reserved3 */
  0,          /* reserved4 */
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
};

/* Check if a Doh object */
int DohCheck(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!b) return 0;
  if (b->magic != DOH_MAGIC) return 0;
  if (!b->objinfo) return 0;
  return 1;
}

/* -----------------------------------------------------------------------------
   String objects

   The following structure maps raw char * entries to string objects.  
   ----------------------------------------------------------------------------- */

typedef struct StringNode {
    char   *cstr;
    DOH    *sstr;
    struct StringNode *left;
    struct StringNode *right;
} StringNode;

static StringNode *root = 0;

static DOH *find_internal(DOH *co) {
  StringNode *r, *s;
  int d;
  char *c;
  if (DohCheck(co)) return co;
  c = (char *) co;
  r = root;
  s = 0;
  while (r) {
    s = r;
    /*    printf("checking %s\n", r->cstr);*/
    d = strcmp(r->cstr,c);
    if (d == 0) return r->sstr;
    if (d < 0) r = r->left;
    else r = r->right;
  }
  r = (StringNode *) malloc(sizeof(StringNode));
  r->cstr = (char *) malloc(strlen(c)+1);
  strcpy(r->cstr,c);
  r->sstr = NewString(c);
  Incref(r->sstr);
  r->left = 0;
  r->right = 0;
  if (!s) { root = r; }
  else {
    if (d < 0) s->left = r;
    else s->right = r;
  }
  return r->sstr;
}

/* Destroy an object */
void DohDestroy(DOH *obj) {
    DohBase *b = (DohBase *) obj;
    if (!DohCheck(b)) return;
    b->refcount--;
    if (b->refcount <= 0) {
      if (b->objinfo->doh_del) {
	(b->objinfo->doh_del)(obj);
	return;
      } 
      free(b);
    }
}

/* Copy an object */
DOH *DohCopy(DOH *obj) {
    DOH  *result;
    DohBase *b = (DohBase *) obj;
    if (!DohCheck(b)) return 0;
    if (b->objinfo->doh_copy) {
      return (b->objinfo->doh_copy)(obj);
    }
    printf("No copy method defined for type '%s'\n", b->objinfo->objname);
    return 0;
}

void DohClear(DOH *obj) {
    DohBase *b = (DohBase *) obj;
    if (!DohCheck(b)) return;
    if (b->objinfo->doh_clear) {
      (b->objinfo->doh_clear)(obj);
      return;
    }
    printf("No clear method defined for type '%s'\n", b->objinfo->objname);
}

/* Turn an object into a string */
DOH *DohStr(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj; 
    if (DohCheck(b)) {
	if (b->objinfo->doh_str) {
	  return (b->objinfo->doh_str)(b);
	}
	s = NewString("<Object ");
	Appendf(s,"'%s' at %x>", b->objinfo->objname, b);
	return s;
    } else {
      return NewString(obj);
    }
}

/* Get the length */
int DohLen(DOH *obj) {
    int s;
    DohBase *b = (DohBase *) obj;
    if (DohCheck(b)) {
      if (b->objinfo->doh_len) {
	return (b->objinfo->doh_len)(obj);
      }
    }
    printf("No len method defined for type '%s'\n", b->objinfo->objname);
    return 0;
}

/* Get the hash value */
int DohHashval(DOH *obj) {
    int s;
    DohBase *b = (DohBase *) obj;
    if (DohCheck(b)) {
      if (b->objinfo->doh_hash) {
	return (b->objinfo->doh_hash)(obj);
      }
      printf("No hash method defined for type '%s'\n", b->objinfo->objname);
    }
    return 0;
}

/* Get raw data */
void *DohData(DOH *obj) {
    char *c;
    char *s;
    DohBase *b = (DohBase *) obj;
    c = (char *) obj;
    if (!c) return 0;
    if (*c == DOH_MAGIC) {
      if (b->objinfo) {
	if (b->objinfo->doh_data) {
	  return (b->objinfo->doh_data)(obj);
	}
      }
      printf("No data method defined for type '%s'\n", b->objinfo->objname);
      return 0;
    } 
    return c;
}

/* Get the line number */
int DohGetline(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    return b->line;
  }
  return 0;
}

/* Set the line number */
void DohSetline(DOH *obj, int line) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    b->line = line;
  }
}

/* Get the file name */
DOH *DohGetfile(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    return b->file;
  }
  return 0;
}

/* Set the file */
void DohSetfile(DOH *obj, DOH *file) {
  DOH *nf;
  DohBase *b = (DohBase *) obj;
  if (DohCheck(obj)) {
    if (file) {
      nf = find_internal(file);
      Incref(nf);
      if (b->file) Delete(b->file);
      b->file = nf;
    } else {
      Delete(b->file);
      b->file = 0;
    }
  }
}

/* Get an attribute from an object */
int DohCmp(DOH *obj1, DOH *obj2) {
    int s;
    DohBase *b1, *b2;
    b1 = (DohBase *) obj1;
    b2 = (DohBase *) obj2;
    if (!DohCheck(b1)) {
	b1 = find_internal(b1);
    }
    if (!DohCheck(b2)) {
	b2 = find_internal(b2);
    }
    if (b1->objinfo == b2->objinfo) {
	if (b1->objinfo->doh_cmp) {
	    return (b1->objinfo->doh_cmp)(b1,b2);
	}
	printf("No cmp method defined for type '%s'\n", b1->objinfo->objname);
    }
    printf("Can't compare type '%s' with type '%s'\n", b1->objinfo->objname, b2->objinfo->objname);
    return 0;
}

/* ----------------------------------------------------------------------
 * Mapping Interface 
 * ---------------------------------------------------------------------- */

int DohIsMapping(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_mapping) return 1;
  else return 0;
}

/* Get an attribute from an object */
DOH *DohGetattr(DOH *obj, DOH *name) {
  DOH  *s;
  DOH  *name_obj;
  DohBase *b = (DohBase *) obj;
  if (DohIsMapping(b)) {
    name_obj = find_internal(name);
    if (b->objinfo->doh_mapping->doh_getattr) {
      return (b->objinfo->doh_mapping->doh_getattr)(obj,name_obj);
    }
    return 0;
  }
  return 0;
}

/* Getattrf */
int DohGetattrf(DOH *obj, DOH *name, char *format, ...) {
  va_list ap;
  int ret = 0;
  DOH *item, *str;
  item = DohGetattr(obj,name);
  if (item) {
    str = DohStr(item);
    DohSeek(str,0,SEEK_SET);
    va_start(ap,format);
    ret = DohvScanf(str,format,ap);
    va_end(ap);
    Delete(str);
    return ret;
  } 
  return ret;
}


/* Set an attribute in an object */
int DohSetattr(DOH *obj, DOH *name, DOH *value) {
    int s;
    DOH *name_obj, *value_obj;
    DohBase *b = (DohBase *) obj;
    if (DohIsMapping(b)) {
      name_obj = find_internal(name);
      value_obj = find_internal(value);
      if (b->objinfo->doh_mapping->doh_setattr) {
	return (b->objinfo->doh_mapping->doh_setattr)(obj,name_obj,value_obj);
      }
      printf("No setattr method defined for type '%s'\n", b->objinfo->objname);
    }
    return 0;
}


/* Setattrf */
int DohSetattrf(DOH *obj, DOH *name, char *format, ...) {
  va_list ap;
  int ret = 0;
  DOH *str;
  str = NewString("");
  Incref(str);
  va_start(ap,format);
  ret = DohvPrintf(str,format,ap);
  va_end(ap);
  DohSetattr(obj,name,str);
  Delete(str);
  return ret;
}

/* Delete an attribute from an object */
void DohDelattr(DOH *obj, DOH *name) {
  DOH *name_obj;
  DohBase *b = (DohBase *) obj;
  if (DohIsMapping(obj)) {
    name_obj = find_internal(name);
    if (b->objinfo->doh_mapping->doh_delattr) {
      (b->objinfo->doh_mapping->doh_delattr)(obj,name_obj);
      return;
    }
    printf("No delattr method defined for type '%s'\n", b->objinfo->objname);
  }
}


/* Get first item in an object */
DOH *DohFirst(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_firstkey) {
	return DohGetattr(obj,(b->objinfo->doh_mapping->doh_firstkey)(obj));
      }
      printf("No firstkey method defined for type '%s'\n", b->objinfo->objname);
      return 0;
    }
    return 0;
}

/* Get next item in an object */
DOH *DohNext(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_nextkey) {
	return DohGetattr(obj,(b->objinfo->doh_mapping->doh_nextkey)(obj));
      }
      printf("No nextkey method defined for type '%s'\n", b->objinfo->objname);
      return 0;
    }
    return 0;
}


/* Get first item in an object */
DOH *DohFirstkey(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_firstkey) {
	return (b->objinfo->doh_mapping->doh_firstkey)(obj);
      }
      printf("No firstkey method defined for type '%s'\n", b->objinfo->objname);
      return 0;
    }
    return 0;
}

/* Get next item in an object */
DOH *DohNextkey(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_nextkey) {
	return (b->objinfo->doh_mapping->doh_nextkey)(obj);
      }
      printf("No nextkey method defined for type '%s'\n", b->objinfo->objname);
      return 0;
    }
    return 0;
}

/* ----------------------------------------------------------------------
 * Sequence Interface
 * ---------------------------------------------------------------------- */

int DohIsSequence(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_sequence) return 1;
  else return 0;
}

/* Get an item from an object */
DOH *DohGetitem(DOH *obj, int index) {
    DOH  *s;
    DohBase *b = (DohBase *) obj;
    if (DohIsSequence(obj)) {
      if (b->objinfo->doh_sequence->doh_getitem) {
	return (b->objinfo->doh_sequence->doh_getitem)(obj,index);
      }
      printf("No getitem method defined for type '%s'\n", b->objinfo->objname);
    }
    return 0;
}

/* Set an item in an object */
void DohSetitem(DOH *obj, int index, DOH *value) {
  DOH *value_obj;
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    value_obj = find_internal(value);
    if (b->objinfo->doh_sequence->doh_setitem) {
      (b->objinfo->doh_sequence->doh_setitem)(obj,index,value_obj);
      return;
    }
    printf("No setitem method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* Delete an item from an object */
void DohDelitem(DOH *obj, int index) {
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_delitem) {
      (b->objinfo->doh_sequence->doh_delitem)(obj,index);
      return;
    }
    printf("No delitem method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* Set an item in an object */
void DohInsertitem(DOH *obj, int index, DOH *value) {
  DOH *value_obj;
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    value_obj = find_internal(value);
    if (b->objinfo->doh_sequence->doh_insitem) {
      (b->objinfo->doh_sequence->doh_insitem)(obj,index,value_obj);
      return;
    }
    printf("No insitem method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* Set an item in an object */
void DohInsertitemf(DOH *obj, int index, char *format, ...) {
  va_list ap;
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_insertf) {
      va_start(ap,format);
      (b->objinfo->doh_sequence->doh_insertf)(obj,index,format,ap);
      va_end(ap);
      return;
    }
    printf("No insertf method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* Set an item in an object */
void DohvInsertitemf(DOH *obj, int index, char *format, va_list ap) {
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_insertf) {
      (b->objinfo->doh_sequence->doh_insertf)(obj,index,format,ap);
      return;
    }
    printf("No insertf method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* Append an item to an object */
void DohAppendf(DOH *obj, char *format, ...) {
  va_list ap;
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_insertf) {
      va_start(ap,format);
      (b->objinfo->doh_sequence->doh_insertf)(obj,DOH_END,format,ap);
      va_end(ap);
      return;
    }
    printf("No appendf method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* Append an item to an object */
void DohvAppendf(DOH *obj, char *format, va_list ap) {
  DohBase *b = (DohBase *) obj;
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_insertf) {
      (b->objinfo->doh_sequence->doh_insertf)(obj,DOH_END,format,ap);
      return;
    }
    printf("No appendf method defined for type '%s'\n", b->objinfo->objname);
  }
}

/* -----------------------------------------------------------------------------
 * File methods 
 * ----------------------------------------------------------------------------- */

int DohIsFile(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_file) return 1;
  else return 0;
}

/* Read */
int DohRead(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_read) {
      return (b->objinfo->doh_file->doh_read)(obj,buffer,length);
    }
    printf("No read method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* Write */
int DohWrite(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_write) {
      return (b->objinfo->doh_file->doh_write)(obj,buffer,length);
    }
    printf("No write method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* Seek */
int DohSeek(DOH *obj, long offset, int whence) {
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_seek) {
      return (b->objinfo->doh_file->doh_seek)(obj,offset,whence);
    }
    printf("No seek method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* Tell */
long DohTell(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_tell) {
      return (b->objinfo->doh_file->doh_tell)(obj);
    }
    printf("No tell method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* Printf */
int DohPrintf(DOH *obj, char *format, ...) {
  va_list ap;
  int ret;
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_printf) {
      va_start(ap,format);
      ret = (b->objinfo->doh_file->doh_printf)(obj,format,ap);
      va_end(ap);
      return ret;
    }
    printf("No printf method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* vPrintf */
int DohvPrintf(DOH *obj, char *format, va_list ap) {
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_printf) {
      return (b->objinfo->doh_file->doh_printf)(obj,format,ap);
    }
    printf("No printf method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* Printf */
int DohScanf(DOH *obj, char *format, ...) {
  va_list ap;
  int ret;
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_scanf) {
      va_start(ap,format);
      ret = (b->objinfo->doh_file->doh_scanf)(obj,format,ap);
      va_end(ap);
      return ret;
    }
    printf("No scanf method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

/* vPrintf */
int DohvScanf(DOH *obj, char *format, va_list ap) {
  DohBase *b = (DohBase *) obj;
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_scanf) {
      return (b->objinfo->doh_file->doh_scanf)(obj,format,ap);
    }
    printf("No scanf method defined for type '%s'\n", b->objinfo->objname);
  }
  return -1;
}

void DohInit(DOH *b) {
    DohBase *bs = (DohBase *) b;
    bs->refcount =0;
    bs->objinfo = &DohBaseType;
    bs->magic = DOH_MAGIC;
    bs->moremagic[0] = 0;
    bs->moremagic[1] = 0;
    bs->moremagic[2] = 0;
    bs->line = 0;
    bs->file = 0;
}
