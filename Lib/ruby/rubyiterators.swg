/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * rubyiterators.swg
 *
 * Implement a ruby 'output' iterator for Ruby.
 *
 * Users can derive form the RubySwigIterator to implemet their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template RubySwigIterator_T does the
 * implementation for genereic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%fragment("RubySwigIterator","header") {  
namespace swig {
  struct stop_iteration {
  };

  struct RubySwigIterator {
  private:
    VALUE _seq;

  protected:
    RubySwigIterator(VALUE seq) : _seq(seq)
    {
    }
      
  public:
    virtual ~RubySwigIterator() {}

    // Access iterator method, required by Ruby
    virtual VALUE value() const = 0;

//     // Set referenced object
//     virtual bool set(VALUE v) = 0;

    // Forward iterator method, required by Ruby
    virtual RubySwigIterator *incr(size_t n = 1) = 0;
    
    // Backward iterator method, very common in C++, but not required in Ruby
    virtual RubySwigIterator *decr(size_t n = 1)
    {
      throw stop_iteration();
    }

    // Random access iterator methods, but not required in Ruby
    virtual ptrdiff_t distance(const RubySwigIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const RubySwigIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }
    
    // C++ common/needed methods
    virtual RubySwigIterator *copy() const = 0;

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

    RubySwigIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }
      
    bool operator == (const RubySwigIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const RubySwigIterator& x) const
    {
      return ! operator==(x);
    }
      
    RubySwigIterator& operator += (ptrdiff_t n)
    {
      return *advance(n);
    }

    RubySwigIterator& operator -= (ptrdiff_t n)
    {
      return *advance(-n);
    }
      
    RubySwigIterator* operator + (ptrdiff_t n) const
    {
      return copy()->advance(n);
    }

    RubySwigIterator* operator - (ptrdiff_t n) const
    {
      return copy()->advance(-n);
    }
      
    ptrdiff_t operator - (const RubySwigIterator& x) const
    {
      return x.distance(*this);
    }
      
    static swig_type_info* descriptor() {
      static int init = 0;
      static swig_type_info* desc = 0;
      if (!init) {
	desc = SWIG_TypeQuery("swig::RubySwigIterator *");
	init = 1;
      }	
      return desc;
    }    
  };
}
}

%fragment("RubySwigIterator_T","header",fragment="RubySwigIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace swig {
  template<typename OutIterator>
  class RubySwigIterator_T :  public RubySwigIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;    
    typedef RubySwigIterator_T<out_iterator> self_type;

    RubySwigIterator_T(out_iterator curr, VALUE seq = Qnil)
      : RubySwigIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }

    
    bool equal (const RubySwigIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    ptrdiff_t distance(const RubySwigIterator &iter) const
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
    typedef VALUE result_type;
    result_type operator()(argument_type v) const
    {
      return swig::from(v);
    }
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class RubySwigIteratorOpen_T :  public RubySwigIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef RubySwigIterator_T<out_iterator>  base;
    typedef RubySwigIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;
    
    RubySwigIteratorOpen_T(out_iterator curr, VALUE seq = Qnil)
      : RubySwigIterator_T<OutIterator>(curr, seq)
    {
    }
    
    virtual VALUE value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }

//     virtual bool set(VALUE v) {
//       value_type val;
//       if ( !asval(v, &val) ) return SWIG_ERROR;
//       *(base::current) = val;
//       return SWIG_OK;
//     }
    
    
    RubySwigIterator *copy() const
    {
      return new self_type(*this);
    }

    RubySwigIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    RubySwigIterator *decr(size_t n = 1)
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
  class RubySwigIteratorClosed_T :  public RubySwigIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef RubySwigIterator_T<out_iterator>  base;    
    typedef RubySwigIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;
    
    RubySwigIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, VALUE seq = Qnil)
      : RubySwigIterator_T<OutIterator>(curr, seq), begin(first), end(last)
    {
    }
    
    virtual VALUE value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }
    
//     virtual bool set(VALUE v) {
//       value_type val;
//       if ( !asval(v, &val) ) return SWIG_ERROR;
//       *(base::current) = val;
//       return SWIG_OK;
//     }
    
    RubySwigIterator *copy() const
    {
      return new self_type(*this);
    }

    RubySwigIterator *incr(size_t n = 1)
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

    RubySwigIterator *decr(size_t n = 1)
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
  inline RubySwigIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, VALUE seq = Qnil)
  {
    return new RubySwigIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline RubySwigIterator*
  make_output_iterator(const OutIter& current, VALUE seq = Qnil)
  {
    return new RubySwigIteratorOpen_T<OutIter>(current, seq);
  }
}
}


%fragment("RubySwigIterator");
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
  %newobject RubySwigIterator::copy;
  %newobject RubySwigIterator::operator + (ptrdiff_t n) const;
  %newobject RubySwigIterator::operator - (ptrdiff_t n) const;

  %nodirector RubySwigIterator;

  %catches(swig::stop_iteration) RubySwigIterator::value() const;
  %catches(swig::stop_iteration) RubySwigIterator::incr(size_t n = 1);
  %catches(swig::stop_iteration) RubySwigIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) RubySwigIterator::distance(const RubySwigIterator &x) const;
  %catches(std::invalid_argument) RubySwigIterator::equal (const RubySwigIterator &x) const;
  %catches(swig::stop_iteration) RubySwigIterator::next();
  %catches(swig::stop_iteration) RubySwigIterator::previous();
  %catches(swig::stop_iteration) RubySwigIterator::advance(ptrdiff_t n);
  %catches(swig::stop_iteration) RubySwigIterator::operator += (ptrdiff_t n);
  %catches(swig::stop_iteration) RubySwigIterator::operator -= (ptrdiff_t n);
  %catches(swig::stop_iteration) RubySwigIterator::operator + (ptrdiff_t n) const;
  %catches(swig::stop_iteration) RubySwigIterator::operator - (ptrdiff_t n) const;


  struct RubySwigIterator
  {
  protected:
    RubySwigIterator(VALUE seq);

  public:
    virtual ~RubySwigIterator();

    // Access iterator method, required by Ruby
    virtual VALUE value() const = 0;

//     // Set referenced object, required by Ruby
//     virtual bool set(VALUE val) = 0;

    // Forward iterator method, required by Ruby
    virtual RubySwigIterator *incr(size_t n = 1) = 0;
    
    // Backward iterator method, very common in C++, but not required in Ruby
    virtual RubySwigIterator *decr(size_t n = 1);

    // Random access iterator methods, but not required in Ruby
    virtual ptrdiff_t distance(const RubySwigIterator &x) const;

    virtual bool equal (const RubySwigIterator &x) const;
    
    // C++ common/needed methods
    virtual RubySwigIterator *copy() const = 0;

    VALUE next();
    VALUE previous();
    RubySwigIterator *advance(ptrdiff_t n);

    bool operator == (const RubySwigIterator& x)  const;
    RubySwigIterator* operator + (ptrdiff_t n) const;
    RubySwigIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const RubySwigIterator& x) const;
  };
}

