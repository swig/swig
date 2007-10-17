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
 * Copyright (C) 2000.  The University of Chicago. 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * See the file COPYING for a complete copy of the LGPL.
 * ----------------------------------------------------------------------------- */

#include "wad.h"

static char cvs[] = "$Id$";

/* Include the proper code for reading the segment map */

#ifdef WAD_SOLARIS

/* This code is used to read the process virtual memory map on Solaris machines */

static int
segment_open() {
  int f;
  f = open("/proc/self/map", O_RDONLY);
  return f;
}

static int
segment_read(int fs, WadSegment *s) {
  int     dz;
  int     n;
  prmap_t pmap;

  n = read(fs, &pmap, sizeof(prmap_t));
  if (n <= 0) return 0;
  s->mapname = wad_strdup(pmap.pr_mapname);
  s->mappath = (char *) wad_malloc(20+strlen(pmap.pr_mapname));
  wad_strcpy(s->mappath,"/proc/self/object/");
  strcat(s->mappath,pmap.pr_mapname);
  s->vaddr = (char *) pmap.pr_vaddr;

  /* This is a solaris oddity.  a.out section starts 1 page up, but
     symbols are relative to a base of 0 */

  if (strcmp(s->mapname,"a.out") == 0) s->base = 0;
  else s->base = s->vaddr;

  s->size  = pmap.pr_size;
  s->offset = pmap.pr_offset;
  return 1;
}

#endif           /* WAD_SOLARIS */

#ifdef WAD_LINUX
static char linux_firstsegment[1024];
static int linux_first = 1;

static int
segment_open() {
  FILE *f;
  f = fopen("/proc/self/maps", "r");
  linux_first =1;
  return (int) f;
}

static int 
segment_read(int fd, WadSegment *s)
{
  char pbuffer[1024];
  char *c;
  int  len;
  FILE *fs = (FILE *) fd;
  c = fgets(pbuffer,1024,fs);
  if (!c) return 0;

  pbuffer[strlen(pbuffer)-1] = 0;   /* Chop off endline */

  /* Break up the field into records */
  /*    0-8       : Starting address
	9-17      : Ending Address
	18        : r
	19        : w
	20        : x
	21        : p
	23-31     : Offset 
	49-       : Filename */

  len = strlen(pbuffer);
  pbuffer[8] = 0;
  pbuffer[17] = 0;
  pbuffer[31] = 0;
  if (len >= 49) {
    s->mapname = wad_strdup(pbuffer+49);
    s->mappath = s->mapname;
  }  else {
    s->mapname = "";
    s->mappath = s->mapname;
  }
  if (linux_first) {
    wad_strcpy(linux_firstsegment, s->mappath);
    linux_first = 0;
  }
  s->vaddr = (char *) strtoul(pbuffer,NULL,16);
  s->size = strtoul(pbuffer+9,NULL,16) - (long) (s->vaddr);
  s->offset = strtoul(pbuffer+23,NULL,16);
  if (strcmp(linux_firstsegment, s->mappath) == 0) {
    s->base = 0;
  } else {
    s->base = s->vaddr;
  }
  s++;
  return 1;
}

#endif   /* WAD_LINUX */

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
  skip:
    n = segment_read(fs,s);
    if (n <= 0) break;
    if (wad_file_check(s->vaddr)) goto skip;  /* Skip files we already loaded */
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
    if (strcmp(s->mapname,ls->mapname) || (!strlen(ls->mapname))) {
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




