/*
  Multisets
*/

%include <std_unordered_set.i>

%fragment("StdUnorderedMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class RubySeq, class T>
    inline void
    assign(const RubySeq& rubyseq, std::unordered_multiset<T>* seq) {
      // seq->insert(rubyseq.begin(), rubyseq.end()); // not used as not always implemented
      typedef typename RubySeq::value_type value_type;
      typename RubySeq::const_iterator it = rubyseq.begin();
      for (;it != rubyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
    }

    template <class T>
    struct traits_asptr<std::unordered_multiset<T> >  {
      static int asptr(VALUE obj, std::unordered_multiset<T> **m) {
	return traits_asptr_stdseq<std::unordered_multiset<T> >::asptr(obj, m);
      }
    };

    template <class T>
    struct traits_from<std::unordered_multiset<T> > {
      static VALUE from(const std::unordered_multiset<T>& vec) {
	return traits_from_stdseq<std::unordered_multiset<T> >::from(vec);
      }
    };
  }
%}

#define %swig_unordered_multiset_methods(Set...) %swig_unordered_set_methods(Set)



%rename("delete")     std::unordered_multiset::__delete__;
%rename("reject!")    std::unordered_multiset::reject_bang;
%rename("map!")       std::unordered_multiset::map_bang;
%rename("empty?")     std::unordered_multiset::empty;
%rename("include?")  std::unordered_multiset::__contains__ const;
%rename("has_key?")  std::unordered_multiset::has_key const;

%alias  std::unordered_multiset::push          "<<";

%include <std/std_unordered_multiset.i>
