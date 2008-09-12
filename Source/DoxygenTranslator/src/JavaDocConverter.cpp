#include "JavaDocConverter.h"
#include "DoxygenParser.h"
#include <iostream>
#define APPROX_LINE_LENGTH 64//characters per line allowed
#define TAB_SIZE 8//characters per line allowed
int printSortedTree2 = 0;
//TODO {@link} {@linkplain} {@docRoot}, and other useful doxy commands that are not a javadoc tag

std::string JavaDocConverter::formatCommand(std::string unformattedLine, int indent){
  std::string formattedLines = "\n * ";
  int lastPosition = 0;
  int i = 0;
  int isFirstLine  = 1;
  while (i != -1 && i < (int)unformattedLine.length()){
    lastPosition = i;
    if (isFirstLine){
      i+=APPROX_LINE_LENGTH;
    }
    else i+=APPROX_LINE_LENGTH - indent*TAB_SIZE;
    i = unformattedLine.find(" ", i);

    if (i > 0 && i + 1 < (int)unformattedLine.length()){
      if (!isFirstLine) for (int j = 0; j < indent; j++) {
        formattedLines.append("\t");
        }
      else {
        isFirstLine = 0;
      }
      formattedLines.append(unformattedLine.substr(lastPosition, i - lastPosition + 1));
      formattedLines.append("\n *");

    }
  }
  if (lastPosition < (int)unformattedLine.length()){
    if (!isFirstLine) {for (int j = 0; j < indent; j++) {formattedLines.append("\t");}}
    formattedLines.append(unformattedLine.substr(lastPosition, unformattedLine.length() - lastPosition));
  }

  return formattedLines;
}

/* Contains the conversions for tags
 * could probably be much more efficient...
 */
std::string JavaDocConverter::javaDocFormat(DoxygenEntity &doxygenEntity){
  if(doxygenEntity.typeOfEntity.compare("partofdescription") == 0){
        return doxygenEntity.data;
    }
  if (doxygenEntity.typeOfEntity.compare("plainstring") == 0){
      return  doxygenEntity.data;
  }
  else if (doxygenEntity.typeOfEntity.compare("b") == 0){
    return "<b>" + doxygenEntity.data + "</b>";
  }
  else if (doxygenEntity.typeOfEntity.compare("c") == 0){
    return "<tt>" + doxygenEntity.data + "</tt>";
  }
  else if (doxygenEntity.typeOfEntity.compare("@") == 0){
    return "@";
  }
  else if (doxygenEntity.typeOfEntity.compare("\\") == 0){
    return "\\";
  }
  else if (doxygenEntity.typeOfEntity.compare("<") == 0){
    return "&lt;";
  }
  else if (doxygenEntity.typeOfEntity.compare(">") == 0){
    return "&gt;";
  }
  else if (doxygenEntity.typeOfEntity.compare("&") == 0){
    return "&amp;";
  }
  else if (doxygenEntity.typeOfEntity.compare("#") == 0){
    return "#";
  }
  else if (doxygenEntity.typeOfEntity.compare("%") == 0){
    return "%";
  }
  else if (doxygenEntity.typeOfEntity.compare("~") == 0){
    return "~";
  }
  return "";
}


std::string JavaDocConverter::translateSubtree( DoxygenEntity &doxygenEntity){
  std::string returnedString;
  if (doxygenEntity.isLeaf){ return javaDocFormat(doxygenEntity) + " ";}
  else {
    returnedString += javaDocFormat(doxygenEntity);
    std::list<DoxygenEntity>::iterator p = doxygenEntity.entityList.begin();
    while (p != doxygenEntity.entityList.end()){
      returnedString+= translateSubtree(*p);
      p++;
    }
  }
  return returnedString;
}

std::string JavaDocConverter::translateEntity(DoxygenEntity &doxyEntity){
  if(doxyEntity.typeOfEntity.compare("partofdescription")== 0) return formatCommand(std::string(translateSubtree(doxyEntity)), 0);
  if ((doxyEntity.typeOfEntity.compare("brief") == 0)||(doxyEntity.typeOfEntity.compare("details") == 0)){
  return formatCommand(std::string(translateSubtree(doxyEntity)), 0) + "\n * ";}
  else if(doxyEntity.typeOfEntity.compare("plainstring")== 0 || doxyEntity.typeOfEntity.compare("deprecated")== 0 || doxyEntity.typeOfEntity.compare("brief")== 0)
    return formatCommand(doxyEntity.data, 0) + "\n * ";
  else if(doxyEntity.typeOfEntity.compare("see") == 0){
    return formatCommand(std::string("@" + doxyEntity.typeOfEntity + "\t\t" + translateSubtree(doxyEntity)), 2);
  }
  else if(doxyEntity.typeOfEntity.compare("return")== 0
      || doxyEntity.typeOfEntity.compare("author")== 0
      || doxyEntity.typeOfEntity.compare("param")== 0
      || doxyEntity.typeOfEntity.compare("since")== 0
      || doxyEntity.typeOfEntity.compare("version")== 0
      || doxyEntity.typeOfEntity.compare("exception") == 0
      || doxyEntity.typeOfEntity.compare("deprecated") == 0){
    return formatCommand(std::string("@" + doxyEntity.typeOfEntity + "\t" + translateSubtree(doxyEntity)), 2);
  }
  else if(doxyEntity.typeOfEntity.compare("sa")== 0){
    return formatCommand(std::string("@see\t\t" + translateSubtree(doxyEntity)), 2);
  }
  else return formatCommand(javaDocFormat(doxyEntity), 0 );
  return "";
}

bool JavaDocConverter::getDocumentation(Node *n, String *&documentation){
  documentation = Getattr(n,"DoxygenComment");
  if(documentation == NULL)
    return false;
  
  std::list <DoxygenEntity> entityList = DoxygenParser().createTree(Char(documentation));
  Delete(documentation);
  
  entityList.sort(CompareDoxygenEntities());
  
  if(debug){
    std::cout << "---RESORTED LIST---" << std::endl;
    printTree(entityList);
  }

  std::string javaDocString = "/**";
  
  for(std::list<DoxygenEntity>::iterator entityIterator = entityList.begin(); entityIterator != entityList.end();){
    javaDocString += translateEntity(*entityIterator);
    entityIterator++;
  }

  javaDocString += "\n */\n";
  
  if(debug){
    std::cout << "\n---RESULT IN JAVADOC---" << std::endl;
    std::cout << javaDocString; 
  }
  
  documentation = NewString(javaDocString.c_str());
  return true;
}
