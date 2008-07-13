#ifndef TOKENLIST_H_
#define TOKENLIST_H_
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>
#include "Token.h"
using namespace std;

/* a small class used to represent the sequence of tokens
 * that can be derived from a formatted doxygen string
 */

class TokenList{
public:
	/* constructor takes a blob of Doxygen comment */
	TokenList(string doxygenString);
	~TokenList();
	Token peek(); 	/* returns next token without advancing */
	Token next(); 	/* returns next token and advances */
	void printList(); /* prints out the sequence of tokens */
};

#endif /*TOKENLIST_H_*/
