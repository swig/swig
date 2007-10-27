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


    // Template specialization to construct a closed iterator for sets
    // this turns a nonconst iterator into a const one for ruby to avoid
    // allowing the user to change the value
    template< typename InOutIter >
    inline ConstIterator*
    make_set_nonconst_iterator(const InOutIter& current, 
			       const InOutIter& begin,
			       const InOutIter& end, 
			       VALUE seq = Qnil)
    {
      return new ConstIteratorClosed_T< InOutIter >(current, 
						    begin, end, seq);
    }

    // Template specialization to construct an open iterator for sets
    // this turns a nonconst iterator into a const one for ruby to avoid
    // allowing the user to change the value
    template< typename InOutIter >
    inline ConstIterator*
    make_set_nonconst_iterator(const InOutIter& current, 
			       VALUE seq = Qnil)
    {
      return new ConstIteratorOpen_T< InOutIter >(current, seq);
    }

  }
%}


%define %swig_set_methods(set...)

  %swig_sequence_methods_common(%arg(set));

// Redefine std::set iterator/reverse_iterator typemap
%typemap(out,noblock=1)
iterator, reverse_iterator {
  $result = SWIG_NewPointerObj(swig::make_set_nonconst_iterator(%static_cast($1,const $type &),
								self),
			       swig::ConstIterator::descriptor(),SWIG_POINTER_OWN);
 }


  %extend  {
    %alias push "<<";
    value_type push(const value_type& x) {
      self->insert(x);
      return x;
    }
  
    bool __contains__(const value_type& x) {
      return self->find(x) != self->end();
    }

    value_type __getitem__(difference_type i) const throw (std::out_of_range) {
      return *(swig::cgetpos(self, i));
    }

  };
%enddef


%mixin std::set "Enumerable";



%rename("delete")     std::set::__delete__;
%rename("reject!")    std::set::reject_bang;
%rename("map!")       std::set::map_bang;
%rename("empty?")     std::set::empty;
%rename("include?" )  std::set::__contains__ const;
%rename("has_key?" )  std::set::has_key const;

%alias  std::set::push          "<<";


%include <std/std_set.i>

