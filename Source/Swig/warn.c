/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * warn.c
 *
 * SWIG warning framework.  This was added to warn developers about 
 * deprecated APIs and other features.
 * ----------------------------------------------------------------------------- */

char cvsroot_warn_c[] = "$Header$";

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
