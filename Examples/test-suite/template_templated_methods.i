%module template_templated_methods

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

#include <iterator>

class SimpleIterator {};

%{
class SimpleIterator : public std::iterator<std::input_iterator_tag, eprosima::fastrtps::rtps::octet>
{
  std::vector<eprosima::fastrtps::rtps::octet>::iterator it;
public:
  SimpleIterator() :it() {}
  SimpleIterator(std::vector<eprosima::fastrtps::rtps::octet>::iterator it) :it(it) {}
  SimpleIterator(const SimpleIterator& mit) : it(mit.it) {}
  SimpleIterator& operator++() {++it;return *this;}
  SimpleIterator operator++(int) {SimpleIterator tmp(*this); operator++(); return tmp;}
  bool operator==(const SimpleIterator& rhs) const {return it==rhs.it;}
  bool operator!=(const SimpleIterator& rhs) const {return it!=rhs.it;}
  eprosima::fastrtps::rtps::octet& operator*() {return *it;}
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

%template(OctetVector) std::vector<eprosima::fastrtps::rtps::octet>;
%template(OctetResourceLimitedVector) eprosima::fastrtps::ResourceLimitedVector<eprosima::fastrtps::rtps::octet>;
%extend eprosima::fastrtps::ResourceLimitedVector<eprosima::fastrtps::rtps::octet> {
  %template(assign) assign<SimpleIterator>;
  %template(assign_and_append) assign_and_append<SimpleIterator>;
}
