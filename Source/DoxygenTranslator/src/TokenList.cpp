#include "TokenList.h"
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>
#include "Token.h"
#include "DoxygenEntity.h"
#define TOKENSPERLINE 8; //change this to change the printing behaviour of the token list

using namespace std;

int noisy2 = 0;
/* The tokenizer*/
TokenList::TokenList(const std::string &doxygenStringConst){
    size_t commentPos;
    string doxygenString = doxygenStringConst;

    /* Comment start tokens are replaced in parser.y, see doxygen_comment and
       doxygen_post_comment_item
       do {
        commentPos = doxygenString.find("///<");
        if (commentPos != string::npos) {
            doxygenString.replace(commentPos, 4, " ");
            continue;
        }
        commentPos = doxygenString.find("/**<");
        if (commentPos != string::npos) {
            doxygenString.replace(commentPos, 4, " ");
            continue;
        }
        commentPos = doxygenString.find("/*!<");
        if (commentPos != string::npos) {
            doxygenString.replace(commentPos, 4, " ");
            continue;
        }
        commentPos = doxygenString.find("//!<");
        if (commentPos != string::npos) {
            doxygenString.replace(commentPos, 4, " ");
            continue;
        }
        break;
    } while (true); */

    size_t currentIndex = 0;
    size_t nextIndex = 0;

	string currentWord;

	while (currentIndex < doxygenString.length()){	

		if(doxygenString[currentIndex] == '\n'){
            m_tokenList.push_back(Token(END_LINE, currentWord));
			currentIndex++;
		}

        // skip WS, except \n
		while(currentIndex < doxygenString.length() && (doxygenString[currentIndex] == ' ' 
			|| doxygenString[currentIndex]== '\t')) currentIndex ++;

        if (currentIndex < doxygenString.length()) {

            nextIndex = currentIndex;

            // skip non WS
		while (nextIndex  < doxygenString.length() && (doxygenString[nextIndex] != ' ' 
                   && doxygenString[nextIndex] != '\t' && doxygenString[nextIndex]!= '\n')) 
                nextIndex++;

            // now we have a token
		currentWord = doxygenString.substr(currentIndex, nextIndex-currentIndex);

            if(noisy2) 
                cout << "Current Word: " << currentWord << endl;

		if (currentWord[0] == '@' || currentWord[0] == '\\'){
                // it is doxygen command
			currentWord = currentWord.substr(1, currentWord.length()-1);
                m_tokenList.push_back(Token(COMMAND, currentWord));

            } else if (currentWord[0] == '\n'){

                m_tokenList.push_back(Token(END_LINE, currentWord));
			
		}
		else if (currentWord[0] == '*' || currentWord[0] == '/' ||currentWord[0] == '!'){
				
                bool isPlainString = false;

                if (currentWord.length() > 1) {

                    for(size_t i = 1; i < currentWord.length(); i++){
                        if (currentWord[i] != '*' && currentWord[i] != '/' && 
                            currentWord[i] != '!') {
                                isPlainString = true;
                                break;
                        }
			}
		}
		
                if(isPlainString) 
                    m_tokenList.push_back(Token(PLAINSTRING, currentWord));

            } else if (!currentWord.empty()) {
                m_tokenList.push_back(Token(PLAINSTRING, currentWord));
            }
		currentIndex = nextIndex;
	}
	}

    m_tokenListIter = m_tokenList.begin(); 
}


TokenList::	~TokenList(){
}

Token TokenList::peek(){
    if(m_tokenListIter!= m_tokenList.end()){
        Token returnedToken = (*m_tokenListIter);
		return returnedToken;
	}
	else
		return Token(0, "");
} 


Token TokenList::next(){
    if(m_tokenListIter != m_tokenList.end()){
        Token returnedToken = (*m_tokenListIter);
        m_tokenListIter++;
		return (returnedToken);
	}
	else
		return Token(0, "");
} 	


list<Token>::iterator TokenList::end(){
	return tokenList.end();
}


list<Token>::iterator TokenList::current(){
  return m_tokenListIter;
}


list<Token>::iterator TokenList::iteratorCopy(){
  return m_tokenListIter;
}


void TokenList::setIterator(list<Token>::iterator newPosition){
  m_tokenListIter = newPosition;
}


void TokenList::printList(){
    list<Token>::iterator p = m_tokenList.begin();
			int i = 1;
			int b = 0;
    while (p != m_tokenList.end()){
				cout << (*p).toString() << " ";
				b = i%TOKENSPERLINE;
				if (b == 0) cout << endl;
				p++; i++;
			}
}

