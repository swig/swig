/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * tclfragments.swg
 * ----------------------------------------------------------------------------- */

/*
  Create a file with this name, 'fragments.i', in your working
  directory and add all the %fragments you want to take precedence
  over the ones defined by default by swig.

  For example, if you add:
  
  %fragment(SWIG_AsVal_frag(int),"header") {
   SWIGINTERNINLINE int
   SWIG_AsVal_dec(int)(TclObject *obj, int *val)
   { 
     <your code here>;
   }
  }
  
  this will replace the code used to retreive an integer value for all
  the typemaps that need it, including:
  
    int, std::vector<int>, std::list<std::pair<int,int> >, etc.

*/
