#ifndef TOKEN_H_
#define TOKEN_H_
#include <string>

#define  END_LINE 101
#define PARAGRAPH_END 102
#define  PLAINSTRING 103
#define  COMMAND  104
using namespace std;

class Token
{
public:
	Token(int tType, string tString);
	~Token();
	int tokenType; /* currently can be END_LINE, PLAINSTRING, or COMMAND */
	string tokenString; /* the data , such as param for @param*/
	string toString();
};

#endif /*TOKEN_H_*/
