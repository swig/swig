/*
  Multisets
*/

%include <std_set.i>

%fragment("StdMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class RubySeq, class T> 
    inline void
    assign(const RubySeq& rubyseq, std::multiset<T>* seq) {
#ifdef SWIG_STD_NOINSERT_TEMPLATE_STL
      typedef typename RubySeq::value_type value_type;
      typename RubySeq::const_iterator it = rubyseq.begin();
      for (;it != rubyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
#else
      seq->insert(rubyseq.begin(), rubyseq.end());
#endif
    }

    template <class T>
    struct traits_asptr<std::multiset<T> >  {
      static int asptr(VALUE obj, std::multiset<T> **m) {
	return traits_asptr_stdseq<std::multiset<T> >::asptr(obj, m);
      }
    };

    template <class T>
    struct traits_from<std::multiset<T> > {
      static VALUE from(const std::multiset<T>& vec) {
	return traits_from_stdseq<std::multiset<T> >::from(vec);
      }
    };
  }
%}

#define %swig_multiset_methods(Set...) %swig_set_methods(Set)



%include <std/std_multiset.i>
