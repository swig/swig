/*
  Sets
*/

%fragment("StdSetTraits","header",fragment="StdSequenceTraits")
%{
  namespace swig {
    template <class RubySeq, class T> 
    inline void 
    assign(const RubySeq& rubyseq, std::set<T>* seq) {
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
    struct traits_asptr<std::set<T> >  {
      static int asptr(VALUE obj, std::set<T> **s) {  
	return traits_asptr_stdseq<std::set<T> >::asptr(obj, s);
      }
    };

    template <class T>
    struct traits_from<std::set<T> > {
      static VALUE from(const std::set<T>& vec) {
	return traits_from_stdseq<std::set<T> >::from(vec);
      }
    };
  }
%}

%define %swig_set_methods(set...)
  %swig_sequence_methods_common(set); 

  %extend  {
    %alias push "<<";
    value_type push(const value_type& x) {
      self->insert(x);
      return x;
    }
  
    %rename("include?") __contains__;
    bool __contains__(const value_type& x) {
      return self->find(x) != self->end();
    }

    value_type __getitem__(difference_type i) const throw (std::out_of_range) {
      return *(swig::cgetpos(self, i));
    }

  };
%enddef

#if defined(SWIG_RUBY_AUTORENAME)

  %mixin std::set "Enumerable";
  %rename("empty?") std::set::empty;

#else

  %mixin std::set "Enumerable";
  %rename("empty?") std::set::empty;

#endif


%include <std/std_set.i>
