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
 * Please read the file LICENSE for the copyright and terms by which DOH
 * can be used and distributed.
 ****************************************************************************/

/*******************************************************************************
 * $Header$
 *
 * File : base.c
 *
 * Methods for base objects
 *******************************************************************************/

#include "dohint.h"

int    doh_debug_level = 0;

void DohError(int level, char *fmt, ...) {
  va_list ap;
  va_start(ap,fmt);
  if (level <= doh_debug_level) {
    printf("DOH %d:",level);
    vprintf(fmt,ap);
  }
  va_end(ap);
}

void DohDebug(int d) {
  doh_debug_level = d;
}

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
  0,                /* doh_len */
  0,                /* doh_hash    */
  0,                /* doh_cmp */
  0,                /* doh_mapping */
  0,                /* doh_sequence */
  0,                /* doh_file  */
  0,                /* doh_string */
  0,                /* doh_callable */
  0,                /* reserved4 */
  0,                /* reserved5 */
  0,                /* reserved6 */
  0,                /* user1 */
  0,                /* user2 */
  0,                /* user3 */
  0,                /* user4 */
};

/* -----------------------------------------------------------------------------
   String interning.    This is used for getattr,setattr functions.

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
  if (doh_debug_level) {
    DohError(DOH_CONVERSION,"Unknown object '%s' being treated as 'char *'.\n", c);
  }
  r = root;
  s = 0;
  while (r) {
    s = r;
    /*    printf("checking %s\n", r->cstr); */
    d = strcmp(r->cstr,c);
    if (d == 0) return r->sstr;
    if (d < 0) r = r->left;
    else r = r->right;
  }
  r = (StringNode *) DohMalloc(sizeof(StringNode));
  r->cstr = (char *) DohMalloc(strlen(c)+1);
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
    DohError(DOH_CALLS,"DohDestroy %x\n",obj);
    if (!DohCheck(b)) return;
    b->refcount--;
    if (b->refcount <= 0) {
      if (doh_debug_level >= DOH_MEMORY) {
	if (DohObjFreeCheck(obj)) {
	  DohError(DOH_MEMORY,"DohDestroy. %x was already released! (ignoring for now)\n", obj);
	  return;
	}
      }
      if (b->objinfo->doh_del) {
	(b->objinfo->doh_del)(obj);
	return;
      } else {
	/*	free(b); */
      }
    }
}

/* Copy an object */
DOH *DohCopy(DOH *obj) {
    DOH  *result;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohCopy %x\n",obj);
    if (!DohCheck(b)) {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to Copy.\n", obj);
      return 0;
    }
    if (b->objinfo->doh_copy) {
      return (b->objinfo->doh_copy)(obj);
    }
    DohError(DOH_UNSUPPORTED,"No copy method defined for type '%s'\n", b->objinfo->objname);
    return 0;
}

void DohClear(DOH *obj) {
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohClear %x\n",obj);
    if (!DohCheck(b)) {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to Clear.\n",obj);
      return;
    }
    if (b->objinfo->doh_clear) {
      (b->objinfo->doh_clear)(obj);
      return;
    }
    DohError(DOH_UNSUPPORTED, "No clear method defined for type '%s'\n", b->objinfo->objname);
}

/* Turn an object into a string */
DOH *DohStr(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj; 
    DohError(DOH_CALLS,"DohStr %x\n",obj);
    if (DohCheck(b)) {
	if (b->objinfo->doh_str) {
	  return (b->objinfo->doh_str)(b);
	}
	s = NewString("<Object ");
	Printf(s,"'%s' at %x>", b->objinfo->objname, b);
	return s;
    } else {
      DohError(DOH_CONVERSION, "Creating new string from unknown object %x (assuming char *).\n", obj);
      return NewString(obj);
    }
}

/* Serialize an object */
int DohDump(DOH *obj, DOH *out) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohDump %x, %x\n",obj,out);
  if (DohCheck(obj)) {
    if (b->objinfo->doh_dump) {
      return (b->objinfo->doh_dump)(b,out);
    }
    DohError(DOH_UNSUPPORTED,"No dump method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN, "Unknown object %x passed to Dump.\n",obj);
  }
  return 0;
}

/* Get the length */
int DohLen(DOH *obj) {
    int s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohLen %x\n",obj);
    if (!b) return 0;
    if (DohCheck(b)) {
      if (b->objinfo->doh_len) {
	return (b->objinfo->doh_len)(obj);
      }
      DohError(DOH_UNSUPPORTED, "No len method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_CONVERSION, "Using strlen() on unknown object %x.\n", obj);
      return strlen((char *) obj);
    }
    return 0;
}

/* Get the hash value */
int DohHashval(DOH *obj) {
    int s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohHashval %x\n",obj);
    if (DohCheck(b)) {
      if (b->objinfo->doh_hash) {
	return (b->objinfo->doh_hash)(obj);
      }
      DohError(DOH_UNSUPPORTED,"No hash method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to Hashval.\n", obj);
    }
    return 0;
}

/* Get raw data */
void *DohData(DOH *obj) {
    char *c;
    char *s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohData %x\n",obj);
    c = (char *) obj;
    if (DohCheck(c)) {
      if (b->objinfo) {
	if (b->objinfo->doh_data) {
	  return (b->objinfo->doh_data)(obj);
	}
      }
      DohError(DOH_UNSUPPORTED,"No data method defined for type '%s'\n", b->objinfo->objname);
      return 0;
    } else {
      DohError(DOH_CONVERSION, "Unknown object %x passed to Data being returned as-is.\n", obj);
    }
    return c;
}

/* Get the line number */
int DohGetline(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohGetline %x\n",obj);
  if (DohCheck(obj)) {
    return b->line;
  } else {
    DohError(DOH_UNKNOWN, "Unknown object %x passed to Getline.\n", obj);
  }
  return 0;
}

/* Set the line number */
void DohSetline(DOH *obj, int line) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohSetline %x, %d\n",obj, line);
  if (DohCheck(obj)) {
    b->line = line;
  } else {
    DohError(DOH_UNKNOWN, "Unknown object %x passed to Setline.\n", obj);
  }
}

/* Get the file name */
DOH *DohGetfile(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohGetfile %x\n",obj);
  if (DohCheck(obj)) {
    return b->file;
  } else {
    DohError(DOH_UNKNOWN, "Unknown object %x passed to Getfile.\n", obj);
  }
  return 0;
}

/* Set the file */
void DohSetfile(DOH *obj, DOH *file) {
  DOH *nf;
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohSetfile %x, %x\n",obj,file);
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
  } else {
    DohError(DOH_UNKNOWN, "Unknown object %x passed to Setfile.\n", obj);
  }
}

/* Get an attribute from an object */
int DohCmp(DOH *obj1, DOH *obj2) {
    int s;
    DohBase *b1, *b2;
    DohError(DOH_CALLS,"DohCmp %x, %x\n",obj1,obj2);
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
      DohError(DOH_UNSUPPORTED,"No cmp method defined for type '%s'\n", b1->objinfo->objname);
      return 1;
    }
    DohError(DOH_UNSUPPORTED,"Can't compare type '%s' with type '%s'\n", b1->objinfo->objname, b2->objinfo->objname);
    return 1;
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
  DohError(DOH_CALLS,"DohGetattr %x, %x\n",obj,name);
  if (!name) return 0;
  if (DohIsMapping(b)) {
    name_obj = find_internal(name);
    if (b->objinfo->doh_mapping->doh_getattr) {
      return (b->objinfo->doh_mapping->doh_getattr)(obj,name_obj);
    }
  }
  if (DohCheck(b)) {
    DohError(DOH_UNSUPPORTED,"No getattr method defined for type '%s'\n", b->objinfo->objname); 
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to Getattr.\n", obj);
  }
  return 0;
}

/* Set an attribute in an object */
int DohSetattr(DOH *obj, DOH *name, DOH *value) {
    int s;
    DOH *name_obj, *value_obj;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohSetattr %x, %x, %x\n",obj,name, value);
    if ((!name) || (!value)) return 0;
    if (DohIsMapping(b)) {
      name_obj = find_internal(name);
      if (!DohCheck(value)) {
	DohError(DOH_CONVERSION,"Unknown object %x converted to a string in Setattr.\n",value);
	value_obj = NewString(value);
      } else {
	value_obj = value;
      }
      if (b->objinfo->doh_mapping->doh_setattr) {
	return (b->objinfo->doh_mapping->doh_setattr)(obj,name_obj,value_obj);
      }
    }
    if (DohCheck(b)) {
      DohError(DOH_UNSUPPORTED, "No setattr method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to Setattr\n", obj);
    }
    return 0;
}

/* Delete an attribute from an object */
void DohDelattr(DOH *obj, DOH *name) {
  DOH *name_obj;
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohDelattr %x, %x\n",obj,name);
  if (!name) return;
  if (DohIsMapping(obj)) {
    name_obj = find_internal(name);
    if (b->objinfo->doh_mapping->doh_delattr) {
      (b->objinfo->doh_mapping->doh_delattr)(obj,name_obj);
      return;
    }
  }
  if (DohCheck(obj)) {
    DohError(DOH_UNSUPPORTED, "No delattr method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to Delattr\n",obj);
  }
}


/* Get first item in an object */
DOH *DohFirst(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohFirst %x\n",obj);
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_firstkey) {
	return DohGetattr(obj,(b->objinfo->doh_mapping->doh_firstkey)(obj));
      }
    } 
    if (DohCheck(obj)) {
      DohError(DOH_UNSUPPORTED,"No firstkey method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to DohFirst\n",obj);
    }
    return 0;
}

/* Get next item in an object */
DOH *DohNext(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohNext %x\n",obj);
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_nextkey) {
	return DohGetattr(obj,(b->objinfo->doh_mapping->doh_nextkey)(obj));
      }
    }
    if (DohCheck(obj)) {
      DohError(DOH_UNSUPPORTED,"No nextkey method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to DohNext\n",obj);
    }
    return 0;
}


/* Get first item in an object */
DOH *DohFirstkey(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohFirstkey %x\n",obj);
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_firstkey) {
	return (b->objinfo->doh_mapping->doh_firstkey)(obj);
      }
    }
    if (DohCheck(obj)) {
      DohError(DOH_UNSUPPORTED,"No firstkey method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to DohFirstkey\n",obj);
    }
    return 0;
}

/* Get next item in an object */
DOH *DohNextkey(DOH *obj) {
    DOH *s;
    DohBase *b = (DohBase *) obj;
    DohError(DOH_CALLS,"DohNextkey %x\n",obj);
    if (DohIsMapping(obj)) {
      if (b->objinfo->doh_mapping->doh_nextkey) {
	return (b->objinfo->doh_mapping->doh_nextkey)(obj);
      }
    }
    if (DohCheck(obj)) {
      DohError(DOH_UNSUPPORTED,"No nextkey method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to DohNextkey\n",obj);
    }
    return 0;
}

int DohGetInt(DOH *obj, DOH *name) {
  int ival;
  DOH *val;
  DohError(DOH_CALLS,"DohGetInt %x, %x\n",obj,name);  
  val = Getattr(obj,name);
  if (!val) return 0;
  if (String_check(val)) {
    return atoi(Data(val));
  } 
  return 0;
}

double DohGetDouble(DOH *obj, DOH *name) {
  double dval;
  DOH *val;
  DohError(DOH_CALLS,"DohGetDouble %x, %x\n",obj,name);  
  val = Getattr(obj,name);
  if (!val) return 0;
  if (String_check(val)) {
    return atof(Data(val));
  } 
  return 0;
}

char *DohGetChar(DOH *obj, DOH *name) {
  double dval;
  DOH *val;
  DohError(DOH_CALLS,"DohGetChar %x, %x\n",obj,name);  
  val = Getattr(obj,name);
  if (!val) return 0;
  if (String_check(val)) {
    return (char *) Data(val);
  } 
  return 0;
}

void DohSetInt(DOH *obj, DOH *name, int value) {
  DOH *temp;
  DohError(DOH_CALLS,"DohSetInt %x, %x, %d\n", obj, name, value);
  temp = NewString("");
  Printf(temp,"%d",value);
  Setattr(obj,name,temp);
}

void DohSetDouble(DOH *obj, DOH *name, double value) {
  DOH *temp;
  DohError(DOH_CALLS,"DohSetInt %x, %x, %g\n", obj, name, value);
  temp = NewString("");
  Printf(temp,"%g",value);
  Setattr(obj,name,temp);
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
    DohError(DOH_CALLS,"DohGetitem %x, %d\n",obj,index);  
    if (DohIsSequence(obj)) {
      if (b->objinfo->doh_sequence->doh_getitem) {
	return (b->objinfo->doh_sequence->doh_getitem)(obj,index);
      }
    }
    if (DohCheck(obj)) {
      DohError(DOH_UNSUPPORTED,"No getitem method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohError(DOH_UNKNOWN,"Unknown object %x passed to DohGetitem\n",obj);
    }
    return 0;
}

/* Set an item in an object */
void DohSetitem(DOH *obj, int index, DOH *value) {
  DOH *value_obj;
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohSetitem %x, %d, %x\n",obj,index, value);  
  if (DohIsSequence(obj)) {
    if (!DohCheck(value)) {
      DohError(DOH_CONVERSION,"Unknown object %x being converted to a string in Setitem.\n", value);
      value_obj = NewString(value);
    } else {
      value_obj = value;
    }
    if (b->objinfo->doh_sequence->doh_setitem) {
      (b->objinfo->doh_sequence->doh_setitem)(obj,index,value_obj);
      return;
    }
  }
  if (DohCheck(obj)) {
    DohError(DOH_UNSUPPORTED,"No setitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to DohSetitem\n",obj);
  }
}

/* Delete an item from an object */
void DohDelitem(DOH *obj, int index) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohDelitem %x, %d\n",obj,index);
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_delitem) {
      (b->objinfo->doh_sequence->doh_delitem)(obj,index);
      return;
    }
  }
  if (DohCheck(obj)) {
    DohError(DOH_UNSUPPORTED,"No delitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to DohDelitem\n",obj);
  }
}

/* Set an item in an object */
void DohInsertitem(DOH *obj, int index, DOH *value) {
  DOH *value_obj;
  int  no = 0;
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohInsertitem %x, %d, %x\n",obj,index, value);
  if (DohIsSequence(obj)) {
    if (!DohCheck(value)) {
      DohError(DOH_CONVERSION,"Unknown object %x being converted to a string in Insertitem.\n", value);
      value_obj = NewString(value);
      no = 1;
      Incref(value_obj);
    } else {
      value_obj = value;
    }
    if (b->objinfo->doh_sequence->doh_insitem) {
      (b->objinfo->doh_sequence->doh_insitem)(obj,index,value_obj);
    }
    if (no) {
      Delete(value_obj);
    }
    return;
  }
  if (DohCheck(obj)) {
    DohError(DOH_UNSUPPORTED,"No insitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to DohInsertitem\n",obj);
  }
}

/* Delete an item from an object */
DOH *DohFirstitem(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohFirstitem %x\n");
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_firstitem) {
      return (b->objinfo->doh_sequence->doh_firstitem)(obj);
    }
  }
  if (DohCheck(obj)) {
    DohError(DOH_UNSUPPORTED,"No firstitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to DohFirstitem\n",obj);
  }
  return 0;
}

/* Delete an item from an object */
DOH *DohNextitem(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohNextitem %x\n");
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_nextitem) {
      return (b->objinfo->doh_sequence->doh_nextitem)(obj);
    }
  }
  if (DohCheck(obj)) {
    DohError(DOH_UNSUPPORTED,"No nextitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohError(DOH_UNKNOWN,"Unknown object %x passed to DohNextitem\n",obj);
  }
  return 0;
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
  DohError(DOH_CALLS,"DohRead %x, %x, %d\n",obj,buffer,length);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_read) {
      return (b->objinfo->doh_file->doh_read)(obj,buffer,length);
    }
  } else if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohRead\n",b);
    return fread(buffer,1,length,(FILE *) b);
  }
  DohError(DOH_UNSUPPORTED,"No read method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* Write */
int DohWrite(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohWrite %x, %x, %d\n",obj,buffer,length);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_write) {
      return (b->objinfo->doh_file->doh_write)(obj,buffer,length);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohWrite\n",b);
    return fwrite(buffer,1,length,(FILE *) b);
  }
  DohError(DOH_UNSUPPORTED,"No write method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* Seek */
int DohSeek(DOH *obj, long offset, int whence) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohSeek %x, %d, %d\n",obj,offset,whence);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_seek) {
      return (b->objinfo->doh_file->doh_seek)(obj,offset,whence);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohSeek\n",b);
    return fseek((FILE *) b, offset, whence);
  }
  DohError(DOH_UNSUPPORTED,"No seek method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* Tell */
long DohTell(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohTell %x\n",obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_tell) {
      return (b->objinfo->doh_file->doh_tell)(obj);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohTell\n",b);
    return ftell((FILE *) b);
  }
  DohError(DOH_UNSUPPORTED,"No tell method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* Getc */
int DohGetc(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohGetc %x\n",obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_getc) {
      return (b->objinfo->doh_file->doh_getc)(obj);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohGetc\n",b);
    return fgetc((FILE *) b);
  }
  DohError(DOH_UNSUPPORTED,"No getc method defined for type '%s'\n", b->objinfo->objname);
  return EOF;
}

/* Putc */
int DohPutc(int ch, DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohPutc '%c',%x\n",ch,obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_putc) {
      return (b->objinfo->doh_file->doh_putc)(obj,ch);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohPutc\n",b);
    return fputc(ch,(FILE *) b);
  }
  DohError(DOH_UNSUPPORTED,"No putc method defined for type '%s'\n", b->objinfo->objname);
  return EOF;
}

/* ungetc */
int DohUngetc(int ch, DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohUngetc '%c',%x\n",ch,obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_ungetc) {
      return (b->objinfo->doh_file->doh_ungetc)(obj,ch);
    }
  } 
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohUngetc\n",b);
    return ungetc(ch,(FILE *) b);
  }
  DohError(DOH_UNSUPPORTED,"No ungetc method defined for type '%s'\n", b->objinfo->objname);
  return EOF;
}

int DohClose(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohError(DOH_CALLS,"DohClose %x\n",obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_close) {
      return (b->objinfo->doh_file->doh_close)(obj);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohError(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohClose\n",b);
    return fclose((FILE *) obj);
  }
  DohError(DOH_UNSUPPORTED,"No close method defined for type '%s'\n", b->objinfo->objname);
  return 0;
}

void DohInit(DOH *b) {
    DohBase *bs = (DohBase *) b;
    bs->refcount =0;
    bs->objinfo = &DohBaseType;
    bs->line = 0;
    bs->file = 0;
}
