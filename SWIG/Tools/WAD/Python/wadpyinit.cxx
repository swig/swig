/* ----------------------------------------------------------------------------- 
 * wadpyinit.cxx
 *
 *     C++ automatic initializer for Python module.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 2001
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * ----------------------------------------------------------------------------- */

#include "wad.h"

extern "C" void pywadinit();

/* This hack is used to auto-initialize wad regardless of whether we are
   used as an imported module or as a link-library for another module */
   
class wadinitializer {
public:
  wadinitializer() {
    pywadinit();
  }
};

static wadinitializer wi;


