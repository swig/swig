
/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * kotlin_native.cxx
 *
 * Kotlin/Native language module for SWIG.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include <limits.h>
#include "cparse.h"
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>


class KOTLIN_NATIVE:public Language {
public:
  KOTLIN_NATIVE() {
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {
    SWIG_library_directory("kotlin_native");
    Preprocessor_define("SWIGKOTLINNATIVE 1", 0);
    SWIG_typemap_lang("kotlin_native");
    //SWIG_config_file("kotlin_native.swg");
  }



  /* ------------------------------------------------------------
   * top()
   * ------------------------------------------------------------ */

  /*virtual int top(Node *n) {

  }*/

};


/* -----------------------------------------------------------------------------
 * swig_kotlin_native()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_kotlin_native() {
  return new KOTLIN_NATIVE();
}
extern "C" Language *swig_kotlin_native(void) {
  return new_swig_kotlin_native();
}
