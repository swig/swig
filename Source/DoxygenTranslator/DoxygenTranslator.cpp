/* The main class for translating blobs of Doxygen for SWIG
 * by Cheryl Foil, mentor Olly Betts, for Google's Summer of Code Program
 * Currently the spacing/format on this is a bit goofy in places, due to shuffling code
 * between 2 editors! Apologies for anyone combing through it :)
 */
//TODO DOH instead of STL?
//TODO Most commands are not fully implemented

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include "DoxygenEntity.h"

using namespace std;


//////////////////////////////////////////
/*Set these to pick what internal functions
to test. */

//int testCommandParsingFunctions = 1;// not implemented

int testCodeCrawlingFunctions = 1;
int demonstrateParsing = 0;

//////////////////////////////////////////



/* Globals*/


// An array of all the commands and my generic description tag, plaindescription

string commandArray[] = {"a", "addindex", "addtogroup", "anchor", "arg", "attention",
		"author", "b", "brief", "bug", "c", "callgraph", "callergraph", "category",
		"class", "code", "cond", "copybrief", "copydetails", "copydoc", "date", "def",
		"defgroup", "deprecated", "details", "dir", "dontinclude", "dot", "dotfile", "e",
		"else", "elseif", "em", "endcode", "endcond", "enddot", "endhtmlonly", "endif",
		"endlatexonly", "endlink", "endmanonly", "endmsc", "endverbatim", "endxmlonly",
		"enum", "example", "exception", "f$", "f[", "f]", "f{", "f}", "file", "fn", "headerfile",
		"hideinitializer", "htmlinclude", "htmlonly", "if", "ifnot", "image", "include",
		"includelineno", "ingroup", "internal", "invariant", "interface", "latexonly", "li",
		"line", "link", "mainpage", "manonly", "msc", "n", "name", "namespace", "nosubgrouping",
		"note", "overload", "p", "package", "page", "par", "paragraph", "param", "post", "pre",
		"private", "privatesection", "property", "protected", "protectedsection", "protocol",
		"public", "publicsection", "ref", "relates", "relatesalso", "remarks", "return", "retval",
		"sa", "section", "see", "showinitializer", "since", "skip", "skipline", "struct", "subpage",
		"subsection", "subsubsection", "test", "throw", "todo", "tparam", "typedef", "union", "until",
		"var", "verbatim", "verbinclude", "version", "warning", "weakgroup", "xmlonly", "xrefitem",
		"$", "@", string(1, 92), string(1, '&'), "~", "<", ">", string(1, '#'), "%", "plaindescription"};


string sectionIndicators[] = { "attention", "author", "brief", "bug", "cond", "date", "deprecated", "details",
		"else", "elseif", "endcond", "endif", "exception", "if", "ifnot", "invariant", "note", "par", "param",
		"tparam", "post" , "pre", "remarks", "return", "retval", "sa", "see", "since", "test", "throw", "todo",
		"version", "warning", "xrefitem" };


 int startIndex = 0;
 int endIndex = 0;
 int isNewLine = 0;

 string doxygenString = "";
 int briefDescExists = 0;

 /* Entity list is the root list.
  * it is arranged this way to help documentation modules,
  * such as the javaDoc one, "sort" entities where they need to.
  */

 list <DoxygenEntity> rootList;

/* General (untested) assist methods */

 string StringToLower(string stringToConvert)

 {//change each element of the string to lower case

    for(unsigned int i=0;i<stringToConvert.length();i++)
    {
    stringToConvert[i] = tolower(stringToConvert[i]);
    }
    return stringToConvert;//return the converted string
 }

 int findCommand(string smallString){

 	smallString = StringToLower(smallString);
 	int a;
 	for (int i = 0; i < sizeof(commandArray)/sizeof(*commandArray); i++){
 		if( (a = smallString.compare(commandArray[i])) == 0){
 			return 101 + i;
 		}


 	}
 	return -1;
 }

 /* isSectionIndicator returns a boolean if the command is a section indicator
  * This is a helper method for finding the end of a paragraph
  * by Doxygen's terms
  */
 int isSectionIndicator(string smallString){
 	smallString = StringToLower(smallString);

 	for (int i = 0; i < sizeof(commandArray)/sizeof(*commandArray); i++){
 		if( smallString.compare(commandArray[i]) == 0){
 			return 1;
 		}
 	}
 	return 0;
 }


 /* HELPER METHODS
  * To test these, change the flags at the top of this class
  */

 /* Tiny method to compartmentalise the removal of all optional comment fluff such as ///
  * or **** that often occurs before commment blobs.
  */
 int clearFluff(int startInd){
	int startIndex = startInd;
 	int amountRemoved = 0;

 	while(doxygenString[startIndex] == '/'|| doxygenString[startIndex] == '!' || doxygenString[startIndex] == '*'
 			|| doxygenString[startIndex] == '\n' || doxygenString[startIndex] == ' '){
 		startIndex++;
 		amountRemoved++;
 		}

 	return startIndex;
 }

 /* Returns the next word ON THE CURRENT LINE ONLY
  * if a new line is encountered, returns a blank string.
  * Updates the index it is given after completion.
  */

 string getNextWord(int &startInd){
	int startIndex = startInd;
 	string nextWord = "";
 	while (doxygenString[startIndex] == '/'|| doxygenString[startIndex] == ' '
 		|| doxygenString[startIndex] == '*' || doxygenString[startIndex]== '\n'
		|| doxygenString[startIndex] == '!'){
 		if(doxygenString[startIndex]== '\n') return nextWord;
 		startIndex++;
 		//cout << "Start Index" << startIndex << endl;
 		}
 	//cout << doxygenString[startIndex] << endl;
 	int endIndex = startIndex;

 	while (doxygenString[endIndex]!= '\n' && doxygenString[endIndex]!= ' '){
 		endIndex++;
 		//cout << "End Index " << endIndex << endl;
 		}
 	nextWord = doxygenString.substr(startIndex, endIndex - startIndex);
 	startInd = endIndex;
 	//cout << "Next Word :" << nextWord << ":" << endl;
 	return nextWord;
 }

 /* Returns the string remaining on a line
  * and moved the index to the NEXT line
  * returns "" if nothing on the current line.
  */
 string getOneLine(int &startInd){
	int startIndex = startInd;
 	while (doxygenString[startIndex] == '/'|| doxygenString[startIndex] == ' '
 		|| doxygenString[startIndex] == '*' || doxygenString[startIndex]== '\n'
		|| doxygenString[startIndex] == '!'){
 		if(doxygenString[startIndex]== '\n') return "";
 		startIndex++;
 		}

	int endIndex = startIndex;
 	while ((endIndex != doxygenString.length())&& (doxygenString[endIndex] != '\n')){
 		endIndex++;
 		//cout << doxygenString[endIndex] << "End Index: " << endIndex << endl;
 		}
 	string returnedLine = doxygenString.substr(startIndex, endIndex - startIndex);
 	if (doxygenString[endIndex] == '\n' && (endIndex < doxygenString.length())) endIndex++;
 	startInd = endIndex;
 	return returnedLine;
 }

/* Returns a Paragraph- defined in Doxygen to be a paragraph of text
 * seperate by either a structural command or a blank line
 * This method is VERY messy currently
 */
 //TODO fix getStringTilEndOfParagraph to be more forgiving, work on ' ' characters
 string getStringTilEndOfParagraph(int &startInd){
	 if (startInd >= doxygenString.length()) return "";
	int startIndex = startInd;
	int endIndex = startInd;
 	string description = "";
 	/* Find the End of the description */
 	int keepLooping = 1;
 	int spareIndex = 0;
 	int counter;
 	int finalIndex;
 	while(keepLooping && endIndex < doxygenString.length()){
		if (doxygenString[endIndex] == '\n'){
			//cout << "1 ";
			counter = endIndex;
			if ( keepLooping && endIndex < doxygenString.length()-1) {
				counter++;
				//cout << "Counter :" << counter << endl;
				while(keepLooping && endIndex < doxygenString.length() && (doxygenString[counter] == ' ' ||
				               doxygenString[counter] == '*'|| doxygenString[counter] == '\n'|| doxygenString[counter] == '/'
				            	   || doxygenString[counter] == '!') ){
									if(doxygenString[counter] == '\n') {
										//cout << "Blank line found" << endl;
										keepLooping = 0;
										finalIndex = counter;}
									else{ counter++;}
									}

			}
			//endIndex = counter;
		}
 		else if (doxygenString[endIndex] == 92 || doxygenString[endIndex] == '@'){
 			//cout << "2 ";
			spareIndex = endIndex;
 			if (isSectionIndicator(getNextWord(spareIndex))) keepLooping = 0;
 			}
		else if(endIndex < doxygenString.length() - 1
				&& string("*/").compare(doxygenString.substr(endIndex , endIndex  + 1)) == 0){
			//cout << "3 ";
			keepLooping = 0;
		}
 		if(keepLooping){
 			//cout << "4 ";
 			endIndex++;
 		}
 	}
 	//cout << "Done with EndIndex" << endl;
 	while(doxygenString[startIndex] == '!' || doxygenString[startIndex] == ' '
 		|| doxygenString[startIndex] == '/' || doxygenString[startIndex] == '*') startIndex++;

 	for (int i = startIndex; i < endIndex; i++){

 		if (doxygenString[i] == '\n') {

 			while ((doxygenString[i] == '\n' || doxygenString[i] == ' '
 				|| doxygenString[i] == '*' || doxygenString[i] == '/')&& endIndex < doxygenString.length() - 1){
 				i++;
 				}
 			description.append(" ");
 		}
 		description.push_back(doxygenString[i]);
 		//cout << doxygenString[i];
 	}
 	startInd = finalIndex;
 	return description;
 }

 /* This method is for a specific form of doxygen command
  * that begins with a \command and ends in \endcommand
  * such as \code and \endcode. The proper usage is
  * progressTilEndCommand("endcode", index)
  * currently this method does NOT process what is in between the two commands
  */
 //TODO Make progressTilCommand return a formatted string
 int progressTilEndCommand(string theCommand, int &startInd){
 	endIndex = startInd;
 	while (endIndex < doxygenString.length()){
 		if (doxygenString[endIndex] == 92 || doxygenString[endIndex] == '@'){
 			//cout << doxygenString.substr(endIndex + 1 , theCommand.length())<< endl;
 			if (theCommand.compare(doxygenString.substr(endIndex + 1 , theCommand.length())) == 0){
 				startInd = endIndex + theCommand.length() + 1;
 				return 1;
 			}
 		}
 		endIndex++;
 	}
 	//End command not found
 	return 0;
 }

 string getStringTilAnyCommand(string theCommand, int &startInd){
	 endIndex = startInd;
	 startIndex = startInd;
	 int keepLooping = 1;
	 while (keepLooping && endIndex < doxygenString.length()){
	  		if (doxygenString[endIndex] == 92 || doxygenString[endIndex] == '@'){
	  			startInd = endIndex;
	  			keepLooping = 0;
	  			}
	 endIndex++;
	 }
	 string description = "";
	 for (int i = startIndex; i < endIndex; i++){

	  		if (doxygenString[i] == '\n') {

	  			while ((doxygenString[i] == '\n' || doxygenString[i] == ' '
	  				|| doxygenString[i] == '*' || doxygenString[i] == '/')&& endIndex < doxygenString.length() - 1){
	  				i++;
	  				}
	  			description.append(" ");
	  		}
	  		description.push_back(doxygenString[i]);
	  		//cout << doxygenString[i];
	  	}
	  	startInd = endIndex;
	  	return description;
	 return 0;
 }
 ///////////////TEST CLASSES AND MAIN BELOW/////////////////


 /*  Testing clearFluff(), a method to scan past all excess / * ! from beginning of
  * a comment blob. Compartmentalised simply because this is a comment habit that
  * differs wildly */

 int testClearFluff(){

  string cases[] = {"/** WORD", "/*! WORD", "/******* WORD", "///// WORD", "//! WORD", "//! WORD", "///WORD",
 		 "/**\nWORD", "/**\n*WORD", "/** \n WORD"};
  int testPassed = 1;
  int casesSize = sizeof(cases)/sizeof(*cases);
  for (int i = 0; i < casesSize; i++){
	  doxygenString = cases[i];
	  if(cases[i][clearFluff(0)] != 'W'){
		  cout << "ClearFluff failed for string :" << doxygenString << "\t Displayed :" << cases[i][clearFluff(0)] << ": Instead." << endl;
		  testPassed = 0;
	  }
  }
  if(testPassed) cout << "+++ClearFluff passed for all tests+++\n" << endl;
  else cout << "+++ClearFluff FAILED.+++" << endl;
  return testPassed;

  };

 int testGetNextWord(){
	  string cases[] = {"/** WORD ", " * WORD ", "///!WORD ", " WORD ", "//! WORD ", " * WORD ", "*WORD "};
	  int testPassed = 1;
	  string testWord = "";
	  int placement = 0;
	  int casesSize = sizeof(cases)/sizeof(*cases);
	  for (int i = 0; i < casesSize; i++){
		  doxygenString = cases[i];
		  placement = 0;
		  testWord = getNextWord(placement);
		  if(testWord.compare("WORD") != 0){
			  cout << "GetNextWord failed for string :" << doxygenString << "\t Displayed :" << testWord << ": Instead." << endl;
			  testPassed = 0;
		  }
		 //else cout << "GetNextWord passed for string :" << doxygenString << endl;
	  }
	    placement = 0;
		doxygenString = " * @WORD ";
		testWord = getNextWord(placement);
		if(testWord.compare("@WORD") != 0){
			cout << "GetNextWord failed for string :"
			<< doxygenString << "\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		 //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		testWord = " * ";
		testWord.push_back(92);
		testWord = testWord + "WORD ";
		string commandWord = "";
		commandWord.push_back(92);
		commandWord = commandWord + "WORD";
		doxygenString = testWord;
		placement = 0;
		testWord = getNextWord(placement);
		if(testWord.compare(commandWord) != 0){
			cout << "GetNextWord failed for string :" << doxygenString
			<< "\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		  //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		doxygenString = "WORD ANOTHER WORD1 WORD2 \n";
		placement = 0;
		testWord = getNextWord(placement);
		if(testWord.compare("WORD") != 0){
			cout << "GetNextWord failed for string :" << doxygenString
			<< "\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		  //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		testWord = getNextWord(placement);
		if(testWord.compare("ANOTHER") != 0){
			cout << "GetNextWord failed for string :" << doxygenString
			<< "\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		 //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		testWord = getNextWord(placement);
		if(testWord.compare("WORD1") != 0){
			cout << "GetNextWord failed for string :" << doxygenString
			<< "\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		  //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		testWord = getNextWord(placement);
		if(testWord.compare("WORD2") != 0){
			cout << "GetNextWord failed for string :"
			<< doxygenString << "\t Displayed :" << testWord
			<< ": Instead." << endl;
			testPassed = 0;}
		  //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		testWord = getNextWord(placement);
		if(testWord.compare("") != 0){
			cout << "GetNextWord failed for string :" << doxygenString
			<< "\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		  //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		testWord = getNextWord(placement);
		if(testWord.compare("") != 0){
			cout << "GetNextWord failed for string :" << doxygenString <<
			"\t Displayed :" << testWord << ": Instead." << endl;
			testPassed = 0;}
		  //else cout << "GetNextWord passed for string :" << doxygenString << endl;
		  if(testPassed) cout << "+++NextWord passed for all tests+++\n" << endl;
		 else cout << "+++NextWord FAILED+++\n" << endl;
		  return testPassed;
 }

 int testGetOneLine(){
	  string cases[] = {" * Crop this sentence after this period.\n",
			  " * Crop this sentence after this period.\n",
			  "Crop this sentence after this period.\n",
			  "//! Crop this sentence after this period.\n",
			  " Crop this sentence after this period.\n"
			  };
	  int testPassed = 1;
	  string testWord = "";
		int placement = 0;
	  int casesSize = sizeof(cases)/sizeof(*cases);
	  for (int i = 0; i < casesSize; i++){
		  doxygenString = cases[i];
		  placement = 0;
		  testWord = getOneLine(placement);
		  if(testWord.compare("Crop this sentence after this period.") != 0){
			  cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testWord << ": Instead." << endl;
			  testPassed = 0;
		  }
	  }
	  doxygenString = ("Get this line.\n * Now get this line.");
	  placement = 0;
	  testWord = getOneLine(placement);
	  if(testWord.compare("Get this line.") != 0){
	  		cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testWord << ": Instead." << endl;
	  		testPassed = 0;
	  		  }
	  testWord = getOneLine(placement);
	  if(testWord.compare("Now get this line.") != 0){
	  		cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testWord << ": Instead." << endl;
	  		testPassed = 0;
	  		  }
	  testWord = getOneLine(placement);
	  if(testWord.compare("") != 0){
	  		cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testWord << ": Instead." << endl;
	  		testPassed = 0;
	  		  }

	  if(testPassed) cout << "+++GetOneLine passed for all tests+++\n" << endl;
	 else cout << "+++GetOneLine FAILED+++\n" << endl;
	  return testPassed;
 }
//TODO Flesh testGetStringTilEndOfParagraph out, fix weird spacing problems
 int testGetStringTilEndOfParagraph(){
	int placement = 0;
	int testPassed = 1;
	string testParagraph;
	doxygenString = ("/* This is a description,\n * thus it continues on\n * for several lines.\n\n This Shouldn't be included.\n\n **/");
	testParagraph = getStringTilEndOfParagraph(placement);
	if( testParagraph.compare("This is a description, thus it continues on for several lines.") != 0){
  		cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testParagraph << ": Instead." << endl;
  		testPassed = 0;
  	}
	//cout << "Curr Placement: " << placement<< endl;
	testParagraph = getStringTilEndOfParagraph(placement);
	//cout << "Curr Placement: " << placement<< endl;
	if( testParagraph.compare(" This Shouldn't be included.") != 0){
  		cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testParagraph << ": Instead." << endl;
  		testPassed = 0;
  	}

	//cout << "Curr Placement: " << placement<< endl;
	//cout << "String Length: " << doxygenString.length() << endl;

	doxygenString = "/* This is a description,\n * thus it continues on\n * for several lines.\n * \n * ";
	doxygenString.push_back(92);
	doxygenString += "author cheryl foil \n\n **/";
	placement = 0;
	testParagraph = getStringTilEndOfParagraph(placement);
	if( testParagraph.compare("This is a description, thus it continues on for several lines.") != 0){
  		cout << "GetOneLine failed for string :" << doxygenString << "\t Displayed :" << testParagraph << ": Instead." << endl;
  		testPassed = 0;
  	}

	if(testPassed) cout << "+++GetDescription passed for all tests+++\n" << endl;
	else cout << "+++GetDescription FAILED+++\n" << endl;
	return testPassed;
 }

 int testProgressTilEndCommand(){
		int placement = 0;
		int testPassed = 1;
		string testParagraph;
		doxygenString = "Let's pretend this \n * is a bunch of code to be ended in ";
		doxygenString.push_back(92);
		doxygenString += "endcodeSTOP";
		progressTilEndCommand("endcode", placement);
		//cout << "Placement : " << placement << endl;
		if( doxygenString[placement] != 'S'){
	  		cout << "GetOneLine failed for string :" << doxygenString << "\n\t Displayed :" << testParagraph << ": Instead." << endl;
	  		testPassed = 0;
	  	}
		if(testPassed) cout << "+++ProgressTilEndCommand passed for all tests+++\n" << endl;
		else cout << "+++ProgressTilEndCommand FAILED+++\n" << endl;
	 return testPassed;
 }

 int testCCF(){
	cout << "TESTING COMMAND PARSING FUNCTIONS" << endl;
	cout << "Testing clearFluff" << endl;
	testClearFluff();

 	cout << "Testing getNextWord" << endl;
 	testGetNextWord();
 	cout << "Testing getOneLine"<< endl;
 	testGetOneLine();

 	cout << "Testing getStringTilEndOfParagraph" << endl;
 	testGetStringTilEndOfParagraph();

 	cout << "Testing progressTilEndCommand" << endl;
 	testProgressTilEndCommand();

 	return 1;
 }

 /* prints the parse tree
  *
  */
 void printTree(){

		list<DoxygenEntity>::iterator p = rootList.begin();
		while (p != rootList.end()){
			(*p).printEntity();
			p++;
		}

 }
 /* The actual "meat" of the doxygen parser. This is not yet fully implemented
  * with my current design- however the skeletal outline is contained in
  * the file Skeleton
  */

 int addCommand(int commentNum, int &startInd, list <DoxygenEntity> &doxyList){
	    startIndex = startInd;
	 	string name;
	 	string nextWordInLine = "";
	 	string restOfLine = "";
	 	string restOfParagraph = "";
	 	string headerfile ="";
	 	string headername = "";
	 	switch(commentNum){


		/* \b */
		case 108:
			name = getNextWord(startIndex);
			if (!name.empty()) doxyList.push_back( DoxygenEntity(108, name));
			else cout << "No word followed b command. Not added" << endl;
			break;
		/* \brief */
		case 109:
			restOfParagraph = getStringTilEndOfParagraph(startIndex);
			if(!restOfParagraph.empty()) doxyList.push_back( DoxygenEntity(109, restOfLine));
			else cout << "Nothing followed brief command. Not added" <<endl;
			break;

	 	/* plain description */
	 	case 238:
	 		//doxyList.push_back(DoxygenEntity(238, parse(startIndex, new list<DoxygenEntity> entityList() )));

	 		break;

	 	default:
			cout << "Command " << commentNum << " not supported yet" << endl;
			break;
	 	}
	 	startInd = startIndex;
 }

 /* Returns the parse tree */

list<DoxygenEntity> parse(int startInd, int endInd, list<DoxygenEntity> &doxyList){
	string currWord = "";
	int startIndex = startInd;
	int savedIndex;
	int currCommand;
	while (startIndex < endIndex){
		savedIndex = startIndex;
		currWord = getNextWord(startIndex);

		if(currWord[0] == 92 || currWord[0] == '@'){
			currWord = doxygenString.substr(startIndex+1, currWord.length() - 1);
			currCommand = findCommand(currWord);
			if (currCommand < 0 ){ cout << "BAD COMMAND: " << currWord << endl; exit(1);}
				//cout << "Command: " << currWord << " " << currCommand << endl;
			addCommand(currCommand, startIndex, doxyList);
		}
		else{
			startIndex = savedIndex;
			addCommand(238, startIndex, doxyList);

		}
	}


}


 int main(int argc, char *argv[]){
 	if(testCodeCrawlingFunctions) testCCF();
 	if (demonstrateParsing){
 		int placement = 0;
 		clearFluff(0);
 		parse(0, doxygenString.length(), rootList);
 		printTree();
 	}
 	return 1;
 }
