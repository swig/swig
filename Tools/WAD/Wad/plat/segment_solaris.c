/* ----------------------------------------------------------------------------- 
 * segment_solaris.c
 *
 *      This file reads the virtual memory map on Solaris machines.  
 *      This file is not compiled directly, it is included in the
 *      segment.c file.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */


static FILE *
segment_open() {
  FILE *f;
  f = fopen("/proc/self/map", "r");
  return f;
}

static int
segment_read(FILE *fs, WadSegment *s) {
  int     dz;
  int     n;
  prmap_t pmap;

  n = fread(&pmap, sizeof(prmap_t), 1, fs);
  if (n <= 0) return 0;
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
  return 1;
}
