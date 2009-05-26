/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_map.i
 *
 * SWIG typemaps for std::map
 * C# implementation by Yuval Baror (http://yuval.bar-or.org)
 *
 * The C# wrapper is made to look and feel like a C# System.Collections.Generic.IDictionary<>.
 * 
 * Using this wrapper is fairly simple. For example, to create a map from integers to doubles use:
 *
 *   %include <std_map.i>
 *   %template(Map_Int_Double) std::map<int, double>
 *
 * Very often the C# generated code will not compile as the C++ template type is not the same as the C# 
 * proxy type, so use the SWIG_STD_MAP_SPECIALIZED or SWIG_STD_MAP_SPECIALIZED_SIMPLE macros. For example:
 *
 *   SWIG_STD_MAP_SPECIALIZED(MyCppKeyClass, MyCppValueClass, MyCsKeyClass, MyCsValueClass)
 *   %template(Map_MyCppKeyClass_MyCppValueClass) std::map<MyCppKeyClass, MyCppValueClass >;
 *
 * Or if the C# class names are the same as the C++ class names, you can use:
 *
 *   SWIG_STD_MAP_SPECIALIZED_SIMPLE(MyKeyClass, MyValueClass)
 *   %template(Map_MyCppKeyClass_MyCppValueClass) std::map<MyKeyClass, MyValueClass >;
 *
 * Notes:
 * 1) For .NET 1 compatibility, define SWIG_DOTNET_1 when compiling the C# code. In this case 
 *    the C# wrapper has only basic functionality.
 * 2) IEnumerable<> is implemented in the proxy class which is useful for using LINQ with 
 *    C++ std::map wrappers.
 *
 * Warning: heavy macro usage in this file. Use swig -E to get a sane view on the real file contents!
 * ----------------------------------------------------------------------------- */

%{
#include <map>
#include <algorithm>
#include <stdexcept>
%}

// A minimal implementation to be used when no specialization exists.
%define SWIG_STD_MAP_MINIMAL_INTERNAL(K, T)
  public:
    map();
    map(const map<K, T > &other);

    typedef K key_type;
    typedef T mapped_type;
    typedef size_t size_type;
    size_type size() const;
    bool empty() const;
    %rename(Clear) clear;
    void clear();
    %extend {
      const mapped_type& get(const key_type& key) throw (std::out_of_range) {
        std::map<K,T >::iterator iter = $self->find(key);
        if (iter != $self->end())
          return iter->second;
        else
          throw std::out_of_range("key not found");
      }

      void set(const key_type& key, const mapped_type& x) {
        (*$self)[key] = x;
      }

      void del(const key_type& key) throw (std::out_of_range) {
        std::map<K,T >::iterator iter = $self->find(key);
        if (iter != $self->end())
          $self->erase(iter);
        else
          throw std::out_of_range("key not found");
      }

      bool has_key(const key_type& key) {
        std::map<K,T >::iterator iter = $self->find(key);
        return iter != $self->end();
      }
    }

%enddef

/* The specialized std::map implementation
 * K is the C++ key type
 * T is the C++ value type
 * CSKEYTYPE is the C# key type
 * CSVALUETYPE is the C# value type
 */
%define SWIG_STD_MAP_SPECIALIZED_INTERNAL(K, T, CSKEYTYPE, CSVALUETYPE)
// add typemaps here
%typemap(csinterfaces) std::map<K, T > "IDisposable \n#if !SWIG_DOTNET_1\n    , System.Collections.Generic.IDictionary<CSKEYTYPE, CSVALUETYPE>\n#endif\n";
%typemap(cscode) std::map<K, T > %{

  public CSVALUETYPE this[CSKEYTYPE key] {
    get {
      return getitem(key);
    }

    set {
      setitem(key, value);
    }
  }

  public bool TryGetValue(CSKEYTYPE key, out CSVALUETYPE value) {
    if (this.ContainsKey(key)) {
      value = this[key];
      return true;
    }
    value = default(CSVALUETYPE);
    return false;
  }

  public int Count {
    get {
      return (int)size();
    }
  }

  public bool IsReadOnly {
    get { 
      return false; 
    }
  }

#if !SWIG_DOTNET_1

  public System.Collections.Generic.ICollection<CSKEYTYPE> Keys {
    get {
      System.Collections.Generic.ICollection<CSKEYTYPE> keys = new System.Collections.Generic.List<CSKEYTYPE>();
      IntPtr iter = create_iterator_begin();
      try {
        while (true) {
          keys.Add(get_next_key(iter));
        }
      } catch (ArgumentOutOfRangeException) {
      }
      return keys;
    }
  }

  public System.Collections.Generic.ICollection<CSVALUETYPE> Values {
    get {
      System.Collections.Generic.ICollection<CSVALUETYPE> vals = new System.Collections.Generic.List<CSVALUETYPE>();
      foreach (System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE> pair in this) {
        vals.Add(pair.Value);
      }
      return vals;
    }
  }
  
  public void Add(System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE> item) {
    Add(item.Key, item.Value);
  }

  public bool Remove(System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE> item) {
    if (Contains(item)) {
      return Remove(item.Key);
    } else {
      return false;
    }
  }

  public bool Contains(System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE> item) {
    if (this[item.Key] == item.Value) {
      return true;
    } else {
      return false;
    }
  }

  public void CopyTo(System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>[] array) {
    CopyTo(array, 0);
  }

  public void CopyTo(System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>[] array, int arrayIndex) {
    if (array == null)
      throw new ArgumentNullException("array");
    if (arrayIndex < 0)
      throw new ArgumentOutOfRangeException("arrayIndex", "Value is less than zero");
    if (array.Rank > 1)
      throw new ArgumentException("Multi dimensional array.", "array");
    if (arrayIndex+this.Count > array.Length)
      throw new ArgumentException("Number of elements to copy is too large.");

    System.Collections.Generic.IList<CSKEYTYPE> keyList = new System.Collections.Generic.List<CSKEYTYPE>(this.Keys);
    for (int i = 0; i < keyList.Count; i++) {
      CSKEYTYPE currentKey = keyList[i];
      array.SetValue(new System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>(currentKey, this[currentKey]), arrayIndex+i);
    }
  }

  System.Collections.Generic.IEnumerator<System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>> System.Collections.Generic.IEnumerable<System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>>.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  public $csclassnameEnumerator GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  // Type-safe enumerator
  /// Note that the IEnumerator documentation requires an InvalidOperationException to be thrown
  /// whenever the collection is modified. This has been done for changes in the size of the
  /// collection but not when one of the elements of the collection is modified as it is a bit
  /// tricky to detect unmanaged code that modifies the collection under our feet.
  public sealed class $csclassnameEnumerator : System.Collections.IEnumerator, 
      System.Collections.Generic.IEnumerator<System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>>
  {
    private $csclassname collectionRef;
    private System.Collections.Generic.IList<CSKEYTYPE> keyCollection;
    private int currentIndex;
    private object currentObject;
    private int currentSize;

    public $csclassnameEnumerator($csclassname collection) {
      collectionRef = collection;
      keyCollection = new System.Collections.Generic.List<CSKEYTYPE>(collection.Keys);
      currentIndex = -1;
      currentObject = null;
      currentSize = collectionRef.Count;
    }

    // Type-safe iterator Current
    public System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE> Current {
      get {
        if (currentIndex == -1)
          throw new InvalidOperationException("Enumeration not started.");
        if (currentIndex > currentSize - 1)
          throw new InvalidOperationException("Enumeration finished.");
        if (currentObject == null)
          throw new InvalidOperationException("Collection modified.");
        return (System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>)currentObject;
      }
    }

    // Type-unsafe IEnumerator.Current
    object System.Collections.IEnumerator.Current {
      get {
        return Current;
      }
    }

    public bool MoveNext() {
      int size = collectionRef.Count;
      bool moveOkay = (currentIndex+1 < size) && (size == currentSize);
      if (moveOkay) {
        currentIndex++;
        CSKEYTYPE currentKey = keyCollection[currentIndex];
        currentObject = new System.Collections.Generic.KeyValuePair<CSKEYTYPE, CSVALUETYPE>(currentKey, collectionRef[currentKey]);
      } else {
        currentObject = null;
      }
      return moveOkay;
    }

    public void Reset() {
      currentIndex = -1;
      currentObject = null;
      if (collectionRef.Count != currentSize) {
        throw new InvalidOperationException("Collection modified.");
      }
    }

    public void Dispose() {
      currentIndex = -1;
      currentObject = null;
    }
  }
#endif
  
%}

  public:
    map();
    map(const map<K, T > &other);

    typedef K key_type;
    typedef T mapped_type;
    typedef size_t size_type;
    size_type size() const;
    bool empty() const;
    %rename(Clear) clear;
    void clear();
    %extend {
      const mapped_type& getitem(const key_type& key) throw (std::out_of_range) {
        std::map<K,T >::iterator iter = $self->find(key);
        if (iter != $self->end())
          return iter->second;
        else
          throw std::out_of_range("key not found");
      }

      void setitem(const key_type& key, const mapped_type& x) {
        (*$self)[key] = x;
      }

      bool ContainsKey(const key_type& key) {
        std::map<K, T >::iterator iter = $self->find(key);
        return iter != $self->end();
      }

      void Add(const key_type& key, const mapped_type& val) throw (std::out_of_range) {
        std::map<K, T >::iterator iter = $self->find(key);
        if (iter != $self->end())
          throw std::out_of_range("key already exists");
        $self->insert(std::pair<K, T >(key, val));
      }

      bool Remove(const key_type& key) {
        std::map<K, T >::iterator iter = $self->find(key);
        if (iter != $self->end()) {
          $self->erase(iter);
          return true;
        }                
        return false;
      }

      // create_iterator_begin() and get_next_key() work together to provide a collection of keys to C#
      %apply void *VOID_INT_PTR { std::map<K, T >::iterator *std::map<K, T >::create_iterator_begin }
      %apply void *VOID_INT_PTR { std::map<K, T >::iterator *swigiterator }

      std::map<K, T >::iterator *create_iterator_begin() {
        return new std::map<K, T >::iterator($self->begin());
      }

      const key_type& get_next_key(std::map<K, T >::iterator *swigiterator) throw (std::out_of_range) {
        std::map<K, T >::iterator iter = *swigiterator;
        if (iter == $self->end()) {
          delete swigiterator;
          throw std::out_of_range("no more map elements");
        }
        (*swigiterator)++;
        return (*iter).first;
      }
    }


%csmethodmodifiers std::map<K, T >::size "private"
%csmethodmodifiers std::map<K, T >::getitem "private"
%csmethodmodifiers std::map<K, T >::setitem "private"
%csmethodmodifiers std::map<K, T >::create_iterator_begin "private"
%csmethodmodifiers std::map<K, T >::get_next_key "private"

%enddef


// Main specialization macros
%define SWIG_STD_MAP_SPECIALIZED(K, T, CSKEY, CSVAL)
namespace std {
  template<> class map<K, T > {
    SWIG_STD_MAP_SPECIALIZED_INTERNAL(K, T, CSKEY, CSVAL)
  };
}
%enddef

%define SWIG_STD_MAP_SPECIALIZED_SIMPLE(K, T)
  SWIG_STD_MAP_SPECIALIZED(K, T, K, T)
%enddef

// Old macros (deprecated)
%define specialize_std_map_on_key(K,CHECK,CONVERT_FROM,CONVERT_TO)
#warning specialize_std_map_on_key ignored - macro is deprecated, please use SWIG_STD_MAP_MINIMAL_INTERNAL in Lib/csharp/std_map.i
%enddef

%define specialize_std_map_on_value(T,CHECK,CONVERT_FROM,CONVERT_TO)
#warning specialize_std_map_on_value ignored - macro is deprecated, please use SWIG_STD_MAP_MINIMAL_INTERNAL in Lib/csharp/std_map.i
%enddef

%define specialize_std_map_on_both(K,CHECK_K,CONVERT_K_FROM,CONVERT_K_TO, T,CHECK_T,CONVERT_T_FROM,CONVERT_T_TO)
#warning specialize_std_map_on_both ignored - macro is deprecated, please use SWIG_STD_MAP_MINIMAL_INTERNAL in Lib/csharp/std_map.i
%enddef

// Default implementation
namespace std {   
  template<class K, class T> class map {    
    SWIG_STD_MAP_MINIMAL_INTERNAL(K, T)
  };
}
 
// specializations for built-ins
SWIG_STD_MAP_SPECIALIZED(std::string, std::string, string, string)
SWIG_STD_MAP_SPECIALIZED(std::string, bool, string, bool)
SWIG_STD_MAP_SPECIALIZED(std::string, int, string, int)
SWIG_STD_MAP_SPECIALIZED(std::string, unsigned long long, string, ulong)
SWIG_STD_MAP_SPECIALIZED(std::string, unsigned long, string, uint)
SWIG_STD_MAP_SPECIALIZED(std::string, unsigned short, string, ushort)
SWIG_STD_MAP_SPECIALIZED(std::string, long long, string, long)
SWIG_STD_MAP_SPECIALIZED(std::string, unsigned int, string, uint)
SWIG_STD_MAP_SPECIALIZED(std::string, unsigned char, string, byte)
SWIG_STD_MAP_SPECIALIZED(std::string, signed char, string, sbyte)
SWIG_STD_MAP_SPECIALIZED(std::string, double, string, double)
SWIG_STD_MAP_SPECIALIZED(std::string, short, string, short)
SWIG_STD_MAP_SPECIALIZED(std::string, float, string, float)
SWIG_STD_MAP_SPECIALIZED(std::string, char, string, char)
SWIG_STD_MAP_SPECIALIZED(std::string, long, string, int)
SWIG_STD_MAP_SPECIALIZED(bool, std::string, bool, string)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(bool, bool)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(bool, int)
SWIG_STD_MAP_SPECIALIZED(bool, unsigned long long, bool, ulong)
SWIG_STD_MAP_SPECIALIZED(bool, unsigned long, bool, uint)
SWIG_STD_MAP_SPECIALIZED(bool, unsigned short, bool, ushort)
SWIG_STD_MAP_SPECIALIZED(bool, long long, bool, long)
SWIG_STD_MAP_SPECIALIZED(bool, unsigned int, bool, uint)
SWIG_STD_MAP_SPECIALIZED(bool, unsigned char, bool, byte)
SWIG_STD_MAP_SPECIALIZED(bool, signed char, bool, sbyte)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(bool, double)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(bool, short)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(bool, float)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(bool, char)
SWIG_STD_MAP_SPECIALIZED(bool, long, bool, int)
SWIG_STD_MAP_SPECIALIZED(int, std::string, int, string)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(int, bool)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(int, int)
SWIG_STD_MAP_SPECIALIZED(int, unsigned long long, int, ulong)
SWIG_STD_MAP_SPECIALIZED(int, unsigned long, int, uint)
SWIG_STD_MAP_SPECIALIZED(int, unsigned short, int, ushort)
SWIG_STD_MAP_SPECIALIZED(int, long long, int, long)
SWIG_STD_MAP_SPECIALIZED(int, unsigned int, int, uint)
SWIG_STD_MAP_SPECIALIZED(int, unsigned char, int, byte)
SWIG_STD_MAP_SPECIALIZED(int, signed char, int, sbyte)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(int, double)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(int, short)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(int, float)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(int, char)
SWIG_STD_MAP_SPECIALIZED(int, long, int, int)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, std::string, ulong, string)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, bool, ulong, bool)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, int, ulong, int)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, unsigned long long, ulong, ulong)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, unsigned long, ulong, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, unsigned short, ulong, ushort)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, long long, ulong, long)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, unsigned int, ulong, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, unsigned char, ulong, byte)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, signed char, ulong, sbyte)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, double, ulong, double)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, short, ulong, short)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, float, ulong, float)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, char, ulong, char)
SWIG_STD_MAP_SPECIALIZED(unsigned long long, long, ulong, int)
SWIG_STD_MAP_SPECIALIZED(unsigned long, std::string, uint, string)
SWIG_STD_MAP_SPECIALIZED(unsigned long, bool, uint, bool)
SWIG_STD_MAP_SPECIALIZED(unsigned long, int, uint, int)
SWIG_STD_MAP_SPECIALIZED(unsigned long, unsigned long long, uint, ulong)
SWIG_STD_MAP_SPECIALIZED(unsigned long, unsigned long, uint, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned long, unsigned short, uint, ushort)
SWIG_STD_MAP_SPECIALIZED(unsigned long, long long, uint, long)
SWIG_STD_MAP_SPECIALIZED(unsigned long, unsigned int, uint, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned long, unsigned char, uint, byte)
SWIG_STD_MAP_SPECIALIZED(unsigned long, signed char, uint, sbyte)
SWIG_STD_MAP_SPECIALIZED(unsigned long, double, uint, double)
SWIG_STD_MAP_SPECIALIZED(unsigned long, short, uint, short)
SWIG_STD_MAP_SPECIALIZED(unsigned long, float, uint, float)
SWIG_STD_MAP_SPECIALIZED(unsigned long, char, uint, char)
SWIG_STD_MAP_SPECIALIZED(unsigned long, long, uint, int)
SWIG_STD_MAP_SPECIALIZED(unsigned short, std::string, ushort, string)
SWIG_STD_MAP_SPECIALIZED(unsigned short, bool, ushort, bool)
SWIG_STD_MAP_SPECIALIZED(unsigned short, int, ushort, int)
SWIG_STD_MAP_SPECIALIZED(unsigned short, unsigned long long, ushort, ulong)
SWIG_STD_MAP_SPECIALIZED(unsigned short, unsigned long, ushort, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned short, unsigned short, ushort, ushort)
SWIG_STD_MAP_SPECIALIZED(unsigned short, long long, ushort, long)
SWIG_STD_MAP_SPECIALIZED(unsigned short, unsigned int, ushort, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned short, unsigned char, ushort, byte)
SWIG_STD_MAP_SPECIALIZED(unsigned short, signed char, ushort, sbyte)
SWIG_STD_MAP_SPECIALIZED(unsigned short, double, ushort, double)
SWIG_STD_MAP_SPECIALIZED(unsigned short, short, ushort, short)
SWIG_STD_MAP_SPECIALIZED(unsigned short, float, ushort, float)
SWIG_STD_MAP_SPECIALIZED(unsigned short, char, ushort, char)
SWIG_STD_MAP_SPECIALIZED(unsigned short, long, ushort, int)
SWIG_STD_MAP_SPECIALIZED(long long, std::string, long, string)
SWIG_STD_MAP_SPECIALIZED(long long, bool, long, bool)
SWIG_STD_MAP_SPECIALIZED(long long, int, long, int)
SWIG_STD_MAP_SPECIALIZED(long long, unsigned long long, long, ulong)
SWIG_STD_MAP_SPECIALIZED(long long, unsigned long, long, uint)
SWIG_STD_MAP_SPECIALIZED(long long, unsigned short, long, ushort)
SWIG_STD_MAP_SPECIALIZED(long long, long long, long, long)
SWIG_STD_MAP_SPECIALIZED(long long, unsigned int, long, uint)
SWIG_STD_MAP_SPECIALIZED(long long, unsigned char, long, byte)
SWIG_STD_MAP_SPECIALIZED(long long, signed char, long, sbyte)
SWIG_STD_MAP_SPECIALIZED(long long, double, long, double)
SWIG_STD_MAP_SPECIALIZED(long long, short, long, short)
SWIG_STD_MAP_SPECIALIZED(long long, float, long, float)
SWIG_STD_MAP_SPECIALIZED(long long, char, long, char)
SWIG_STD_MAP_SPECIALIZED(long long, long, long, int)
SWIG_STD_MAP_SPECIALIZED(unsigned int, std::string, uint, string)
SWIG_STD_MAP_SPECIALIZED(unsigned int, bool, uint, bool)
SWIG_STD_MAP_SPECIALIZED(unsigned int, int, uint, int)
SWIG_STD_MAP_SPECIALIZED(unsigned int, unsigned long long, uint, ulong)
SWIG_STD_MAP_SPECIALIZED(unsigned int, unsigned long, uint, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned int, unsigned short, uint, ushort)
SWIG_STD_MAP_SPECIALIZED(unsigned int, long long, uint, long)
SWIG_STD_MAP_SPECIALIZED(unsigned int, unsigned int, uint, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned int, unsigned char, uint, byte)
SWIG_STD_MAP_SPECIALIZED(unsigned int, signed char, uint, sbyte)
SWIG_STD_MAP_SPECIALIZED(unsigned int, double, uint, double)
SWIG_STD_MAP_SPECIALIZED(unsigned int, short, uint, short)
SWIG_STD_MAP_SPECIALIZED(unsigned int, float, uint, float)
SWIG_STD_MAP_SPECIALIZED(unsigned int, char, uint, char)
SWIG_STD_MAP_SPECIALIZED(unsigned int, long, uint, int)
SWIG_STD_MAP_SPECIALIZED(unsigned char, std::string, byte, string)
SWIG_STD_MAP_SPECIALIZED(unsigned char, bool, byte, bool)
SWIG_STD_MAP_SPECIALIZED(unsigned char, int, byte, int)
SWIG_STD_MAP_SPECIALIZED(unsigned char, unsigned long long, byte, ulong)
SWIG_STD_MAP_SPECIALIZED(unsigned char, unsigned long, byte, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned char, unsigned short, byte, ushort)
SWIG_STD_MAP_SPECIALIZED(unsigned char, long long, byte, long)
SWIG_STD_MAP_SPECIALIZED(unsigned char, unsigned int, byte, uint)
SWIG_STD_MAP_SPECIALIZED(unsigned char, unsigned char, byte, byte)
SWIG_STD_MAP_SPECIALIZED(unsigned char, signed char, byte, sbyte)
SWIG_STD_MAP_SPECIALIZED(unsigned char, double, byte, double)
SWIG_STD_MAP_SPECIALIZED(unsigned char, short, byte, short)
SWIG_STD_MAP_SPECIALIZED(unsigned char, float, byte, float)
SWIG_STD_MAP_SPECIALIZED(unsigned char, char, byte, char)
SWIG_STD_MAP_SPECIALIZED(unsigned char, long, byte, int)
SWIG_STD_MAP_SPECIALIZED(signed char, std::string, sbyte, string)
SWIG_STD_MAP_SPECIALIZED(signed char, bool, sbyte, bool)
SWIG_STD_MAP_SPECIALIZED(signed char, int, sbyte, int)
SWIG_STD_MAP_SPECIALIZED(signed char, unsigned long long, sbyte, ulong)
SWIG_STD_MAP_SPECIALIZED(signed char, unsigned long, sbyte, uint)
SWIG_STD_MAP_SPECIALIZED(signed char, unsigned short, sbyte, ushort)
SWIG_STD_MAP_SPECIALIZED(signed char, long long, sbyte, long)
SWIG_STD_MAP_SPECIALIZED(signed char, unsigned int, sbyte, uint)
SWIG_STD_MAP_SPECIALIZED(signed char, unsigned char, sbyte, byte)
SWIG_STD_MAP_SPECIALIZED(signed char, signed char, sbyte, sbyte)
SWIG_STD_MAP_SPECIALIZED(signed char, double, sbyte, double)
SWIG_STD_MAP_SPECIALIZED(signed char, short, sbyte, short)
SWIG_STD_MAP_SPECIALIZED(signed char, float, sbyte, float)
SWIG_STD_MAP_SPECIALIZED(signed char, char, sbyte, char)
SWIG_STD_MAP_SPECIALIZED(signed char, long, sbyte, int)
SWIG_STD_MAP_SPECIALIZED(double, std::string, double, string)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(double, bool)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(double, int)
SWIG_STD_MAP_SPECIALIZED(double, unsigned long long, double, ulong)
SWIG_STD_MAP_SPECIALIZED(double, unsigned long, double, uint)
SWIG_STD_MAP_SPECIALIZED(double, unsigned short, double, ushort)
SWIG_STD_MAP_SPECIALIZED(double, long long, double, long)
SWIG_STD_MAP_SPECIALIZED(double, unsigned int, double, uint)
SWIG_STD_MAP_SPECIALIZED(double, unsigned char, double, byte)
SWIG_STD_MAP_SPECIALIZED(double, signed char, double, sbyte)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(double, double)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(double, short)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(double, float)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(double, char)
SWIG_STD_MAP_SPECIALIZED(double, long, double, int)
SWIG_STD_MAP_SPECIALIZED(short, std::string, short, string)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(short, bool)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(short, int)
SWIG_STD_MAP_SPECIALIZED(short, unsigned long long, short, ulong)
SWIG_STD_MAP_SPECIALIZED(short, unsigned long, short, uint)
SWIG_STD_MAP_SPECIALIZED(short, unsigned short, short, ushort)
SWIG_STD_MAP_SPECIALIZED(short, long long, short, long)
SWIG_STD_MAP_SPECIALIZED(short, unsigned int, short, uint)
SWIG_STD_MAP_SPECIALIZED(short, unsigned char, short, byte)
SWIG_STD_MAP_SPECIALIZED(short, signed char, short, sbyte)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(short, double)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(short, short)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(short, float)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(short, char)
SWIG_STD_MAP_SPECIALIZED(short, long, short, int)
SWIG_STD_MAP_SPECIALIZED(float, std::string, float, string)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(float, bool)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(float, int)
SWIG_STD_MAP_SPECIALIZED(float, unsigned long long, float, ulong)
SWIG_STD_MAP_SPECIALIZED(float, unsigned long, float, uint)
SWIG_STD_MAP_SPECIALIZED(float, unsigned short, float, ushort)
SWIG_STD_MAP_SPECIALIZED(float, long long, float, long)
SWIG_STD_MAP_SPECIALIZED(float, unsigned int, float, uint)
SWIG_STD_MAP_SPECIALIZED(float, unsigned char, float, byte)
SWIG_STD_MAP_SPECIALIZED(float, signed char, float, sbyte)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(float, double)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(float, short)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(float, float)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(float, char)
SWIG_STD_MAP_SPECIALIZED(float, long, float, int)
SWIG_STD_MAP_SPECIALIZED(char, std::string, char, string)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(char, bool)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(char, int)
SWIG_STD_MAP_SPECIALIZED(char, unsigned long long, char, ulong)
SWIG_STD_MAP_SPECIALIZED(char, unsigned long, char, uint)
SWIG_STD_MAP_SPECIALIZED(char, unsigned short, char, ushort)
SWIG_STD_MAP_SPECIALIZED(char, long long, char, long)
SWIG_STD_MAP_SPECIALIZED(char, unsigned int, char, uint)
SWIG_STD_MAP_SPECIALIZED(char, unsigned char, char, byte)
SWIG_STD_MAP_SPECIALIZED(char, signed char, char, sbyte)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(char, double)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(char, short)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(char, float)
SWIG_STD_MAP_SPECIALIZED_SIMPLE(char, char)
SWIG_STD_MAP_SPECIALIZED(char, long, char, int)
SWIG_STD_MAP_SPECIALIZED(long, std::string, int, string)
SWIG_STD_MAP_SPECIALIZED(long, bool, int, bool)
SWIG_STD_MAP_SPECIALIZED(long, int, int, int)
SWIG_STD_MAP_SPECIALIZED(long, unsigned long long, int, ulong)
SWIG_STD_MAP_SPECIALIZED(long, unsigned long, int, uint)
SWIG_STD_MAP_SPECIALIZED(long, unsigned short, int, ushort)
SWIG_STD_MAP_SPECIALIZED(long, long long, int, long)
SWIG_STD_MAP_SPECIALIZED(long, unsigned int, int, uint)
SWIG_STD_MAP_SPECIALIZED(long, unsigned char, int, byte)
SWIG_STD_MAP_SPECIALIZED(long, signed char, int, sbyte)
SWIG_STD_MAP_SPECIALIZED(long, double, int, double)
SWIG_STD_MAP_SPECIALIZED(long, short, int, short)
SWIG_STD_MAP_SPECIALIZED(long, float, int, float)
SWIG_STD_MAP_SPECIALIZED(long, char, int, char)
SWIG_STD_MAP_SPECIALIZED(long, long, int, int)

// add specializations here


