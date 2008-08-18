#include "Token.h"
using namespace std;


Token::Token(int tType, string tString)
{	
	tokenType = tType;
	tokenString = tString;
}

string Token::toString()
{
	if (tokenType == END_LINE){
		return "{END OF LINE}";
	}
	if (tokenType == PARAGRAPH_END){
		return "{END OF PARAGRAPH}";
	}
	if (tokenType == PLAINSTRING){
		return "{PLAINSTRING :" + tokenString + "}";
	}
	if (tokenType == COMMAND){
		return "{COMMAND : " + tokenString+ "}";
	}
	return "";
}

Token::	~Token(){}
