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
	int tokenType;
	string tokenString;
	string toString();
};

#endif /*TOKEN_H_*/
