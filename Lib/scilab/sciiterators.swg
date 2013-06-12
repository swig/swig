/* -----------------------------------------------------------------------------
 * sciiterators.swg
 *
 * Users can derive form the SciSwigIterator to implemet their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template SciSwigIterator_T does the
 * implementation for generic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%fragment("SciSwigIterator","header",fragment="<stddef.h>") {
namespace swig {
  struct stop_iteration {
  };

  struct SciSwigIterator {
  private:
    SciObject _seq;

  protected:
    SciSwigIterator(SciObject seq) : _seq(seq)
    {
    }

  public:
    virtual ~SciSwigIterator() {}

    virtual SciObject value() const = 0;

    virtual SciSwigIterator *incr(size_t n = 1) = 0;

    virtual SciSwigIterator *decr(size_t n = 1)
    {
      throw stop_iteration();
    }

    virtual ptrdiff_t distance(const SciSwigIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const SciSwigIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual SciSwigIterator *copy() const = 0;

    SciObject next()
    {
      SciObject obj = value();
      incr();
      return obj;
    }

    SciObject previous()
    {
      decr();
      return value();
    }

    SciSwigIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }

    bool operator == (const SciSwigIterator& x)  const
    {
      return equal(x);
    }

    bool operator != (const SciSwigIterator& x) const
    {
      return ! operator==(x);
    }

    SciSwigIterator* operator ++ () {
      incr();
      return this;
    }

    SciSwigIterator* operator -- () {
      decr();
      return this;
    }

    SciSwigIterator* operator + (ptrdiff_t n) const
    {
      return copy()->advance(n);
    }

    SciSwigIterator* operator - (ptrdiff_t n) const
    {
      return copy()->advance(-n);
    }

    ptrdiff_t operator - (const SciSwigIterator& x) const
    {
      return x.distance(*this);
    }

    static swig_type_info* descriptor() {
      static int init = 0;
      static swig_type_info* desc = 0;
      if (!init) {
	desc = SWIG_TypeQuery("swig::SciSwigIterator *");
	init = 1;
      }
      return desc;
    }
  };
}
}

%fragment("SciSwigIterator_T","header",fragment="<stddef.h>",fragment="SciSwigIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace swig {
  template<typename OutIterator>
  class SciSwigIterator_T :  public SciSwigIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;
    typedef SciSwigIterator_T<out_iterator> self_type;

    SciSwigIterator_T(out_iterator curr, SciObject seq)
      : SciSwigIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }


    bool equal (const SciSwigIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }

    ptrdiff_t distance(const SciSwigIterator &iter) const
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
    typedef SciObject result_type;
    result_type operator()(argument_type v) const
    {
      return swig::from(v);
    }
  };

  template<typename OutIterator,
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class SciSwigIteratorOpen_T :  public SciSwigIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef SciSwigIterator_T<out_iterator>  base;
    typedef SciSwigIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;

    SciSwigIteratorOpen_T(out_iterator curr, SciObject seq)
      : SciSwigIterator_T<OutIterator>(curr, seq)
    {
    }

    SciObject value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }

    SciSwigIterator *copy() const
    {
      return new self_type(*this);
    }

    SciSwigIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    SciSwigIterator *decr(size_t n = 1)
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
  class SciSwigIteratorClosed_T :  public SciSwigIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef SciSwigIterator_T<out_iterator>  base;
    typedef SciSwigIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;

    SciSwigIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, SciObject seq)
      : SciSwigIterator_T<OutIterator>(curr, seq), begin(first), end(last)
    {
    }

    SciObject value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }

    SciSwigIterator *copy() const
    {
      return new self_type(*this);
    }

    SciSwigIterator *incr(size_t n = 1)
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

    SciSwigIterator *decr(size_t n = 1)
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
  inline SciSwigIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, SciObject seq = SciObject())
  {
    return new SciSwigIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline SciSwigIterator*
  make_output_iterator(const OutIter& current, SciObject seq = SciObject())
  {
    return new SciSwigIteratorOpen_T<OutIter>(current, seq);
  }
}
}


%fragment("SciSwigIterator");
namespace swig
{
// Throw a StopIteration exception
  %ignore stop_iteration;
  struct stop_iteration {};

  %typemap(throws) stop_iteration
  {
    Scierror(999, "%s: stop_iteration exception", SWIG_Scilab_GetFname());
    SWIG_fail;
  }

// Mark methods that return new objects
  %newobject SciSwigIterator::copy;
  %newobject SciSwigIterator::operator + (ptrdiff_t n) const;
  %newobject SciSwigIterator::operator - (ptrdiff_t n) const;

  %nodirector SciSwigIterator;

  %catches(swig::stop_iteration) SciSwigIterator::value() const;
  %catches(swig::stop_iteration) SciSwigIterator::incr(size_t n = 1);
  %catches(swig::stop_iteration) SciSwigIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) SciSwigIterator::distance(const SciSwigIterator &x) const;
  %catches(std::invalid_argument) SciSwigIterator::equal (const SciSwigIterator &x) const;
  %catches(swig::stop_iteration) SciSwigIterator::next();
  %catches(swig::stop_iteration) SciSwigIterator::previous();
  %catches(swig::stop_iteration) SciSwigIterator::advance(ptrdiff_t n);
  %catches(swig::stop_iteration) SciSwigIterator::operator += (ptrdiff_t n);
  %catches(swig::stop_iteration) SciSwigIterator::operator -= (ptrdiff_t n);
  %catches(swig::stop_iteration) SciSwigIterator::operator + (ptrdiff_t n) const;
  %catches(swig::stop_iteration) SciSwigIterator::operator - (ptrdiff_t n) const;

  %ignore SciSwigIterator::operator==;
  %ignore SciSwigIterator::operator!=;
  %ignore SciSwigIterator::operator++;
  %ignore SciSwigIterator::operator--;
  %ignore SciSwigIterator::operator+;
  %ignore SciSwigIterator::operator-;

  struct SciSwigIterator
  {
  protected:
    SciSwigIterator(SciObject seq);

  public:
    virtual ~SciSwigIterator();

    virtual SciObject value() const = 0;

    virtual SciSwigIterator *incr(size_t n = 1) = 0;

    virtual SciSwigIterator *decr(size_t n = 1);

    virtual ptrdiff_t distance(const SciSwigIterator &x) const;

    virtual bool equal (const SciSwigIterator &x) const;

    virtual SciSwigIterator *copy() const = 0;

    SciObject next();
    SciObject previous();
    SciSwigIterator *advance(ptrdiff_t n);

    bool operator == (const SciSwigIterator& x)  const;
    bool operator != (const SciSwigIterator& x) const;
    SciSwigIterator* operator ++ ();
    SciSwigIterator* operator -- ();
    SciSwigIterator* operator + (ptrdiff_t n) const;
    SciSwigIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const SciSwigIterator& x) const;
  };
}
