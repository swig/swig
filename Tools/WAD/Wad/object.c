/* ----------------------------------------------------------------------------- 
 * object.c
 *
 *     This file provides access to raw object files, executables, and
 *     library files.  Memory management is handled through mmap() to
 *     avoid the use of heap/stack space.
 *
 *     All of the files and objects created by this module persist
 *     until the process exits.  Since WAD may be invoked multiple times
 *     over the course of program execution, it makes little sense to keep
 *     loading and unloading files---subsequent invocations of the handler
 *     can simply used previously loaded copies.  Caveat: things probably
 *     won't work right if a program is doing lots of low-level manipulation
 *     of the dynamic loader.
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

#include <ar.h>

typedef struct WadFile {
  void   *addr;                /* Base address of the file */
  int     size;                /* Size in bytes            */
  char   *path;                /* Path name                */
  struct  WadFile *next;       /* Next file                */
} WadFile;

static WadFile     *wad_files = 0;              /* Linked list of loaded files */

/* private function to manage the loading of raw files into memory */
static WadFile *
load_file(const char *path) {
  int fd;
  WadFile *wf = wad_files;

  if (wad_debug_mode & DEBUG_FILE) {
    wad_printf("wad: Loading file     '%s' ... ", path);
  }
  while (wf) {
    if (strcmp(wf->path,path) == 0) {
      if (wad_debug_mode & DEBUG_FILE) wad_printf("cached.\n");
      return wf;
    }
    wf = wf->next;
  }
  fd = open(path, O_RDONLY);
  if (fd < 0) {
    if (wad_debug_mode & DEBUG_FILE) wad_printf("not found!\n");
    return 0;       /* Doesn't exist. Oh well */
  }
  if (wad_debug_mode & DEBUG_FILE) wad_printf("loaded.\n");
  wf = (WadFile *) wad_malloc(sizeof(WadFile));
  wf->path = wad_strdup(path);

  /* Get file length */
  wf->size = lseek(fd,0,SEEK_END);
  lseek(fd,0,SEEK_SET);
  
  /* Try to mmap the file */
  wf->addr = mmap(NULL,wf->size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, fd, 0);
  close(fd);
  if (wf->addr == MAP_FAILED) {
    if (wad_debug_mode & DEBUG_FILE) wad_printf("wad: Couldn't mmap '%s'\n", path);
    return 0;
  }
  wf->next = wad_files;
  wad_files = wf;
  return wf;
}

static WadObjectFile *wad_objects = 0;              /* Linked list of object files */

/* -----------------------------------------------------------------------------
 * wad_object_cleanup()
 *
 * Reset the object file loader.  This unmaps the files themselves, but
 * memory will leak for object files pointers themselves. 
 * ----------------------------------------------------------------------------- */

void
wad_object_reset() {
  WadFile *f = wad_files;
  if (wad_debug_mode & DEBUG_OBJECT) {
    wad_printf("wad: Releasing all files.\n");
  }
  /* Unmap all of the loaded files */
  while (f) {
    if (f->addr) {
      munmap(f->addr, f->size);
    }
    f = f->next;
  }
  /* Reset the linked lists */
  wad_files = 0;
  wad_objects = 0;
}

/* -----------------------------------------------------------------------------
 * wad_object_load()
 * 
 * Load an object file into memory using mmap.   Returns 0 if the object does
 * not exist or if we're out of memory.
 * ----------------------------------------------------------------------------- */

WadObjectFile *
wad_object_load(const char *path) {
  WadObjectFile *wo;
  WadFile *wf;
  WadObjectFile  *wad_arobject_load(const char *path, const char *name);

  if (wad_debug_mode & DEBUG_OBJECT) {
    wad_printf("wad: Loading object   '%s'", path);
  }
  for (wo = wad_objects; wo; wo=wo->next) {
    if (strcmp(wo->path,path) == 0) {
      if (wad_debug_mode & DEBUG_OBJECT) {
	wad_printf(" (cached)\n");
      }
      return wo;
    }
  }
  if (wad_debug_mode & DEBUG_OBJECT) {
    wad_printf("\n");
  }
  /* Didn't find it.  Now we need to go load some files */

  /* If this is an archive reference like /path/libfoo.a(blah.o), we need to
     split up the name a little bit */
  {
    char realfile[MAX_PATH];
    char *objfile;
    char *c;
    c = strchr(path,'(');
    if (c) {
      wad_strcpy(realfile,path);
      c = strchr(realfile,'(');
      *c = 0;
      objfile = c+1;
      c = strchr(objfile,')');
      *c = 0;
      
      /* Okay, I'm going to attempt to map this as a library file */
      wo = wad_arobject_load(realfile,objfile);
      if (wo) {
	/* Reset the path */
	wo->path = wad_strdup(path);
	wo->next = wad_objects;
	wad_objects = wo;
	return wo;
      }
    }
  }
  wf = load_file(path);
  if (!wf) return 0;

  wo = (WadObjectFile *) wad_malloc(sizeof(WadObjectFile));
  wo->path = wad_strdup(path);
  wo->ptr = wf->addr;
  wo->len = wf->size;
  wo->next = wad_objects;
  wad_objects = wo;
  return wo;
}

/* -----------------------------------------------------------------------------
 * wad_arobject_load()
 * 
 * Load an object file stored in an archive file created with an archive.  The
 * pathname should be the path of the .a file and robjname should be the name
 * of the object file stored in the object file.
 * ----------------------------------------------------------------------------- */

WadObjectFile *
wad_arobject_load(const char *arpath, const char *robjname) {
  WadObjectFile *wo;
  WadFile       *wf;
  int arlen;
  char *arptr;
  struct ar_hdr  *ah;
  int offset;
  int msize;
  char *strtab = 0;
  int   sobjname;
  char  objname[MAX_PATH];

  wad_strcpy(objname,robjname);
  wad_strcat(objname,"/");
  sobjname = strlen(objname);

  wf = load_file(arpath);
  if (!wf) return 0;          /* Doesn't exit */

  arptr = (char *) wf->addr;
  arlen = wf->size;

  /* Now take a look at the archive */
  if (strncmp(arptr,ARMAG,SARMAG) == 0) {
    /* printf("Got an archive\n"); */
  } else {
    return 0;
  }

  /* Search the archive for the request member */
  strtab = 0;
  offset = SARMAG;
  while (offset < arlen) {
    char mname[MAX_PATH];
    ah = (struct ar_hdr *) (arptr + offset);
    if (strncmp(ah->ar_name,"// ", 3) == 0) {
      strtab = arptr + offset + sizeof(struct ar_hdr);
    }
    msize = atoi(ah->ar_size);    

    offset += sizeof(struct ar_hdr);
    /* Try to figure out the filename */
    if ((ah->ar_name[0] == '/') && (isdigit(ah->ar_name[1]))) {
      int soff;
      char *e;
      /* Must be in the string offset table */
      soff = atoi(ah->ar_name+1);
      if (!strtab) {
	/* No offset table */
	return 0;
      }
      e = strchr(strtab+soff,'\n');
      if (e) {
	strncpy(mname, strtab+soff, (e - (strtab+soff)));
	mname[e-(strtab+soff)] = 0;
      } else {
	mname[0] = 0;
      }
    } else {
      /* Name must be in the name field */
      strncpy(mname,ah->ar_name,16);
      mname[16] = 0;
    }
    /* Compare the names */
    if (strncmp(mname,objname,sobjname) == 0) {
      /* Found the archive */
      wo = (WadObjectFile *) wad_malloc(sizeof(WadObjectFile));
      wo->ptr = (void *) (arptr + offset);
      wo->len = msize;
      wo->path = 0;
      return wo;
    }
    offset += msize;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * wad_find_object(WadFrame *f)
 *
 * Given a stack frame.  Try to locate the object file
 * ----------------------------------------------------------------------------- */

void wad_find_object(WadFrame *f) {
  if (f->segment) {
    f->object = wad_object_load(f->segment->mappath);
  }
}

/* -----------------------------------------------------------------------------
 * wad_file_check(void *addr)
 *
 * Given an address, this function checks to see if it corresponds to a file
 * we already mapped.
 * ----------------------------------------------------------------------------- */

int
wad_file_check(void *addr) {
  WadFile *f = wad_files;
  while (f) {
    if ((((char *) f->addr) <= ((char *) addr)) && 
	(((char *) addr) < (((char *) f->addr) + f->size))) {
      return 1;
    }
    f = f->next;
  }
  return 0;
}
