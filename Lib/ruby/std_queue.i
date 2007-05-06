/*
  Queues
*/

%fragment("StdQueueTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class T>
    struct traits_asptr<std::queue<T> >  {
      static int asptr(VALUE obj, std::queue<T>  **vec) {
	return traits_asptr_stdseq<std::queue<T> >::asptr(obj, vec);
      }
    };

    template <class T>
    struct traits_from<std::queue<T> > {
      static VALUE from(const std::queue<T> & vec) {
	return traits_from_stdseq<std::queue<T> >::from(vec);
      }
    };
  }
%}

%include <std/std_queue.i>
