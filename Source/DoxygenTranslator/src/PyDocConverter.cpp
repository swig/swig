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
#include <sstream>
#include <vector>
#include <iostream>

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

std::string PyDocConverter::processEntityList(Node *n, std::list<DoxygenEntity>& entityList){
  std::string result;
  bool inParamsSection = false;
  
  for(std::list<DoxygenEntity>::iterator entityIterator = entityList.begin(); entityIterator != entityList.end();){
    if(entityIterator->typeOfEntity.compare("param") == 0 && !inParamsSection){
      inParamsSection = true;
      result += "\nArguments:\n";
    }
    else if(entityIterator->typeOfEntity.compare("param") != 0 && inParamsSection)
      inParamsSection = false;
    
    result += translateEntity(n, *entityIterator);
    entityIterator++;
  }  
  
  return result;
}

bool PyDocConverter::getDocumentation(Node *n, String *&documentation){
  std::string pyDocString, result;
  
  // for overloaded functions we must concat documentation for underlying overloads
  if(Checkattr(n, "kind", "function") && Getattr(n, "sym:overloaded")){
    // rewind to the first overload
    while (Getattr(n, "sym:previousSibling"))
      n = Getattr(n, "sym:previousSibling");
    
    std::vector<std::string> allDocumentation;
    
    // for each real method (not a generated overload) append the documentation
    while(n){
      documentation = Getattr(n,"DoxygenComment");
      if(!Swig_is_generated_overload(n) && documentation){
	std::list<DoxygenEntity> entityList = DoxygenParser().createTree(Char(documentation));
	allDocumentation.push_back(processEntityList(n, entityList));
      }
      n = Getattr(n, "sym:nextSibling");
    }
    
    // construct final documentation string
    if(allDocumentation.size() > 1){
      std::ostringstream concatDocString;
      for(int realOverloadCount = 0; realOverloadCount < (int)allDocumentation.size(); realOverloadCount++){
	concatDocString << generateDivider();
	concatDocString << "Overload " << (realOverloadCount + 1) << ":" << std::endl;
	concatDocString << generateDivider();
	concatDocString << allDocumentation[realOverloadCount] << std::endl;
      }
      pyDocString = concatDocString.str();
    } 
    else if (allDocumentation.size() == 1) {
      pyDocString = *(allDocumentation.begin());
    }
  } 
  // for other nodes just process as normal
  else {
    documentation = Getattr(n,"DoxygenComment");
    if(documentation != NULL){
      std::list<DoxygenEntity> entityList = DoxygenParser().createTree(Char(documentation));
      pyDocString = processEntityList(n, entityList);
    }
  }
  
  // if we got something log the result and construct DOH string to return
  if(pyDocString.length()) {
    result = "\"\"\"\n" + pyDocString + "\"\"\"\n";
    
    if(debug){
      std::cout << "\n---RESULT IN PYDOC---" << std::endl;
      std::cout << result;
      std::cout << std::endl;
    }
    
    documentation = NewString(result.c_str());
    return true;
  }
  
  return false;
}

std::string PyDocConverter::generateDivider(){
  std::ostringstream dividerString;
  for(int i = 0; i < DOC_STRING_LENGTH; i++)
    dividerString << '-';
  dividerString << std::endl;
  return dividerString.str();
}
