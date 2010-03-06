/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * DoxygenParser.h
 * ----------------------------------------------------------------------------- */

#ifndef DOXYGENPARSER_H_
#define DOXYGENPARSER_H_
#include <string>
#include <list>
#include "DoxygenEntity.h"
class DoxygenParser {
public:
  DoxygenParser();
  virtual ~DoxygenParser();
  std::list < DoxygenEntity > createTree(std::string doxygen);
};

#endif
