//
// std::map
//

%include <std_pair.i>
%include <std_container.i>

%define %std_map_methods_common(map...)
  %std_container_methods(map);

  size_type erase(const key_type& x);
  size_type count(const key_type& x) const;

#ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(iterator position, const value_type& x);
  void erase(iterator position);
  void erase(iterator first, iterator last);

  iterator find(const key_type& x);
  const_iterator find(const key_type& x) const;
  iterator lower_bound(const key_type& x);
  const_iterator lower_bound(const key_type& x) const;
  iterator upper_bound(const key_type& x);
  const_iterator upper_bound(const key_type& x) const;
#endif
%enddef

%define %std_map_methods(map...)
  %std_map_methods_common(map);

  #ifdef SWIG_EXPORT_ITERATOR_METHODS
  iterator insert(const value_type& x);
  #endif
%enddef


// **** Note ****
// 
// If you are going to use a map, you need to instantiate both the 
// map and the pair class:
//
//   %template(pair_ii) std::pair<int, int>;
//   %template(map_ii) std::map<int, int>;
//
// or
//
//   %template() std::pair<int, int>;
//   %template(map_ii) std::map<int, int>;
//
// **** Note ****
// ------------------------------------------------------------------------
// std::map
// 
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::map<T>), f(const std::map<T>&):
//      the parameter being read-only, either a sequence or a
//      previously wrapped std::map<T> can be passed.
//   -- f(std::map<T>&), f(std::map<T>*):
//      the parameter may be modified; therefore, only a wrapped std::map
//      can be passed.
//   -- std::map<T> f(), const std::map<T>& f():
//      the map is returned by copy; therefore, a sequence of T:s 
//      is returned which is most easily used in other functions
//   -- std::map<T>& f(), std::map<T>* f():
//      the map is returned by reference; therefore, a wrapped std::map
//      is returned
//   -- const std::map<T>* f(), f(const std::map<T>*):
//      for consistency, they expect and return a plain map pointer.
// ------------------------------------------------------------------------

%{
#include <map>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {

  template<class K, class T> class map {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef K key_type;
    typedef T mapped_type;
    typedef std::pair<const K, T> value_type;

    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    %traits_swigtype(K);
    %traits_swigtype(T);	    

    %fragment(SWIG_Traits_frag(std::map<K, T >), "header",
	      fragment=SWIG_Traits_frag(std::pair<K, T >),
	      fragment="StdMapTraits") {
      namespace swig {
	template <>  struct traits<std::map<K, T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::map<" #K "," #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_MAP, std::map<K, T >);
  
    %std_map_methods(map);

#ifdef %swig_map_methods
    // Add swig/language extra methods
    %swig_map_methods(std::map<K, T >);
#endif
  };

}
