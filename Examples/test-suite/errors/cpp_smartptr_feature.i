%module xxx

%feature("smartptr", noblock=1) AA { std::shared_ptr< AA > }
%feature("smartptr", noblock=1) DD { std::shared_ptr< }


struct AA {};
struct BB : AA {};
struct CC : AA {};
struct DD : AA {};

%ignore EE;
struct EE : AA {}; // should not warn for AA base as EE is ignored
struct EEE : EE {}; // should warn for AA base, but not for EE base

%feature("smartptr", noblock=1) YY { std::shared_ptr< YY > }
struct XX {};
struct YY : XX {};

%feature("smartptr", noblock=1) ZZ { std::shared_ptr< YY > }
%ignore ZZ;
struct ZZ : XX {};
// Next two are NOT smartptr and so should not issue warning
struct ZZZ : ZZ {};
struct ZZZZ : ZZZ {};
