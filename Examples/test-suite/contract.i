%module contract

%warnfilter(SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
	    SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) C; /* Ruby, C#, D, Java, PHP multiple inheritance */

#ifdef SWIGCSHARP
%ignore B::bar; // otherwise get a warning: `C.bar' no suitable methods found to override
#endif

#ifdef SWIGD
%ignore B::bar; // Prevents getting an error that C.bar does not override any function because multiple inheritance is not supported.
#endif

%contract test_preassert(int a, int b) {
require:
	a > 0;
	b > 0;
}

%contract test_postassert(int a) {
ensure:
	test_postassert > 0;
}

%contract test_prepost(int a, int b) {
require:
	a > 0;
ensure:
	test_prepost > 0;
}

// Contract parameter names that are also the names used in the wrapper for the arguments and the result
%contract test_arg_names(int x, int arg1) {
require:
	x > 0;
}

%contract test_result_name(int result) {
ensure:
	test_result_name > 0;
}

// Members with the names of a parameter and of the function
%contract test_member_names(const ContractSize *size, int n) {
require:
	size->n == n;
ensure:
	test_member_names == size->test_member_names + n;
}

// A parameter's name in a literal
%contract test_literal_name(const char *n) {
require:
	n[0] != 'n';
}

%inline %{
int test_arg_names(int x, int arg1) {
    return x + arg1;
}

int test_result_name(int value) {
    return -value;
}

typedef struct ContractSize {
  int n;
  int test_member_names;
} ContractSize;

int test_member_names(const ContractSize *size, int n) {
    return size->test_member_names + n;
}

int test_literal_name(const char *n) {
    return n[0];
}

int test_preassert(int x, int y) {
   if ((x > 0) && (y > 0)) return 1;
   return 0;
}

int test_postassert(int x) {
    return x;
}

int test_prepost(int x, int y) {
    return x+y;    
}
%}

#ifdef __cplusplus
/* Class tests */

%contract Foo::test_preassert(int x, int y) {
 require:
  x > 0;
  y > 0;
}

%contract Foo::test_postassert(int a) {
 ensure:
  test_postassert > 0;
}

%contract Foo::test_prepost(int a, int b) {
 require:
  a > 0;
 ensure:
  test_prepost > 0;
}

%contract Foo::stest_prepost(int a, int b) {
 require:
  a > 0;
 ensure:
  stest_prepost > 0;
}

%contract Bar::test_prepost(int c, int d) {
 require:
  d > 0;
}

%inline %{
class Foo {
public:
        virtual ~Foo() { }
  
	virtual int test_preassert(int x, int y) {
            if ((x > 0) && (y > 0)) return 1;
            return 0;
	}   
	virtual int test_postassert(int x) {
	  return x;
	}
	virtual int test_prepost(int x, int y) {
	  return x+y;
	}
	static int stest_prepost(int x, int y) {
	  return x+y;
	}
 };

class Bar : public Foo {
public:
	virtual int test_prepost(int x, int y) {
	  return x+y;
	}
};

%}

/* Multiple inheritance test */

%contract A::foo(int i, int j, int k, int l, int m) {
 require:
  i > 0;
  j > 0;
 ensure:
  foo > 0;
}

%contract B::bar(int x, int y, int z, int w, int v) {
 require:
  w > 0;
  v > 0;
 ensure:
  bar > 0;
}

%contract C::foo(int a, int b, int c, int d, int e) {
 require:
  c > 0;
  d > 0;
 ensure:
  foo > 0;
}

%contract D::foo(int, int, int, int, int x) {
 require:
  x > 0;
}

%contract D::bar(int a, int b, int c, int, int) {
 require:
  a > 0;
  b > 0;
  c > 0;
}

%inline %{
  class A {
   public:
    virtual ~A() {}
    virtual int foo(int a, int b, int c, int d, int e) {
      if ((a > 0) && (b > 0) && (c > 0) && (d > 0) && (e > 0)) {
	return 1;
      }
      return 0;
    }
  };

  class B {
   public:
    virtual ~B() {}
    virtual int bar(int a, int b, int c, int d, int e) {
      if ((a > 0) && (b > 0) && (c > 0) && (d > 0) && (e > 0)) {
	return 1;
      }
      return 0;
    }
  };

  class C : public A, public B {
   public:
    virtual int foo(int a, int b, int c, int d, int e) {
      return A::foo(a,b,c,d,e);
    }
    virtual int bar(int a, int b, int c, int d, int e) {
      return B::bar(a,b,c,d,e);
    }
  };
  
  class D : public C {
   public:
    virtual int foo(int a, int b, int c, int d, int e) {
      return C::foo(a,b,c,d,e);
    }
    virtual int bar(int a, int b, int c, int d, int e) {
      return C::bar(a,b,c,d,e);
    }
  };
  %}

%extend E {
  %contract manipulate_i(int i) {
  require:
  i <= $self->m_i;
  }
  %contract manipulate_arg1(int arg1) {
  require:
  arg1 <= $self->m_i;
  }
  %contract manipulate_m_i(int m_i) {
  require:
  m_i <= $self->m_i;
  }
}

%inline %{
struct E {
  int m_i;
  void manipulate_i(int i) {
  }
  void manipulate_arg1(int arg1) {
  }
  void manipulate_m_i(int m_i) {
  }
};
%}


// Namespace

%{
namespace myNames {

class myClass
{
    public:
    	myClass(int i) {}
};

}
%}

namespace myNames {

%contract myClass::myClass( int i ) {
require:
    i > 0;
}

class myClass
{
    public:
    	myClass(int i) {}
};

}
#endif
