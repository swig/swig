/*
  Stacks
*/

%fragment("StdStackTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class T>
    struct traits_asptr<std::stack<T> >  {
      static int asptr(VALUE obj, std::stack<T>  **vec) {
	return traits_asptr_stdseq<std::stack<T> >::asptr(obj, vec);
      }
    };

    template <class T>
    struct traits_from<std::stack<T> > {
      static VALUE from(const std::stack<T> & vec) {
	return traits_from_stdseq<std::stack<T> >::from(vec);
      }
    };
  }
%}

%include <std/std_stack.i>
