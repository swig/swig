/* ----------------------------------------------------------------------------- 
 * memory.c
 *
 *     This file provides simple mmap() based memory management for WAD.  Since
 *     the process heap-allocator might be corrupted when WAD is invoked, we
 *     have to do all of our own memory management.  However, since WAD mostly
 *     just collects data, we only provide the function wad_malloc().  To
 *     release all allocated memory, the wad_release_memory() function should
 *     be used.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2001.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"

typedef struct _WadMemory {
  int                npages;          /* Number of pages            */
  int                last;            /* Last offset in page        */ 
  struct _WadMemory *next;            /* Pointer to next allocation */
} WadMemory;

static WadMemory *current = 0;                /* Current memory block        */
static WadMemory *persistent = 0;             /* Persistent memory data      */
static int        pagesize = 0;               /* System page size            */
static int        devzero = 0;
static int        npalloc = 8;                 /* Number of pages per alloc   */

/* -----------------------------------------------------------------------------
 * wad_memory_init()
 *
 * Initialize the WAD allocator.
 * ----------------------------------------------------------------------------- */

int wad_memory_init() {
  pagesize = getpagesize();
  devzero = open("/dev/zero", O_RDWR);
  if (devzero < 0) {
    wad_printf("WAD: couldn't open /dev/zero.\n");
    return -1;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_page_alloc()
 *
 * Allocate pages using mmap
 * ----------------------------------------------------------------------------- */

void *wad_page_alloc(int npages) {
  void *m;
  m = mmap(NULL, npages*pagesize, PROT_READ | PROT_WRITE, MAP_PRIVATE, devzero, 0);
  if (((long) m) == -1) return 0;
  return m;
}

/* -----------------------------------------------------------------------------
 * wad_malloc()
 *
 * Allocate memory using mmap().   If the allocation is smaller than half a page,
 * We'll look at current to see if there is enough space.  If so, we'll just
 * use that memory.  Otherwise, we'll allocate a new page.  If the allocation
 * request is larger than a page, we'll round up to the nearest page size and
 * do a special allocation.
 * ----------------------------------------------------------------------------- */

void *wad_malloc(int nbytes) {
  void *ptr;
  WadMemory *wm;
  char      *c;
  int npages;
  /*  wad_printf("wad_malloc: %d\n", nbytes); */
  if (nbytes >= ((npalloc*pagesize) >> 2)) {
    /* Large allocation. */
    npages = ((nbytes + sizeof(WadMemory))/pagesize) + 1;
    ptr = wad_page_alloc(npages);
    if (!ptr) return 0;
    wm = (WadMemory *)ptr;
    wm->npages = npages;
    wm->last = sizeof(WadMemory) + 8;
    wm->next = current;
    current = wm;
    c = (char *) current + (current->last);
    current->last += ((nbytes & ~0x7) + 8);
    return c;
  }
  /* Small allocation.  See if there are any regions big enough */
  wm = current;
  while (wm) {
    if (((wm->npages*pagesize) - wm->last) > nbytes) {
      /* Yep. Found a region */
      break;
    }
    wm = wm->next;
  }
  if (!wm) {
    /*    wad_printf("wad_malloc: new page\n", nbytes);*/
    wm = (WadMemory *) wad_page_alloc(npalloc);
    if (!wm) return 0;
    wm->npages = npalloc;
    wm->last = sizeof(WadMemory);
    wm->next = current;
    current = wm;
  }
  c = ((char *) wm) + (wm->last);
  wm->last += ((nbytes & ~0x7) + 8);
  return c;
}  

/* -----------------------------------------------------------------------------
 * wad_release_memory()
 *
 * Releases all memory previously allocated by wad_malloc().  This is inherently
 * dangerous.
 * ----------------------------------------------------------------------------- */

void wad_release_memory() {
  WadMemory *wm, *next;

  return;
  wm = current;
  while (wm) {
    next = wm->next;
    munmap((char *) wm, wm->npages*pagesize);
    wm = next;
  }
  current = 0;
}    

/* -----------------------------------------------------------------------------
 * wad_strdup()
 *
 * Duplicate a string 
 * ----------------------------------------------------------------------------- */

char *wad_strdup(const char *c) {
  char *t;
  if (!c) c = "";
  t = (char *) wad_malloc(strlen(c)+1);
  strcpy(t,c);
  return t;
}

/* -----------------------------------------------------------------------------
 * wad_memory_debug()
 * ----------------------------------------------------------------------------- */

void wad_memory_debug() {
  int   total_alloc = 0;
  int   inuse = 0;
  WadMemory *m;
  if (wad_debug_mode & DEBUG_MEMORY) {
    m = current;
    while (m) {
      total_alloc += (m->npages)*pagesize;
      inuse += m->last;
      m = m->next;
    }
    printf("WAD: memory allocated %d bytes (%d bytes used).\n", total_alloc, inuse);
  }
}
