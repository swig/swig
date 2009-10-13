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
