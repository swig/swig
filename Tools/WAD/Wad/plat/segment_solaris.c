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
