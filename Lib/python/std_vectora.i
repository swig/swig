//
// std::vector<T,A>
// Python implementation
//
// First attemp to add allocators. Still, the plain version
// works much better. So, if tyou don't need allocators, use
// std_vector.i instead.
//

%include std_container.i

// Vector

%define %std_vector_methods(vector)
  %std_sequence_methods(SWIG_arg(vector))
  
  void reserve(size_type n);
  size_type capacity() const;
%enddef


%define %std_vector_methods_val(vector)
  %std_sequence_methods_val(SWIG_arg(vector))
  
  void reserve(size_type n);
  size_type capacity() const;
%enddef


// ------------------------------------------------------------------------
// std::vector
// 
// The aim of all that follows would be to integrate std::vector with 
// Python as much as possible, namely, to allow the user to pass and 
// be returned Python tuples or lists.
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::vector<T,A>), f(const std::vector<T,A>&):
//      the parameter being read-only, either a Python sequence or a
//      previously wrapped std::vector<T,A> can be passed.
//   -- f(std::vector<T,A>&), f(std::vector<T,A>*):
//      the parameter may be modified; therefore, only a wrapped std::vector
//      can be passed.
//   -- std::vector<T,A> f(), const std::vector<T,A>& f():
//      the vector is returned by copy; therefore, a Python sequence of T:s 
//      is returned which is most easily used in other Python functions
//   -- std::vector<T,A>& f(), std::vector<T,A>* f():
//      the vector is returned by reference; therefore, a wrapped std::vector
//      is returned
//   -- const std::vector<T,A>* f(), f(const std::vector<T,A>*):
//      for consistency, they expect and return a plain vector pointer.
// ------------------------------------------------------------------------

%{
#include <vector>
%}

    
%fragment("StdVectorTraits","header",fragment="StdSequenceTraits")
%{
  namespace swigpy {
    template <class T, class A>
      struct traits_asptr<std::vector<T,A> >  {
      typedef std::vector<T,A> vector_type;
      typedef T value_type;
      static int asptr(PyObject *obj, vector_type **vec) {
	return traits_asptr_stdseq<vector_type>::asptr(obj, vec);
      }
    };

    template <class T, class A>
    struct traits_from<std::vector<T,A> > {
      typedef std::vector<T,A> vector_type;
      static PyObject *from(const vector_type& vec) {
	return traits_from_stdseq<vector_type>::from(vec);
      }
    };
  }
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
	      fragment="StdVectorTraits") {
      namespace swigpy {
	template <>  struct traits<std::vector<T,A > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::vector<" #T "," #A " >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_CCode(VECTOR), std::vector<T,A >);
  
  %std_vector_methods(SWIG_arg(vector<T,A >));
    %pysequence_methods(SWIG_arg(std::vector<T,A >));
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
	      fragment="StdVectorTraits") {
      namespace swigpy {
	template <>  struct traits<std::vector<T*,A > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::vector<" #T " *,"#A" >";
	  }
	};
      }
    }

    %typemap_traits(SWIG_CCode(VECTOR), std::vector<T*,A >);

    %std_vector_methods_val(vector);
    %pysequence_methods_val(SWIG_arg(std::vector<T*,A >));
  };

  // Add the order operations <,>,<=,=> as needed
  /*
  %define %std_order_vector(T)
    %std_comp_methods(vector<T,A>);
  %enddef
  
  %apply_otypes(%std_order_vector);

  // bool specialization
  %extend vector<bool> {
    void flip() 
    {
      self->flip();
    }
  }
  */
}


%define %std_vector_ptypen(...) 
namespace std {
  %template() vector<__VA_ARGS__, std::allocator<__VA_ARGS__ > >;

  //
  // These extra %apply are needed since swig doesn't try 
  // std::vector<int> and std::vector<int, std::allocator<int> > as
  // the same type yet. When this get fixed, these %apply should be
  // removed (and maybe we will be able to have an unique std_vector.i
  // definition too).
  //
  %apply vector<__VA_ARGS__, std::allocator<__VA_ARGS__ > > {
    vector<__VA_ARGS__ >
  }
  %apply const vector<__VA_ARGS__, std::allocator<__VA_ARGS__ > >& {
    const vector<__VA_ARGS__ >&
  }
}
%enddef

%apply_cpptypes(%std_vector_ptypen);

