/* ----------------------------------------------------------------------------- 
 * segment_linux.c
 *
 *      This file reads the virtual memory map on Linux machines.  
 *      This file is not compiled directly, it is included in the
 *      segment.c file.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static
WadSegment *wad_segment_read() {
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
  if (!f) return 0;
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
    return 0;
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
    s++;
  }
  fclose(f);
  return segments;
}

/* -----------------------------------------------------------------------------
 * wad_segment_release()
 *
 * This function releases all of the segments.
 * ----------------------------------------------------------------------------- */

void 
wad_segment_release() {
  munmap((void *)segments, segments_size);
  segments = 0;
  segments_size = 0;
  nsegments = 0;
}
