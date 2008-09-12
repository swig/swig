/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * python.cxx
 *
 * Part of the Doxygen comment translation module of SWIG.
 * ----------------------------------------------------------------------------- */

#ifndef DOXYGENENTITY_H_
#define DOXYGENENTITY_H_

#include <string>
#include <list>

/*
 * Structure to represent a doxygen comment entry
 */
struct DoxygenEntity{
  DoxygenEntity(std::string typeEnt);
  DoxygenEntity(std::string typeEnt, std::string param1);
  DoxygenEntity(std::string typeEnt, std::list <DoxygenEntity> &entList );
  void printEntity(int level);
  std::string typeOfEntity;
  std::list <DoxygenEntity> entityList;
  std::string data;
  int isLeaf;
};

/* 
 * Functor that sorts entities by javaDoc standard order for commands.
 * NOTE: will not behave entirely properly until "First level" comments
 * such as brief descriptions are TAGGED as such
 */
struct CompareDoxygenEntities {
  bool operator()(DoxygenEntity& first, DoxygenEntity& second);
};

#endif /*TOKENLIST_H_*/
