%module xxx

// Test nspace warnings (based on Examples/test-suite/nspacemove_nested.i)

%feature("flatnested"); // must have in order to see nspace warnings when using Python as nested classes are otherwise simply ignored in Python

%nspace Space::OuterClass1;
%nspacemove(Bad::Space1) Space::OuterClass1::InnerClass1;
%nspacemove(Bad::Space1) Space::OuterClass1::InnerEnum1;

%nspace Space::OuterClass2;
%nonspace Space::OuterClass2::InnerClass2;
%nonspace Space::OuterClass2::InnerEnum2;

%nspacemove(NewSpace3) Space::OuterClass3;
%nspacemove(Bad::Space3) Space::OuterClass3::InnerClass3;
%nspacemove(Bad::Space3) Space::OuterClass3::InnerEnum3;

%nspacemove(NewSpace4::NewSubSpace4) Space::OuterClass4;
%nonspace Space::OuterClass4::InnerClass4;
%nonspace Space::OuterClass4::InnerEnum4;

%nspacemove(NewSpace5) Space::OuterClass5::InnerClass5;
%nspacemove(NewSpace5) Space::OuterClass5::InnerEnum5;

%nonspace Space::OuterClass6;
%nspace Space::OuterClass6::InnerClass6;
%nspace Space::OuterClass6::InnerEnum6;

%nonspace Space::OuterClass7;
%nspacemove(NewSpace7) Space::OuterClass7::InnerClass7;
%nspacemove(NewSpace7) Space::OuterClass7::InnerEnum7;

%inline %{
namespace Space {
  struct OuterClass1 {
    struct InnerClass1 {
      struct BottomClass1 {};
    };
    enum InnerEnum1 { ie1a, ie1b };
    void take(InnerEnum1 e) {}
  };
  struct OuterClass2 {
    struct InnerClass2 {
      struct BottomClass2 {};
    };
    enum InnerEnum2 { ie2a, ie2b };
    void take(InnerEnum2 e) {}
  };
  struct OuterClass3 {
    struct InnerClass3 {
      struct BottomClass3 {};
    };
    enum InnerEnum3 { ie3a, ie3b };
    void take(InnerEnum3 e) {}
  };
  struct OuterClass4 {
    struct InnerClass4 {
      struct BottomClass4 {};
    };
    enum InnerEnum4 { ie4a, ie4b };
    void take(InnerEnum4 e) {}
  };
  struct OuterClass5 {
    struct InnerClass5 {
      struct BottomClass5 {};
    };
    enum InnerEnum5 { ie5a, ie5b };
    void take(InnerEnum5 e) {}
  };
  struct OuterClass6 {
    struct InnerClass6 {
      struct BottomClass6 {};
    };
    enum InnerEnum6 { ie6a, ie6b };
    void take(InnerEnum6 e) {}
  };
  struct OuterClass7 {
    struct InnerClass7 {
      struct BottomClass7 {};
    };
    enum InnerEnum7 { ie7a, ie7b };
    void take(InnerEnum7 e) {}
  };
}
%}


// These should not warn
%nspace Space::OuterClass10;
%nspace Space::OuterClass10::InnerClass10;
%nspace Space::OuterClass10::InnerEnum10;

%nspace Space::OuterClass20;
%clearnspace Space::OuterClass20::InnerClass20;
%clearnspace Space::OuterClass20::InnerEnum20;

%nspacemove(NewOkay30) Space::OuterClass30;
%nspace Space::OuterClass30::InnerClass30;
%nspace Space::OuterClass30::InnerEnum40;

%nspacemove(NewOkay40) Space::OuterClass40;
%clearnspace Space::OuterClass40::InnerClass40;
%clearnspace Space::OuterClass40::InnerEnum40;

%nspacemove(NewOkay50) Space::OuterClass50;

%nonspace Space::OuterClass60;
%nonspace Space::OuterClass60::InnerClass60;
%nonspace Space::OuterClass60::InnerEnum60;

%nonspace Space::OuterClass70;

%inline %{
namespace Space {
  struct OuterClass10 {
    struct InnerClass10 {
      struct BottomClass10 {};
    };
    enum InnerEnum10 { ie10a, ie10b };
    void take(InnerEnum10 e) {}
  };
  struct OuterClass20 {
    struct InnerClass20 {
      struct BottomClass20 {};
    };
    enum InnerEnum20 { ie20a, ie20b };
    void take(InnerEnum20 e) {}
  };
  struct OuterClass30 {
    struct InnerClass30 {
      struct BottomClass30 {};
    };
    enum InnerEnum30 { ie30a, ie30b };
    void take(InnerEnum30 e) {}
  };
  struct OuterClass40 {
    struct InnerClass40 {
      struct BottomClass40 {};
    };
    enum InnerEnum40 { ie40a, ie40b };
    void take(InnerEnum40 e) {}
  };
  struct OuterClass50 {
    struct InnerClass50 {
      struct BottomClass50 {};
    };
    enum InnerEnum50 { ie50a, ie50b };
    void take(InnerEnum50 e) {}
  };
  struct OuterClass60 {
    struct InnerClass60 {
      struct BottomClass60 {};
    };
    enum InnerEnum60 { ie60a, ie60b };
    void take(InnerEnum60 e) {}
  };
  struct OuterClass70 {
    struct InnerClass70 {
      struct BottomClass70 {};
    };
    enum InnerEnum70 { ie70a, ie70b };
    void take(InnerEnum70 e) {}
  };
}
%}
