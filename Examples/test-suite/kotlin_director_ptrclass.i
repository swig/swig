%module(directors="1") kotlin_director_ptrclass

// Tests that custom director typemaps can be used with C++ types that
// represent a pointer, in such a way that Kotlin perceives this class as
// equivalent to the underlying type. In particular, this verifies that
// a typemap lookup within a typemap kwarg, in this case
// kdirectorin:descriptor, works as expected.

%{
namespace bar {
class Baz {
public:
	Baz() : touched(false) {}
	void SetTouched() { touched = true; }
	bool GetTouched() { return touched; }
private:
	bool touched;
};

template <typename T>
class Ptr {
public:
	Ptr(T* b) : b_(b) {}
        T* Get() const { return b_; }
private:
	T* b_;
};

class Foo {
public:
        // Calling FinalMaybeTouch from Kotlin unambiguously goes through C++ to
        // reach MaybeTouch.
        Ptr< bar::Baz > FinalMaybeTouch(Baz* b) {
	  return MaybeTouch(Ptr< bar::Baz >(b));
	}
	virtual Ptr< bar::Baz > MaybeTouch(Ptr< bar::Baz > f) {
	  return f; /* Don't touch */
	}
	virtual ~Foo() {}
};
}
%}

%feature("director") Foo;

%typemap(jni) bar::Ptr< bar::Baz > "jlong"
%typemap(ktype) bar::Ptr< bar::Baz > "Long"
// Kotlin is null-aware: the typemaps below can yield null, so the proxy type is nullable
%typemap(kstype) bar::Ptr< bar::Baz > "Baz?"
%typemap(in) bar::Ptr< bar::Baz > {
  $1 = bar::Ptr< bar::Baz >(*( bar::Baz**)&$input);
}
%typemap(out) bar::Ptr< bar::Baz > {
  const bar::Ptr< bar::Baz >& ptr = $1;
  if (ptr.Get()) {
    $result = ($typemap(jni, bar::Baz))ptr.Get();
  } else {
    $result = 0;
  }
}
%typemap(kin) bar::Ptr< bar::Baz > "$typemap(kstype, bar::Baz).getCPtr($kotlininput)"
%typemap(kout) bar::Ptr< bar::Baz > {
  val cPtr = $jnicall
  return if (cPtr == 0L) null else $typemap(kstype, bar::Baz)(cPtr, false)
}
%typemap(directorin, descriptor="L$packagepath/$typemap(kstype, bar::Baz);") bar::Ptr< bar::Baz >
%{ *((bar::Baz**)&$input) = ((bar::Ptr< bar::Baz >&)$1).Get(); %}
%typemap(directorout) bar::Ptr< bar::Baz > {
  $result = bar::Ptr< bar::Baz >(*( bar::Baz**)&$input);
}
%typemap(kdirectorin) bar::Ptr< bar::Baz > %{
  if ($jniinput == 0L) null else $typemap(kstype, bar::Baz)($jniinput, false)
%}
%typemap(kdirectorout) bar::Ptr< bar::Baz > "$typemap(kstype, bar::Baz).getCPtr($kotlincall)"

namespace bar {
class Baz {
public:
        Baz() : touched(false) {}
        void SetTouched() { touched = true; }
        bool GetTouched() { return touched; }
private:
        bool touched;
};

template <typename T>
class Ptr {
public:
        Ptr(T* b) : b_(b) {}
        T* Get() { return b_; }
private:
        T* b_;
};

class Foo {
public:
        // Calling FinalMaybeTouch from Kotlin unambiguously goes through C++ to
        // reach MaybeTouch.
	Ptr< bar::Baz > FinalMaybeTouch(Baz* b) {
          return MaybeTouch(Ptr< bar::Baz >(b));
        }
        virtual Ptr< bar::Baz > MaybeTouch(Ptr< bar::Baz > f) {
          return f; /* Don't touch */
        }
        virtual ~Foo() {}
};
}
