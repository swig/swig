//
// std::vector
//

%include <std_container.i>

// Vector

%define %std_vector_methods(vector)
  %std_sequence_methods(vector)
  
  void reserve(size_type n);
  size_type capacity() const;
%enddef


%define %std_vector_methods_val(vector)
  %std_sequence_methods_val(vector)
  
  void reserve(size_type n);
  size_type capacity() const;
%enddef


// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// as much as possible, namely, to allow the user to pass and 
// be returned tuples or lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T>), f(const std::vector<T>&):
//      the parameter being read-only, either a sequence or a
//      previously wrapped std::vector<T> can be passed.
//   -- f(std::vector<T>&), f(std::vector<T>*):
//      the parameter may be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T> f(), const std::vector<T>& f():
//      the vector is returned by copy; therefore, a sequence of T:s 
//      is returned which is most easily used in other functions
//   -- std::vector<T>& f(), std::vector<T>* f():
//      the vector is returned by reference; therefore, a wrapped std::vector
//      is returned
//   -- const std::vector<T>* f(), f(const std::vector<T>*):
//      for consistency, they expect and return a plain vector pointer.
// ------------------------------------------------------------------------

%{
#include <vector>
%}    

// exported classes

#if !defined(SWIG_STD_MODERN_STL) || defined(SWIG_STD_NOMODERN_STL) 
%ignore std::vector<bool>::flip();
#endif

namespace std {

  template<class T > class vector {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef T& reference;
    typedef const T& const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::vector<T >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdVectorTraits") {
      namespace swig {
	template <>  struct traits<std::vector<T > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::vector<" #T " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<T >);
  
    %std_vector_methods(vector);
    %swig_vector_methods(std::vector<T >);
  };

  // bool specialization
  %extend vector<bool> {
    void flip() 
    {
      self->flip();
    }
  }


  // ***
  // This specialization should dissapear or get simplified when
  // a 'const SWIGTYPE*&' can be defined
  // ***
  template<class T > class vector<T*> {
  public:
    typedef size_t size_type;    
    typedef ptrdiff_t difference_type;
    typedef T* value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type reference;
    typedef value_type const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::vector<T* >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdVectorTraits") {
      namespace swig {
	template <>  struct traits<std::vector<T* > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::vector<" #T " * >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<T* >);

    %std_vector_methods_val(vector);
    %swig_vector_methods_val(std::vector<T* >);
  };

  // ***
  // ***
  template<class T > class vector<bool> {
  public:
    typedef size_t size_type;    
    typedef ptrdiff_t difference_type;
    typedef bool value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type reference;
    typedef value_type const_reference;

    %traits_swigtype(bool);

    %fragment(SWIG_Traits_frag(std::vector<bool>), "header",
	      fragment=SWIG_Traits_frag(bool),
	      fragment="StdVectorTraits") {
      namespace swig {
	template <>  struct traits<std::vector<bool> > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::vector<bool>";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_VECTOR, std::vector<bool>);

    %std_vector_methods_val(vector<bool>);
    %swig_vector_methods_val(std::vector<bool>);
  };

}
