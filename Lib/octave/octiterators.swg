//
// octiterators.swg - Octave STL iterator support
//

// Users can derive form the OctIterator to implement their
// own iterators. As an example (real one since we use it for STL/STD
// containers), the template OctIterator_T does the
// implementation for generic C++ iterators.

%include <std_common.i>

%fragment("OctIterator", "header", fragment = "<stddef.h>")
{

  namespace swig
  {

    struct OctStopIteration {
    };

    struct OctIterator {

    private:

      octave_value _seq;

    protected:

      OctIterator(octave_value seq) : _seq(seq) {
      }

    public:

      virtual ~OctIterator() {}

      virtual octave_value value() const = 0;

      virtual OctIterator* incr(size_t n = 1) = 0;

      virtual OctIterator* decr(size_t n = 1) {
        throw OctStopIteration();
      }

      virtual ptrdiff_t distance(const OctIterator& x) const {
        throw std::invalid_argument("operation not supported");
      }

      virtual bool equal(const OctIterator& x) const {
        throw std::invalid_argument("operation not supported");
      }

      virtual OctIterator* copy() const = 0;

      octave_value next() {
        octave_value obj = value();
        incr();
        return obj;
      }

      octave_value previous() {
        decr();
        return value();
      }

      OctIterator* advance(ptrdiff_t n) {
        return (n > 0) ?  incr(n) : decr(-n);
      }

      bool operator== (const OctIterator& x)  const {
        return equal(x);
      }

      bool operator!= (const OctIterator& x) const {
        return ! operator== (x);
      }

      OctIterator* operator++ () {
        incr();
        return this;
      }

      OctIterator* operator-- () {
        decr();
        return this;
      }

      OctIterator* operator+ (ptrdiff_t n) const {
        return copy()->advance(n);
      }

      OctIterator* operator- (ptrdiff_t n) const {
        return copy()->advance(-n);
      }

      ptrdiff_t operator- (const OctIterator& x) const {
        return x.distance(*this);
      }

      static swig_type_info* descriptor() {
        static int init = 0;
        static swig_type_info* desc = 0;
        if (!init) {
          desc = SWIG_TypeQuery("swig::OctIterator *");
          init = 1;
        }
        return desc;
      }

    };

  }

}

%fragment("OctIterator_T", "header", fragment = "<stddef.h>", fragment = "OctIterator", fragment = "StdTraits", fragment = "StdIteratorTraits")
{

  namespace swig
  {

    template<typename OutIterator>
    class OctIterator_T : public OctIterator
    {

    public:

      typedef OutIterator out_iterator;
      typedef typename std::iterator_traits<out_iterator>::value_type value_type;
      typedef OctIterator_T<out_iterator> self_type;

      OctIterator_T(out_iterator curr, octave_value seq)
        : OctIterator(seq), current(curr) {
      }

      const out_iterator& get_current() const {
        return current;
      }

      bool equal(const OctIterator& iter) const {
        const self_type* iters = dynamic_cast<const self_type*>(&iter);
        if (iters) {
          return (current == iters->get_current());
        } else {
          throw std::invalid_argument("bad iterator type");
        }
      }

      ptrdiff_t distance(const OctIterator& iter) const {
        const self_type* iters = dynamic_cast<const self_type*>(&iter);
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
    struct OctFromOper {
      typedef const ValueType& argument_type;
      typedef octave_value result_type;
      result_type operator()(argument_type v) const {
        return swig::from(v);
      }
    };

    template < typename OutIterator, typename ValueType = typename std::iterator_traits<OutIterator>::value_type, typename FromOper = OctFromOper<ValueType> >
    class OctIteratorOpen_T : public OctIterator_T<OutIterator>
    {

    public:

      FromOper from;
      typedef OutIterator out_iterator;
      typedef ValueType value_type;
      typedef OctIterator_T<out_iterator>  base;
      typedef OctIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;

      OctIteratorOpen_T(out_iterator curr, octave_value seq)
        : OctIterator_T<OutIterator> (curr, seq) {
      }

      octave_value value() const {
        return from(static_cast<const value_type&>(* (base::current)));
      }

      OctIterator* copy() const {
        return new self_type(*this);
      }

      OctIterator* incr(size_t n = 1) {
        while (n--) {
          ++base::current;
        }
        return this;
      }

      OctIterator* decr(size_t n = 1) {
        while (n--) {
          --base::current;
        }
        return this;
      }

    };

    template < typename OutIterator, typename ValueType = typename std::iterator_traits<OutIterator>::value_type, typename FromOper = OctFromOper<ValueType> >
    class OctIteratorClosed_T : public OctIterator_T<OutIterator>
    {

    public:

      FromOper from;
      typedef OutIterator out_iterator;
      typedef ValueType value_type;
      typedef OctIterator_T<out_iterator>  base;
      typedef OctIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;

      OctIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, octave_value seq)
        : OctIterator_T<OutIterator> (curr, seq), begin(first), end(last) {
      }

      octave_value value() const {
        if (base::current == end) {
          throw OctStopIteration();
        } else {
          return from(static_cast<const value_type&>(* (base::current)));
        }
      }

      OctIterator* copy() const {
        return new self_type(*this);
      }

      OctIterator* incr(size_t n = 1) {
        while (n--) {
          if (base::current == end) {
            throw OctStopIteration();
          } else {
            ++base::current;
          }
        }
        return this;
      }

      OctIterator* decr(size_t n = 1) {
        while (n--) {
          if (base::current == begin) {
            throw OctStopIteration();
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
    inline OctIterator* make_output_iterator(const OutIter& current, const OutIter& begin, const OutIter& end, octave_value seq = octave_value())
    {
      return new OctIteratorClosed_T<OutIter> (current, begin, end, seq);
    }

    template<typename OutIter>
    inline OctIterator* make_output_iterator(const OutIter& current, octave_value seq = octave_value())
    {
      return new OctIteratorOpen_T<OutIter> (current, seq);
    }

  }

}

%fragment("OctIterator");

namespace swig
{

  // Throw a StopIteration exception
  %ignore OctStopIteration;
  struct OctStopIteration {};
  %typemap(throws) OctStopIteration {
    error("OctStopIteration exception");
    SWIG_fail;
  }

  // Mark methods that return new objects
  %newobject OctIterator::copy;
  %newobject OctIterator::operator+ (ptrdiff_t n) const;
  %newobject OctIterator::operator- (ptrdiff_t n) const;

  %catches(swig::OctStopIteration) OctIterator::value() const;
  %catches(swig::OctStopIteration) OctIterator::incr(size_t n = 1);
  %catches(swig::OctStopIteration) OctIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) OctIterator::distance(const OctIterator& x) const;
  %catches(std::invalid_argument) OctIterator::equal(const OctIterator& x) const;
  %catches(swig::OctStopIteration) OctIterator::next();
  %catches(swig::OctStopIteration) OctIterator::previous();
  %catches(swig::OctStopIteration) OctIterator::advance(ptrdiff_t n);
  %catches(swig::OctStopIteration) OctIterator::operator+= (ptrdiff_t n);
  %catches(swig::OctStopIteration) OctIterator::operator-= (ptrdiff_t n);
  %catches(swig::OctStopIteration) OctIterator::operator+ (ptrdiff_t n) const;
  %catches(swig::OctStopIteration) OctIterator::operator- (ptrdiff_t n) const;

  %nodirector OctIterator;
  struct OctIterator {

  protected:

    OctIterator(octave_value seq);

  public:

    virtual ~OctIterator();
    virtual octave_value value() const = 0;
    virtual OctIterator* incr(size_t n = 1) = 0;
    virtual OctIterator* decr(size_t n = 1);
    virtual ptrdiff_t distance(const OctIterator& x) const;
    virtual bool equal(const OctIterator& x) const;
    virtual OctIterator* copy() const = 0;
    octave_value next();
    octave_value previous();
    OctIterator* advance(ptrdiff_t n);
    bool operator== (const OctIterator& x)  const;
    bool operator!= (const OctIterator& x) const;
    OctIterator* operator++ ();
    OctIterator* operator-- ();
    OctIterator* operator+ (ptrdiff_t n) const;
    OctIterator* operator- (ptrdiff_t n) const;
    ptrdiff_t operator- (const OctIterator& x) const;

  };

}
