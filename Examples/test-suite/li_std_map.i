/**
 * @file   li_std_map.i
 * @author gga
 * @date   Mon Apr 30 15:03:58 2007
 * 
 * @brief  a test of map containers. 
 *         Languages should define swig::LANGUAGE_OBJ to be
 *         an entity of their native pointer type which can be
 *         included in a STL container.
 *
 *         For example:
 *                swig::LANGUAGE_OBJ  is  GC_VALUE in Ruby
 *                swig::LANGUAGE_OBJ  is  PyObject_ptr in python
 * 
 * 
 */

%module("templatereduce") li_std_map
%feature("trackobjects");

%include std_pair.i
%include std_map.i
%include std_multimap.i

%inline %{
struct A{
    int val;
    
    A(int v = 0): val(v)
    {
    }

};
%}

namespace std
{
  %template(pairii) pair<int, int>;
  %template(pairAA) pair<int, A>;
  %template(pairA) pair<int, A*>;
  %template(mapA) map<int, A*>;
  %template(mmapA) multimap<int, A*>;

  %template(paircA1) pair<const int, A*>;
  %template(paircA2) pair<const int, const A*>;
  %template(pairiiA) pair<int,pair<int, A*> >;
  %template(pairiiAc) pair<int,const pair<int, A*> >;


  %template() pair< swig::LANGUAGE_OBJ, swig::LANGUAGE_OBJ >;
  %template(LanguageMap) map< swig::LANGUAGE_OBJ, swig::LANGUAGE_OBJ >;
  
}



%inline 
{
std::pair<int, A*> 
p_identa(std::pair<int, A*> p) {
  return p;
}

std::map<int,A*> m_identa(const std::map<int,A*>& v)
{
  return v;
}

}



namespace std
{
%template(mapii) map<int,int>;
}
