/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
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
 *******************************************************************************/

#include "internal.h"
#include "doh.h"

static char cvsroot[] = "$Header$";

/*******************************************************************************
 * File : hash.cxx
 *
 * This is now just a wrapper around the DOH hash table object.
 *******************************************************************************/

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

