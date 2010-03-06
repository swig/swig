/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * warn.c
 *
 * SWIG warning framework.  This was added to warn developers about 
 * deprecated APIs and other features.
 * ----------------------------------------------------------------------------- */

char cvsroot_warn_c[] = "$Id$";

#include "swig.h"

static Hash *warnings = 0;

/* -----------------------------------------------------------------------------
 * Swig_warn()
 * 
 * Issue a warning
 * ----------------------------------------------------------------------------- */

void Swig_warn(const char *filename, int line, const char *msg) {
  String *key;
  if (!warnings) {
    warnings = NewHash();
  }
  key = NewStringf("%s:%d", filename, line);
  if (!Getattr(warnings, key)) {
    Printf(stderr, "swig-dev warning:%s:%d:%s\n", filename, line, msg);
    Setattr(warnings, key, key);
  }
  Delete(key);
}
