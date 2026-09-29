/* Recursive native JavaScript container conversions. */
%insert("header") %{

#include <array>
#include <cmath>
#include <deque>
#include <limits>
#include <iterator>
#include <list>
#include <map>
#include <memory>
#include <set>
#include <stdexcept>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

namespace swig_wasmjs {
using emscripten::val;

struct conversion_error : std::invalid_argument {
  explicit conversion_error(const char *message) : std::invalid_argument(message) {
  }
};

template <class T>
T *proxy_pointer(const val &value) {
  swig_type_info *descriptor = type_descriptor<typename std::remove_const<T>::type>::get();
  void *pointer = 0;
  if (!descriptor || !SWIG_IsOK(SWIG_ConvertPtr(value.as_handle(), &pointer, descriptor, 0)))
    return 0;
  return static_cast<T *>(pointer);
}

/* Roll back owning element proxies if a later output conversion fails. */
class output_context {
  std::vector<val> owned;
  bool committed;

public:
  output_context() : committed(false) {
  }
  void track(const val &value) {
    owned.push_back(value);
  }
  void commit() {
    committed = true;
  }
  ~output_context() {
    if (!committed) {
      for (std::vector<val>::reverse_iterator it = owned.rbegin(); it != owned.rend(); ++it) {
        try {
          it->call<void>("delete");
        } catch (...) {
        }
      }
    }
  }
};

inline unsigned sequence_length(const val &value) {
  if (!value.isArray())
    throw conversion_error("Expected an Array or compatible sequence proxy");
  return value["length"].as<unsigned>();
}

inline val set_entries(const val &value) {
  if (!value.instanceof(val::global("Set")))
    throw conversion_error("Expected a Set or compatible set proxy");
  return val::global("Array").call<val>("from", value);
}

template <class T, class Enable = void>
struct conversion {
  static void validate(const val &value) {
    if (!proxy_pointer<T>(value))
      throw conversion_error("Expected a compatible wrapped object");
  }
  static T read(const val &value) {
    T *pointer = proxy_pointer<T>(value);
    if (!pointer)
      throw conversion_error("Expected a compatible wrapped object");
    return *pointer;
  }
  static val write(const T &value, output_context *context = 0) {
    swig_type_info *descriptor = type_descriptor<T>::get();
    if (!descriptor || !descriptor->clientdata)
      throw conversion_error("Unregistered wrapped element type");
    std::unique_ptr<T> copy(new T(value));
    val proxy = val::take_ownership(SWIG_NewPointerObj(copy.get(), descriptor, SWIG_POINTER_OWN));
    copy.release();
    if (context) {
      try {
        context->track(proxy);
      } catch (...) {
        proxy.call<void>("delete");
        throw;
      }
    }
    return proxy;
  }
};

template <class T>
struct conversion<T *> {
  static void validate(const val &value) {
    if (!value.isNull() && !proxy_pointer<T>(value))
      throw conversion_error("Expected a compatible wrapped pointer");
  }
  static T *read(const val &value) {
    if (value.isNull())
      return 0;
    T *pointer = proxy_pointer<T>(value);
    if (!pointer)
      throw conversion_error("Expected a compatible wrapped pointer");
    return pointer;
  }
  static val write(T *value, output_context * = 0) {
    if (!value)
      return val::null();
    swig_type_info *descriptor = type_descriptor<typename std::remove_const<T>::type>::get();
    if (!descriptor)
      throw conversion_error("Unregistered wrapped pointer element type");
    return val::take_ownership(SWIG_NewPointerObj(const_cast<typename std::remove_const<T>::type *>(value), descriptor, 0));
  }
};

template <class T>
struct conversion<T, typename std::enable_if<std::is_arithmetic<T>::value>::type> {
  static T read(const val &value) {
    const std::string kind = value.typeOf().as<std::string>();
    if (std::is_same<T, bool>::value) {
      if (kind != "boolean")
        throw conversion_error("Expected boolean container element");
      return static_cast<T>(value.as<bool>());
    }
    if (std::is_integral<T>::value && sizeof(T) == 8) {
      if (kind != "bigint")
        throw conversion_error("Expected bigint container element");
      val width = val::global("BigInt").call<val>(std::is_signed<T>::value ? "asIntN" : "asUintN", 64, value);
      if (!width.strictlyEquals(value))
        throw conversion_error("Integer container element out of range");
      return value.as<T>();
    }
    if (kind != "number")
      throw conversion_error("Expected numeric container element");
    double number = value.as<double>();
    if (std::is_integral<T>::value &&
        (!std::isfinite(number) || std::trunc(number) != number || number < static_cast<double>(std::numeric_limits<T>::lowest()) ||
         number > static_cast<double>(std::numeric_limits<T>::max())))
      throw conversion_error("Integer container element out of range");
    if (std::is_floating_point<T>::value && std::isfinite(number) &&
        (number < -static_cast<double>(std::numeric_limits<T>::max()) || number > static_cast<double>(std::numeric_limits<T>::max())))
      throw conversion_error("Floating-point container element out of range");
    return static_cast<T>(number);
  }
  static void validate(const val &value) {
    read(value);
  }
  static val write(T value, output_context * = 0) {
    return val(value);
  }
};

template <class T>
struct conversion<T, typename std::enable_if<std::is_enum<T>::value>::type> {
  static void validate(const val &value) {
    if (!enum_conversion<T>::read(value, 0))
      throw conversion_error("Invalid enum container element or underlying integer range");
  }
  static T read(const val &value) {
    T result;
    if (!enum_conversion<T>::read(value, &result))
      throw conversion_error("Invalid enum container element or underlying integer range");
    return result;
  }
  static val write(T value, output_context * = 0) {
    return enum_conversion<T>::write(value);
  }
};

template <>
struct conversion<std::string> {
  static void validate(const val &value) {
    if (value.typeOf().as<std::string>() != "string")
      throw conversion_error("Expected string container element");
  }
  static std::string read(const val &value) {
    if (value.typeOf().as<std::string>() != "string")
      throw conversion_error("Expected string container element");
    return value.as<std::string>();
  }
  static val write(const std::string &value, output_context * = 0) {
    return val(value);
  }
};

template <class C>
struct sequence_conversion {
  static void validate(const val &value) {
    if (proxy_pointer<C>(value))
      return;
    unsigned length = sequence_length(value);
    for (unsigned i = 0; i < length; ++i)
      conversion<typename C::value_type>::validate(value[i]);
  }
  static C read(const val &value) {
    if (C *pointer = proxy_pointer<C>(value))
      return *pointer;
    unsigned length = sequence_length(value);
    C result;
    for (unsigned i = 0; i < length; ++i)
      result.push_back(conversion<typename C::value_type>::read(value[i]));
    return result;
  }
  static val write(const C &value, output_context *context = 0) {
    val result = val::array();
    unsigned i = 0;
    for (typename C::const_iterator it = value.begin(); it != value.end(); ++it)
      result.set(i++, conversion<typename C::value_type>::write(*it, context));
    return result;
  }
};

template <class T, class A>
struct conversion<std::vector<T, A> > : sequence_conversion<std::vector<T, A> > {};
template <class T, class A>
struct conversion<std::deque<T, A> > : sequence_conversion<std::deque<T, A> > {};
template <class T, class A>
struct conversion<std::list<T, A> > : sequence_conversion<std::list<T, A> > {};

template <class A, class B>
struct conversion<std::pair<A, B> > {
  typedef std::pair<A, B> pair_type;
  static void validate(const val &value) {
    if (proxy_pointer<pair_type>(value))
      return;
    if (sequence_length(value) != 2)
      throw conversion_error("Expected a two-element Array");
    conversion<typename std::remove_const<A>::type>::validate(value[0]);
    conversion<B>::validate(value[1]);
  }
  static pair_type read(const val &value) {
    if (pair_type *pointer = proxy_pointer<pair_type>(value))
      return *pointer;
    if (sequence_length(value) != 2)
      throw conversion_error("Expected a two-element Array");
    return pair_type(conversion<typename std::remove_const<A>::type>::read(value[0]), conversion<B>::read(value[1]));
  }
  static val write(const pair_type &value, output_context *context = 0) {
    val result = val::array();
    result.set(0, conversion<typename std::remove_const<A>::type>::write(value.first, context));
    result.set(1, conversion<B>::write(value.second, context));
    return result;
  }
};

template <class C>
val map_entries(const val &value) {
  if (value.instanceof(val::global("Map")))
    return val::global("Array").call<val>("from", value);
  if (!std::is_same<typename C::key_type, std::string>::value || value.isNull() || value.typeOf().as<std::string>() != "object")
    throw conversion_error("Expected a Map or compatible map proxy");
  val object = val::global("Object");
  val prototype = object.call<val>("getPrototypeOf", value);
  if (!prototype.isNull() && !prototype.strictlyEquals(object["prototype"]))
    throw conversion_error("Expected a plain object with own string keys");
  val keys = object.call<val>("keys", value);
  val entries = val::array();
  unsigned length = keys["length"].as<unsigned>();
  for (unsigned i = 0; i < length; ++i) {
    val key = keys[i];
    val entry = val::array();
    entry.set(0, key);
    entry.set(1, value[key]);
    entries.set(i, entry);
  }
  return entries;
}

template <class C>
struct map_conversion {
  static void validate(const val &value) {
    if (proxy_pointer<C>(value))
      return;
    val entries = map_entries<C>(value);
    unsigned length = entries["length"].as<unsigned>();
    for (unsigned i = 0; i < length; ++i) {
      val entry = entries[i];
      conversion<typename C::key_type>::validate(entry[0]);
      conversion<typename C::mapped_type>::validate(entry[1]);
    }
  }
  static C read(const val &value) {
    if (C *pointer = proxy_pointer<C>(value))
      return *pointer;
    val entries = map_entries<C>(value);
    C result;
    unsigned length = entries["length"].as<unsigned>();
    for (unsigned i = 0; i < length; ++i) {
      val entry = entries[i];
      result.emplace(conversion<typename C::key_type>::read(entry[0]), conversion<typename C::mapped_type>::read(entry[1]));
    }
    return result;
  }
  static val write(const C &value, output_context *context = 0) {
    val result = val::global("Map").new_();
    for (typename C::const_iterator it = value.begin(); it != value.end(); ++it)
      result.call<val>("set", conversion<typename C::key_type>::write(it->first, context), conversion<typename C::mapped_type>::write(it->second, context));
    return result;
  }
};

template <class K, class V, class C, class A>
struct conversion<std::map<K, V, C, A> > : map_conversion<std::map<K, V, C, A> > {};
template <class K, class V, class H, class E, class A>
struct conversion<std::unordered_map<K, V, H, E, A> > : map_conversion<std::unordered_map<K, V, H, E, A> > {};

template <class C>
struct set_conversion {
  static void validate(const val &value) {
    if (proxy_pointer<C>(value))
      return;
    val entries = set_entries(value);
    unsigned length = entries["length"].as<unsigned>();
    for (unsigned i = 0; i < length; ++i)
      conversion<typename C::value_type>::validate(entries[i]);
  }
  static C read(const val &value) {
    if (C *pointer = proxy_pointer<C>(value))
      return *pointer;
    val entries = set_entries(value);
    C result;
    unsigned length = entries["length"].as<unsigned>();
    for (unsigned i = 0; i < length; ++i)
      result.insert(conversion<typename C::value_type>::read(entries[i]));
    return result;
  }
  static val write(const C &value, output_context *context = 0) {
    val result = val::global("Set").new_();
    for (typename C::const_iterator it = value.begin(); it != value.end(); ++it)
      result.call<val>("add", conversion<typename C::value_type>::write(*it, context));
    return result;
  }
};

template <class T, class C, class A>
struct conversion<std::set<T, C, A> > : set_conversion<std::set<T, C, A> > {};
template <class T, class H, class E, class A>
struct conversion<std::unordered_set<T, H, E, A> > : set_conversion<std::unordered_set<T, H, E, A> > {};

template <class T, size_t N>
struct conversion<std::array<T, N> > {
  typedef std::array<T, N> array_type;
  static void validate(const val &value) {
    if (proxy_pointer<array_type>(value))
      return;
    if (sequence_length(value) != N)
      throw conversion_error("Expected an Array of the declared fixed size");
    for (size_t i = 0; i < N; ++i)
      conversion<T>::validate(value[i]);
  }
  static array_type read(const val &value) {
    if (array_type *pointer = proxy_pointer<array_type>(value))
      return *pointer;
    if (sequence_length(value) != N)
      throw conversion_error("Expected an Array of the declared fixed size");
    array_type result;
    for (size_t i = 0; i < N; ++i)
      result[i] = conversion<T>::read(value[i]);
    return result;
  }
  static val write(const array_type &value, output_context *context = 0) {
    val result = val::array();
    for (size_t i = 0; i < N; ++i)
      result.set(i, conversion<T>::write(value[i], context));
    return result;
  }
};

template <class T>
val to_value(const T &value) {
  output_context context;
  val result = conversion<T>::write(value, &context);
  context.commit();
  return result;
}

template <class T>
bool check(EM_VAL handle) {
  try {
    conversion<T>::validate(borrowed_value(handle));
    return true;
  } catch (const std::exception &) {
    return false;
  }
}
}  // namespace swig_wasmjs
%}
