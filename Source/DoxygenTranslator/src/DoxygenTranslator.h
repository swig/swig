#ifndef DOXYGENTRANSLATOR_H_
#define DOXYGENTRANSLATOR_H_
class DoxygenTranslator
{
public:
	DoxygenTranslator();
	virtual ~DoxygenTranslator();
	char* convert(char* doxygenBlob, char* option);
};
#endif /*DOXYGENTRANSLATOR_H_*/
