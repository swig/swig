%module(directors="1") director_abuse

/* Hoping to test bouncing errors between C++ throws and interpreter
 * error objects.  Ideally the translations would be symmetric so that
 * C++ errors don't get mangled by a trip through the interpreter and
 * vice versa.
 * This test uses DirectorException::getMessage which isn't implemented
 * in all languages.
 */

%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) msg;  // Setting a const char * variable may leak memory.

%feature("director") Thing;
%feature("director") Holder;
%feature("director") Exception;

%apply SWIGTYPE *DISOWN { Thing *aThing };

%inline %{

struct Exception {
    const char *msg;
    Exception(const char *str) : msg(str) { };
    virtual ~Exception() {};
};

struct Thing {
    int attr;
    virtual int get_attr(void) { return attr; };
    virtual void set_attr(int v) { attr = v; };
    virtual ~Thing() {};
};

struct Holder {
    Thing *thing;
    Holder() : thing(0) {};
    Holder(Thing *aThing) : thing(aThing) {};
    virtual int get_attr(void) { return thing->get_attr(); }
    virtual void set_attr(int v) { thing->set_attr(v); }
    virtual ~Holder() {
        if (thing) delete thing;
    };
};

const char *set_attr(Holder *h, int v) {
    static char buf[1024];
    buf[0] = '\0';
    try {
        h->set_attr(v);
    } catch(Exception &e) {
        snprintf(buf, 1024, "Exception: %s", e.msg);
    } catch(Swig::DirectorException &e) {
        snprintf(buf, 1024, "Swig::DirectorException: %s", e.getMessage());
    } catch(...) {
        strcpy(buf, "misc exception in set_attr");
    };
    return buf;
}

%}
%extend Exception {
  const char* __str__() {
    return $self->msg;
  }
}
