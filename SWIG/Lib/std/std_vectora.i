//
// std::vector<T,A>
//
//
// First attemp to add allocators. Still, the plain version
// works much better. So, if tyou don't need allocators, use
// std_vector.i instead.
//

%include <std_container.i>

// Vector

%define %std_vector_methods(vector...)
  %std_sequence_methods(SWIG_arg(vector))
  
  void reserve(size_type n);
  size_type capacity() const;
%enddef


%define %std_vector_methods_val(vector...)
  %std_sequence_methods_val(SWIG_arg(vector))
  
  void reserve(size_type n);
  size_type capacity() const;
%enddef


// ------------------------------------------------------------------------
// std::vector
// 
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T,A>), f(const std::vector<T,A>&):
//      the parameter being read-only, either a sequence or a
//      previously wrapped std::vector<T,A> can be passed.
//   -- f(std::vector<T,A>&), f(std::vector<T,A>*):
//      the parameter may be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T,A> f(), const std::vector<T,A>& f():
//      the vector is returned by copy; therefore, a sequence of T:s 
//      is returned which is most easily used in other functions
//   -- std::vector<T,A>& f(), std::vector<T,A>* f():
//      the vector is returned by reference; therefore, a wrapped std::vector
//      is returned
//   -- const std::vector<T,A>* f(), f(const std::vector<T,A>*):
//      for consistency, they expect and return a plain vector pointer.
// ------------------------------------------------------------------------

%{
#include <vector>
%}    

// exported classes

namespace std {

  template<class T, class A = std::allocator<T > >
  class vector {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef T value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef T& reference;
    typedef const T& const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::vector<T,A >), "header",
	      fragment=SWIG_Traits_frag(T),
	      fragment="StdVectorATraits") {
      namespace swig {
	template <>  struct traits<std::vector<T,A > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::vector<" #T "," #A " >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_TYPECHECK_VECTOR, std::vector<T,A >);
  
    %std_vector_methods(vector<T,A >);
    %swig_vector_methods(std::vector<T,A >);
  };


  // ***
  // This pointer especialization should dissapears or get
  // simplified when a 'const SWIGTYPE*&' can be be defined.
  // ***
  template<class T, class A = std::allocator<T*> >
  class vector<T*,A> {
  public:
    typedef size_t size_type;    
    typedef ptrdiff_t difference_type;
    typedef T* value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type reference;
    typedef value_type const_reference;

    %traits_swigtype(T);

    %fragment(SWIG_Traits_frag(std::vector<T*,A >), "header",
	      fragment="StdVectorATraits") {
      namespace swig {
	template <>  struct traits<std::vector<T*,A > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::vector<" #T " *,"#A" >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_TYPECHECK_VECTOR, std::vector<T*,A >);

    %std_vector_methods_val(vector);
    %swig_vector_methods_val(std::vector<T*,A >);
  };


  // bool specialization
  %extend vector<bool,std::allocator<bool> > {
    void flip() 
    {
      self->flip();
    }
  }
}

