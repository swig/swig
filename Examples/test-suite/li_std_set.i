/**
 * @file   li_std_set.i
 * @author gga
 * @date   Tue May  1 02:52:47 2007
 * 
 * @brief  a test of set containers. 
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

%module li_std_set

%include <std_string.i>
%include <std_set.i>
%include <std_multiset.i>
%include <std_vector.i>

%template(set_string) std::set<std::string>;
%template(set_int) std::multiset<int>;


%template(v_int) std::vector<int>;




%template(LanguageSet) std::set<swig::LANGUAGE_OBJ>; 
