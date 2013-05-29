%module  multiple_inheritance_abstract

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include "feature_interface.i"
DECLARE_INTERFACE_RENAME(ABase1, ABase1, SWIGTYPE_ABase1)
DECLARE_INTERFACE_RENAME(CBase1, CBase1, SWIGTYPE_CBase1)
DECLARE_INTERFACE_RENAME(CBase2, CBase2, SWIGTYPE_CBase2)
#endif

%inline %{
struct CBase1 {
virtual void foo9(){
return ;
} 
virtual int foo1(){
 return 1;
}
int foo3(){
return 10;
}
virtual ~CBase1(){
}
};
struct CBase2{
virtual int foo2(){
return 2;
}
virtual ~CBase2(){
}
};
struct ABase1{
virtual int  bar1()=0;
virtual ~ABase1(){
}
};

struct Derived1 : CBase2,CBase1{
  virtual int foo1(){
return 3;
}
virtual void foo9(){
return;
}
virtual int foo2(){
return 4;
}
virtual CBase2* clone(){
return new Derived1(*this);
}
};
struct Derived2:CBase1,ABase1{
virtual int bar1(){
return 5;
}
virtual int foo1(){
return 6;
}
virtual void foo9(){
return;
}
virtual CBase1* clone(){
return new Derived2(*this);
}
};
struct Derived3:ABase1,CBase1,CBase2{
virtual int foo1(){
return 7;
}
virtual int foo2(){
return 8;
}
virtual int bar1(){
return 9;
}
virtual void foo9(){
}
virtual ABase1* clone(){
return new Derived3(*this);
}
};
ABase1* foo4(Derived3 d){
return d.clone();
}
int foo5(CBase1 cb1,CBase2 cb2){
return cb1.foo1()+cb2.foo2();
}
int foo6(ABase1* pab1){
return  pab1->bar1();
}
int foo7(CBase1* pcb1){
return pcb1->foo1();
}
int foo8(CBase2* pcb2){
return pcb2->foo2();
}

%}
