/* ----------------------------------------------------------------------------- 
 * return.c
 *
 *     This file manages the set of return-points for the WAD signal handler.
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

/* Maximum number of return points */
#define WAD_NUMBER_RETURN  128

static WadReturnFunc return_points[WAD_NUMBER_RETURN];
static int           num_return = 0;

void wad_set_return(const char *name, long value) {
  WadReturnFunc *rp;
  rp = &return_points[num_return];
  wad_strcpy(rp->name,name);
  rp->value = value;
  num_return++;
  if (wad_debug_mode & DEBUG_RETURN) {
    printf("wad: Setting return ('%s', %d)\n", name,value);
  }
}

void wad_set_returns(WadReturnFunc *rf) {
  int i = 0;
  while (strlen(rf[i].name)) {
    wad_set_return(rf[i].name, rf[i].value);
    i++;
  }
}

WadReturnFunc *wad_check_return(const char *name) {
  int i;
  if (!name) return 0;
  for (i = 0; i < num_return; i++) {
    if (strcmp(name,return_points[i].name) == 0) {
      if (wad_debug_mode & DEBUG_RETURN) {
	printf("wad: Found return ('%s', %d)\n", return_points[i].name, return_points[i].value);
      }
      return &return_points[i];
    }
  }
  return 0;
}

