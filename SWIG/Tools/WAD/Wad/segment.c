/* ----------------------------------------------------------------------------- 
 * segment.c
 *
 *     This file provides access to the virtual memory map of a process
 *     including the location of the executable, data segments, shared
 *     libraries, and memory mapped regions. 
 *
 *     The primary purpose of this module is to collect this information
 *     and store it in a form that hides platform specific details (the
 *     WadSegment structure).
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

/* Include the proper code for reading the segment map */

#ifdef WAD_SOLARIS
#include "plat/segment_solaris.c"
#endif

#ifdef WAD_LINUX
#include "plat/segment_linux.c"
#endif

static WadSegment    *segments = 0;   /* Linked list of segments */

/* ----------------------------------------------------------------------------- 
 * wad_segment_read()
 *
 * Read all of the memory segments into a linked list.  Any previous segment
 * map is simply lost.  The only way to reclaim this memory is to call
 * wad_release_memory().
 * ----------------------------------------------------------------------------- */

int
wad_segment_read() {
  int         fs;
  int         n;
  WadSegment *s, *lasts;

  segments = 0;
  lasts = 0;
  fs = segment_open();

  while (1) {
    s = (WadSegment *) wad_malloc(sizeof(WadSegment));    
    n = segment_read(fs,s);
    if (n <= 0) break;
    s->next = 0;
    if (!lasts) {
      segments = s;
      lasts = s;
    } else {
      lasts->next = s;
      lasts = s;
    }
    if (wad_debug_mode & DEBUG_SEGMENT) {
      wad_printf("wad_segment: read : %08x-%08x, base=%x in %s\n", s->vaddr, ((char *) s->vaddr) + s->size, s->base, s->mappath);
    }
  }
  close(fs);
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_segment_find()
 *
 * Try to find the virtual memory segment corresponding to a virtual address.
 * If a segment is mapped to a file, this function actually returns the *first*
 * segment that is mapped.   This is because symbol relocations are always
 * performed relative to the beginning of the file (so we need the base address)
 * ----------------------------------------------------------------------------- */

WadSegment *
wad_segment_find(void *vaddr) {
  WadSegment *ls;
  WadSegment *s;
  char *addr = (char *)vaddr;

  s = segments;
  ls = segments;
  while (s) {
    if (strcmp(s->mapname,ls->mapname)) {
      ls = s;    /* First segment for a given name */
    }
    if ((addr >= s->vaddr) && (addr < (s->vaddr + s->size))) {
      if (wad_debug_mode & DEBUG_SEGMENT) {
	wad_printf("wad_segment: %08x --> %08x-%08x in %s\n", vaddr, s->vaddr, ((char *) s->vaddr) + s->size, s->mappath);
      }
      return ls;
    }
    s = s->next;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_segment_valid()
 *
 * Checks to see if a memory address is valid or not based on data in the
 * segment map 
 * ----------------------------------------------------------------------------- */

int wad_segment_valid(void *vaddr) {
  return wad_segment_find(vaddr) ? 1 : 0;
}




