/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * python.cxx
 *
 * Part of the Doxygen comment translation module of SWIG.
 * ----------------------------------------------------------------------------- */

#include "DoxygenEntity.h"
#include <iostream>

DoxygenEntity::DoxygenEntity(std::string typeEnt){
    typeOfEntity = typeEnt;
    data = "";
    isLeaf = 1;
}

/* Basic node for commands that have
 * only 1 thing after them
 * example: \b word
 * OR holding a std::string
 */
DoxygenEntity::DoxygenEntity(std::string typeEnt, std::string param1){
    typeOfEntity = typeEnt;
    data = param1;
    isLeaf = 1;
}

/* Nonterminal node
 * contains
 */
DoxygenEntity::DoxygenEntity(std::string typeEnt, std::list <DoxygenEntity> &entList ){
    typeOfEntity = typeEnt;
    data = "";
    isLeaf = 0;
    entityList = entList;
}

void DoxygenEntity::printEntity(int level){
	int thisLevel = level;
	if (isLeaf) {
		for (int i = 0; i < thisLevel; i++) {std::cout << "\t";}
		std::cout << "Node Command: " << typeOfEntity << " ";
		if (data.compare("") != 0) std::cout << "Node Data: " << data;
		std::cout << std::endl;
	}
	else{
		for (int i = 0; i < thisLevel; i++) {std::cout << "\t";}
		std::cout << "Node Command : " << typeOfEntity << std::endl;
		std::list<DoxygenEntity>::iterator p = entityList.begin();
		thisLevel++;
		while (p != entityList.end()){
			(*p).printEntity(thisLevel);
			p++;
		}
	}
}

bool CompareDoxygenEntities::operator()(DoxygenEntity& first, DoxygenEntity& second){
  if(first.typeOfEntity.compare("brief") == 0) 
    return true;
  if(second.typeOfEntity.compare("brief") == 0) 
    return false;
  if(first.typeOfEntity.compare("details") == 0) 
    return true;
  if(second.typeOfEntity.compare("details") == 0) 
    return false;
  if(first.typeOfEntity.compare("partofdescription") == 0) 
    return true;
  if(first.typeOfEntity.compare("partofdescription") == 0) 
    return false;
  if(first.typeOfEntity.compare("plainstd::string") == 0) 
    return true;
  if(second.typeOfEntity.compare("plainstd::string") == 0) 
    return false;
  if(first.typeOfEntity.compare("param") == 0){
    if(second.typeOfEntity.compare("param")== 0) 
      return true;
    if(second.typeOfEntity.compare("return")== 0) 
      return true;
    if(second.typeOfEntity.compare("exception")== 0) 
      return true;
    if(second.typeOfEntity.compare("author")== 0) 
      return true;
    if(second.typeOfEntity.compare("version")== 0)
      return true;
    if(second.typeOfEntity.compare("see")== 0)
      return true;
    if(second.typeOfEntity.compare("since")== 0)
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  if(first.typeOfEntity.compare("return")== 0){
    if(second.typeOfEntity.compare("return")== 0) 
      return true;
    if(second.typeOfEntity.compare("exception")== 0) 
      return true;
    if(second.typeOfEntity.compare("author")== 0) 
      return true;
    if(second.typeOfEntity.compare("version")== 0)
      return true;
    if(second.typeOfEntity.compare("see")== 0)
      return true;
    if(second.typeOfEntity.compare("since")== 0)
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0
      )return true;
    return false;
  }
  if(first.typeOfEntity.compare("exception")== 0){
    if(second.typeOfEntity.compare("exception")== 0) 
      return true;
    if(second.typeOfEntity.compare("author")== 0) 
      return true;
    if(second.typeOfEntity.compare("version")== 0)
      return true;
    if(second.typeOfEntity.compare("see")== 0)
      return true;
    if(second.typeOfEntity.compare("since")== 0)
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  if(first.typeOfEntity.compare("author")== 0){
    if(second.typeOfEntity.compare("author")== 0) 
      return true;
    if(second.typeOfEntity.compare("version")== 0)
      return true;
    if(second.typeOfEntity.compare("see")== 0)
      return true;
    if(second.typeOfEntity.compare("since")== 0)
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  if(first.typeOfEntity.compare("version")== 0){
    if(second.typeOfEntity.compare("version")== 0)
      return true;
    if(second.typeOfEntity.compare("see")== 0)
      return true;
    if(second.typeOfEntity.compare("since")== 0)
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  if(first.typeOfEntity.compare("see")== 0 || first.typeOfEntity.compare("sa")== 0){
    if(second.typeOfEntity.compare("see")== 0)
      return true;
    if(second.typeOfEntity.compare("sa")== 0)
      return true;
    if(second.typeOfEntity.compare("since")== 0)
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  if(first.typeOfEntity.compare("since")== 0){
    if(second.typeOfEntity.compare("since")== 0) 
      return true;
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  if(first.typeOfEntity.compare("deprecated")== 0){
    if(second.typeOfEntity.compare("deprecated")== 0)
      return true;
    return false;
  }
  return true;
}


