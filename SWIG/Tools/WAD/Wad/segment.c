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
 * wad_segment_read()
 *
 * Read all of the memory segments.
 * ----------------------------------------------------------------------------- */

WadSegment *
wad_segment_read() {
  FILE       *fs;
  int         dz;
  int         offset = 0;
  int         i;
  int         n = 0;
  int         nsegments;
  WadSegment *segments;
  WadSegment *s;
  WadSegment  ws;

  /* Try to load the virtual address map */
  fs = segment_open();
  if (!fs) return 0;
  nsegments = 0;
  while (1) {
    n = segment_read(fs,&ws);
    if (n <= 0) break;
    nsegments++;
  }
  nsegments+=3;
  fclose(fs);

  dz = open("/dev/zero", O_RDWR, 0644);
  if (dz < 0) {
    puts("Couldn't open /dev/zero\n");
    return 0;
  }
  segments = (WadSegment *) mmap(NULL, nsegments*sizeof(WadSegment), PROT_READ | PROT_WRITE, MAP_PRIVATE, dz, 0);
  close(dz);
  
  fs = segment_open();
  i = 0;
  s = segments;

  /* First segment is a map to the segment list */
  s->base = (char *) segments;
  s->vaddr = (char *) segments;
  s->size = nsegments*sizeof(WadSegment);
  s->mapname[0] = 0;
  s->mappath[0] = 0;
  s++;

  while (1) {
    n = segment_read(fs,&ws);
    if (n <= 0) break;
    strcpy(s->mapname, ws.mapname);
    strcpy(s->mappath, ws.mappath);
    s->vaddr = ws.vaddr;
    s->base = ws.base;
    s->size = ws.size;
    s->offset = ws.offset;
    if (wad_debug_mode & DEBUG_SEGMENT) {
      printf("wad_segment: read : %08x-%08x, base=%x in %s\n", s->vaddr, ((char *) s->vaddr) + s->size, s->base, s->mappath);
    }
    s++;
  }
  /* Create sentinel */
  s->base = 0;
  s->vaddr = 0;
  s->size = 0;
  s->offset = 0;
  s->mapname[0] =0;
  s->mappath[0] = 0;
  fclose(fs);
  return segments;
}

/* -----------------------------------------------------------------------------
 * wad_segment_release()
 *
 * This function releases all of the segments.
 * ----------------------------------------------------------------------------- */

void 
wad_segment_release(WadSegment *s) {
  munmap((void *)s, s->size);
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


