%module example

%{
extern "C" void Init_base();
extern "C" void Init_bar();
extern "C" void Init_foo();
extern "C" void Init_spam();
%}

%init {
    Init_base();
    Init_bar();
    Init_foo();
    Init_spam();
}
