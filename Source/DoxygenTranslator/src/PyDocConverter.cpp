/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * PyDocConverter.cpp
 *
 * Module to return documentation for nodes formatted for PyDoc
 * ----------------------------------------------------------------------------- */

#include "PyDocConverter.h"
#include "DoxygenParser.h"
#include <iostream>
#include <sstream>

//TODO {@link} {@linkplain} {@docRoot}, and other useful doxy commands that are not a pydoc tag
PyDocConverter::PyDocConverter()
{
    debug = 1;
}

std::string PyDocConverter::formatParam(Node *n, DoxygenEntity &doxygenEntity) {
  ParmList *plist = CopyParmList(Getattr(n, "parms"));
  Parm *p = NULL;
  
  DoxygenEntity& paramNameEntity = *doxygenEntity.entityList.begin();
  DoxygenEntity& paramDescriptionEntity = *(++doxygenEntity.entityList.begin());
  
  std::string result;
  std::string paramDescription = justifyString(paramDescriptionEntity.data, DOC_PARAM_STRING_LENGTH);
  
  for (p = plist; p;) {
    if(Char(Getattr(p, "name")) == paramNameEntity.data) {
      std::string name = Char(Swig_name_make(n, 0, Getattr(p, "name"), 0, 0));
      std::string type = Char(Swig_name_make(n, 0, Getattr(p, "type"), 0, 0));
      
      result = name + " (" + type + ") ";
      result.resize(DOC_PARAM_STRING_LENGTH - 3, ' ');
      result += "-- " + paramDescription.substr(DOC_PARAM_STRING_LENGTH);
      break;
    }
    p = Getattr(p, "tmap:in") ? Getattr(p, "tmap:in:next") : nextSibling(p);
  }

  Delete(plist);
  return result;
}

std::string PyDocConverter::formatReturnDescription(Node *node, DoxygenEntity &doxygenEntity){
#pragma unused(node)
  return "\nResult:\n" + justifyString(translateSubtree(doxygenEntity));
}

std::string PyDocConverter::justifyString(std::string documentString, int indent, int maxWidth){
  std::ostringstream formattedString;
  std::string currentLine;
  
  for(std::string::iterator stringPosition = documentString.begin(); stringPosition != documentString.end(); ++stringPosition)
  {
    if(currentLine.length() == 0)
      currentLine.resize(indent, ' ');
    
    currentLine += *stringPosition;
      
    if(*stringPosition == ' ' && (int)currentLine.size() >= maxWidth || (stringPosition + 1) == documentString.end())
    {
      formattedString << currentLine << std::endl;
      currentLine = "";
    }
  }
  
  return formattedString.str();
}

std::string PyDocConverter::translateSubtree( DoxygenEntity &doxygenEntity){
  std::string returnedString;
  if (doxygenEntity.isLeaf)
    return doxygenEntity.data + " ";
  else {
    returnedString += doxygenEntity.data;
    std::list<DoxygenEntity>::iterator p = doxygenEntity.entityList.begin();
    while (p != doxygenEntity.entityList.end()){
      returnedString+= translateSubtree(*p);
      p++;
    }
  }
  return returnedString;
}

std::string PyDocConverter::translateEntity(Node *n, DoxygenEntity &doxyEntity){
  if(doxyEntity.typeOfEntity.compare("partofdescription")== 0) 
    return justifyString(std::string(translateSubtree(doxyEntity)), 0);
  
  if ((doxyEntity.typeOfEntity.compare("brief") == 0)||(doxyEntity.typeOfEntity.compare("details") == 0)){
    return justifyString(std::string(translateSubtree(doxyEntity)), 0) + "\n * ";}
  
  if(doxyEntity.typeOfEntity.compare("plainstd::string")== 0 
    || doxyEntity.typeOfEntity.compare("deprecated")== 0 
    || doxyEntity.typeOfEntity.compare("brief")== 0)
    return justifyString(doxyEntity.data, 0) + "\n * ";
  
  if(doxyEntity.typeOfEntity.compare("see") == 0)
    return justifyString(std::string("@" + doxyEntity.typeOfEntity + "\t\t" + translateSubtree(doxyEntity)), 2);
  
  if(doxyEntity.typeOfEntity.compare("param") == 0)
    return formatParam(n, doxyEntity);
  
  if(doxyEntity.typeOfEntity.compare("return")== 0)
    return formatReturnDescription(n, doxyEntity);

  if(doxyEntity.typeOfEntity.compare("author")== 0
    || doxyEntity.typeOfEntity.compare("param")== 0
    || doxyEntity.typeOfEntity.compare("since")== 0
    || doxyEntity.typeOfEntity.compare("version")== 0
    || doxyEntity.typeOfEntity.compare("exception") == 0
    || doxyEntity.typeOfEntity.compare("deprecated") == 0)
    return justifyString(std::string("@" + doxyEntity.typeOfEntity + "\t" + translateSubtree(doxyEntity)), 2);
  
  if(doxyEntity.typeOfEntity.compare("sa")== 0)
    return justifyString(std::string("@see\t\t" + translateSubtree(doxyEntity)), 2);

  return justifyString(doxyEntity.data);
}

bool PyDocConverter::getDocumentation(Node *n, String *&documentation){
  documentation = Getattr(n,"DoxygenComment");
  if(documentation == NULL)
    return false;
  
  std::list <DoxygenEntity> entityList = DoxygenParser().createTree(Char(documentation));
  Delete(documentation);
  
  std::string pyDocString = "\"\"\"\n";
  
  bool inParamsSection = false;
  
  for(std::list<DoxygenEntity>::iterator entityIterator = entityList.begin(); entityIterator != entityList.end();){
    if(entityIterator->typeOfEntity.compare("param") == 0 && !inParamsSection)
    {
      inParamsSection = true;
      pyDocString += "\nArguments:\n";
    }
    else if(entityIterator->typeOfEntity.compare("param") != 0 && inParamsSection)
      inParamsSection = false;
    
    pyDocString += translateEntity(n, *entityIterator);
    entityIterator++;
  }

  pyDocString += "\n\"\"\"\n";
  
  if(debug){
    std::cout << "\n---RESULT IN PYDOC---" << std::endl;
    std::cout << pyDocString;
    std::cout << std::endl;
  }
  
  documentation = NewString(pyDocString.c_str());
  return true;
}