/* ----------------------------------------------------------------------------- 
 * hash.cxx
 *
 *     Hash table object.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "internal.h"
#include "doh.h"

static char cvsroot[] = "$Header$";

Hash::Hash() {
  data = NewHash();
}

Hash::~Hash() {
  Delete(data);
}

int Hash::add(const char *k, void *obj) {
  DOH *v = NewVoid(obj,0);
  if (Getattr(data, (DOH *) k)) return -1;
  Setattr(data, (DOH *) k, v);
  return 0;
}

int Hash::add(const char *k, void *obj, void (*d)(void *)) {
  DOH *v = NewVoid(obj,d);
  if (Getattr(data, (DOH *) k)) return -1;
  Setattr(data, (DOH *) k, v);
  return 0;
}

void *Hash::lookup(const char *k) {
  DOH *v;
  v = Getattr(data,(DOH *)k);
  if (!v) return 0;
  return Data(v);
}

void Hash::remove(const char *k) {
  Delattr(data,(DOH *)k);
}

void *Hash::first() {
  DOH *o;
  DOH *v = Firstkey(data);
  if (v) {
    o = Getattr(data,v);
    return Data(o);
  }
  return 0;
}

char *Hash::firstkey() {
  DOH *v = Firstkey(data);
  if (v) {
    return Char(v);
  }
  return 0;
}

void *Hash::next() {
  DOH *o;
  DOH *v = Nextkey(data);
  if (v) {
    o = Getattr(data,v);
    return Data(o);
  }
  return 0;
}

char *Hash::nextkey() {
  DOH *v = Nextkey(data);
  if (v) {
    return Char(v);
  }
  return 0;
}

