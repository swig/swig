//
// std::list
//

%include <std_container.i>

// List

%define %std_list_methods(list)
  %std_sequence_methods(list)
  
  void pop_front();
  void push_front(const value_type& x);
  		
  void reverse();
  
%enddef


%define %std_list_methods_val(list)
  %std_sequence_methods_val(list)
  
  void pop_front();
  void push_front(value_type x);
  		
  void remove(value_type x);
  void unique();
  void reverse();
  void sort();
  
  void merge(list& x);
%enddef

// ------------------------------------------------------------------------
// std::list
// 
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::list<T>), f(const std::list<T>&):
//      the parameter being read-only, either a sequence or a
//      previously wrapped std::list<T> can be passed.
//   -- f(std::list<T>&), f(std::list<T>*):
//      the parameter may be modified; therefore, only a wrapped std::list
//      can be passed.
//   -- std::list<T> f(), const std::list<T>& f():
//      the list is returned by copy; therefore, a sequence of T:s 
//      is returned which is most easily used in other functions
//   -- std::list<T>& f(), std::list<T>* f():
//      the list is returned by reference; therefore, a wrapped std::list
//      is returned
//   -- const std::list<T>* f(), f(const std::list<T>*):
//      for consistency, they expect and return a plain list pointer.
// ------------------------------------------------------------------------

%{
#include <list>
%}

// exported classes

namespace std {

  template<class T > class list {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::list<T >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdListTraits") {
      namespace swig {
	template <>  struct traits<std::list<T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::list<" #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_LIST, std::list<T >);
  
    %std_list_methods(list);

#ifdef %swig_list_methods
    // Add swig/language extra methods
    %swig_list_methods(std::list<T >);
#endif
  };

  template<class T > class list<T*> {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T* value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type reference;
    typedef value_type const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::list<T* >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdListTraits") {
      namespace swig {
	template <>  struct traits<std::list<T* > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::list<" #T " * >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_LIST, std::list<T* >);

    %std_list_methods_val(list);

#ifdef %swig_list_methods_val
    // Add swig/language extra methods
    %swig_list_methods_val(std::list<T* >);
#endif
  };

}

%define %std_extequal_list(...)
%extend std::list<__VA_ARGS__ > { 
  void remove(const value_type& x) { self->remove(x); }  
  void merge(std::list<__VA_ARGS__ >& x){ self->merge(x); }  
  void unique() { self->unique(); }  
  void sort() { self->sort(); }  
}
%enddef

