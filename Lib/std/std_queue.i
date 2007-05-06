/**
 * @file   std_queue.i
 * @date   Sun May  6 01:48:07 2007
 * 
 * @brief  A wrapping of std::queue for Ruby.
 * 
 * 
 */

%include <std_container.i>

// Queue

%define %std_queue_methods(queue...)
  bool empty() const;
  size_type size() const;
  const value_type& front() const;
  const value_type& back() const;
  void pop();
  void push( const value_type& );
%enddef

%define %std_queue_methods_val(queue...) 
  %std_queue_methods(queue)
%enddef

// ------------------------------------------------------------------------
// std::queue
// 
// const declarations are used to guess the intent of the function being
// exported; therefore, the following rationale is applied:
// 
//   -- f(std::queue<T>), f(const std::queue<T>&):
//      the parameter being read-only, either a sequence or a
//      previously wrapped std::queue<T> can be passed.
//   -- f(std::queue<T>&), f(std::queue<T>*):
//      the parameter may be modified; therefore, only a wrapped std::queue
//      can be passed.
//   -- std::queue<T> f(), const std::queue<T>& f():
//      the queue is returned by copy; therefore, a sequence of T:s 
//      is returned which is most easily used in other functions
//   -- std::queue<T>& f(), std::queue<T>* f():
//      the queue is returned by reference; therefore, a wrapped std::queue
//      is returned
//   -- const std::queue<T>* f(), f(const std::queue<T>*):
//      for consistency, they expect and return a plain queue pointer.
// ------------------------------------------------------------------------

%{
#include <queue>
%}

// exported classes

namespace std {

  template<class _Tp, class _Alloc = allocator<_Tp> > 
  class queue {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef _Tp value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;
    typedef _Alloc allocator_type;

    %traits_swigtype(_Tp);

    %fragment(SWIG_Traits_frag(std::queue<_Tp, _Alloc >), "header",
	      fragment=SWIG_Traits_frag(_Tp),
	      fragment="StdQueueTraits") {
      namespace swig {
	template <>  struct traits<std::queue<_Tp, _Alloc > > {
	  typedef pointer_category category;
	  static const char* type_name() {
	    return "std::queue<" #_Tp " >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_QUEUE, std::queue<_Tp, _Alloc >);
  
#ifdef %swig_queue_methods
    // Add swig/language extra methods
    %swig_queue_methods(std::queue<_Tp, _Alloc >);
#endif

    %std_queue_methods(queue);
  };

  template<class _Tp, class _Alloc > 
  class queue<_Tp*, _Alloc > {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef _Tp* value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type reference;
    typedef value_type const_reference;
    typedef _Alloc allocator_type;

    %traits_swigtype(_Tp);

    %fragment(SWIG_Traits_frag(std::queue<_Tp*, _Alloc >), "header",
	      fragment=SWIG_Traits_frag(_Tp),
	      fragment="StdQueueTraits") {
      namespace swig {
	template <>  struct traits<std::queue<_Tp*, _Alloc > > {
	  typedef value_category category;
	  static const char* type_name() {
	    return "std::queue<" #_Tp " * >";
	  }
	};
      }
    }

    %typemap_traits_ptr(SWIG_TYPECHECK_QUEUE, std::queue<_Tp*, _Alloc >);

#ifdef %swig_queue_methods_val
    // Add swig/language extra methods
    %swig_queue_methods_val(std::queue<_Tp*, _Alloc >);
#endif

    %std_queue_methods_val(std::queue<_Tp*, _Alloc >);
  };

}

