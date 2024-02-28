%module cpp11_template_templated_methods

// Testing templated methods in a template
// Including variadic templated method reported in https://github.com/swig/swig/issues/2794

#if defined(SWIGLUA) || defined(SWIGOCAML)
%rename(end_renamed) end;
%rename(begin_renamed) begin;
#endif

%include <std_vector.i>

%inline %{
namespace eprosima {
namespace fastrtps {

template <
    typename _Ty,
    typename _Collection = std::vector<_Ty> >
class ResourceLimitedVector
{
public:

    using collection_type = _Collection;
    using value_type = _Ty;
    using pointer = typename collection_type::pointer;
    using const_pointer = typename collection_type::const_pointer;
    using reference = typename collection_type::reference;
    using const_reference = typename collection_type::const_reference;
    using size_type = typename collection_type::size_type;
    using difference_type = typename collection_type::difference_type;
    using iterator = typename collection_type::iterator;
    using const_iterator = typename collection_type::const_iterator;
    using reverse_iterator = typename collection_type::reverse_iterator;
    using const_reverse_iterator = typename collection_type::const_reverse_iterator;

    // Templated method in template
    template <class InputIterator>
    void assign( InputIterator first, InputIterator last)
    {
        size_type n = static_cast<size_type>(std::distance(first, last));
        InputIterator value = first;
        std::advance(value, n);
        collection_.assign(first, value);
    }

    // Templated method in template using template parameter from the templated method (InputIterator) and the class (_Ty)
    template <class InputIterator>
    void assign_and_append( InputIterator first, InputIterator last, const _Ty& val)
    {
        assign(first, last);
        collection_.push_back(val);
    }

    // Static templated method in template
    template <class InputIterator>
    static collection_type container_from_iterators( InputIterator first, InputIterator last)
    {
        size_type n = static_cast<size_type>(std::distance(first, last));
        InputIterator value = first;
        std::advance(value, n);
        collection_type c;
        c.assign(first, value);
        return c;
    }

    // Variadic templated method in template
    template<typename ... Args>
    void emplace_back( Args&& ... args )
    {
        collection_.emplace_back(args ...);
    }

    // Variadic templated constructor in template
    template<typename ... Args>
    ResourceLimitedVector( Args&& ... args )
    {
        collection_.emplace_back(args ...);
    }

    // Variadic static templated method in template
    template<typename ... Args>
    static collection_type make_collection( Args&& ... args )
    {
        ResourceLimitedVector rlv(std::forward<Args>(args)...);
        collection_type ct = rlv.collection_;
        return ct;
    }

    ResourceLimitedVector() = default;

    collection_type& getCollection() { return collection_; }

private:
    collection_type collection_;
};

namespace rtps {
  struct octet {
    int num;
    octet(int i=0) : num(i) {}
  };
}
}
}
%}

class SimpleIterator {};

%{
#include <iterator>

class SimpleIterator
{
  std::vector<eprosima::fastrtps::rtps::octet>::iterator it;
public:
  using iterator_category = std::forward_iterator_tag;
  using value_type = eprosima::fastrtps::rtps::octet;
  using difference_type = std::ptrdiff_t;
  using pointer = eprosima::fastrtps::rtps::octet *;
  using reference = eprosima::fastrtps::rtps::octet &;
  SimpleIterator() : it() {}
  SimpleIterator(std::vector<eprosima::fastrtps::rtps::octet>::iterator it) :it(it) {}
  SimpleIterator& operator++() {++it;return *this;}
  SimpleIterator operator++(int) {SimpleIterator tmp(*this); operator++(); return tmp;}
  bool operator==(const SimpleIterator& rhs) const {return it==rhs.it;}
  bool operator!=(const SimpleIterator& rhs) const {return it!=rhs.it;}
  eprosima::fastrtps::rtps::octet& operator*() const {return *it;}
};
%}

%inline %{
struct SimpleContainer {
    std::vector<eprosima::fastrtps::rtps::octet> container;
    SimpleContainer(std::vector<eprosima::fastrtps::rtps::octet> v) : container(v) {}
    SimpleIterator begin() { return SimpleIterator(container.begin()); }
    SimpleIterator end() { return SimpleIterator(container.end()); }
};
%}

%apply const int & {int &&}; // for emplace_back

%template(OctetVector) std::vector<eprosima::fastrtps::rtps::octet>;
%template(OctetResourceLimitedVector) eprosima::fastrtps::ResourceLimitedVector<eprosima::fastrtps::rtps::octet>;
%extend eprosima::fastrtps::ResourceLimitedVector<eprosima::fastrtps::rtps::octet> {
  %template(assign) assign<SimpleIterator>;
  %template(assign_and_append) assign_and_append<SimpleIterator>;
  %template(container_from_iterators) container_from_iterators<SimpleIterator>;
  // emplace_back template parameters need to match those in the octet constructor
  %template(emplace_back) emplace_back<>;
  %template(emplace_back) emplace_back<int>;
  %template(emplace_back) emplace_back<eprosima::fastrtps::rtps::octet>;
  // Variadic templated constructor in template
  %template(ResourceLimitedVector) ResourceLimitedVector<int>;
  %template(ResourceLimitedVector) ResourceLimitedVector<eprosima::fastrtps::rtps::octet>;
  // Variadic static templated method in template
  %template(make_collection) make_collection<>;
  %template(make_collection) make_collection<int>;
  %template(make_collection) make_collection<eprosima::fastrtps::rtps::octet>;
}
