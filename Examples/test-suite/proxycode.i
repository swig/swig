%module proxycode

%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Proxy4::Proxy4Nested;

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGD) || defined(SWIGKOTLIN)

%{
struct Proxy1 {};
%}
struct Proxy1 {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode1(i: Int): Int {
    return i+1
  }
%}
#else
%proxycode %{
  public int proxycode1(int i) {
    return i+1;
  }
%}
#endif
};

%proxycode %{
  this should be ignored as it is not in scope of a class
%}

%extend Proxy2 {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode2a(i: Int): Int {
    return i+2
  }
%}
#else
%proxycode %{
  public int proxycode2a(int i) {
    return i+2;
  }
%}
#endif
}

%extend Proxy2 {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode2b(i: Int): Int {
    return i+2
  }
%}
#else
%proxycode %{
  public int proxycode2b(int i) {
    return i+2;
  }
%}
#endif
}

%inline %{
struct Proxy2 {};
struct Proxy3 {};
struct Proxy4 {
  struct Proxy4Nested {};
};
%}

%extend Proxy3 {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode3(i: Int): Int {
    return i+3
  }
%}
#else
%proxycode %{
  public int proxycode3(int i) {
    return i+3;
  }
%}
#endif
}

%extend Proxy4 {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode4(i: Int): Int {
    return i+4
  }
%}
#else
%proxycode %{
  public int proxycode4(int i) {
    return i+4;
  }
%}
#endif
}
%extend Proxy4::Proxy4Nested {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode4nested(i: Int): Int {
    return i+44
  }
%}
#else
%proxycode %{
  public int proxycode4nested(int i) {
    return i+44;
  }
%}
#endif
}

%extend TemplateProxy {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode5(i: $typemap(kstype, T)): $typemap(kstype, T) {
    return i
  }
%}
#else
%proxycode %{
  public T proxycode5(T i) {
    return i;
  }
%}
#endif
}

%extend TemplateProxy<int> {
#if defined(SWIGKOTLIN)
%proxycode %{
  fun proxycode5(i: Int, j: Int): Int {
    return i+j+55
  }
%}
#else
%proxycode %{
  public int proxycode5(int i, int j) {
    return i+j+55;
  }
%}
#endif
}

%inline %{
template <typename T> struct TemplateProxy {};
%}

%template(Proxy5a) TemplateProxy<short>;
%template(Proxy5b) TemplateProxy<int>;

%inline %{
template <typename T> struct TypemapProxy {
  T useT(T t1, T const& t2) {
    return t1+t2;
  }
};
%}

%extend TypemapProxy {
#if defined(SWIGJAVA)
%proxycode %{
  public $javaclassname proxyUseT(long t1,  long t2) {
    $typemap(jstype, unsigned int) tt1 = t1;
    $typemap(jstype, unsigned int const&) tt2 = t2;
    long ret = useT(tt1, tt2);
    if (ret != t1+t2)
      throw new RuntimeException("wrong sum");
    return this;
  }
%}
#elif defined(SWIGKOTLIN)
%proxycode %{
  fun proxyUseT(t1: Long, t2: Long): $kotlinclassname {
    val tt1: $typemap(kstype, unsigned int) = t1
    val tt2: $typemap(kstype, unsigned int const&) = t2
    val ret: Long = useT(tt1, tt2)
    if (ret != t1 + t2)
      throw RuntimeException("wrong sum")
    return this
  }
%}
#elif defined(SWIGCSHARP)
%proxycode %{
  public $csclassname proxyUseT(uint t1,  uint t2) {
    $typemap(cstype, unsigned int) tt1 = t1;
    $typemap(cstype, unsigned int const&) tt2 = t2;
    uint ret = useT(tt1, tt2);
    if (ret != t1+t2)
      throw new System.Exception("wrong sum");
    return this;
  }
%}
#elif defined(SWIGD)
%proxycode %{
  public $dclassname proxyUseT(uint t1,  uint t2) {
    $typemap(dtype, unsigned int) tt1 = t1;
    $typemap(dtype, unsigned int const&) tt2 = t2;
    uint ret = useT(tt1, tt2);
    if (ret != t1+t2)
      throw new Exception("wrong sum");
    return this;
  }
%}
#else
#error "missing test"
#endif
}

%template(Proxy6) TypemapProxy<unsigned int>;

#endif
