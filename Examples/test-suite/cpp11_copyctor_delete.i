%module cpp11_copyctor_delete

%{
#if defined(_MSC_VER)
  #pragma warning(disable : 4624) // warning C4624: 'StackOnlyDerived1': destructor was implicitly defined as deleted
#endif
%}

%inline %{
struct DeletedPublic1 {
  DeletedPublic1() = delete;
};
struct DeletedPublic2 {
  DeletedPublic2() = delete;
  DeletedPublic2(const DeletedPublic2&) = delete;
};
struct DeletedPublic3 {
  DeletedPublic3(const DeletedPublic3&) = delete;
};
struct DeletedPublic4 {
  DeletedPublic4() = default;
  DeletedPublic4(const DeletedPublic4&) = delete;
};
struct DeletedPublic5 {
  DeletedPublic5() = default;
  DeletedPublic5(const DeletedPublic5&) = delete;
};

struct DeletedProtected1 {
protected:
  DeletedProtected1() = delete;
};
struct DeletedProtected2 {
protected:
  DeletedProtected2() = delete;
  DeletedProtected2(const DeletedProtected2&) = delete;
};
struct DeletedProtected3 {
protected:
  DeletedProtected3(const DeletedProtected3&) = delete;
};
struct DeletedProtected4 {
protected:
  DeletedProtected4() = default;
  DeletedProtected4(const DeletedProtected4&) = delete;
};
struct DeletedProtected5 {
protected:
  DeletedProtected5() = default;
  DeletedProtected5(const DeletedProtected5&) = delete;
};

struct DeletedPrivate1 {
private:
  DeletedPrivate1() = delete;
};
struct DeletedPrivate2 {
private:
  DeletedPrivate2() = delete;
  DeletedPrivate2(const DeletedPrivate2&) = delete;
};
struct DeletedPrivate3 {
private:
  DeletedPrivate3(const DeletedPrivate3&) = delete;
};
struct DeletedPrivate4 {
private:
  DeletedPrivate4() = default;
  DeletedPrivate4(const DeletedPrivate4&) = delete;
};
struct DeletedPrivate5 {
private:
  DeletedPrivate5() = default;
  DeletedPrivate5(const DeletedPrivate5&) = delete;
};

struct StackOnly1 {
  // Only constructible on the stack
  ~StackOnly1() = delete;
};
struct StackOnlyDerived1 : StackOnly1 {
  // this class is not constructible due to deleted base destructor
};
struct StackOnlyDerivedMore1 : StackOnlyDerived1 {
  // this class is not constructible due to deleted base destructor
};
%}

// copyctor feature turned on
%copyctor;
%inline %{
struct CopyCtorDeletedPublic1 {
#if __cplusplus >= 202002L
  // Uniform/aggregate initialization was removed in C++20 if there is a user declared constructor, so the initialization in make() below does not work
  // This example can only be tested for C++11 to C++17, in C++20 the constructor declaration is removed by making it an aggregate
  // SWIG still sees the deleted constructor below
#else
  CopyCtorDeletedPublic1() = delete;
#endif
  static CopyCtorDeletedPublic1 make() { return {}; }
};
struct CopyCtorDeletedPublic2 {
  CopyCtorDeletedPublic2() = delete;
  CopyCtorDeletedPublic2(const CopyCtorDeletedPublic2&) = delete;
};
struct CopyCtorDeletedPublic3 {
  CopyCtorDeletedPublic3(const CopyCtorDeletedPublic3&) = delete;
};
struct CopyCtorDeletedPublic4 {
  CopyCtorDeletedPublic4() = default;
  CopyCtorDeletedPublic4(const CopyCtorDeletedPublic4&) = delete;
};
struct CopyCtorDeletedPublic5 {
  CopyCtorDeletedPublic5() = default;
  CopyCtorDeletedPublic5(const CopyCtorDeletedPublic5&) = delete;
};

struct CopyCtorDeletedProtected1 {
protected:
#if __cplusplus >= 202002L
  // Uniform/aggregate initialization was removed in C++20 if there is a user declared constructor, so the initialization in make() below does not work
  // This example can only be tested for C++11 to C++17, in C++20 the constructor declaration is removed by making it an aggregate
  // SWIG still sees the deleted constructor below
#else
  CopyCtorDeletedProtected1() = delete;
#endif
public:
  static CopyCtorDeletedProtected1 make() { return {}; }
};
struct CopyCtorDeletedProtected2 {
protected:
  CopyCtorDeletedProtected2() = delete;
  CopyCtorDeletedProtected2(const CopyCtorDeletedProtected2&) = delete;
};
struct CopyCtorDeletedProtected3 {
protected:
  CopyCtorDeletedProtected3(const CopyCtorDeletedProtected3&) = delete;
};
struct CopyCtorDeletedProtected4 {
protected:
  CopyCtorDeletedProtected4() = default;
  CopyCtorDeletedProtected4(const CopyCtorDeletedProtected4&) = delete;
};
struct CopyCtorDeletedProtected5 {
protected:
  CopyCtorDeletedProtected5() = default;
  CopyCtorDeletedProtected5(const CopyCtorDeletedProtected5&) = delete;
};

struct CopyCtorDeletedPrivate1 {
private:
#if __cplusplus >= 202002L
  // Uniform/aggregate initialization was removed in C++20 if there is a user declared constructor, so the initialization in make() below does not work
  // This example can only be tested for C++11 to C++17, in C++20 the constructor declaration is removed by making it an aggregate
  // SWIG still sees the deleted constructor below
#else
  CopyCtorDeletedPrivate1() = delete;
#endif
public:
  static CopyCtorDeletedPrivate1 make() { return {}; }
};
struct CopyCtorDeletedPrivate2 {
private:
  CopyCtorDeletedPrivate2() = delete;
  CopyCtorDeletedPrivate2(const CopyCtorDeletedPrivate2&) = delete;
};
struct CopyCtorDeletedPrivate3 {
private:
  CopyCtorDeletedPrivate3(const CopyCtorDeletedPrivate3&) = delete;
};
struct CopyCtorDeletedPrivate4 {
private:
  CopyCtorDeletedPrivate4() = default;
  CopyCtorDeletedPrivate4(const CopyCtorDeletedPrivate4&) = delete;
};
struct CopyCtorDeletedPrivate5 {
private:
  CopyCtorDeletedPrivate5() = default;
  CopyCtorDeletedPrivate5(const CopyCtorDeletedPrivate5&) = delete;
};

struct CopyCtorStackOnly1 {
  // Only constructible on the stack
  ~CopyCtorStackOnly1() = delete;
};
struct CopyCtorStackOnlyDerived1 : CopyCtorStackOnly1 {
  // this class is not constructible due to deleted base destructor
};
struct CopyCtorStackOnlyDerivedMore1 : CopyCtorStackOnlyDerived1 {
  // this class is not constructible due to deleted base destructor
};
%}
