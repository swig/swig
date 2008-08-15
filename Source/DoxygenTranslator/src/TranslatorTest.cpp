
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <list>
using namespace std;


/* This classes primary function is to test the basic text processing abilities of
 * the Doxygen parsing class
 * It is currently a little messy */


int testCommandParsingFunctions = 1;
int testCodeCrawlingFunctions = 1;


/*  Testing clearFluff(), a method to scan past all excess / * ! from beginning of
 * a comment blob. Compartmentalised simply because this is a comment habit that
 * differs wildly */

int testClearFluff(){

 string cases[] = {"/** WORD", "/*! WORD", "/******* WORD", "///// WORD", "//! WORD", "//! WORD", "///WORD",
		 "/**\nWORD", "/**\n*WORD", "/** \n WORD"};
 
 return 1;
 
 };

int testCCF(){
	

	
	cout << "Testing getNextWord" << endl;
	// Case 1: \command <name>
	string case1 = "\b word";
	string case2 = "\b word ";
	string case3 = "\b word\n";
	string case4 = "\b word \n";
	string case5 = "\b word word";
	//Case 2: \command {paragraph}
	
	//Case 3: \command (text til end of line)
		
	
	return 1;
}

int testCPF(){
	// Case 1: \command <name>
	string case1 = "\b word";
	//Case 2: \command {paragraph}
		
	//Case 3: \command (text til end of line)
		
	return 1;
	
}

int main(int argc, char *argv[]){
	if(testCodeCrawlingFunctions) testCCF();
	if(testCommandParsingFunctions) testCPF();
	
	
	return 1;
}
