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

WadSegment *
wad_segment_read() {
  int     fd;
  int     dz;
  int     offset = 0;
  int     i;
  int     n = 0;
  int     nsegments;
  WadSegment *segments;
  WadSegment *s;
  prmap_t pmap;

  /* Try to load the virtual address map */
  fd = open("/proc/self/map", O_RDONLY);
  if (fd < 0) {
    return 0;
  }
  nsegments = 0;
  while (1) {
    n = read(fd,&pmap,sizeof(prmap_t));
    if (n <= 0) break;
    nsegments++;
  }
  nsegments+=3;
  close(fd);

  dz = open("/dev/zero", O_RDWR, 0644);
  if (dz < 0) {
    puts("Couldn't open /dev/zero\n");
    return 0;
  }
  segments = (WadSegment *) mmap(NULL, nsegments*sizeof(WadSegment), PROT_READ | PROT_WRITE, MAP_PRIVATE, dz, 0);
  close(dz);
  
  fd = open("/proc/self/map", O_RDONLY);
  if (fd < 0) return;
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
    s++;
  }
  /* Create sentinel */
  s->base = 0;
  s->vaddr = 0;
  s->size = 0;
  s->offset = 0;
  s->mapname[0] =0;
  s->mappath[0] = 0;
  close(fd);
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
