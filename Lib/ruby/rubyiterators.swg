/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * rubyiterators.swg
 *
 * Implement a C++ 'output' iterator for Ruby.
 *
 * Users can derive form the Iterator to implemet their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template Iterator_T does the
 * implementation for generic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>


/** 
 * Abstract base class used to represent all iterators of STL containers.
 */
%fragment("ConstIterator","header") {  
namespace swig {
  struct stop_iteration {
  };

  struct ConstIterator {
  protected:
    VALUE _seq;

  protected:
    ConstIterator(VALUE seq) : _seq(seq)
    {
    }
      
  public:
    virtual ~ConstIterator() {}

    // Access iterator method, required by Ruby
    virtual VALUE value() const = 0;

    // Forward iterator method, required by Ruby
    virtual ConstIterator *incr(size_t n = 1) = 0;
    
    // Backward iterator method, very common in C++, but not required in Ruby
    virtual ConstIterator *decr(size_t n = 1)
    {
      throw stop_iteration();
    }

    // Random access iterator methods, but not required in Ruby
    virtual ptrdiff_t distance(const ConstIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const ConstIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }
    
    // C++ common/needed methods
    virtual ConstIterator *dup() const = 0;

    VALUE next()
    {
      VALUE obj = value();
      incr();
      return obj;
    }

    VALUE previous()
    {
      decr();
      return value();
    }

    ConstIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }
      
    bool operator == (const ConstIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const ConstIterator& x) const
    {
      return ! operator==(x);
    }
      
    ConstIterator& operator += (ptrdiff_t n)
    {
      return *advance(n);
    }

    ConstIterator& operator -= (ptrdiff_t n)
    {
      return *advance(-n);
    }
      
    ConstIterator* operator + (ptrdiff_t n) const
    {
      return dup()->advance(n);
    }

    ConstIterator* operator - (ptrdiff_t n) const
    {
      return dup()->advance(-n);
    }
      
    ptrdiff_t operator - (const ConstIterator& x) const
    {
      return x.distance(*this);
    }
      
    static swig_type_info* descriptor() {
      static int init = 0;
      static swig_type_info* desc = 0;
      if (!init) {
	desc = SWIG_TypeQuery("swig::ConstIterator *");
	init = 1;
      }	
      return desc;
    }

    // Ruby common/needed printing methods
    virtual VALUE inspect() const = 0;
    virtual VALUE to_s()    const = 0;
  };

  struct Iterator : public ConstIterator {
  protected:
    Iterator(VALUE seq) : ConstIterator(seq)
    {
    }

  public:
    // Iterator setter method, required by Ruby
    virtual bool set( const VALUE& v ) = 0;

    static swig_type_info* descriptor() {
      static int init = 0;
      static swig_type_info* desc = 0;
      if (!init) {
	desc = SWIG_TypeQuery("swig::Iterator *");
	init = 1;
      }	
      return desc;
    }

    // C++ common/needed methods
    virtual Iterator *dup() const = 0;

    Iterator *advance(ptrdiff_t n)
    {
      return (Iterator*) ( (n > 0) ?  incr(n) : decr(-n) );
    }
      
    bool operator == (const ConstIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const Iterator& x) const
    {
      return ! operator==(x);
    }
      
    Iterator& operator += (ptrdiff_t n)
    {
      return *advance(n);
    }

    Iterator& operator -= (ptrdiff_t n)
    {
      return *advance(-n);
    }
      
    Iterator* operator + (ptrdiff_t n) const
    {
      return dup()->advance(n);
    }

    Iterator* operator - (ptrdiff_t n) const
    {
      return dup()->advance(-n);
    }
      
    ptrdiff_t operator - (const Iterator& x) const
    {
      return x.distance(*this);
    }
  };

}
}


%fragment("ConstIterator_T","header",fragment="ConstIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace swig {

  /** 
   * Abstract base classes for all custom const_iterators.
   *
   */
  template<typename OutConstIterator>
  class ConstIterator_T :  public ConstIterator
  {
  public:
    typedef OutConstIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;    
    typedef ConstIterator_T<out_iterator> self_type;

    ConstIterator_T(out_iterator curr, VALUE seq = Qnil)
      : ConstIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }

    
    bool equal (const ConstIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    virtual ptrdiff_t distance(const ConstIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return std::distance(current, iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    virtual VALUE inspect() const
    {
      VALUE ret = rb_str_new2("#<");
      ret = rb_str_cat2( ret, rb_obj_classname(_seq) );
      ret = rb_str_cat2( ret, "::const_iterator " );
      VALUE cur = value();
      ret = rb_str_concat( ret, rb_inspect(cur) );
      ret = rb_str_cat2( ret, ">" );
      return ret;
    }

    virtual VALUE to_s()    const
    {
      VALUE ret = rb_str_new2( rb_obj_classname(_seq) );
      ret = rb_str_cat2( ret, "::const_iterator " );
      VALUE cur = value();
      ret = rb_str_concat( ret, rb_obj_as_string(cur) );
      return ret;
    }

  protected:
    out_iterator current;
  };


  /** 
   * Abstract base classes for all custom iterators.
   *
   */
  template<typename InOutIterator>
  class Iterator_T :  public Iterator
  {
  public:
    typedef InOutIterator inout_iterator;
    typedef typename std::iterator_traits<inout_iterator>::value_type value_type;    
    typedef Iterator_T<inout_iterator> self_type;

    Iterator_T(inout_iterator curr, VALUE seq = Qnil)
      : Iterator(seq), current(curr)
    {
    }

    const inout_iterator& get_current() const
    {
      return current;
    }

    bool equal (const ConstIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    virtual ptrdiff_t distance(const ConstIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return std::distance(current, iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    virtual VALUE inspect() const
    {
      VALUE ret = rb_str_new2("#<");
      ret = rb_str_cat2( ret, rb_obj_classname(_seq) );
      ret = rb_str_cat2( ret, "::iterator " );
      VALUE cur = value();
      ret = rb_str_concat( ret, rb_inspect(cur) );
      ret = rb_str_cat2( ret, ">" );
      return ret;
    }

    virtual VALUE to_s()    const
    {
      VALUE ret = rb_str_new2( rb_obj_classname(_seq) );
      ret = rb_str_cat2( ret, "::iterator " );
      VALUE cur = value();
      ret = rb_str_concat( ret, rb_obj_as_string(cur) );
      return ret;
    }

  protected:
    inout_iterator current;
  };


  
  template <class ValueType>
  struct asval_oper 
  {
    typedef ValueType    value_type;
    typedef bool        result_type;
    bool operator()(VALUE obj, value_type& v) const
    {
      return ( swig::asval< value_type >(obj, &v) == SWIG_OK );
    }
  };

  template <class ValueType>
  struct from_oper 
  {
    typedef const ValueType& argument_type;
    typedef VALUE result_type;
    result_type operator()(argument_type v) const
    {
      return swig::from(v);
    }
  };


  /** 
   * ConstIterator class for a const_iterator with no end() boundaries.
   *
   */
  template<typename OutConstIterator, 
	   typename ValueType = typename std::iterator_traits<OutConstIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class ConstIteratorOpen_T :  public ConstIterator_T<OutConstIterator>
  {
  public:
    FromOper from;
    typedef OutConstIterator out_iterator;
    typedef ValueType value_type;
    typedef ConstIterator_T<out_iterator>  base;
    typedef ConstIteratorOpen_T<OutConstIterator, ValueType, FromOper> self_type;
    
    ConstIteratorOpen_T(out_iterator curr, VALUE seq = Qnil)
      : ConstIterator_T<OutConstIterator>(curr, seq)
    {
    }
    
    virtual VALUE value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }
    
    ConstIterator *dup() const
    {
      return new self_type(*this);
    }

    ConstIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    ConstIterator *decr(size_t n = 1)
    {
      while (n--) {
	--base::current;
      }
      return this;
    }
  };

  /** 
   * Iterator class for an iterator with no end() boundaries.
   *
   */
  template<typename InOutIterator, 
	   typename ValueType = typename std::iterator_traits<InOutIterator>::value_type,
	   typename FromOper = from_oper<ValueType>,
	   typename AsvalOper = asval_oper<ValueType> >
  class IteratorOpen_T :  public Iterator_T<InOutIterator>
  {
  public:
    FromOper  from;
    AsvalOper asval;
    typedef InOutIterator inout_iterator;
    typedef ValueType value_type;
    typedef Iterator_T<inout_iterator>  base;
    typedef IteratorOpen_T<InOutIterator, ValueType, FromOper, AsvalOper> self_type;
    
    IteratorOpen_T(inout_iterator curr, VALUE seq = Qnil)
      : Iterator_T<InOutIterator>(curr, seq)
    {
    }
    
    virtual VALUE value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }

    virtual bool set( const VALUE& v )
    {
      value_type& dst = *base::current;
      return asval(v, dst);
    }
    
    Iterator *dup() const
    {
      return new self_type(*this);
    }

    Iterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    Iterator *decr(size_t n = 1)
    {
      while (n--) {
	--base::current;
      }
      return this;
    }
  };

  /** 
   * ConstIterator class for a const_iterator where begin() and end() boundaries are known.
   *
   */
  template<typename OutConstIterator, 
	   typename ValueType = typename std::iterator_traits<OutConstIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class ConstIteratorClosed_T :  public ConstIterator_T<OutConstIterator>
  {
  public:
    FromOper from;
    typedef OutConstIterator out_iterator;
    typedef ValueType value_type;
    typedef ConstIterator_T<out_iterator>  base;    
    typedef ConstIteratorClosed_T<OutConstIterator, ValueType, FromOper> self_type;
    
    ConstIteratorClosed_T(out_iterator curr, out_iterator first, 
			  out_iterator last, VALUE seq = Qnil)
      : ConstIterator_T<OutConstIterator>(curr, seq), begin(first), end(last)
    {
    }
    
    virtual VALUE value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }
    
    
    ConstIterator *dup() const
    {
      return new self_type(*this);
    }

    ConstIterator *incr(size_t n = 1)
    {
      while (n--) {
	if (base::current == end) {
	  throw stop_iteration();
	} else {
	  ++base::current;
	}
      }
      return this;
    }

    ConstIterator *decr(size_t n = 1)
    {
      while (n--) {
	if (base::current == begin) {
	  throw stop_iteration();
	} else {
	  --base::current;
	}
      }
      return this;
    }

  private:
    out_iterator begin;
    out_iterator end;
  };

  /** 
   * Iterator class for a const_iterator where begin() and end() boundaries are known.
   *
   */
  template<typename InOutIterator, 
	   typename ValueType = typename std::iterator_traits<InOutIterator>::value_type,
	   typename FromOper = from_oper<ValueType>,
	   typename AsvalOper = asval_oper<ValueType> >
  class IteratorClosed_T :  public Iterator_T<InOutIterator>
  {
  public:
    FromOper   from;
    AsvalOper asval;
    typedef InOutIterator inout_iterator;
    typedef ValueType value_type;
    typedef Iterator_T<inout_iterator>  base;
    typedef IteratorClosed_T<InOutIterator, ValueType, FromOper, AsvalOper> self_type;
    
    IteratorClosed_T(inout_iterator curr, inout_iterator first, 
		     inout_iterator last, VALUE seq = Qnil)
      : Iterator_T<InOutIterator>(curr, seq), begin(first), end(last)
    {
    }
    
    virtual VALUE value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }
    
    // Iterator setter method, required by Ruby
    virtual bool set( const VALUE& v )
    {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	value_type& dst = *base::current;
	return asval( v, dst );
      }
    }
    
    Iterator *dup() const
    {
      return new self_type(*this);
    }

    Iterator *incr(size_t n = 1)
    {
      while (n--) {
	if (base::current == end) {
	  throw stop_iteration();
	} else {
	  ++base::current;
	}
      }
      return this;
    }

    Iterator *decr(size_t n = 1)
    {
      while (n--) {
	if (base::current == begin) {
	  throw stop_iteration();
	} else {
	  --base::current;
	}
      }
      return this;
    }

  private:
    inout_iterator begin;
    inout_iterator end;
  };

  /* Partial specialization for bools which don't allow de-referencing */
  template< typename InOutIterator, typename FromOper, typename AsvalOper >
  class IteratorOpen_T< InOutIterator, bool, FromOper, AsvalOper > : 
    public Iterator_T<InOutIterator>
  {
  public:
    FromOper   from;
    AsvalOper asval;
    typedef InOutIterator inout_iterator;
    typedef bool value_type;
    typedef Iterator_T<inout_iterator>  base;
    typedef IteratorOpen_T<InOutIterator, bool, FromOper, AsvalOper> self_type;

    IteratorOpen_T(inout_iterator curr, VALUE seq = Qnil)
      : Iterator_T<InOutIterator>(curr, seq)
    {
    }

    virtual VALUE value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }
    
    virtual bool set( const VALUE& v )
    {
      return false;
    }    
    
    Iterator *dup() const
    {
      return new self_type(*this);
    }

    Iterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    Iterator *decr(size_t n = 1)
    {
      while (n--) {
	--base::current;
      }
      return this;
    }
    
  };

  /* Partial specialization for bools which don't allow de-referencing */
  template< typename InOutIterator, typename FromOper, typename AsvalOper >
  class IteratorClosed_T< InOutIterator, bool, FromOper, AsvalOper > : 
    public Iterator_T<InOutIterator>
  {
  public:
    FromOper   from;
    AsvalOper asval;
    typedef InOutIterator inout_iterator;
    typedef bool value_type;
    typedef Iterator_T<inout_iterator>  base;
    typedef IteratorClosed_T<InOutIterator, bool, FromOper, AsvalOper> self_type;
    
    IteratorClosed_T(inout_iterator curr, inout_iterator first, 
		     inout_iterator last, VALUE seq = Qnil)
      : Iterator_T<InOutIterator>(curr, seq), begin(first), end(last)
    {
    }

    virtual VALUE value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }

    virtual bool set( const VALUE& v )
    {
      return false;
    }
    
    Iterator *dup() const
    {
      return new self_type(*this);
    }

    Iterator *incr(size_t n = 1)
    {
      while (n--) {
	if (base::current == end) {
	  throw stop_iteration();
	} else {
	  ++base::current;
	}
      }
      return this;
    }

    Iterator *decr(size_t n = 1)
    {
      while (n--) {
	if (base::current == begin) {
	  throw stop_iteration();
	} else {
	  --base::current;
	}
      }
      return this;
    }

  private:
    inout_iterator begin;
    inout_iterator end;
    
  };


  /** 
   * Helper function used to wrap a bounded const_iterator.  This is to be used in
   * a %typemap(out), for example.
   *
   */
  template<typename InOutIter>
  inline Iterator*
  make_inout_iterator(const InOutIter& current, const InOutIter& begin,
		      const InOutIter& end, VALUE seq = Qnil)
  {
    return new IteratorClosed_T<InOutIter>(current, begin, end, seq);
  }

  /** 
   * Helper function used to wrap an unbounded const_iterator.  This is to be used in
   * a %typemap(out), for example.
   *
   */
  template<typename InOutIter>
  inline Iterator*
  make_inout_iterator(const InOutIter& current, VALUE seq = Qnil)
  {
    return new IteratorOpen_T<InOutIter>(current, seq);
  }

  /** 
   * Helper function used to wrap a bounded const_iterator.  This is to be used in
   * a %typemap(out), for example.
   *
   */
  template<typename OutIter>
  inline ConstIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,
                       const OutIter& end, VALUE seq = Qnil)
  {
    return new ConstIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  /** 
   * Helper function used to wrap an unbounded const_iterator.  This is to be used in
   * a %typemap(out), for example.
   *
   */
  template<typename OutIter>
  inline ConstIterator*
  make_output_iterator(const OutIter& current, VALUE seq = Qnil)
  {
    return new ConstIteratorOpen_T<OutIter>(current, seq);
  }
}
}


%fragment("ConstIterator");


//
// This part is just so SWIG is aware of the base abstract iterator class.
//
namespace swig 
{
  /*
    Throw a StopIteration exception
  */
  %ignore stop_iteration;
  struct stop_iteration {};
  
  %typemap(throws) stop_iteration {
    (void)$1;
    SWIG_Ruby_ExceptionType(NULL, Qnil);
    SWIG_fail;
  }

  /* 
     Mark methods that return new objects
  */
  %newobject ConstIterator::dup;
  %newobject ConstIterator::operator + (ptrdiff_t n) const;
  %newobject ConstIterator::operator - (ptrdiff_t n) const;

  %nodirector ConstIterator;

  %catches(swig::stop_iteration)  ConstIterator::value() const;
  %catches(swig::stop_iteration)  ConstIterator::incr(size_t n = 1);
  %catches(swig::stop_iteration)  ConstIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) ConstIterator::distance(const ConstIterator &x) const;
  %catches(std::invalid_argument) ConstIterator::equal (const ConstIterator &x) const;
  %catches(swig::stop_iteration)  ConstIterator::next();
  %catches(swig::stop_iteration)  ConstIterator::previous();
  %catches(swig::stop_iteration)  ConstIterator::advance(ptrdiff_t n);
  %catches(swig::stop_iteration)  ConstIterator::operator += (ptrdiff_t n);
  %catches(swig::stop_iteration)  ConstIterator::operator -= (ptrdiff_t n);
  %catches(swig::stop_iteration)  ConstIterator::operator + (ptrdiff_t n) const;
  %catches(swig::stop_iteration)  ConstIterator::operator - (ptrdiff_t n) const;


  struct ConstIterator
  {
  protected:
    ConstIterator(VALUE seq);

  public:
    virtual ~ConstIterator();

    // Access iterator method, required by Ruby
    virtual VALUE value() const = 0;

    // Forward iterator method, required by Ruby
    virtual ConstIterator *incr(size_t n = 1) = 0;
    
    // Backward iterator method, very common in C++, but not required in Ruby
    virtual ConstIterator *decr(size_t n = 1);

    // Random access iterator methods, but not required in Ruby
    virtual ptrdiff_t distance(const ConstIterator &x) const;

    virtual bool equal (const ConstIterator &x) const;
    
    // C++ common/needed methods
    virtual ConstIterator *dup() const = 0;

    virtual VALUE inspect()    const = 0;
    virtual VALUE to_s()    const = 0;

    VALUE next();
    VALUE previous();
    ConstIterator *advance(ptrdiff_t n);

    bool operator == (const ConstIterator& x)  const;
    ConstIterator* operator + (ptrdiff_t n) const;
    ConstIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const ConstIterator& x) const;
  };

  struct Iterator : public ConstIterator
  {
    virtual bool set( const VALUE& v ) = 0;

    // Random access iterator methods, but not required in Ruby
    virtual ptrdiff_t distance(const Iterator &x) const;
    virtual bool equal (const Iterator &x) const;

    virtual Iterator *dup() const = 0;
    Iterator *advance(ptrdiff_t n);

    bool operator == (const Iterator& x)  const;
    Iterator* operator + (ptrdiff_t n) const;
    Iterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const Iterator& x) const;
  };

}

