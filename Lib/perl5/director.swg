/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to Perl extensions.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#include <string>
#include <typeinfo>
#include <exception>
#include <map>

#define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)

#define swig_owntype int

namespace Swig {
  /* base class for director exceptions */
  class DirectorException {
    public:
      SV *sv;
      DirectorException(const char *err = "") throw() :
        sv(newSVpv(err, 0)) {
        init();
      }
      DirectorException(SV *err) throw() : sv(err) {
        init();
      }
      /* to comply with the std::exception interface */
      virtual const char *what() const throw() {
        return SvPV_nolen(sv);
      }
      /* to comply with the Swig::DirectorException interface of other
       * language directors */
      virtual const char *getMessage() const {
        return SvPV_nolen(sv);
      }
      virtual ~DirectorException() throw() {
        SvREFCNT_dec(sv);
      }
    private:
      virtual void init() {
        SvREFCNT_inc(sv);
        /* warn("throwing <<%s>>", SvPV_nolen(sv)); */
      }
  };

  /* type mismatch in the return value from a python method call */
  class DirectorTypeMismatchException : public DirectorException {
    public:
      DirectorTypeMismatchException(const char* type, const char* msg="") :
        Swig::DirectorException(newSVpvf("%s %s", type, msg)) {
      }
      static void raise(const char* type, const char *msg) {
        throw DirectorTypeMismatchException(type, msg);
      }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
    public:
      DirectorPureVirtualException(const char *msg) :
        Swig::DirectorException(newSVpvf("%s is abstract", msg)) {
      }
      static void raise(const char *msg) {
        throw DirectorPureVirtualException(msg);
      }
  };

  /* Perl exceptions generated during director methods get wrapped for
   * their journey though C++ */
  class DirectorMethodException : public DirectorException {
    public:
      DirectorMethodException(SV *err) : DirectorException(err) {}
      static void raise(SV *err) {
        throw DirectorMethodException(err);
      }
  };
  struct GCItem { /* typeless abstract base */
    virtual ~GCItem() {};
    virtual void drop(void) = 0;
  };
  template <typename Type>
  struct GCTyped : GCItem { /* type specific common abstract base */
    Type ptr;
    GCTyped(Type aPtr) : ptr(aPtr) {};
    virtual ~GCTyped() {};
    void drop(void) {
      ptr = 0;
    }
  };
  struct GCObj : GCTyped<void*> {
    GCObj(void *aPtr) : GCTyped<void*>(aPtr) {};
    ~GCObj() {
      /* TODO: I'm unclear on why swig_acquire_ownership_obj() gets a
       * void* where others get a typed object.  what I'd really love is
       * access to the swig_perl_wrap struct, but getting that will be
       * fairly involved. */
      /* if (this->ptr) delete this->ptr; */
    }
  };
  template <typename Type>
  struct GCArray : GCTyped<Type> {
    GCArray(Type aPtr) : GCTyped<Type>(aPtr) {};
    ~GCArray() {
      if (this->ptr) delete[] this->ptr;
    }
  };
  template <typename Type>
  struct GCPtr : GCTyped<Type> {
    GCPtr(Type aPtr) : GCTyped<Type>(aPtr) {};
    ~GCPtr() {
      if (this->ptr) delete this->ptr;
    }
  };

  /* director base class */
  class Director {
    private:
      SV  *mSelf;
      typedef std::map<void*, GCItem*> hold_map;
      mutable hold_map holdings;

      /* TODO: understand ownership handling */
      /* working assumption: a "disowned" director must keep the perl
       * self SV alive manually because 
       * C++ holds director and director must hold the sv.
       * but an "owned" one must not hold a reference it's sv because
       * the perl interpreter will expect it to fall out when it lets
       * go.
       */
    public:
      Director() : mSelf(0) {
      }
      virtual ~Director() {
        if (!SvWEAKREF(mSelf))
          SvREFCNT_dec(mSelf);
        for (hold_map::iterator cur = holdings.begin();
            cur != holdings.end(); cur++) {
          delete cur->second;
        }
      }
      void setSelf(SV *self) {
        if (mSelf)
          croak("can not recycle directors");
        if (!self || !SvOK(self))
          croak("refusing to wrap bogus perl val");
        mSelf = newSVsv(self);
        sv_rvweaken(mSelf);
      }
      SV *getSelf() const {
        if (!mSelf)
          croak("director has no identity %p(%p)", this, mSelf);
        return mSelf;
      }
      void swig_disown() {
        /* perl will let go, so I need to hang on.  We can't
         * unweaken a ref, but we can copy it to a strong one. */
        mSelf = newSVsv(mSelf);
      }
      /* swig_{acquire,release}* are fully functional yet and the api
       * not final.  There are almost certainly leaks, but should be no
       * segfaults. */
      void swig_acquire_ownership_obj(void *vptr, int own) const {
        if (!vptr) return;
        holdings[vptr] = new GCObj(vptr);
        /* warn("acquiring ownership obj 0x%p %08x", vptr, own); */
      }
      template <typename Type>
      void swig_acquire_ownership_array(Type vptr) const {
        if (!vptr) return;
        holdings[vptr] = new GCArray<Type>(vptr);
        /* warn("acquiring ownership array 0x%p", vptr); */
      }
      template <typename Type>
      void swig_acquire_ownership(Type vptr) const {
        if (!vptr) return;
        holdings[vptr] = new GCPtr<Type>(vptr);
        /* warn("acquiring ownership 0x%p", vptr); */
      }
      int swig_release_ownership(void *vptr) const {
        if (!vptr) return 0;
        hold_map::iterator iter = holdings.find(vptr);
        if (iter == holdings.end()) return 0;
        GCItem *gc = iter->second;
        holdings.erase(iter);
        gc->drop();
        delete gc;
        /* warn("swig_release_ownership 0x%p", vptr); */
        return 1;
      }
  };
}

#endif /* __cplusplus */
