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
    strcpy(linux_firstsegment, s->mappath);
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


