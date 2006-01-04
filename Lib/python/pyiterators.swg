//
//  Implemet a python 'output' iterator for Python 2.2 or higher.
//
//  Users can derive form the PySwigIterator to implemet their
//  own iterators. As an example (real one since we use it for STL/STD
//  containers), the template PySwigIterator_T does the
//  implementation for genereic C++ iterators.
//  
%include <std_common.i>



namespace swig 
{
  /*
    Throw a StopIteration exception
  */
  %ignore stop_iteration;
  %typemap(throws) stop_iteration {
    (void)$1;
    SWIG_SetErrorObj(PyExc_StopIteration, SWIG_Py_Void());
    SWIG_fail;
  }

  /* 
     Mark methods that return new objects
  */
  %newobject PySwigIterator::copy;
  %newobject PySwigIterator::operator + (ptrdiff_t n) const;
  %newobject PySwigIterator::operator - (ptrdiff_t n) const;
}

%nodirector swig::PySwigIterator;
%inline {
namespace swig {
  struct stop_iteration
  {
  };

  struct PySwigIterator
  {
  private:
    PyObject_ptr _seq;

  protected:
    PySwigIterator(PyObject *seq) : _seq(seq)
    {
    }
      
  public:
    virtual ~PySwigIterator() {}

    // Access iterator method, required by Python
    virtual PyObject *value() const throw (stop_iteration) = 0;

    // Forward iterator method, required by Python
    virtual PySwigIterator *incr(size_t n = 1) throw (stop_iteration) = 0;
    
    // Backward iterator method, very common in C++, but not required in Python
    virtual PySwigIterator *decr(size_t n = 1) throw (stop_iteration) 
    {
      throw stop_iteration();
    }

    // Random access iterator methods, but not required in Python
    virtual ptrdiff_t distance(const PySwigIterator &x) const throw (std::invalid_argument)
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const PySwigIterator &x) const throw (std::invalid_argument) 
    {
      throw std::invalid_argument("operation not supported");
    }
    
    // C++ common/needed methods
    virtual PySwigIterator *copy() const = 0;

  public:

    PyObject *next() throw (stop_iteration)
    {
      PyObject *obj = value();
      incr();
      return obj;
    }

    PyObject *previous() throw (stop_iteration)
    {
      decr();
      return value();
    }

    PySwigIterator *advance(ptrdiff_t n) throw (stop_iteration)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }
      
    bool operator == (const PySwigIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const PySwigIterator& x) const
    {
      return ! operator==(x);
    }
      
    PySwigIterator& operator += (ptrdiff_t n) throw (stop_iteration)
    {
      return *advance(n);
    }

    PySwigIterator& operator -= (ptrdiff_t n) throw (stop_iteration)
    {
      return *advance(-n);
    }
      
    PySwigIterator* operator + (ptrdiff_t n) const throw (stop_iteration)
    {
      return copy()->advance(n);
    }

    PySwigIterator* operator - (ptrdiff_t n) const throw (stop_iteration)
    {
      return copy()->advance(-n);
    }
      
    ptrdiff_t operator - (const PySwigIterator& x) const
    {
      return x.distance(*this);
    }
      
    static swig_type_info* descriptor() {
      static int init = 0;
      static swig_type_info* desc = 0;
      if (!init) {
	desc = SWIG_TypeQuery("swig::PySwigIterator *");
	init = 1;
      }	
      return desc;
    }
  };
}
}

%fragment("PySwigIterator_T","header",fragment="StdTraits") {
#include <iterator>  
namespace swig {
  template<typename OutIterator>
  class PySwigIterator_T :  public PySwigIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;
    
    typedef PySwigIterator_T<out_iterator> self_type;
    
    PySwigIterator_T(out_iterator curr, out_iterator first, out_iterator last, PyObject *seq)
      : PySwigIterator(seq), current(curr), begin(first), end(last)
    {
    }
    
    PyObject *value() const throw (stop_iteration) {
      if (current == end) {
	throw stop_iteration();
      } else {
	return swig::from((const value_type&)*(current));
      }
    }
    
    PySwigIterator *copy() const
    {
      return new self_type(*this);
    }

    PySwigIterator *incr(size_t n = 1) throw (stop_iteration)
    {
      while (n--) {
	if (current == end) {
	  throw stop_iteration();
	} else {
	  ++current;
	}
      }
      return this;
    }

    PySwigIterator *decr(size_t n = 1) throw (stop_iteration)
    {
      while (n--) {
	if (current == begin) {
	  throw stop_iteration();
	} else {
	  --current;
	}
      }
      return this;
    }
    
    bool equal (const PySwigIterator &iter) const throw (std::invalid_argument)
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    ptrdiff_t distance(const PySwigIterator &iter) const throw (std::invalid_argument)
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return std::distance(current, iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    const out_iterator& get_current() const
    {
      return current;
    }
    
  private:
    out_iterator current;
    out_iterator begin;
    out_iterator end;
  };

  template<typename OutIter>
  inline PySwigIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin = OutIter(), 
		       const OutIter& end = OutIter(), PyObject *seq = 0)
  {
    return new PySwigIterator_T<OutIter>(current, begin, end, seq);
  }
}
}

