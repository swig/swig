%module xxx

%feature("smartptr", noblock=1) AA { std::shared_ptr< AA > }
%feature("smartptr", noblock=1) DD { std::shared_ptr< }


struct AA {};
struct BB : AA {};
struct CC : AA {};
struct DD : AA {};

%feature("smartptr", noblock=1) YY { std::shared_ptr< YY > }
struct XX {};
struct YY : XX {};
