/*
 * Test Kotlin director typemaps and features
 */

%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR); /* Thread/reentrant unsafe wrapping, consider returning by value instead. */

%module(directors="1") kotlin_director

// Kotlin has no finalizers (the kfinalize typemap is empty by default and memory is
// reclaimed by an explicit delete() call), so unlike the Java test there is no
// finalize()-based reaping of director objects - the runme calls delete() explicitly.

%{
#include <string>
#include <vector>

class Quux {
public:
	Quux() : memb_("default Quux ctor arg") {instances_++; }
	Quux(const std::string &arg) : memb_(arg) {instances_++;}
	Quux(const Quux &src) : memb_(src.memb_) {instances_++;}
	virtual ~Quux() {instances_--;}
	virtual const std::string &director_method() { return memb_; }
	const std::string &member() { return memb_; }
        static int instances() { return instances_; }
private:
        static int instances_;
	std::string memb_;
};

int Quux::instances_ = 0;

class QuuxContainer {
protected:
	typedef std::vector<Quux *> quuxvec_t;
public:
	QuuxContainer() : quuxen_()
	{ }
	~QuuxContainer() {
	  for (quuxvec_t::iterator iter = quuxen_.begin(); iter != quuxen_.end(); ++iter) {
	    delete *iter;
          }
	  quuxen_.clear();
	}
	void push(Quux *elem) {
	  quuxen_.push_back(elem);
	}
	Quux *get(int idx) {
	  return quuxen_[idx];
        }
	const std::string &invoke(int idx) {
	  return quuxen_[idx]->director_method();
        }
	size_t size() {
	  return quuxen_.size();
        }
private:
	quuxvec_t quuxen_;
};
%}

%include "std_string.i"

%feature("director") Quux;
SWIG_DIRECTOR_OWNED(Quux)

class Quux {
public:
	Quux();
	Quux(const std::string &arg);
	Quux(const Quux &src);
	virtual ~Quux();
	virtual const std::string &director_method();
	const std::string &member();
        static int instances();
};

class QuuxContainer {
public:
	QuuxContainer();
	~QuuxContainer();
	void push(Quux *elem);
	Quux *get(int idx);
	const std::string &invoke(int idx);
	size_t size();
};


%feature("director");

%typemap(kcode) hi::Quux1 %{
  @JvmField var disconnectMethodCalled: Boolean = false
%}

%typemap(directordisconnect, methodname="disconnect_director") hi::Quux1 %{
  fun $methodname() {
    swigCMemOwn = false
    $jnicall
    // add in a flag to check this method is really called
    disconnectMethodCalled = true
  }
%}

%inline %{

namespace hi  {
  struct Quux1 : public Quux {
    Quux1(const std::string& arg) : Quux(arg) {}
    virtual int ff(int i = 0) {return i;}
  };
}

struct JObjectTest {
  virtual ~JObjectTest() {}
  // Test special Java JNI type jobject
  virtual jobject foo(jobject x) { return x; }
};

%}

%kotlinexception("Exception") etest "$action"
%inline %{
struct KotlinExceptionTest {
  virtual ~KotlinExceptionTest() {}
  virtual void etest() {}
};
%}
