//
// std::deque

%include <std_container.i>

// Deque

%define %std_deque_methods(deque)  
  %std_sequence_methods(deque)

  void pop_front();
  void push_front(const value_type& x);
%enddef

%define %std_deque_methods_val(deque)
  %std_sequence_methods_val(deque)

  void pop_front();
  void push_front(value_type x);
%enddef

// ------------------------------------------------------------------------
// std::deque
// 
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::deque<T>), f(const std::deque<T>&):
//      the parameter being read-only, either a sequence or a
//      previously wrapped std::deque<T> can be passed.
//   -- f(std::deque<T>&), f(std::deque<T>*):
//      the parameter may be modified; therefore, only a wrapped std::deque
//      can be passed.
//   -- std::deque<T> f(), const std::deque<T>& f():
//      the deque is returned by copy; therefore, a sequence of T:s 
//      is returned which is most easily used in other functions
//   -- std::deque<T>& f(), std::deque<T>* f():
//      the deque is returned by reference; therefore, a wrapped std::deque
//      is returned
//   -- const std::deque<T>* f(), f(const std::deque<T>*):
//      for consistency, they expect and return a plain deque pointer.
// ------------------------------------------------------------------------

%{
#include <deque>
%}

// exported classes

namespace std {

  template<class T > class deque {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::deque<T >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdDequeTraits") {
      namespace swig {
	template <>  struct traits<std::deque<T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::deque<" #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_DEQUE, std::deque<T >);
  
    %std_deque_methods(deque);
    %swig_deque_methods(std::deque<T >);
  };

  template<class T > class deque<T*> {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T* value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type reference;
    typedef value_type const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::deque<T* >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdDequeTraits") {
      namespace swig {
	template <>  struct traits<std::deque<T* > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::deque<" #T " * >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_DEQUE, std::deque<T* >);

    %std_deque_methods_val(std::deque<T* >);
    %swig_deque_methods_val(std::deque<T* >);
  };

}

