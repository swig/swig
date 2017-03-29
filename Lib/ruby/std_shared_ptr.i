#define SWIG_SHARED_PTR_NAMESPACE std
%include <boost_shared_ptr.i>


 /*
  * We want to put the following code after the fragment "StdTraits" at rubystdcommon.swg.
  * This code is needed if and only if the fragment and this std_shared_ptr.i are included at the same time.
  * They don't always require each other. The order of including them is not predetermined either.
  * So specifying the dependecy by using %fragment does not work.
  */
%wrapper %{
#ifdef SWIG_RUBYSTDCOMMON
namespace swig {
  template <class Type>
  struct traits_asptr<std::shared_ptr<Type> > {
    static int asptr(VALUE obj, std::shared_ptr<Type> **val) {
      std::shared_ptr<Type> *p=0;
      swig_type_info *descriptor = type_info<std::shared_ptr<Type> >();
      swig_ruby_owntype newmem = {0, 0};
      int res = descriptor ? SWIG_ConvertPtrAndOwn(obj, (void **)&p, descriptor, 0, &newmem) : SWIG_ERROR;
      if (SWIG_IsOK(res) && p) {
	if (val && *val) **val = *p;
        if (newmem.own & SWIG_CAST_NEW_MEMORY) delete p;
        return SWIG_OK;
      } else {
        return SWIG_ERROR;
      }
    }
  };

  template <class Type>
  struct traits_asval<std::shared_ptr<Type> > {
    static int asval(VALUE obj, std::shared_ptr<Type> *val) {
      if (val) {
        std::shared_ptr<Type> ret;
	std::shared_ptr<Type> *p=&ret;
	int res = traits_asptr<std::shared_ptr<Type> >::asptr(obj, &p);
	if (!SWIG_IsOK(res)) return res;
        if (val) *val = ret;
        return SWIG_OK;
      } else {
	return traits_asptr<std::shared_ptr<Type> >::asptr(obj, (std::shared_ptr<Type> **)(0));
      }
    }
  };

  template <class Type>
    struct traits_asval<std::shared_ptr<Type>*> {
    static int asval(VALUE obj, std::shared_ptr<Type> **val) {
      if (val && *val) {
        typedef typename noconst_traits<std::shared_ptr<Type> >::noconst_type noconst_type;
        noconst_type ret;
        noconst_type *p = &ret;
        int res = traits_asptr<noconst_type>::asptr(obj,  &p);
        if (SWIG_IsOK(res)) {
          **(const_cast<noconst_type**>(val)) = ret;
	}
	return res;
      } else {
	return traits_asptr<std::shared_ptr<Type> >::asptr(obj, (std::shared_ptr<Type> **)(0));
      }
    }
  };

  template <class Type>
  struct traits_as<std::shared_ptr<Type>, pointer_category> {
    static std::shared_ptr<Type> as(VALUE obj, bool throw_error) {
      std::shared_ptr<Type> ret;
      std::shared_ptr<Type> *v = &ret;
      int res = traits_asptr<std::shared_ptr<Type> >::asptr(obj, &v);
      if (SWIG_IsOK(res)) {
	return ret;
      } else {
	// Uninitialized return value, no Type() constructor required.
	if (throw_error) throw std::invalid_argument("bad type");
	VALUE lastErr = rb_gv_get("$!");
	if (lastErr == Qnil) {
	  SWIG_Error(SWIG_TypeError,  swig::type_name<std::shared_ptr<Type> >());
	}
	static std::shared_ptr<Type> *v_def = (std::shared_ptr<Type>*) malloc(sizeof(std::shared_ptr<Type>));
	memset(v_def,0,sizeof(std::shared_ptr<Type>));
	return *v_def;
      }
    }
  };

  template<class Type>
  struct traits_from<std::shared_ptr<const Type> > {
    static VALUE from(const std::shared_ptr<const Type>& val) {
      std::shared_ptr<Type> p = std::const_pointer_cast<Type>(val);
      return swig::from(p);
    }
  };
}
#endif
%}
