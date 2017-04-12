#define SWIG_SHARED_PTR_NAMESPACE std
%include <boost_shared_ptr.i>


%wrapper %{
#ifdef SWIG_RUBYSTDCOMMON
namespace swig {
  template<class Type>
  struct traits_from<std::shared_ptr<const Type> > {
    static VALUE from(const std::shared_ptr<const Type>& val) {
      std::shared_ptr<Type> p = std::const_pointer_cast<Type>(val);
      return swig::from(p);
    }
  };
};
#endif
%}
