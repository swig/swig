// This tests SWIG's handling of typemaps and namespaces
%module namespace_typemap

%{
namespace test {
   /* A minimalistic string class */
   class string {
      char *data;
   public:
      string() {
	data = 0;
      }
      string(const char *s) {
        data = new char[strlen(s)+1];
	strcpy(data,s);
      }
     ~string() {
        if (data) delete [] data;
      }
      char *c_str() {
        return data;
      };
   };

   /* A minimalistic complex class */
   class complex {
      double re;
      double im;
   public:
      complex(double r = 0, double i = 0) {
	re = r;
	im = i;
      }
      double real() {
        return re;
      }
      double imag() {
        return im;
      }
   };
}
 %}

/* SWIG interface tests */

#ifdef SWIGPYTHON
%typemap(in) test::complex * {
    if (PyComplex_Check($input)) {
	$1 = new complex(PyComplex_RealAsDouble($input),
			 PyComplex_ImagAsDouble($input));
    } else {
	PyErr_SetString(PyExc_TypeError,"Expected complex.\n");
	return NULL;
    }
}
%typemap(freearg) complex * {
    delete $1;
}
#endif

namespace test {
    class string;
#ifdef SWIGPYTHON
	%typemap(in) string * {
	    $1 = new string(PyString_AsString($input));
	}
	%typemap(freearg) string * {
	    delete $1;
	}
#endif
}

%inline %{
    namespace test {
	class string;
	class complex;

	/* Functions in the namespace itself */
	char *stest1(string *s) {
	    return s->c_str();
	}
	double ctest1(complex *c) {
	    return c->real();
	}
    }

    namespace test2 {
	using test::string;
	using test::complex;

	/* Functions in another namespace */
	char *stest2(string *s) {
	    return s->c_str();
	}
	double ctest2(complex *c) {
	    return c->real();
	}
    }

    namespace test3 {
	using namespace test;

	char *stest3(string *s) {
	    return s->c_str();
	}
	double ctest3(complex *c) {
	    return c->real();
	}
    }
    
    namespace test4 {
	using namespace test2;

	char *stest4(string *s) {
	    return s->c_str();
	}
	double ctest4(complex *c) {
	    return c->real();
	}
    }

    namespace test5 {
	using namespace test3;

	char *stest5(string *s) {
	    return s->c_str();
	}
	double ctest5(complex *c) {
	    return c->real();
	}
    }

    char *stest6(test::string *s) {
	return s->c_str();
    }
    double ctest6(test::complex *c) {
	return c->real();
    }

    char *stest7(test2::string *s) {
	return s->c_str();
    }
    double ctest7(test2::complex *c) {
	return c->real();
    }

    char *stest8(test3::string *s) {
	return s->c_str();
    }
    double ctest8(test3::complex *c) {
	return c->real();
    }

    char *stest9(test4::string *s) {
	return s->c_str();
    }
    double ctest9(test4::complex *c) {
	return c->real();
    }

    char *stest10(test5::string *s) {
	return s->c_str();
    }
    double ctest10(test5::complex *c) {
	return c->real();
    }

    namespace test11 = test;
    
    char *stest11(test11::string *s) {
	return s->c_str();
    }
    double ctest11(test11::complex *c) {
	return c->real();
    }

    using namespace test2;
    using test::complex;

    char *stest12(string *s) {
	return s->c_str();
    }
    double ctest12(complex *c) {
	return c->real();
    }
%}







