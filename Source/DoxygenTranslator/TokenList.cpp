#include "TokenList.h"
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>
#include "Token.h"
#define TOKENSPERLINE 8; //change this to change the printing behaviour of the token list
#define  END_LINE 101
#define PARAGRAPH_END 102 //not used at the moment 
#define  PLAINSTRING 103
#define  COMMAND  104
using namespace std;


list <Token> tokenList;
list<Token>::iterator tokenListIterator;
int noisy2 = 0;
/* The tokenizer*/

TokenList::TokenList(string doxygenString){
	int currentIndex = 0;
	//Regex whitespace("[ \t]+");
	//Regex newLine("[\n]");
	//Regex command("[@|\\]{1}[^ \t \n]+"); //the cheap solution 
	//Regex doxygenFluff("[/*!]+");
	int nextIndex = 0;
	int isFluff = 0;
	string currentWord;
	while (currentIndex < doxygenString.length()){	
		if(doxygenString[currentIndex] == '\n'){
			tokenList.push_back(Token(END_LINE, currentWord));
			currentIndex++;
		}
		while(currentIndex < doxygenString.length() && (doxygenString[currentIndex] == ' ' 
			|| doxygenString[currentIndex]== '\t')) currentIndex ++;
		if (currentIndex == doxygenString.length()) {} //do nothing since end of string was reached
		else {nextIndex = currentIndex;
		while (nextIndex  < doxygenString.length() && (doxygenString[nextIndex] != ' ' 
			&& doxygenString[nextIndex]!= '\t' && doxygenString[nextIndex]!= '\n')) nextIndex++;
		currentWord = doxygenString.substr(currentIndex, nextIndex-currentIndex);
		if(noisy2) cout << "Current Word: " << currentWord << endl;
		if (currentWord[0] == '@' || currentWord[0] == '\\'){
			currentWord = currentWord.substr(1, currentWord.length()-1);
			tokenList.push_back(Token(COMMAND, currentWord));
		}
		else if (currentWord[0] == '\n'){
			//if ((tokenList.back()).tokenType == END_LINE){}
			tokenList.push_back(Token(END_LINE, currentWord));
			
		}
		else if (currentWord[0] == '*' || currentWord[0] == '/' ||currentWord[0] == '!'){
			if (currentWord.length() == 1) {isFluff = 1;}	
			else { isFluff = 1;
				for(int i = 1; i < currentWord.length(); i++){
					if (currentWord[0] != '*' && currentWord[0] != '/' && currentWord[0] != '!') isFluff = 0;
				}
				
			}
			if(!isFluff) tokenList.push_back(Token(PLAINSTRING, currentWord));
		}
		
		else tokenList.push_back(Token(PLAINSTRING, currentWord));
		currentIndex = nextIndex;
	}
	}
	tokenListIterator = tokenList.begin(); 
}

Token TokenList::peek(){
	if(tokenListIterator!= tokenList.end()){
		Token returnedToken = (*tokenListIterator);
		return returnedToken;
	}
	else
		return Token(0, "");
} 

Token TokenList::next(){
	if(tokenListIterator != tokenList.end()){
		Token returnedToken = (*tokenListIterator);
		tokenListIterator++;
		return (returnedToken);
	}
	else
		return Token(0, "");
} 	

list<Token>::iterator TokenList::end(){
	return tokenList.end();
}

list<Token>::iterator TokenList::current(){
	return tokenListIterator;
}
void TokenList::printList(){
	list<Token>::iterator p = tokenList.begin();
			int i = 1;
			int b = 0;
			while (p != tokenList.end()){
				cout << (*p).toString() << " ";
				b = i%TOKENSPERLINE;
				if (b == 0) cout << endl;
				p++; i++;
			}
}

list<Token>::iterator  TokenList::iteratorCopy(){
	list<Token>::iterator p = tokenListIterator;
	return p;
}
void TokenList::setIterator(list<Token>::iterator newPosition){
	tokenListIterator = newPosition;
}
TokenList::	~TokenList(){}
