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
#include <procfs.h>



/* The current segment is stored in statically allocated memory to avoid
   the use of malloc()/free().  If a caller wants to make a copy, that is
   their problem */

static WadSegment segment;              /* Currently loaded segment */
static int        read_segment = 0;

/* -----------------------------------------------------------------------------
 * wad_segment_print()
 *
 * Print the contents of a memory segment. (Debugging)
 * ----------------------------------------------------------------------------- */

void
wad_segment_print(WadSegment *s) {
    printf("Segment %x:::\n",s);
    printf("   mapname    = %s\n", s->mapname);
    printf("   mappath    = %s\n", s->mappath);
    printf("   vaddr      = 0x%x\n", s->vaddr);
    printf("   size       = %d\n", s->size);
    printf("   offset     = %d\n", s->offset);
    printf("   flags      = 0x%x\n", s->flags);
    printf("   identifier = %d\n", s->identifier);
}


/* -----------------------------------------------------------------------------
 * wad_segment_find()
 *
 * Try to find the virtual memory segment corresponding to a virtual address.
 * This overwrites the previously returned segment data.
 * ----------------------------------------------------------------------------- */

WadSegment *
wad_segment_find(wadaddr_t addr) {
  char dirname[MAX_PATH];
  char filename[MAX_PATH];
  int  fd;
  prmap_t pmap;
  int  offset = 0;
  int  i;
  int  n;

  if (read_segment) {
    if ((addr >= segment.vaddr) && (addr < (segment.vaddr+segment.size))) return &segment;
  }
  
  /* Set location in /proc */
  sprintf(dirname,"/proc/%d",getpid());
  
  /* Try to load the virtual address map */
  sprintf(filename,"%s/map",dirname);
  fd = open(filename, O_RDONLY);
  if (fd < 0) {
    printf("wad_segment_find: couldn't open '%s'\n", filename);
    return 0;
  }
  
  segment.mapname[0] = 0;

  read_segment = 0;
  while (1) {
    n = read(fd,&pmap,sizeof(prmap_t));
    if (n <= 0) break;
    offset += n;
    if ((addr >= (wadaddr_t) pmap.pr_vaddr) && (addr <= (wadaddr_t) (pmap.pr_vaddr + pmap.pr_size))) {
      /* We are in a new segment */
      strncpy(segment.mapname, pmap.pr_mapname, MAX_PATH);
      strcpy(segment.mappath,dirname);
      strcat(segment.mappath,"/object/");
      strcat(segment.mappath,pmap.pr_mapname);
      segment.vaddr = (wadaddr_t) pmap.pr_vaddr;
      segment.size  = pmap.pr_size;
      segment.offset = pmap.pr_offset;
      segment.flags  = pmap.pr_mflags;
      segment.identifier = pmap.pr_shmid;
      segment.wad = offset;
      read_segment = 1;
      close(fd);
      return &segment;
    }
  } 
  close(fd);
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_segment_next()
 *
 * Read the next segment
 * ----------------------------------------------------------------------------- */

WadSegment *wad_segment_next() {

  char dirname[MAX_PATH];
  char filename[MAX_PATH];
  int  fd;
  prmap_t pmap;
  int  offset = 0;
  int  i;
  int  n;

  if (!read_segment) {
    segment.wad = 0;
  }

  /* Set location in /proc */
  sprintf(dirname,"/proc/%d",getpid());
  
  /* Try to load the virtual address map */
  sprintf(filename,"%s/map",dirname);
  fd = open(filename, O_RDONLY);
  if (fd < 0) {
    printf("wad_segment_find: couldn't open '%s'\n", filename);
    return 0;
  }
  if (lseek(fd, segment.wad, SEEK_SET) < 0) {
    close(fd);
    return 0;
  }
  n = read(fd,&pmap,sizeof(prmap_t));
  if (n <= 0) {
    read_segment = 0;
    close(fd);
    return 0;
  }
  strncpy(segment.mapname, pmap.pr_mapname, MAX_PATH);
  strcpy(segment.mappath,dirname);
  strcat(segment.mappath,"/object/");
  strcat(segment.mappath,pmap.pr_mapname);
  segment.vaddr = (wadaddr_t) pmap.pr_vaddr;
  segment.size  = pmap.pr_size;
  segment.offset = pmap.pr_offset;
  segment.flags  = pmap.pr_mflags;
  segment.identifier = pmap.pr_shmid;
  segment.wad += n;
  read_segment = 1;
  close(fd);
  return &segment;
}

WadSegment *
wad_segment_first() {
  segment.wad = 0;
  read_segment = 0;
  return wad_segment_next();
}
