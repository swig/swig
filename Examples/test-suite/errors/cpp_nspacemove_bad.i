%module xxx

// Bad names for %nspacemove
%nspacemove(2) AA::BB::Bad1;
%nspacemove(1abc) AA::BB::Bad2;
%nspacemove(abc.def) AA::BB::Bad3;
%nspacemove(0gh::ij) AA::BB::Bad4;
%nspacemove(kl::1mn) AA::BB::Bad5;
%nspacemove(kl::mn<int>) AA::BB::Bad6;

// Good names for %nspacemove
%nspacemove(_aaa::_bbb) AA::BB::Good1;
%nspacemove(_ccc::_ddd::_eee) AA::BB::Good2;
%nspacemove(_1ccc::_2ddd::_3eee) AA::BB::Good3;

namespace AA {
  namespace BB {
    struct Bad1 {};
    struct Bad2 {};
    struct Bad3 {};
    struct Bad4 {};
    struct Bad5 {};
    struct Bad6 {};

    struct Good1 {};
    struct Good2 {};
    struct Good3 {};
  }
}
