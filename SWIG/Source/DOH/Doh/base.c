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
  0,                /* doh_scope */
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
  0,                /* doh_positional */
  0,                /* reserved5 */
  0,                /* reserved6 */
  0,                /* user1 */
  0,                /* user2 */
  0,                /* user3 */
  0,                /* user4 */
};

static int    doh_debug_level = 0;

/* -----------------------------------------------------------------------------
 * DohTrace()
 *
 * This function is used to print tracing information during debugging.
 * ----------------------------------------------------------------------------- */

void
DohTrace(int level, char *fmt, ...) {
  va_list ap;
  va_start(ap,fmt);
  if (level & doh_debug_level) {
    printf("DOH %x:", level);
    vprintf(fmt,ap);
  }
  va_end(ap);
}

/* -----------------------------------------------------------------------------
 * DohDebug()
 *
 * Set the DOH tracing level.
 * ----------------------------------------------------------------------------- */

void
DohDebug(int d) {
  doh_debug_level = d;
}

/* -----------------------------------------------------------------------------
 * DohDelete()
 *
 * Delete an object by decreasing its reference count. Calls the object
 * destructor if the reference count is zero after the decrement.
 * ----------------------------------------------------------------------------- */

void 
DohDelete(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohDelete %x\n",obj);
  if (!DohCheck(b)) return;
  if (b->flags & DOH_FLAG_INTERN) return;
  b->refcount--;
  if (b->refcount == 0) {
    if (b->objinfo->doh_del) (b->objinfo->doh_del)(obj); 
  }
}

/* -----------------------------------------------------------------------------
 * DohIntern()
 * 
 * Flips the intern bit on an object forcing it to be never be garbage collected.
 * ----------------------------------------------------------------------------- */

void
DohIntern(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohIntern %x\n", obj);
  if (!DohCheck(b)) return;
  b->flags = b->flags | DOH_FLAG_INTERN;
}

/* -----------------------------------------------------------------------------
 * DohCopy()
 *
 * Make a copy of an object.
 * ----------------------------------------------------------------------------- */

DOH *
DohCopy(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohCopy %x\n",obj);
  if (!DohCheck(b)) {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Copy.\n", obj);
    return 0;
  }
  if (b->objinfo->doh_copy) return (b->objinfo->doh_copy)(b);
  DohTrace(DOH_UNSUPPORTED,"No copy method defined for type '%s'\n", b->objinfo->objname);
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohClear()
 *
 * Clear the contents of an object.
 * ----------------------------------------------------------------------------- */

void
DohClear(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohClear %x\n",obj);
  if (!DohCheck(b)) {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Clear.\n",obj);
    return;
  }
  if (b->objinfo->doh_clear) {
    (b->objinfo->doh_clear)(obj);
    return;
  }
  DohTrace(DOH_UNSUPPORTED, "No clear method defined for type '%s'\n", b->objinfo->objname);
}

/* ----------------------------------------------------------------------------- 
 * DohSetScope()
 *
 * Manually change the scope level of an object.
 * ----------------------------------------------------------------------------- */

void
DohSetScope(DOH *obj, int s) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohScope %x\n",obj);
  if (!DohCheck(b)) {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Scope.\n",obj);
    return;
  }
  if (b->objinfo->doh_scope) {
    (b->objinfo->doh_scope)(obj,s);
    return;
  }
  if (s < b->scope) b->scope = s;
}

/* -----------------------------------------------------------------------------
 * DohStr()
 *
 * Create a string representation of an object.  If the object has no str method
 * a generic representation of the form <Object 'name' at %x> is created. 
 * Non-DOH objects are assumed to 
 * ----------------------------------------------------------------------------- */

DOH *
DohStr(const DOH *obj) {
  DOH *s;
  DohBase *b = (DohBase *) obj; 
  DohTrace(DOH_CALLS,"DohStr %x\n",obj);
  if (DohCheck(b)) {
    if (b->objinfo->doh_str) {
      return (b->objinfo->doh_str)(b);
    }
    s = NewString("<Object ");
    Printf(s,"'%s' at %x>", b->objinfo->objname, b);
    Seek(s,0,SEEK_SET);
    return s;
  } else {
    DohTrace(DOH_CONVERSION, "Creating new string from unknown object %x (assuming char *).\n", obj);
    return NewString(obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohDump()
 *
 * Serialize an object onto an output stream.
 * ----------------------------------------------------------------------------- */

int
DohDump(const DOH *obj, DOH *out) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohDump %x, %x\n",obj,out);
  if (DohCheck(obj)) {
    if (b->objinfo->doh_dump) {
      return (b->objinfo->doh_dump)(b,out);
    }
    DohTrace(DOH_UNSUPPORTED,"No dump method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN, "Unknown object %x passed to Dump.\n",obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohLen()
 *
 * Return the length of an object. If a non-DOH object is passed, strlen()
 * is invoked on it.
 * ----------------------------------------------------------------------------- */
int
DohLen(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohLen %x\n",obj);
  if (!b) return 0;
  if (DohCheck(b)) {
    if (b->objinfo->doh_len) {
      return (b->objinfo->doh_len)(b);
    }
    DohTrace(DOH_UNSUPPORTED, "No len method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_CONVERSION, "Using strlen() on unknown object %x.\n", obj);
    return strlen((char *) obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohHashVal()
 *
 * Compute the integer hash value of an object. Only needed for objects that
 * need to serve as a keys.
 * ----------------------------------------------------------------------------- */

int
DohHashval(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohHashval %x\n",obj);
  if (DohCheck(b)) {
    if (b->objinfo->doh_hash) {
      return (b->objinfo->doh_hash)(b);
    }
    DohTrace(DOH_UNSUPPORTED,"No hash method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Hashval.\n", obj);
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * DohData()
 *
 * Return pointer to the raw data stored inside an object (when applicable).
 * ----------------------------------------------------------------------------- */

void *
DohData(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohData %x\n",obj);
  if (DohCheck(obj)) {
    if (b->objinfo) {
      if (b->objinfo->doh_data) {
	return (b->objinfo->doh_data)(b);
      }
    }
    DohTrace(DOH_UNSUPPORTED,"No data method defined for type '%s'\n", b->objinfo->objname);
    return 0;
  }
  DohTrace(DOH_CONVERSION, "Unknown object %x passed to Data being returned as-is.\n", obj);
  return (char *) obj;
}

/* -----------------------------------------------------------------------------
 * DohGetLine()
 *
 * Return the line number associated with an object or -1 if unspecified.
 * ----------------------------------------------------------------------------- */

int 
DohGetline(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohGetline %x\n",obj);
  if (DohCheck(obj)) {
    if (b->objinfo->doh_position && b->objinfo->doh_position->doh_getline) {
      return (b->objinfo->doh_position->doh_getline)(b);
    } else {
      DohTrace(DOH_UNSUPPORTED,"No getline method defined for type '%s'\n", b->objinfo->objname);
      return -1;
    }
  }
  DohTrace(DOH_UNKNOWN, "Unknown object %x passed to Getline.\n", obj);
  return -1;
}

/* -----------------------------------------------------------------------------
 * DohSetLine()
 * 
 * Set the line number associated with an object.
 * ----------------------------------------------------------------------------- */

void 
DohSetline(DOH *obj, int line) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohSetline %x, %d\n",obj, line);
  if (DohCheck(obj)) {
    if (b->objinfo->doh_position && b->objinfo->doh_position->doh_setline) {
      (b->objinfo->doh_position->doh_setline)(obj, line);
      return;
    }
    DohTrace(DOH_UNSUPPORTED,"No setline method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN, "Unknown object %x passed to Setline.\n", obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohGetfile()
 * 
 * Get the file associated with an object.
 * ----------------------------------------------------------------------------- */

DOH *
DohGetfile(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohGetfile %x\n",obj);
  if (DohCheck(obj)) {
    if (b->objinfo->doh_position && b->objinfo->doh_position->doh_getfile) {
      return (b->objinfo->doh_position->doh_getfile)(b);
    }
    DohTrace(DOH_UNSUPPORTED,"No getfile method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN, "Unknown object %x passed to Getfile.\n", obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohSetfile()
 *
 * Set the file associated with an object.
 * ----------------------------------------------------------------------------- */

void
DohSetfile(DOH *obj, DOH *file) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohSetfile %x, %x\n",obj,file);
  if (DohCheck(obj)) {
    if (b->objinfo->doh_position && b->objinfo->doh_position->doh_setfile) {
      (b->objinfo->doh_position->doh_setfile)(obj,file);
      return;
    }
    DohTrace(DOH_UNSUPPORTED,"No setfile method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN, "Unknown object %x passed to Setfile.\n", obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohCmp()
 *
 * Compare two objects.  If either of the objects are non-DOH objects, the
 * objects are compared using strcmp().
 * ----------------------------------------------------------------------------- */
 
int
DohCmp(const DOH *obj1, const DOH *obj2) {
  DohBase *b1, *b2;
  DohTrace(DOH_CALLS,"DohCmp %x, %x\n",obj1,obj2);
  b1 = (DohBase *) obj1;
  b2 = (DohBase *) obj2;
  if ((!DohCheck(b1)) || (!DohCheck(b2))) {
    return strcmp((char *) DohData(b1),(char *) DohData(b2));
  }
  if (b1->objinfo->doh_cmp) {
    return (b1->objinfo->doh_cmp)(b1,b2);
  }
  DohTrace(DOH_UNSUPPORTED,"No cmp method defined for type '%s'\n", b1->objinfo->objname);
  return 1;
}

/* ----------------------------------------------------------------------
 * Mapping Interface 
 * ---------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * DohIsMapping()
 *
 * Return 1 if an object defines a mapping interface.
 * ----------------------------------------------------------------------------- */

int 
DohIsMapping(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_mapping) return 1;
  else return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetattr()
 *
 * Get an attribute from a mapping object.
 * ----------------------------------------------------------------------------- */

DOH *
DohGetattr(DOH *obj, const DOH *name) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohGetattr %x, %x\n",obj,name);
  if (DohIsMapping(b)) {
    if (b->objinfo->doh_mapping->doh_getattr) {
      return (b->objinfo->doh_mapping->doh_getattr)(b,(DOH *) name);
    }
  }
  if (DohCheck(b)) {
    DohTrace(DOH_UNSUPPORTED,"No getattr method defined for type '%s'\n", b->objinfo->objname); 
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Getattr.\n", obj);
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * DohSetattr()
 *
 * Set an attribute in a mapping object.
 * ----------------------------------------------------------------------------- */

int 
DohSetattr(DOH *obj, const DOH *name, const DOH *value) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohSetattr %x, %x, %x\n",obj,name, value);
  if (DohIsMapping(b)) {
    if (b->objinfo->doh_mapping->doh_setattr) {
      return (b->objinfo->doh_mapping->doh_setattr)(b,(DOH *) name,(DOH *) value);
    }
  }
  if (DohCheck(b)) {
    DohTrace(DOH_UNSUPPORTED, "No setattr method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Setattr\n", obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohDelattr()
 *
 * Delete an attribute in a mapping object.
 * ----------------------------------------------------------------------------- */

void
DohDelattr(DOH *obj, const DOH *name) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohDelattr %x, %x\n",obj,name);
  if (DohIsMapping(obj)) {
    if (b->objinfo->doh_mapping->doh_delattr) {
      (b->objinfo->doh_mapping->doh_delattr)(b,(DOH *) name);
      return;
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED, "No delattr method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Delattr\n",obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohFirstkey()
 *
 * Return the first key value in a mapping object.
 * ----------------------------------------------------------------------------- */

DOH *
DohFirstkey(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohFirstkey %x\n",obj);
  if (DohIsMapping(obj)) {
    if (b->objinfo->doh_mapping->doh_firstkey) {
      return (b->objinfo->doh_mapping->doh_firstkey)(obj);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No firstkey method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohFirstkey\n",obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohNextkey()
 *
 * Return the next key in a mapping object.
 * ----------------------------------------------------------------------------- */

DOH *
DohNextkey(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohNextkey %x\n",obj);
  if (DohIsMapping(obj)) {
    if (b->objinfo->doh_mapping->doh_nextkey) {
      return (b->objinfo->doh_mapping->doh_nextkey)(obj);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No nextkey method defined for type '%s'\n", b->objinfo->objname);
    } else {
      DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohNextkey\n",obj);
    }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetInt()
 *
 * Return an element as an integer.
 * ----------------------------------------------------------------------------- */

int 
DohGetInt(DOH *obj, const DOH *name) {
  DOH *val;
  DohTrace(DOH_CALLS,"DohGetInt %x, %x\n",obj,name);  
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  if (DohIsString(val)) {
    return atoi(Data(val));
  } 
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetDouble()
 *
 * Return an element as a double.
 * ----------------------------------------------------------------------------- */

double
DohGetDouble(DOH *obj, const DOH *name) {
  DOH *val;
  DohTrace(DOH_CALLS,"DohGetDouble %x, %x\n",obj,name);  
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  if (DohIsString(val)) {
    return atof(Data(val));
  } 
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetChar()
 * 
 * Return an element as a char *
 * ----------------------------------------------------------------------------- */

char *
DohGetChar(DOH *obj, const DOH *name) {
  DOH *val;
  DohTrace(DOH_CALLS,"DohGetChar %x, %x\n",obj,name);  
  val = Getattr(obj,(DOH *) name);
  if (!val) return 0;
  if (DohIsString(val)) {
    return (char *) Data(val);
  } 
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohSetInt()
 *
 * Set an attribute as an integer
 * ----------------------------------------------------------------------------- */

void
DohSetInt(DOH *obj, const DOH *name, int value) {
  DOH *temp;
  DohTrace(DOH_CALLS,"DohSetInt %x, %x, %d\n", obj, name, value);
  temp = NewString("");
  Printf(temp,"%d",value);
  Setattr(obj,(DOH *) name,temp);
}

/* ----------------------------------------------------------------------------- 
 * DohSetDouble()
 *
 * Set an attribute as a double
 * ----------------------------------------------------------------------------- */

void
DohSetDouble(DOH *obj, const DOH *name, double value) {
  DOH *temp;
  DohTrace(DOH_CALLS,"DohSetDouble %x, %x, %g\n", obj, name, value);
  temp = NewString("");
  Printf(temp,"%0.17f",value);
  Setattr(obj,(DOH *) name,temp);
}

/* -----------------------------------------------------------------------------
 * DohSetChar()
 *
 * Set an attribute as a string.
 * ----------------------------------------------------------------------------- */

void
DohSetChar(DOH *obj, const DOH *name, char *value) {
  DOH *temp;
  DohTrace(DOH_CALLS,"DohSetChar %x, %x, %g\n", obj, name, value);
  temp = NewString(value);
  Setattr(obj,(DOH *) name,temp);
}

/* ----------------------------------------------------------------------
 * Sequence Interface
 * ---------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * DohIsSequence()
 *
 * Return 1 if an object supports sequence methods.
 * ----------------------------------------------------------------------------- */

int 
DohIsSequence(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_sequence) return 1;
  else return 0;
}

/* -----------------------------------------------------------------------------
 * DohGetitem()
 *
 * Return an item from a sequence.
 * ----------------------------------------------------------------------------- */

DOH *
DohGetitem(DOH *obj, int index) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohGetitem %x, %d\n",obj,index);  
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_getitem) {
      return (b->objinfo->doh_sequence->doh_getitem)(obj,index);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No getitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohGetitem\n",obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohSetitem()
 *
 * Set an item in a sequence.
 * ----------------------------------------------------------------------------- */
   
int 
DohSetitem(DOH *obj, int index, const DOH *value) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohSetitem %x, %d, %x\n",obj,index, value);  
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_setitem) {
      return (b->objinfo->doh_sequence->doh_setitem)(obj,index,(DOH *) value);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No setitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohSetitem\n",obj);
  }
}

/* -----------------------------------------------------------------------------
 * DohDelitem()
 * 
 * Delete an item in a sequence.
 * ----------------------------------------------------------------------------- */

int 
DohDelitem(DOH *obj, int index) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohDelitem %x, %d\n",obj,index);
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_delitem) {
      return (b->objinfo->doh_sequence->doh_delitem)(obj,index);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No delitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohDelitem\n",obj);
  }
}

/* ----------------------------------------------------------------------------- 
 * DohInsertitem()
 *
 * Insert an item into a sequence.
 * ----------------------------------------------------------------------------- */

int 
DohInsertitem(DOH *obj, int index, const DOH *value) {
  int  no = 0;
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohInsertitem %x, %d, %x\n",obj,index, value);
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_insitem) {
      return (b->objinfo->doh_sequence->doh_insitem)(obj,index,(DOH *) value);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No insitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohInsertitem\n",obj);
  }
}

/* ----------------------------------------------------------------------------- 
 * DohFirstitem()
 *
 * Get the first item in a sequence
 * ----------------------------------------------------------------------------- */

DOH *
DohFirstitem(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohFirstitem %x\n");
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_firstitem) {
      return (b->objinfo->doh_sequence->doh_firstitem)(obj);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No firstitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohFirstitem\n",obj);
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * DohNextitem()
 *
 * Get the next item in a sequence.
 * ----------------------------------------------------------------------------- */

DOH *
DohNextitem(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohNextitem %x\n");
  if (DohIsSequence(obj)) {
    if (b->objinfo->doh_sequence->doh_nextitem) {
      return (b->objinfo->doh_sequence->doh_nextitem)(obj);
    }
  }
  if (DohCheck(obj)) {
    DohTrace(DOH_UNSUPPORTED,"No nextitem method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to DohNextitem\n",obj);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * File methods 
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * DohIsFile()
 *
 * Return 1 if an object supports file methods.
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
 *
 * Read bytes from an object.  Implicitly converts to a FILE *.
 * ----------------------------------------------------------------------------- */

int 
DohRead(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohRead %x, %x, %d\n",obj,buffer,length);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_read) {
      return (b->objinfo->doh_file->doh_read)(obj,buffer,length);
    }
  } else if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohRead\n",b);
    return fread(buffer,1,length,(FILE *) b);
  }
  DohTrace(DOH_UNSUPPORTED,"No read method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* ----------------------------------------------------------------------------- 
 * DohWrite()
 * 
 * Write bytes to an object. Implicitly converts to a FILE *
 * ----------------------------------------------------------------------------- */

int 
DohWrite(DOH *obj, void *buffer, int length) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohWrite %x, %x, %d\n",obj,buffer,length);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_write) {
      return (b->objinfo->doh_file->doh_write)(obj,buffer,length);
    }
  }
  if (!DohCheck(b)) {
    /* Hmmm.  Not a file.  Maybe it's a real FILE */
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohWrite\n",b);
    return fwrite(buffer,1,length,(FILE *) b);
  }
  DohTrace(DOH_UNSUPPORTED,"No write method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* -----------------------------------------------------------------------------
 * DohSeek()
 *
 * Seek to a new position.
 * ----------------------------------------------------------------------------- */

int 
DohSeek(DOH *obj, long offset, int whence) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohSeek %x, %d, %d\n",obj,offset,whence);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_seek) {
      return (b->objinfo->doh_file->doh_seek)(obj,offset,whence);
    }
  }
  if (!DohCheck(b)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohSeek\n",b);
    return fseek((FILE *) b, offset, whence);
  }
  DohTrace(DOH_UNSUPPORTED,"No seek method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* -----------------------------------------------------------------------------
 * DohTell()
 *
 * Return current file pointer.
 * ----------------------------------------------------------------------------- */

long 
DohTell(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohTell %x\n",obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_tell) {
      return (b->objinfo->doh_file->doh_tell)(obj);
    }
  }
  if (!DohCheck(b)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohTell\n",b);
    return ftell((FILE *) b);
  }
  DohTrace(DOH_UNSUPPORTED,"No tell method defined for type '%s'\n", b->objinfo->objname);
  return -1;
}

/* ----------------------------------------------------------------------------- 
 * DohGetc()
 *
 * Return a character
 * ----------------------------------------------------------------------------- */

int 
DohGetc(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohGetc %x\n",obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_getc) {
      return (b->objinfo->doh_file->doh_getc)(obj);
    }
  }
  if (!DohCheck(b)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohGetc\n",b);
    return fgetc((FILE *) b);
  }
  DohTrace(DOH_UNSUPPORTED,"No getc method defined for type '%s'\n", b->objinfo->objname);
  return EOF;
}

/* -----------------------------------------------------------------------------
 * DohPutc()
 *
 * Put a character.
 * ----------------------------------------------------------------------------- */

int 
DohPutc(int ch, DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohPutc '%c',%x\n",ch,obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_putc) {
      return (b->objinfo->doh_file->doh_putc)(obj,ch);
    }
  }
  if (!DohCheck(b)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohPutc\n",b);
    return fputc(ch,(FILE *) b);
  }
  DohTrace(DOH_UNSUPPORTED,"No putc method defined for type '%s'\n", b->objinfo->objname);
  return EOF;
}

/* -----------------------------------------------------------------------------
 * DohUngetc()
 *
 * Put a character back on the input stream.
 * ----------------------------------------------------------------------------- */

int 
DohUngetc(int ch, DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohUngetc '%c',%x\n",ch,obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_ungetc) {
      return (b->objinfo->doh_file->doh_ungetc)(obj,ch);
    }
  } 
  if (!DohCheck(b)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohUngetc\n",b);
    return ungetc(ch,(FILE *) b);
  }
  DohTrace(DOH_UNSUPPORTED,"No ungetc method defined for type '%s'\n", b->objinfo->objname);
  return EOF;
}

/* -----------------------------------------------------------------------------
 * DohClose()
 *
 * Close a file object.
 * ----------------------------------------------------------------------------- */

int 
DohClose(DOH *obj) {
  DohBase *b = (DohBase *) obj;
  DohTrace(DOH_CALLS,"DohClose %x\n",obj);
  if (DohIsFile(obj)) {
    if (b->objinfo->doh_file->doh_close) {
      return (b->objinfo->doh_file->doh_close)(obj);
    }
  }
  if (!DohCheck(b)) {
    DohTrace(DOH_CONVERSION,"Unknown object %x converted to FILE * in DohClose\n",b);
    return fclose((FILE *) obj);
  }
  DohTrace(DOH_UNSUPPORTED,"No close method defined for type '%s'\n", b->objinfo->objname);
  return 0;
}

/* -----------------------------------------------------------------------------
 * String methods
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * DohIsString()
 *
 * Return 1 if an object supports string methods.
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
 *
 * Perform string replacement.
 * ----------------------------------------------------------------------------- */

int 
DohReplace(DOH *src, const DOH *token, const DOH *rep, int flags) {
  DohBase *b = (DohBase *) src;
  DohTrace(DOH_CALLS, "DohReplace %x\n", src);
  if (DohIsString(src)) {
    if (b->objinfo->doh_string->doh_replace) {
      return (b->objinfo->doh_string->doh_replace)(src,(DOH *) token, (DOH *) rep,flags);
    }
  }
  if (DohCheck(b)) {
    DohTrace(DOH_UNSUPPORTED, "No replace method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Replace\n", b);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * DohChop()
 *
 * Chop whitespace at the end of a string.
 * ----------------------------------------------------------------------------- */

void 
DohChop(DOH *src) {
  DohBase *b = (DohBase *) src;
  DohTrace(DOH_CALLS, "DohChop %x\n", src);
  if (DohIsString(src)) {
    if (b->objinfo->doh_string->doh_chop) {
      (b->objinfo->doh_string->doh_chop)(src);
    }
  }
  if (DohCheck(b)) {
    DohTrace(DOH_UNSUPPORTED, "No chop method defined for type '%s'\n", b->objinfo->objname);
  } else {
    DohTrace(DOH_UNKNOWN,"Unknown object %x passed to Chop\n", b);
  }
}

/* -----------------------------------------------------------------------------
 * Callable methods
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * DohIsCallable()
 *
 * Return 1 if an object supports callable methods.
 * ----------------------------------------------------------------------------- */

int 
DohIsCallable(const DOH *obj) {
  DohBase *b = (DohBase *) obj;
  if (!DohCheck(b)) return 0;
  if (b->objinfo->doh_callable) return 1;
  else return 0;
}


/* -----------------------------------------------------------------------------
 * DohCall()
 *
 * Perform a function call on an object.
 * ----------------------------------------------------------------------------- */

DOH *
DohCall(DOH *obj, DOH *args) {
  DohBase *b = (DohBase *) obj; 
  DohTrace(DOH_CALLS,"DohCall %x\n",obj);
  if (DohCheck(b)) {
    if ((b->objinfo->doh_callable) && (b->objinfo->doh_callable->doh_call)) {
	  return (b->objinfo->doh_callable->doh_call)(b,args);
    }
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * DohInit()
 *
 * Initialize an object.
 * ----------------------------------------------------------------------------- */

void 
DohInit(DOH *b) {
  DohBase *bs = (DohBase *) b;
  bs->refcount = 1;
  bs->objinfo = &DohBaseType;
  bs->flags = 0;
}

/* -----------------------------------------------------------------------------
 * DohXBase_setfile()
 *
 * Set file location (default method).
 * ----------------------------------------------------------------------------- */
void
DohXBase_setfile(DOH *ho, DOH *file) {
  DohXBase *h = (DohXBase *) ho;
  if (!DohCheck(file)) file = NewString(file);
  h->file = file;
  Incref(h->file);
}

/* -----------------------------------------------------------------------------
 * DohXBase_getfile()
 * ----------------------------------------------------------------------------- */

DOH *
DohXBase_getfile(DOH *ho) {
  DohXBase *h = (DohXBase *) ho;
  return h->file;
}

/* -----------------------------------------------------------------------------
 * DohXBase_setline()
 * ----------------------------------------------------------------------------- */
void 
DohXBase_setline(DOH *ho, int l) {
  DohXBase *h = (DohXBase *) ho;
  h->line = l;
}

/* -----------------------------------------------------------------------------
 * DohXBase_getline()
 * ----------------------------------------------------------------------------- */
int 
DohXBase_getline(DOH *ho) {
  DohXBase *h = (DohXBase *) ho;
  return h->line;
}

static DohPositionalMethods XBasePositionalMethods = {
  DohXBase_setfile,
  DohXBase_getfile,
  DohXBase_setline,
  DohXBase_getline
};

/* -----------------------------------------------------------------------------
 * DohXInit()
 *
 * Initialize an extended object.
 * ----------------------------------------------------------------------------- */
void 
DohXInit(DOH *b) {
  DohXBase *bs = (DohXBase *) b;
  bs->file = 0;
  bs->line = 0;
  bs->objinfo->doh_position = &XBasePositionalMethods;
}




