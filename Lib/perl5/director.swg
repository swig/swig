/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to Perl extensions.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#include <string>
#include <typeinfo>
#include <exception>

#define swig_owntype int

namespace Swig {

  /* base class for director exceptions */
  class DirectorException {
    public:
      SV *sv;
      DirectorException(const char *msg="") {
	sv = sv_2mortal(newSVpv(msg, 0));
	SvREFCNT_inc(sv);
      }
      DirectorException(SV *err) : sv(err) { }
      virtual ~DirectorException() {
	/* TODO: probably leaky here */
	/* SvREFCNT_dec(sv); */
      }
  };

  /* type mismatch in the return value from a python method call */
  class DirectorTypeMismatchException : public DirectorException {
    public:
      DirectorTypeMismatchException(const char* type, const char* msg="") {
	sv = newSVpvf("%s %s", type, msg);
      }
      static void raise(const char* type, const char *msg) {
        throw DirectorTypeMismatchException(type, msg);
      }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
    public:
      DirectorPureVirtualException(const char *msg) {
	sv = newSVpvf("%s is abstract", msg);
      }
      static void raise(const char *msg) {
        throw DirectorPureVirtualException(msg);
      }
  };

  /* Perl exceptions generated during director methods get wrapped for
   * their journey though C++ */
  class DirectorRunException : public DirectorException {
    public:
      DirectorRunException(SV *err) : DirectorException(err) { }
      static void raise(SV *err) {
	throw DirectorRunException(err);
      }
  };

  /* director base class */
  class Director {
    private:
      SV  *mSelf;
	  bool mDisowned;
	  AV  *mOwned;

      /* TODO: understand ownership handling */
	  /* working assumption: a "disowned" director must keep the perl
	   * self SV alive manually because 
	   * C++ holds director and director must hold the sv.
	   * but an "owned" one must not hold a reference it's sv because
	   * the perl interpreter will expect it to fall out when it lets
	   * go.
	   */
    public:
      Director() : mSelf(NULL), mDisowned(false), mOwned(newAV()) {
      }
      virtual ~Director() {
	  	if(mDisowned)
			SvREFCNT_dec(mSelf);
		av_undef(mOwned);
      }
      void setSelf(SV *self) {
	  	if(mSelf) croak("can not recycle directors");
		if(!self || !SvOK(self)) croak("refusing to wrap bogus perl val");
		mSelf = newSVsv(self);
		sv_rvweaken(mSelf);
//		do_sv_dump(0, Perl_debug_log, mSelf, 0, 0, false, 0);
      }
      SV *getSelf() const {
        if(!mSelf || !SvOK(mSelf)) {
			croak("director has no identity %p(%p) %c",
				this, mSelf, mDisowned ? 't' : 'f');
		}
        return mSelf;
      }
      void swig_disown() {
	  	if(mDisowned) return;
	  	mDisowned = true;
		// our weak ref should become a hard ref now.
		// don't know how to unweaken, but I can create a stong copy.
		sv_2mortal(mSelf);
		mSelf = newSVrv(SvRV(mSelf), NULL);
		SvREFCNT_inc(mSelf);
        warn("disowning %s and I don't know why", SvPV_nolen(mSelf));
      }
	  void swig_acquire_ownership_obj(void *vptr, int own) const {
	    warn("acquiring ownership obj 0x%p %08x", vptr, own);
		//warn(">|> %d\n", SvREFCNT(own));
	//	av_push(mOwned, own);
		//warn(">|> %d\n", SvREFCNT(own));
	  }
	  void swig_acquire_ownership_array(void *vptr) const {
	    warn("acquiring ownership array 0x%p", vptr);
	  }
	  void swig_acquire_ownership(void *vptr) const {
	    warn("acquiring ownership 0x%p", vptr);
	  }
	  int swig_release_ownership(void *vptr) const {
	  	warn("swig_release_ownership 0x%p", vptr);
	  }
  };
}

#endif /* __cplusplus */
