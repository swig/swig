#define IMPLEMENT_GET_CLASS(cls) \
        HPHP::Class* cls::getClass() { \
                if (s_class == nullptr) { \
                        s_class = HPHP::Unit::lookupClass(s_className.get()); \
                        assert(s_class); \
                } \
                return s_class; \
        }

namespace HPHP {
namespace {

template<typename T>
struct SWIG_Ptr : public SweepableResourceData {
private:
  T* m_ptr;
public:
  DECLARE_RESOURCE_ALLOCATION(SWIG_Ptr)
  CLASSNAME_IS("SWIG_Ptr")
  const String& o_getClassNameHook() const override { return classnameof(); }

  explicit SWIG_Ptr(T* ptr) : m_ptr(ptr) {}
  virtual ~SWIG_Ptr() { close(); }
  void close() {
    m_ptr = nullptr;
  }
  T* get() const { return m_ptr; }
};

template<typename T> inline void SWIG_Ptr<T>::sweep() { close(); }

}
}
