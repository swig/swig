/* ----------------------------------------------------------------------------- 
 * object.c
 *
 *     This file provides access to raw object files, executables, and
 *     library files.  Memory management is handled through mmap() to
 *     avoid the use of heap/stack space.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"
#include <ar.h>


/* Maximum number of files that can be loaded at once */
   
#define WAD_MAX_FILE         32

typedef struct WadFile {
  int     refcnt; 
  void   *addr;
  int     size;
  char    path[MAX_PATH];
} WadFile;

static WadFile      wad_files[WAD_MAX_FILE];    /* Array of file objects */

/* private function to manage the loading of raw files into memory */

static WadFile *
load_file(const char *path) {
  int i;
  int fd;
  WadFile *firstfree = 0;
  WadFile *firstreplace = 0;
  WadFile *wf = wad_files;

  if (wad_debug_mode & DEBUG_FILE) {
    printf("wad: Loading file     '%s' ... ", path);
  }
  /* Walk through the file list to see if we already know about the file */
  for (i = 0; i < WAD_MAX_FILE; i++, wf++) {
    if (strcmp(wf->path, path) == 0) {
      wf->refcnt++;
      if (wad_debug_mode & DEBUG_FILE) {
	printf("cached.\n");
      }
      return wf;
    }
    if (wf->refcnt <= 0) {
      if (wf->path[0] == 0) firstfree = wf;
      else firstreplace = wf;
    }
  }
  
  if (!firstfree && !firstreplace) {
    if (wad_debug_mode & DEBUG_FILE) printf("out of memory!\n");
    return 0;  /* Out of space */
  }

  if (!firstfree) firstfree = firstreplace;

  fd = open(path, O_RDONLY);
  if (fd < 0) {
    if (wad_debug_mode & DEBUG_FILE) printf("not found!\n");
    return 0;       /* Doesn't exist. Oh well */
  }
  if (wad_debug_mode & DEBUG_FILE) printf("loaded.\n");
  /* If already mapped, unmap the file */
  if (firstfree->addr) {
    if (wad_debug_mode & DEBUG_FILE) 
      printf("wad: Unloading file '%s'\n", firstfree->path);
    munmap(firstfree->addr,firstfree->size);
  }

  firstfree->refcnt = 1;  
  strncpy(firstfree->path,path,MAX_PATH);

  /* Get file length */
  firstfree->size = lseek(fd,0,SEEK_END);
  lseek(fd,0,SEEK_SET);
  
  /* Try to mmap the file */
  firstfree->addr = mmap(NULL,firstfree->size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, fd, 0);
  close(fd);
  if (firstfree->addr == MAP_FAILED) {
    if (wad_debug_mode & DEBUG_FILE) printf("wad: Couldn't mmap '%s'\n", path);
    firstfree->refcnt = 0;
    firstfree->path[0] = 0;
    firstfree->addr = 0;
    firstfree->size = 0;
    return 0;
  }
  return firstfree;
}

static void
release_file(WadFile *f) {
  if (wad_debug_mode & DEBUG_FILE) printf("wad: Releasing file   '%s'\n", f->path);
  f->refcnt--;
}

#define WAD_MAX_OBJECT       32

static WadObjectFile wad_objects[WAD_MAX_OBJECT];   /* Object file descriptor table */
static int           wad_obj_free[WAD_MAX_OBJECT];  /* Free object stack */
static int           wad_obj_nfree = 0;             /* Num free object descriptors */


/* -----------------------------------------------------------------------------
 * wad_object_init()
 *
 * Initialize the object file system
 * ----------------------------------------------------------------------------- */

void wad_object_init() {
  int i;

  for (i = 0; i < WAD_MAX_FILE; i++) {
    wad_files[i].refcnt = 0;
    wad_files[i].addr = 0;
    wad_files[i].size = 0;
    wad_files[i].path[0] = 0;
  }

  wad_obj_nfree = 0;
  for (i = 0; i < WAD_MAX_OBJECT; i++) {
    wad_objects[i].ptr = 0;
    wad_objects[i].len = 0;
    wad_objects[i].refcnt = 0;
    wad_objects[i].path[0] = 0;
    wad_obj_free[i] = i;
    wad_obj_nfree++;
  }
} 

/* -----------------------------------------------------------------------------
 * wad_object_cleanup()
 *
 * Release all files loaded during the debugging
 * ----------------------------------------------------------------------------- */

void
wad_object_cleanup() {
  int i;
  WadFile *f = wad_files;
  if (wad_debug_mode & DEBUG_OBJECT) {
    printf("wad: Releasing all files.\n");
  }
  for (i = 0; i < WAD_MAX_FILE; i++, f++) {
    if (f->addr) {
      munmap(f->addr, f->size);
    }
    f->addr = 0;
    f->size = 0;
    f->path[0] = 0;
    f->refcnt = 0;
  }
}

/* -----------------------------------------------------------------------------
 * wad_object_release()
 *
 * Done with the object.
 * ----------------------------------------------------------------------------- */

void
wad_object_release(WadObjectFile *wo) {
  int n;
  if (!wo) return;

  wo->refcnt--;
  if (wo->refcnt > 0) return;
  if (wad_debug_mode & DEBUG_OBJECT) {
    printf("wad: Releasing object '%s'\n", wo->path);
  }
  release_file(wo->file);
  wo->file = 0;
  wo->ptr = 0;
  wo->len = 0;
  wo->path[0] = 0;
  n = wo - wad_objects;
  wad_obj_free[wad_obj_nfree++] = n;
}

/* -----------------------------------------------------------------------------
 * wad_object_load()
 * 
 * Load an object file into memory using mmap.   Returns 0 if the object does
 * not exist or if there are no more object descriptor slots
 * ----------------------------------------------------------------------------- */

WadObjectFile *
wad_object_load(const char *path) {
  WadObjectFile *wo;
  WadFile *wf;
  int i;
  WadObjectFile  *wad_arobject_load(const char *path, const char *name);

  if (wad_debug_mode & DEBUG_OBJECT) {
    printf("wad: Loading object   '%s'\n", path);
  }
  /* See if the path has already been loaded */
  for (i = 0; i < WAD_MAX_OBJECT; i++) {
    if (strcmp(wad_objects[i].path,path) == 0) {
      wo = &wad_objects[i];
      wo->refcnt++;
      return wo;
    }
  }
  if (wad_obj_nfree == 0) {
    if (wad_debug_mode & DEBUG_OBJECT)
      printf("wad: No more space in wad_object_load()\n");
    return 0;
  }

  /* If this is an archive reference like /path/libfoo.a(blah.o), we need to
     split up the name a little bit */
  {
    char realfile[MAX_PATH];
    char *objfile;
    char *c;
    c = strchr(path,'(');
    if (c) {
      strcpy(realfile,path);
      c = strchr(realfile,'(');
      *c = 0;
      objfile = c+1;
      c = strchr(objfile,')');
      *c = 0;
      
      /* Okay, I'm going to attempt to map this as a library file */
      wo = wad_arobject_load(realfile,objfile);
      if (wo) {
	strncpy(wo->path, path, MAX_PATH);
	return wo;
      }
    }
  }
  wf = load_file(path);
  if (!wf) return 0;

  wo = wad_objects + wad_obj_free[wad_obj_nfree-1];
  wad_obj_nfree--;

  wo->file = wf;
  wo->refcnt = 1;
  strncpy(wo->path,path, MAX_PATH);
  wo->ptr = wf->addr;
  wo->len = wf->size;
  return wo;
}

/* -----------------------------------------------------------------------------
 * wad_arobject_load()
 * 
 * Load an archive file object into memory using mmap.
 * ----------------------------------------------------------------------------- */

WadObjectFile *
wad_arobject_load(const char *arpath, const char *robjname) {
  WadObjectFile *wo;
  WadFile       *wf;
  int nf;
  int fd;
  int i;
  int arlen;
  char *arptr;
  struct ar_hdr  *ah;
  int offset;
  int msize;
  char *strtab = 0;
  int   sobjname;
  char  objname[MAX_PATH];

  strcpy(objname,robjname);
  strcat(objname,"/");
  sobjname = strlen(objname);

  wf = load_file(arpath);
  if (!wf) return 0;          /* Doesn't exit */

  arptr = (char *) wf->addr;
  arlen = wf->size;

  nf = wad_obj_free[wad_obj_nfree-1];
  wo = wad_objects + nf;
  wad_obj_nfree--;
  wo->refcnt = 1;
  wo->ptr = 0;

  /* Now take a look at the archive */
  if (strncmp(arptr,ARMAG,SARMAG) == 0) {
    /* printf("Got an archive\n"); */
  } else {
    /* Not an archive file */
    release_file(wf);
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
	release_file(wf);
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
      
      wo = wad_objects + wad_obj_free[wad_obj_nfree-1];
      wad_obj_nfree--;
      wo->file = wf;
      wo->refcnt = 1;
      wo->ptr = (void *) (arptr + offset);
      wo->len = msize;
      return wo;
    }
    offset += msize;
  }
  release_file(wf);
  return 0;
}

