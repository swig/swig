clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))
#source("unittest.R")

dyn.load(paste("li_boost_shared_ptr", .Platform$dynlib.ext, sep=""))
source("li_boost_shared_ptr.R")
cacheMetaData(1)

# simple shared_ptr usage - created in C++

invisible(debug_shared(TRUE))
unittest(debug_shared(), TRUE)


# Expect 1 instance - the one global variable (GlobalValue)
unittest(Klass_getTotal_count(), 1)

# Change loop count to run for a long time to monitor memory
unittest(shared_ptr_wrapper_count(), NOT_COUNTING())


#
# test suite to be run in a loop
#

testSuite_verifyCount <- function(expected, k) {
  got = use_count(k)
  unittest(expected, got);
}

testSuite <- function() {

  #
  # Reference Implementation is li_boost_shared_ptr_runme.py
  #

  # simple shared_ptr usage - created in C++
  {
    k = Klass("me oh my")
    val = k$getValue()
    unittest("me oh my", val)
    testSuite_verifyCount(1, k)
  }

  # simple shared_ptr usage - not created in C++
  {
    k = factorycreate()
    val = k$getValue()
    unittest("factorycreate", val)
    testSuite_verifyCount(1, k)
  }

  # pass by shared_ptr
  {
    k = Klass("me oh my")
    kret = smartpointertest(k)
    val = kret$getValue()
    unittest("me oh my smartpointertest", val)
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(2, kret)
  }

  # pass by shared_ptr pointer
  {
    k = Klass("me oh my")
    kret = smartpointerpointertest(k)
    val = kret$getValue()
    unittest("me oh my smartpointerpointertest", val)
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(2, kret)
  }

  # pass by shared_ptr reference
  {
    k = Klass("me oh my")
    kret = smartpointerreftest(k)
    val = kret$getValue()
    unittest("me oh my smartpointerreftest", val)
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(2, kret)
  }

  {
    # pass by shared_ptr pointer reference
    k = Klass("me oh my")
    kret = smartpointerpointerreftest(k)
    val = kret$getValue()
    unittest("me oh my smartpointerpointerreftest", val)
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(2, kret)
  }

  {
    # pass by shared_ptr pointer reference
    k = Klass("me oh my");
    kret = smartpointerpointerreftest(k);
    val = kret$getValue()
    unittest("me oh my smartpointerpointerreftest", val);
    testSuite_verifyCount(2, k);
    testSuite_verifyCount(2, kret);
  }

  # const pass by shared_ptr
  {
    k = Klass("me oh my");
    kret = constsmartpointertest(k);
    val = Klass_getValue(kret);
    unittest("me oh my", val);
    testSuite_verifyCount(2, k);
    testSuite_verifyCount(2, kret);
  }

  # const pass by shared_ptr pointer
  {
    k = Klass("me oh my")
    kret = constsmartpointerpointertest(k)
    val = Klass_getValue(kret)
    unittest("me oh my", val)
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(2, kret)
  }

  # const pass by shared_ptr reference
  {
    k = Klass("me oh my")
    kret = constsmartpointerreftest(k)
    val = Klass_getValue(kret)
    unittest("me oh my", val)
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(2, kret)
  }

  # pass by value
  {
    k = Klass("me oh my");
    kret = valuetest(k);
    val = kret$getValue();
    unittest("me oh my valuetest", val);
    testSuite_verifyCount(1, k);
    testSuite_verifyCount(1, kret);
  }

  # pass by pointer
  {
    k = Klass("me oh my");
    kret = pointertest(k);
    val = kret$getValue();
    unittest("me oh my pointertest", val);
    testSuite_verifyCount(1, k);
    testSuite_verifyCount(1, kret);
  }

  # pass by reference
  {
    k = Klass("me oh my");
    kret = reftest(k);
    val = kret$getValue();
    unittest("me oh my reftest", val);
    testSuite_verifyCount(1, k);
    testSuite_verifyCount(1, kret);
  }

  # pass by pointer reference
  {
    k = Klass("me oh my");
    kret = pointerreftest(k);
    val = kret$getValue();
    unittest("me oh my pointerreftest", val);
    testSuite_verifyCount(1, k);
    testSuite_verifyCount(1, kret);
  }

  # null tests
  {
    k = NULL

    if (!is.null(smartpointertest(k))) {
      stop("return was not null");
    }

    if (!is.null(smartpointerpointertest(k))) {
      stop("return was not null");
    }

    if (!is.null(smartpointerreftest(k))) {
      stop("return was not null");
    }

    if (!is.null(smartpointerpointerreftest(k))) {
      stop("return was not null");
    }

    if (nullsmartpointerpointertest(k) != "null pointer") {
      stop("not null smartpointer pointer");
    }

    bNotCatched = F
    try({
      valuetest(k);
      bNotCatched = T
    }, silent = T)
    if (bNotCatched) {
      stop("Failed to catch null pointer");
    }

   if (!is.null(pointertest(k))) {
      stop("return was not null");
    }

    bNotCatched = F
    try({
      reftest(k);
      bNotCatched = T
    }, silent = T)
    if (bNotCatched) {
      stop("Failed to catch null pointer");
    }

    # test null pointers emitted from C++

    k = sp_pointer_null()
    if (!is.null(k)) {
      stop("return was not null")
    }

    k = null_sp_pointer()
    if (!is.null(k)) {
      stop("return was not null")
    }

    k = sp_value_null()
    if (!is.null(k)) {
      stop("return was not null")
    }
  }

  # $owner
  {
    k = pointerownertest();
    val = k$getValue();
    unittest("pointerownertest", val);
    testSuite_verifyCount(1, k);
  }

  {
    k = smartpointerpointerownertest();
    val = k$getValue();
    unittest("smartpointerpointerownertest", val);
    testSuite_verifyCount(1, k);
  }

  #
  # ###################### Derived and base class mixed ######################
  #

  # pass by shared_ptr (mixed)
  {
    k = KlassDerived("me oh my");
    kret = derivedsmartptrtest(k);
    val = kret$getValue();
    unittest("me oh my derivedsmartptrtest-Derived", val);
    testSuite_verifyCount(2, k);
    testSuite_verifyCount(2, kret);
  }

  # pass by shared_ptr pointer (mixed)
  {
    k = KlassDerived("me oh my");
    kret = derivedsmartptrpointertest(k);
    val = kret$getValue();
    unittest("me oh my derivedsmartptrpointertest-Derived", val);
    testSuite_verifyCount(2, k);
    testSuite_verifyCount(2, kret);
  }

  # pass by shared_ptr ref (mixed)
  {
    k = KlassDerived("me oh my");
    kret = derivedsmartptrreftest(k);
    val = kret$getValue();
    unittest("me oh my derivedsmartptrreftest-Derived", val);
    testSuite_verifyCount(2, k);
    testSuite_verifyCount(2, kret);
  }

  # pass by shared_ptr pointer reference (mixed)
  {
    k = KlassDerived("me oh my");
    kret = smartpointerpointerreftest(k);
    val = kret$getValue();
    unittest("me oh my smartpointerpointerreftest-Derived", val);
    #testSuite_verifyCount(2, k); # includes two extra references for upcasts in the proxy classes
    #testSuite_verifyCount(2, kret);
  }

  # pass by value (mixed)
  {
    k = KlassDerived("me oh my")
    kret = valuetest(k)
    val = kret$getValue()
    unittest("me oh my valuetest", val)  # note slicing
    testSuite_verifyCount(2, k)
    testSuite_verifyCount(1, kret)

    # --> these are the python expected counting
    # testSuite_verifyCount(1, k)
    # testSuite_verifyCount(1, kret)
  }

  # pass by pointer (mixed)
  {
    k = KlassDerived("me oh my");
    kret = derivedpointertest(k);
    val = kret$getValue();
    unittest("me oh my derivedpointertest-Derived", val);
    testSuite_verifyCount(1, k);
    testSuite_verifyCount(1, kret);
  }

  # pass by ref (mixed)
  {
    k = KlassDerived("me oh my");
    kret = reftest(k);
    val = kret$getValue();
    unittest("me oh my reftest-Derived", val);
    testSuite_verifyCount(2, k);
    testSuite_verifyCount(1, kret);

    # --> these are the python expected counting
    #testSuite_verifyCount(1, k);
    #testSuite_verifyCount(1, kret);
  }

  #
  # ################# Overloading tests ##################
  #

  # Base class
  {
    k = Klass("me oh my");

    unittest(overload_rawbyval(k), "rawbyval")
    unittest(overload_rawbyref(k), "rawbyref")
    unittest(overload_rawbyptr(k), "rawbyptr")
    unittest(overload_rawbyptrref(k), "rawbyptrref")

    unittest(overload_smartbyval(k), "smartbyval")
    unittest(overload_smartbyref(k), "smartbyref")
    unittest(overload_smartbyptr(k), "smartbyptr")
    unittest(overload_smartbyptrref(k), "smartbyptrref")
  }

  # Derived class
  {
    k = KlassDerived("me oh my")

    unittest(overload_rawbyval(k), "rawbyval")
    unittest(overload_rawbyref(k), "rawbyref")
    unittest(overload_rawbyptr(k), "rawbyptr")
    unittest(overload_rawbyptrref(k), "rawbyptrref")

    unittest(overload_smartbyval(k), "smartbyval")
    unittest(overload_smartbyref(k), "smartbyref")
    unittest(overload_smartbyptr(k), "smartbyptr")
    unittest(overload_smartbyptrref(k), "smartbyptrref")
  }

  # 3rd derived class
  {
    k = Klass3rdDerived("me oh my")

    unittest(overload_rawbyval(k), "rawbyval")
    unittest(overload_rawbyref(k), "rawbyref")
    unittest(overload_rawbyptr(k), "rawbyptr")
    unittest(overload_rawbyptrref(k), "rawbyptrref")

    unittest(overload_smartbyval(k), "smartbyval")
    unittest(overload_smartbyref(k), "smartbyref")
    unittest(overload_smartbyptr(k), "smartbyptr")
    unittest(overload_smartbyptrref(k), "smartbyptrref")
  }

  #
  # ################ Member variables ####################
  #

  # smart pointer by value
  {
    m = MemberVariables();
    k = Klass("smart member value");
    m$SmartMemberValue = k;

    val = k$getValue();
    unittest("smart member value", val);
    testSuite_verifyCount(2, k);

    kmember = m$SmartMemberPointer;
    val = kmember$getValue();
    unittest("smart member value", val);
    testSuite_verifyCount(3, kmember);
    testSuite_verifyCount(3, k);

    delete_MemberVariables(m)
    testSuite_verifyCount(2, kmember);
    testSuite_verifyCount(2, k);
  }

  # smart pointer by pointer
  {
    m = MemberVariables();
    k = Klass("smart member pointer");
    m$SmartMemberPointer = k;
    val = k$getValue();
    unittest("smart member pointer", val);
    testSuite_verifyCount(1, k);

    kmember = m$SmartMemberPointer;
    val = kmember$getValue();
    unittest("smart member pointer", val);
    testSuite_verifyCount(2, kmember);
    testSuite_verifyCount(2, k);

    delete_MemberVariables(m);
    testSuite_verifyCount(2, kmember);
    testSuite_verifyCount(2, k);
  }

  # smart pointer by reference
  {
    m = MemberVariables();
    k = Klass("smart member reference");
    m$SmartMemberReference = k;
    val = k$getValue();
    unittest("smart member reference", val);
    testSuite_verifyCount(2, k);

    kmember = m$SmartMemberPointer;
    val = kmember$getValue();
    unittest("smart member reference", val);
    testSuite_verifyCount(3, kmember);
    testSuite_verifyCount(3, k);

    # The C++ reference refers to SmartMemberValue...
    kmemberVal = m$SmartMemberReference;
    val = kmember$getValue();
    unittest("smart member reference", val);
    testSuite_verifyCount(4, kmemberVal);
    testSuite_verifyCount(4, kmember);
    testSuite_verifyCount(4, k);

    delete_MemberVariables(m);
    testSuite_verifyCount(3, kmemberVal);
    testSuite_verifyCount(3, kmember);
    testSuite_verifyCount(3, k);
  }

  # plain by value
  {
    m = MemberVariables();
    k = Klass("plain member value");
    m$MemberValue = k;
    val = k$getValue();
    unittest("plain member value", val);
    testSuite_verifyCount(1, k);

    kmember = m$MemberValue;
    val = kmember$getValue();
    unittest("plain member value", val);
    testSuite_verifyCount(1, kmember);
    testSuite_verifyCount(1, k);

    delete_MemberVariables(m); # m.delete();
    testSuite_verifyCount(1, kmember);
    testSuite_verifyCount(1, k);
  }

  # plain by pointer
  {
    m = MemberVariables();
    k = Klass("plain member pointer");
    m$MemberPointer = k;
    val = k$getValue();
    unittest("plain member pointer", val);
    testSuite_verifyCount(1, k);

    kmember = m$MemberPointer;
    val = kmember$getValue();
    unittest("plain member pointer", val);
    testSuite_verifyCount(1, kmember);
    testSuite_verifyCount(1, k);

    delete_MemberVariables(m); # m.delete();
    testSuite_verifyCount(1, kmember);
    testSuite_verifyCount(1, k);
  }

  # plain by reference
  {
    m = MemberVariables();
    k = Klass("plain member reference");
    m$MemberReference = k;
    val = k$getValue();
    unittest("plain member reference", val);
    testSuite_verifyCount(1, k);

    kmember = m$MemberReference;
    val = kmember$getValue();
    unittest("plain member reference", val);
    testSuite_verifyCount(1, kmember);
    testSuite_verifyCount(1, k);

    delete_MemberVariables(m); # m.delete();
    testSuite_verifyCount(1, kmember);
    testSuite_verifyCount(1, k);
  }

  # null member variables
  {
    m = MemberVariables();

    # shared_ptr by value
    k = m$SmartMemberValue;
    if (!is.null(k))
      stop("expected null");

    m$SmartMemberValue = NULL;
    k = m$SmartMemberValue;
    if (!is.null(k))
      stop("expected null");
    #testSuite_verifyCount(0, k); # this does not work for nulls

    # plain by value
    bNotCatched = F
    try({
      m$MemberValue = NULL
      bNotCatched = T
    }, silent = T)
    if (bNotCatched) {
      stop("Failed to catch null pointer")
    }
  }


  #
  # ################ Global variables ####################
  #

  # smart pointer
  {
    kglobal = GlobalSmartValue_get();
    if (!is.null(kglobal))
      stop("expected null");

    k = Klass("smart global value");
    GlobalSmartValue_set(k);
    testSuite_verifyCount(2, k);

    kglobal = GlobalSmartValue_get();
    val = kglobal$getValue();
    unittest("smart global value", val);
    testSuite_verifyCount(3, kglobal);
    testSuite_verifyCount(3, k);
    unittest("smart global value", GlobalSmartValue_get()$getValue());

    GlobalSmartValue_set(NULL);
  }

  # plain value
  {
    k = Klass("global value");
    GlobalValue_set(k);
    testSuite_verifyCount(1, k);

    kglobal = GlobalValue_get();
    val = kglobal$getValue();
    unittest("global value", val);
    testSuite_verifyCount(1, kglobal);
    testSuite_verifyCount(1, k);
    unittest("global value", GlobalValue_get()$getValue());

    bNotCatched = F
    try({
      GlobalValue_set(NULL)
      bNotCatched = T
    }, silent = T)
    if (bNotCatched) {
      stop("Failed to catch null pointer")
    }
  }

  # plain pointer
  {
    kglobal = GlobalPointer_get();
    if (!is.null(kglobal))
      stop("expected null");

    k = Klass("global pointer");
    GlobalPointer_set(k);
    testSuite_verifyCount(1, k);

    kglobal = GlobalPointer_get();
    val = kglobal$getValue();
    unittest("global pointer", val);
    testSuite_verifyCount(1, kglobal);
    testSuite_verifyCount(1, k);
    GlobalPointer_set(NULL);
  }

  # plain reference
  {
    k = Klass("global reference");
    GlobalReference_set(k);
    testSuite_verifyCount(1, k);

    kglobal = GlobalReference_get();
    val = kglobal$getValue();
    unittest("global reference", val);
    testSuite_verifyCount(1, kglobal);
    testSuite_verifyCount(1, k);

    bNotCatched = F
    try({
      GlobalReference_set(NULL)
      bNotCatched = T
    }, silent = T)
    if (bNotCatched) {
      stop("Failed to catch null pointer")
    }
  }


  #
  # ###################### Templates ######################
  #
  {
    pid = PairIntDouble(10, 20.2);
    if (BaseIntDouble_baseVal1_get(pid) != 20 || BaseIntDouble_baseVal2_get(pid) != 40.4)
      stop("Base values wrong");
    if (PairIntDouble_val1_get(pid) != 10 || PairIntDouble_val2_get(pid) != 20.2)
      stop("Derived Values wrong");
  }

}


# actually do the tests
for (i in 1:10) {
  print(paste("Start Loop: ", i))
  testSuite()
  print(paste("End Loop: ", i))
}


# wait for the GC to collect unused objects

#for (i in 1:10) {
#  invisible(gc(verbose = F, full = T))
#
#  if (Klass_getTotal_count() == 1) {
#    break
#  }
#
#  print(paste("Still waiting for GC to collect ", Klass_getTotal_count()-1, " objects, ", i))
#  Sys.sleep(1)
#}

# Expect
unittest(shared_ptr_wrapper_count(), NOT_COUNTING())

# Expect 1 instance - the one global variable (GlobalValue)
# -> documented bug - gc does not work on some objects - https://www.swig.org/Doc4.0/SWIGDocumentation.html#R_nn2
if (FALSE) {
  unittest(Klass_getTotal_count(), 1)
}


q(save="no")
