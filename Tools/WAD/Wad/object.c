/* ----------------------------------------------------------------------------- 
 * object.c
 *
 *     This file provides access to raw object files and executables.
 *     All memory management is done through mmap() to avoid the
 *     use of malloc()/free()
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "wad.h"
#include <sys/mman.h>
#include <ar.h>
#include <string.h>
#include <ctype.h>

static WadObject wad_objects[WAD_MAX_OBJECT];   /* Object file descriptor table */
static int       wad_obj_free[WAD_MAX_OBJECT];  /* Free object stack */
static int       wad_obj_nfree = 0;             /* Num free object descriptors */
static int       wad_obj_init = 0;              /* Initialized? */

/* Initialize internal memory management */
static void
init_object() {
  int i;
  if (wad_obj_init) return;
  for (i = 0; i < WAD_MAX_OBJECT; i++) {
    wad_objects[i].mptr = 0;
    wad_objects[i].mlen = 0;
    wad_objects[i].ptr = 0;
    wad_objects[i].len = 0;
    wad_objects[i].refcnt = 0;
    wad_objects[i].path[0] = 0;
    wad_obj_free[i] = i;
    wad_obj_nfree++;
  }
  wad_obj_init = 1;
} 

/* -----------------------------------------------------------------------------
 * wad_object_release()
 *
 * Done with the object.
 * ----------------------------------------------------------------------------- */

void
wad_object_release(WadObject *wo) {
  int n;
  if (!wo) return;
  wo->refcnt--;
  if (wo->refcnt > 0) return;
  if (wo->mptr) {
    munmap(wo->mptr, wo->mlen);
  }
  wo->mptr = 0;
  wo->mlen = 0;
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

WadObject *
wad_object_load(const char *path) {
  WadObject *wo;
  int nf;
  int fd;
  int i;
  if (!wad_obj_init) init_object();

  /*  printf("loading '%s'\n", path); */

  /* See if the path has already been loaded */
  for (i = 0; i < WAD_MAX_OBJECT; i++) {
    if (strcmp(wad_objects[i].path,path) == 0) {
      wo = &wad_objects[i];
      wo->refcnt++;
      return wo;
    }
  }
  if (wad_obj_nfree == 0) {
    printf("wad_object_load: No more space!\n");
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

  /* Try to open the requested pathname */
  fd = open(path, O_RDONLY);
  if (fd < 0) return 0;       /* Doesn't exist */

  nf = wad_obj_free[wad_obj_nfree-1];
  wo = wad_objects + nf;
  wad_obj_nfree--;

  wo->refcnt = 1;
  strncpy(wo->path,path, MAX_PATH);
  wo->mlen = lseek(fd,0,SEEK_END);    /* Get length of the file */
  lseek(fd,0,SEEK_SET);
  
  /* Try to mmap the file */
  wo->mptr = mmap(NULL,wo->mlen, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, fd, 0);
  if (wo->mptr == MAP_FAILED) {
    perror("Whoa. Can't mmap.");
    wo->mptr = 0;
    wad_object_release(wo);
    close(fd);
    return 0;
  }
  close(fd);
  wo->ptr = wo->mptr;
  wo->len = wo->mlen;
  return wo;
}

/* -----------------------------------------------------------------------------
 * wad_arobject_load()
 * 
 * Load an archive file object into memory using mmap.
 * ----------------------------------------------------------------------------- */

WadObject *
wad_arobject_load(const char *arpath, const char *robjname) {
  WadObject *wo;
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
  if (!wad_obj_init) init_object();

  if (wad_obj_nfree == 0) {
    printf("wad_object_load: No more space!\n");
    return 0;
  }

  /* Try to open the requested archive name */
  fd = open(arpath, O_RDONLY);
  if (fd < 0) return 0;       /* Doesn't exist */

  nf = wad_obj_free[wad_obj_nfree-1];
  wo = wad_objects + nf;
  wad_obj_nfree--;
  wo->refcnt = 1;
  wo->ptr = 0;

  arlen = lseek(fd,0,SEEK_END);    /* Get length of the file */
  lseek(fd,0,SEEK_SET);
  
  /* Try to mmap the file */
  arptr = (char *) mmap(NULL,arlen, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE, fd, 0);
  if (arptr == MAP_FAILED) {
    perror("Whoa. Can't mmap.");
    close(fd);
    return 0;
  }

  /* Now take a look at the archive */
  if (strncmp(arptr,ARMAG,SARMAG) == 0) {
    /* printf("Got an archive\n"); */
  } else {
    printf("Not an archive file\n");
    goto fatal_error;
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
	printf("Whoa. No string offset table\n"); 
	goto fatal_error;
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
    
    /*    printf("ar_name = '%s', ar_size = '%0.10s'\n", mname, ah->ar_size); */
    /* Compare the names */
    if (strncmp(mname,objname,sobjname) == 0) {
      /* Leave the archive mapped in memory, but set a pointer to the member
         name */

      wo->mptr = (void *) arptr;
      wo->mlen = arlen;
      wo->ptr = (void *) (arptr + offset);
      wo->len = msize;
      close(fd);
      return wo;
      break;
    }

    offset += msize;
  }
  
 fatal_error:
  munmap(arptr,arlen);
  close(fd);
  wad_object_release(wo);
  return 0;
  
}

