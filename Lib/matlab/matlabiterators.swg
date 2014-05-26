/* -----------------------------------------------------------------------------
 * matlabiterators.swg
 *
 * Users can derive from the MatlabSwigIterator to implement their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template MatlabSwigIterator_T does the
 * implementation for generic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%fragment("MatlabSwigIterator","header",fragment="<stddef.h>") {  
namespace swig {
  struct stop_iteration {
  };

  struct MatlabSwigIterator {
  private:
    mxArray* _seq;

  protected:
    MatlabSwigIterator(mxArray* seq) : _seq(seq)
    {
    }
      
  public:
    virtual ~MatlabSwigIterator() {}

    virtual mxArray* value() const = 0;

    virtual MatlabSwigIterator *incr(size_t n = 1) = 0;

    virtual MatlabSwigIterator *decr(size_t n = 1)
    {
      throw stop_iteration();
    }

    virtual ptrdiff_t distance(const MatlabSwigIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const MatlabSwigIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }
    
    virtual MatlabSwigIterator *copy() const = 0;

    mxArray* next()
    {
      mxArray* obj = value();
      incr();
      return obj;
    }

    mxArray* previous()
    {
      decr();
      return value();
    }

    MatlabSwigIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }
      
    bool operator == (const MatlabSwigIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const MatlabSwigIterator& x) const
    {
      return ! operator==(x);
    }

    MatlabSwigIterator* operator ++ () {
      incr();
      return this;
    }

    MatlabSwigIterator* operator -- () {
      decr();
      return this;
    }
      
    MatlabSwigIterator* operator + (ptrdiff_t n) const
    {
      return copy()->advance(n);
    }

    MatlabSwigIterator* operator - (ptrdiff_t n) const
    {
      return copy()->advance(-n);
    }
      
    ptrdiff_t operator - (const MatlabSwigIterator& x) const
    {
      return x.distance(*this);
    }
      
    static swig_type_info* descriptor() {
      static int init = 0;
      static swig_type_info* desc = 0;
      if (!init) {
	desc = SWIG_TypeQuery("swig::MatlabSwigIterator *");
	init = 1;
      }	
      return desc;
    }    
  };
}
}

%fragment("MatlabSwigIterator_T","header",fragment="<stddef.h>",fragment="MatlabSwigIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace swig {
  template<typename OutIterator>
  class MatlabSwigIterator_T :  public MatlabSwigIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;    
    typedef MatlabSwigIterator_T<out_iterator> self_type;

    MatlabSwigIterator_T(out_iterator curr, mxArray* seq)
      : MatlabSwigIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }

    
    bool equal (const MatlabSwigIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    ptrdiff_t distance(const MatlabSwigIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return std::distance(current, iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }    
    
  protected:
    out_iterator current;
  };
  
  template <class ValueType>
  struct from_oper 
  {
    typedef const ValueType& argument_type;
    typedef mxArray* result_type;
    result_type operator()(argument_type v) const
    {
      return swig::from(v);
    }
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class MatlabSwigIteratorOpen_T :  public MatlabSwigIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef MatlabSwigIterator_T<out_iterator>  base;
    typedef MatlabSwigIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;
    
    MatlabSwigIteratorOpen_T(out_iterator curr, mxArray* seq)
      : MatlabSwigIterator_T<OutIterator>(curr, seq)
    {
    }
    
    mxArray* value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }
    
    MatlabSwigIterator *copy() const
    {
      return new self_type(*this);
    }

    MatlabSwigIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    MatlabSwigIterator *decr(size_t n = 1)
    {
      while (n--) {
	--base::current;
      }
      return this;
    }
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class MatlabSwigIteratorClosed_T :  public MatlabSwigIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef MatlabSwigIterator_T<out_iterator>  base;    
    typedef MatlabSwigIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;
    
    MatlabSwigIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, mxArray* seq)
      : MatlabSwigIterator_T<OutIterator>(curr, seq), begin(first), end(last)
    {
    }
    
    mxArray* value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }
    
    MatlabSwigIterator *copy() const
    {
      return new self_type(*this);
    }

    MatlabSwigIterator *incr(size_t n = 1)
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

    MatlabSwigIterator *decr(size_t n = 1)
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

  template<typename OutIter>
  inline MatlabSwigIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, mxArray* seq = 0 /* KT mxArray()*/)
  {
    return new MatlabSwigIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline MatlabSwigIterator*
  make_output_iterator(const OutIter& current, mxArray* seq = 0 /* KT mxArray()*/)
  {
    return new MatlabSwigIteratorOpen_T<OutIter>(current, seq);
  }
}
}


%fragment("MatlabSwigIterator");
namespace swig 
{
// Throw a StopIteration exception
  %ignore stop_iteration;
  struct stop_iteration {};
  
  %typemap(throws) stop_iteration {
    SWIG_Error(SWIG_RuntimeError,"stop_iteration exception"); /* KT TODO */
    SWIG_fail;
  }

// Mark methods that return new objects
  %newobject MatlabSwigIterator::copy;
  %newobject MatlabSwigIterator::operator + (ptrdiff_t n) const;
  %newobject MatlabSwigIterator::operator - (ptrdiff_t n) const;

  %nodirector MatlabSwigIterator;

  %catches(swig::stop_iteration) MatlabSwigIterator::value() const;
  %catches(swig::stop_iteration) MatlabSwigIterator::incr(size_t n = 1);
  %catches(swig::stop_iteration) MatlabSwigIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) MatlabSwigIterator::distance(const MatlabSwigIterator &x) const;
  %catches(std::invalid_argument) MatlabSwigIterator::equal (const MatlabSwigIterator &x) const;
  %catches(swig::stop_iteration) MatlabSwigIterator::next();
  %catches(swig::stop_iteration) MatlabSwigIterator::previous();
  %catches(swig::stop_iteration) MatlabSwigIterator::advance(ptrdiff_t n);
  %catches(swig::stop_iteration) MatlabSwigIterator::operator += (ptrdiff_t n);
  %catches(swig::stop_iteration) MatlabSwigIterator::operator -= (ptrdiff_t n);
  %catches(swig::stop_iteration) MatlabSwigIterator::operator + (ptrdiff_t n) const;
  %catches(swig::stop_iteration) MatlabSwigIterator::operator - (ptrdiff_t n) const;


  struct MatlabSwigIterator
  {
  protected:
    MatlabSwigIterator(mxArray* seq);

  public:
    virtual ~MatlabSwigIterator();

    virtual mxArray* value() const = 0;

    virtual MatlabSwigIterator *incr(size_t n = 1) = 0;
    
    virtual MatlabSwigIterator *decr(size_t n = 1);

    virtual ptrdiff_t distance(const MatlabSwigIterator &x) const;

    virtual bool equal (const MatlabSwigIterator &x) const;
    
    virtual MatlabSwigIterator *copy() const = 0;

    mxArray* next();
    mxArray* previous();
    MatlabSwigIterator *advance(ptrdiff_t n);

    bool operator == (const MatlabSwigIterator& x)  const;
    bool operator != (const MatlabSwigIterator& x) const;
    MatlabSwigIterator* operator ++ ();
    MatlabSwigIterator* operator -- ();
    MatlabSwigIterator* operator + (ptrdiff_t n) const;
    MatlabSwigIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const MatlabSwigIterator& x) const;
  };
}

