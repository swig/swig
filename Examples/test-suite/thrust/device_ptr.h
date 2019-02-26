#ifndef thrust_device_ptr_h
#define thrust_device_ptr_h
// Mock 'thrust' library

namespace thrust {
template<class T>
class device_ptr {
public:
  T *ptr;

  device_ptr(T *p) : ptr(p) {}
  device_ptr() : ptr(NULL) {}
};
template<class T>
T *raw_pointer_cast(device_ptr<T> dp) {
  return dp.ptr;
}
}
#endif
