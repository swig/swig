/* ----------------------------------------------------------------------------- 
 * string.c
 *
 *    This file provides support for string storage in WAD.  Since strings are
 *    used frequently in WAD, this file implements string interning and
 *    some lookup functions that can be used to return a previously stored
 *    string rather than making a new copy.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago.  All rights reserved. 
 * ----------------------------------------------------------------------------- */

#include "wad.h"

static char cvs[] = "$Header$";

/* Hash table containing stab strings and such */
typedef struct stringtype {
  char             *str;
  struct stringtype *next;
} stringtype;

#define STRING_HASH_SIZE  1013

static stringtype *strings[STRING_HASH_SIZE];
static int         strings_init = 0;

static int shash(char *name) {
  unsigned int h = 0;
  char *c;
  int i;
  c = name;
  for (i = 0; (i < 16) && (*c); i++, c++) {
    h = ((h^~i) << 6) + *c;
  }
  return h % STRING_HASH_SIZE;
}

char *
wad_string_lookup(char *s) {
  int h;
  int i;
  stringtype *st;

  if (!strings_init) {
    for (i = 0; i < STRING_HASH_SIZE; i++) {
      strings[i] = 0;
    }
    strings_init = 1;
  }
  
  h = shash(s);
  st = strings[h];
  while (st) {
    if (strcmp(st->str,s) == 0) return st->str;
    st = st->next;
  }
  
  /* Not found. Add the string to the hash table */
  st = (stringtype *) wad_malloc(sizeof(stringtype));
  st->str = wad_strdup(s);
  st->next = strings[h];
  strings[h] = st;
  return st->str;
}

void wad_string_debug() {
  if (wad_debug_mode & DEBUG_STRING) {
    int maxdepth = 0;
    int total = 0;
    int stringlen = 0;
    int i;

    for (i = 0; i < STRING_HASH_SIZE; i++) {
      stringtype *s;
      int c = 0;
      s = strings[i];
      while (s) {
	c++;
	stringlen += strlen(s->str);
	s = s->next;
      }
      /*      wad_printf("WAD: stringhash[%d] = %d\n", i, c);*/
      if (c > maxdepth) maxdepth = c;
      total += c;
    }
    wad_printf("WAD: nstrings = %d (%d bytes)\n", total, stringlen + total*sizeof(stringtype));
    wad_printf("WAD: maxdepth = %d\n", maxdepth);
    }
}

/* Our own string copy */
char *wad_strcpy(char *t, const char *s) {
  if (s)
    for (; *s; s++, t++) *t = *s;
  *t = 0;
  return t;
}

char *
wad_strcat(char *t, const char *s) {
  while (*t) t++;
  return wad_strcpy(t,s);
}

int
wad_strlen(const char *s) {
  int count = 0;
  while (*(s++)) count++;
  return count;
}



