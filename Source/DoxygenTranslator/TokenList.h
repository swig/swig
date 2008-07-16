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
	TokenList(string doxygenString); /* constructor takes a blob of Doxygen comment */
	~TokenList();
	Token peek(); 	/* returns next token without advancing */
	Token next(); 	/* returns next token and advances */
	list<Token>::iterator end(); /* returns an end iterator */
	list<Token>::iterator current(); /* returns the current iterator */
	void printList(); /* prints out the sequence of tokens */
	list<Token>::iterator  iteratorCopy(); /* returns a copy of the current iterator */
	void setIterator(list<Token>::iterator  newPosition); /*moves up the iterator*/
};

#endif /*TOKENLIST_H_*/
