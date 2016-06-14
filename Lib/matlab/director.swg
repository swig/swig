/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Matlab proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_DIRECTOR_MATLAB_HEADER_
#define SWIG_DIRECTOR_MATLAB_HEADER_

#include <string>
#include <sstream>
#include <iostream>
#include <exception>
#include <vector>
#include <map>

/*
  Use -DSWIG_DIRECTOR_NO_UEH if you prefer to avoid the use of the
  Undefined Exception Handler provided by swig.
*/
#ifndef SWIG_DIRECTOR_NO_UEH
#ifndef SWIG_DIRECTOR_UEH
#define SWIG_DIRECTOR_UEH
#endif
#endif


/*
  Use -DSWIG_DIRECTOR_STATIC if you prefer to avoid the use of the
  'Swig' namespace. This could be useful for multi-modules projects.
*/
#ifdef SWIG_DIRECTOR_STATIC
/* Force anonymous (static) namespace */
#define Swig
#endif

# define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)
# define SWIG_DIRECTOR_RGTR(ARG1, ARG2)

extern "C" {
  struct swig_type_info;

  mxArray *mxCreateSharedDataCopy(const mxArray *mx);
  //mxArray *mxCreateReference(const mxArray *mx);

struct mxArray_Tag_Partial {
    void *name_or_CrossLinkReverse;
    mxClassID ClassID;
    int VariableType;
    mxArray *CrossLink;
    size_t ndim;
    unsigned int RefCount; /* Number of sub-elements identical to this one */
};

mxArray *mxCreateReference(const mxArray *mx)
{
    struct mxArray_Tag_Partial *my = (struct mxArray_Tag_Partial *) mx;
    ++my->RefCount;
    return (mxArray *) mx;
}
}



namespace Swig {

  /* memory handler */
  struct GCItem {
    virtual ~GCItem() {}

    virtual int get_own() const {
      return 0;
    }
  };

  struct GCItem_var {
    GCItem_var(GCItem *item = 0) : _item(item) {
    }

    GCItem_var& operator=(GCItem *item) {
      GCItem *tmp = _item;
      _item = item;
      delete tmp;
      return *this;
    }

    ~GCItem_var() {
      delete _item;
    }

    GCItem * operator->() const {
      return _item;
    }

  private:
    GCItem *_item;
  };

  struct GCItem_Object : GCItem {
    GCItem_Object(int own) : _own(own) {
    }

    virtual ~GCItem_Object() {
    }

    int get_own() const {
      return _own;
    }

  private:
    int _own;
  };

  template <typename Type>
  struct GCItem_T : GCItem {
    GCItem_T(Type *ptr) : _ptr(ptr) {
    }

    virtual ~GCItem_T() {
      delete _ptr;
    }

  private:
    Type *_ptr;
  };

  template <typename Type>
  struct GCArray_T : GCItem {
    GCArray_T(Type *ptr) : _ptr(ptr) {
    }

    virtual ~GCArray_T() {
      delete[] _ptr;
    }

  private:
    Type *_ptr;
  };

  /* base class for director exceptions */
  class DirectorException : public std::exception {
  protected:
    std::string swig_msg;
  public:
    DirectorException(const char *error, const char *hdr ="", const char *msg ="") : swig_msg(hdr) {
      if (msg[0]) {
        swig_msg += " ";
        swig_msg += msg;
      }
    }

    virtual ~DirectorException() throw() {
    }

    /* Deprecated, use what() instead */
    const char *getMessage() const {
      return what();
    }

    const char *what() const throw() {
      return swig_msg.c_str();
    }

    static void raise(const char *error, const char *msg) {
      throw DirectorException(error, msg);
    }

    static void raise(const char *msg) {
      raise("SWIG:DirectorRuntimeError", msg);
    }
  };

  /* unknown exception handler  */
  class UnknownExceptionHandler {
  };

  /* type mismatch in the return value from a python method call */
  class DirectorTypeMismatchException : public DirectorException {
  public:
    DirectorTypeMismatchException(const char *error, const char *msg)
      : DirectorException(error, "SWIG director type mismatch", msg) {
    }

    DirectorTypeMismatchException(const char *msg="")
      : DirectorException("SWIG:DirectorRuntimeError", "SWIG director type mismatch", msg) {
    }

    static void raise(const char *error, const char *msg) {
      throw DirectorTypeMismatchException(error, msg);
    }

    static void raise(const char *msg) {
      throw DirectorTypeMismatchException(msg);
    }
  };

  /* any python exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException {
  public:
    DirectorMethodException(const char *msg = "")
      : DirectorException("SWIG:DirectorRuntimeError", "SWIG director method error.", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorMethodException(msg);
    }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg = "")
      : DirectorException("SWIG:DirectorRuntimeError", "SWIG director pure virtual method called", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };



# define SWIG_GUARD(mutex)


  /* director base class */
  class Director {
  private:
    /* reference counter */
    mutable int swig_refcount;

    /* flag indicating whether the object is owned by matlab or c++ */
    mutable bool swig_disown_flag;

    /* Name of field in MATLAB */
    std::string fieldname() const {
      std::stringstream ss;
      ss << "x" << this;
      return ss.str();
    }

    /* decrement the reference count of the wrapped matlab object */
    void swig_decref() {
      if (swig_disown_flag) {
        //mexPrintf("decref to %d\n", swig_refcount-1);

        if (--swig_refcount==0) {
          // Delete MATLAB storage
          std::string fname = fieldname();
          mxArray* field = mxCreateString(fname.c_str());
          mxArray* empty = mxCreateDoubleMatrix(0, 0, mxREAL);
          mxArray* rhs[2] = {field, empty};
          #ifndef HAVE_OCTAVE
          mxArray* error = mexCallMATLABWithTrap(0, 0, 2, rhs, "SwigStorage");
          #else
          int error = mexCallMATLAB(0, 0, 2, rhs, "SwigStorage");
          #endif
          mxDestroyArray(field);
          mxDestroyArray(empty);
          if (error) {
            #ifndef HAVE_OCTAVE
            mxDestroyArray(error);
            #endif
            mexErrMsgIdAndTxt("SWIG:Director:swig_decref", "Cannot call SwigStorage");
          }
        }
      }
    }

  public:
    /* Constructor */
    Director(mxArray *self) : swig_refcount(0), swig_disown_flag(false) {
      // Save MATLAB in SwigStorage
      std::string fname = fieldname();
      mxArray* field = mxCreateString(fname.c_str());
      mxArray* rhs[2] = {field, self};
      mxArray* error = mexCallMATLABWithTrap(0, 0, 2, rhs, "SwigStorage");
      mxDestroyArray(field);
      if (error) {
        mxDestroyArray(error);
        mexErrMsgIdAndTxt("SWIG:Director:Director", "Cannot call SwigStorage");
      }
    }

    /* discard our reference at destruction */
    virtual ~Director() {
      //mexPrintf("Calling destructor\n");
      swig_decref();
    }

    /* return a pointer to the wrapped object */
    mxArray *swig_get_self() const {
      // Save MATLAB in SwigStorage
      std::string fname = fieldname();
      mxArray* field = mxCreateString(fname.c_str());
      mxArray* swig_self = 0;
      mxArray* error = mexCallMATLABWithTrap(1, &swig_self, 1, &field, "SwigStorage");
      mxDestroyArray(field);
      if (error) {
        mxDestroyArray(error);
        mexErrMsgIdAndTxt("SWIG:Director:Director", "Cannot call SwigStorage");
      }
      return swig_self;
    }

    /* acquire ownership of the wrapped object */
    void swig_disown() const {
      if (!swig_disown_flag) {
        swig_disown_flag=true;
        swig_incref();
      }
    }

    /* increase the reference count of the wrapped object */
    void swig_incref() const {
      if (swig_disown_flag) {
        swig_refcount++;
        //mexPrintf("incref to %d\n", swig_refcount);
      }
    }

    /* methods to implement pseudo protected director members */
    virtual bool swig_get_inner(const char * /* swig_protected_method_name */) const {
      return true;
    }

    virtual void swig_set_inner(const char * /* swig_protected_method_name */, bool /* swig_val */) const {
    }

  /* ownership management */
  private:
    typedef std::map<void *, GCItem_var> swig_ownership_map;
    mutable swig_ownership_map swig_owner;

  public:
    template <typename Type>
    void swig_acquire_ownership_array(Type *vptr) const {
      if (vptr) {
        SWIG_GUARD(swig_mutex_own);
        swig_owner[vptr] = new GCArray_T<Type>(vptr);
      }
    }

    template <typename Type>
    void swig_acquire_ownership(Type *vptr) const {
      if (vptr) {
        SWIG_GUARD(swig_mutex_own);
        swig_owner[vptr] = new GCItem_T<Type>(vptr);
      }
    }

    void swig_acquire_ownership_obj(void *vptr, int own) const {
      if (vptr && own) {
        SWIG_GUARD(swig_mutex_own);
        swig_owner[vptr] = new GCItem_Object(own);
      }
    }

    int swig_release_ownership(void *vptr) const {
      int own = 0;
      if (vptr) {
        SWIG_GUARD(swig_mutex_own);
        swig_ownership_map::iterator iter = swig_owner.find(vptr);
        if (iter != swig_owner.end()) {
          own = iter->second->get_own();
          swig_owner.erase(iter);
        }
      }
      return own;
    }

  };

}

#endif
