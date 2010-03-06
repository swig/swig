/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * Token.cpp
 * ----------------------------------------------------------------------------- */

#include "Token.h"
#include "DoxygenEntity.h"
using namespace std;


Token::Token(int tType, string tString) {
  tokenType = tType;
  tokenString = tString;
}

string Token::toString() {
  if (tokenType == END_LINE) {
    return "{END OF LINE}";
  }
  if (tokenType == PARAGRAPH_END) {
    return "{END OF PARAGRAPH}";
  }
  if (tokenType == PLAINSTRING) {
    return "{PLAINSTRING :" + tokenString + "}";
  }
  if (tokenType == COMMAND) {
    return "{COMMAND : " + tokenString + "}";
  }
  return "";
}

Token::~Token() {
}
