%module(ruby_minherit="1") constructor_copy_non_const

// Tests %copyctor and non-const copy constructors in inheritance chain

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) CCDerived; /* C#, D, Java, PHP multiple inheritance */
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) CCProtectedDerived; /* C#, D, Java, PHP multiple inheritance */

%inline %{
  struct CCBase1 {
    CCBase1() {}
  };
%}

%copyctor;

%inline %{
  struct CCBase2 {
    CCBase2() {}
    CCBase2(CCBase2& other) {} // non-const copyctor
  };

  struct CCDerived : CCBase1, CCBase2 {
    CCDerived() {}
    // implicitly declared non-const copyctor
  };
  struct CCMoreDerived : CCDerived {
    // implicitly declared default ctor
    // implicitly declared non-const copyctor
  };
  struct CCMoreDerived2 : CCDerived {
    CCMoreDerived2() {}
    CCMoreDerived2(const CCMoreDerived2& other) {} // const copyctor
  };
  struct CCMoreMoreDerived2 : CCMoreDerived2 {
    // implicitly declared default ctor
    // implicitly declared const copyctor
  };
%}


// Repeat but with protected non-const copyctor
%inline %{
  struct CCProtectedBase2 {
    CCProtectedBase2() {}
  protected:
    CCProtectedBase2(CCProtectedBase2& other) {} // non-const copyctor
  };

  struct CCProtectedDerived : CCBase1, CCProtectedBase2 {
    CCProtectedDerived() {}
    // implicitly declared non-const copyctor
  };
  struct CCProtectedMoreDerived : CCProtectedDerived {
    // implicitly declared default ctor
    // implicitly declared non-const copyctor
  };
  struct CCProtectedMoreDerived2 : CCProtectedDerived {
    CCProtectedMoreDerived2() {}
    CCProtectedMoreDerived2(const CCProtectedMoreDerived2& other) {} // const copyctor
  };
  struct CCProtectedMoreMoreDerived2 : CCProtectedMoreDerived2 {
    // implicitly declared default ctor
    // implicitly declared const copyctor
  };
%}
