/* ----------------------------------------------------------------------------- 
 * segment.c
 *
 *     This file provides access to the virtual memory map of a process
 *     including the location of the executable, data segments, shared
 *     libraries, and memory mapped regions.  This information is 
 *     obtained through /proc.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

/* The segment map is actually stored in an mmap'd data structure so we
   can avoid the use of malloc()/free(). */

static WadSegment *segments = 0;    /* mmap data containing segment info */
static int         segments_size;   /* Size of mmap'd region */
static int         nsegments = 0;   /* Number of segments    */

/* This function reads the segment map into memory */
#ifdef WAD_SOLARIS

/* ------------- Solaris Version ------------------ */

static
void read_segments() {
  int     fd;
  int     dz;
  int     offset = 0;
  int     i;
  int     n = 0;
  WadSegment *s;
  prmap_t pmap;

  /* Try to load the virtual address map */
  fd = open("/proc/self/map", O_RDONLY);
  if (fd < 0) {
    return;
  }
  nsegments = 0;
  while (1) {
    n = read(fd,&pmap,sizeof(prmap_t));
    if (n <= 0) break;
    nsegments++;
  }
  nsegments++;
  close(fd);

  dz = open("/dev/zero", O_RDWR, 0644);
  if (dz < 0) {
    puts("Couldn't open /dev/zero\n");
    return;
  }
  segments = (WadSegment *) mmap(NULL, nsegments*sizeof(WadSegment), PROT_READ | PROT_WRITE, MAP_PRIVATE, dz, 0);
  close(dz);
  segments_size = nsegments*sizeof(WadSegment);
  
  fd = open("/proc/self/map", O_RDONLY);
  if (fd < 0) return;
  i = 0;
  s = segments;
  while (1) {
    n = read(fd,&pmap,sizeof(prmap_t));
    if (n <= 0) break;
    strncpy(s->mapname, pmap.pr_mapname, MAX_PATH);
    strcpy(s->mappath,"/proc/self/object/");
    strcat(s->mappath,pmap.pr_mapname);
    s->vaddr = (char *) pmap.pr_vaddr;

    /* This is a solaris oddity.  a.out section starts 1 page up, but
       symbols are relative to a base of 0 */

    if (strcmp(s->mapname,"a.out") == 0) s->base = 0;
    else s->base = s->vaddr;

    s->size  = pmap.pr_size;
    s->offset = pmap.pr_offset;
    s->flags  = pmap.pr_mflags;
    s++;
  }
  close(fd);
}

#endif

#ifdef WAD_LINUX

/* ------------- Linux Version ------------------ */

static
void read_segments() {
  FILE   *f;
  int     dz;
  int     offset = 0;
  int     i;
  int     n = 0;
  char    pbuffer[1024];
  char    *c;
  WadSegment *s;
  
  /* Try to load the virtual address map */
  f = fopen("/proc/self/maps", "r");
  if (!f) return;
  nsegments = 0;
  while (1) {
    if (fgets(pbuffer,1024,f) == NULL) break;
    nsegments++;
  }
  nsegments++;
  fclose(f);

  dz = open("/dev/zero", O_RDWR, 0644);
  if (dz < 0) {
    puts("Couldn't open /dev/zero\n");
    return;
  }
  segments = (WadSegment *) mmap(NULL, nsegments*sizeof(WadSegment), PROT_READ | PROT_WRITE, MAP_PRIVATE, dz, 0);
  close(dz);
  segments_size = nsegments*sizeof(WadSegment);
  
  f = fopen("/proc/self/maps","r");
  if (!f) return;
  i = 0;
  s = segments;
  while (1) {
    c = fgets(pbuffer,1024,f);
    if (!c) break;

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

    pbuffer[8] = 0;
    pbuffer[17] = 0;
    pbuffer[31] = 0;
    strcpy(s->mapname, pbuffer+49);
    strcpy(s->mappath, pbuffer+49);

    s->vaddr = (char *) strtoul(pbuffer,NULL,16);
    s->size = strtoul(pbuffer+9,NULL,16) - (long) (s->vaddr);
    s->offset = strtoul(pbuffer+23,NULL,16);
    s->base = s->vaddr;
    s->flags  = 0;
    s++;
  }
  fclose(f);
}

#endif

/* -----------------------------------------------------------------------------
 * wad_segment_release()
 *
 * This function releases all of the segments.
 * ----------------------------------------------------------------------------- */
void wad_segment_release() {
  munmap((void *)segments, segments_size);
  segments = 0;
  segments_size = 0;
  nsegments = 0;
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
wad_segment_find(char *addr) {
  int  i;
  WadSegment *s, *ls;

  if (!segments) read_segments();
  if (!segments) return 0;

  s = segments;
  ls = s;
  for (i = 0; i < nsegments; i++, s++) {
    if (strcmp(s->mapname,ls->mapname)) {
      ls = s;    /* First segment for a given name */
    }

    if ((addr >= s->vaddr) && (addr < (s->vaddr + s->size))) {
      return ls;
    }
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_segment_print()
 *
 * Print the contents of a memory segment. (For debugging WAD)
 * ----------------------------------------------------------------------------- */

void
wad_segment_print() {
  int i;
  WadSegment *s;
  if (!segments) {
    read_segments();
  }
  s = segments;
  for (i = 0; i < nsegments; i++, s++) {
    printf("Segment %x:::\n",s);
    printf("   mapname    = %s\n", s->mapname);
    printf("   mappath    = %s\n", s->mappath);
    printf("   vaddr      = 0x%x\n", s->vaddr);
    printf("   size       = %d\n", s->size);
    printf("   offset     = %d\n", s->offset);
    printf("   flags      = 0x%x\n", s->flags);
  }
}
