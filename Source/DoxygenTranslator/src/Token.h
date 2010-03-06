/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * Token.h
 * ----------------------------------------------------------------------------- */

#ifndef TOKEN_H_
#define TOKEN_H_
#include <string>

using namespace std;

class Token {
public:
  Token(int tType, string tString);
  ~Token();

  int tokenType;		/* currently can be END_LINE, PLAINSTRING, or COMMAND */
  string tokenString;		/* the data , such as param for @param */
  string toString();
};

#endif
