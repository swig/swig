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

/* General comments:

   The segment map gets returned as an array of WadSegment structures.
   Due to memory constraints, this is usually located in a memory mapped
   region or similar section of memory.

   The first element of the memory map describes the segment map (address and size)
   so that it can be cleaned up later on.

   The last element of the memory map is a sentinel where base == 0 and size == 0.
*/

/* Include the proper code for reading the segment map */

#ifdef WAD_SOLARIS
#include "plat/segment_solaris.c"
#endif

#ifdef WAD_LINUX
#include "plat/segment_linux.c"
#endif

/* -----------------------------------------------------------------------------
 * wad_segment_find()
 *
 * Try to find the virtual memory segment corresponding to a virtual address.
 * If a segment is mapped to a file, this function actually returns the *first*
 * segment that is mapped.   This is because symbol relocations are always
 * performed relative to the beginning of the file (so we need the base address)
 * ----------------------------------------------------------------------------- */

WadSegment *
wad_segment_find(WadSegment *s, void *vaddr) {
  WadSegment *ls;
  char *addr = (char *)vaddr;

  ls = s;
  while (s->size || s->base) {
    /*    printf("s = %x, %x(%d) %x\n",s, s->vaddr, s->size,addr); */
    if (strcmp(s->mapname,ls->mapname)) {
      ls = s;    /* First segment for a given name */
    }
    if ((addr >= s->vaddr) && (addr < (s->vaddr + s->size))) {
      if (wad_debug_mode & DEBUG_SEGMENT) {
	printf("wad_segment: %08x --> %08x-%08x in %s\n", vaddr, s->vaddr, ((char *) s->vaddr) + s->size, s->mappath);
      }
      return ls;
    }
    s++;
  }
  return 0;
}


