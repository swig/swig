%module cpp11_rvalue_reference3

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK);

%inline %{
#include <utility>
struct Thing {};

Thing && global_rvalue_ref = Thing();
Thing *&& global_rvalue_ref_ptr1 = 0;
Thing const*&& global_rvalue_ref_ptr2 = 0;
Thing *const&& global_rvalue_ref_ptr3 = 0;
Thing const*const &&global_rvalue_ref_ptr4 = 0;

Thing && returnit1() { return std::move(global_rvalue_ref); }
Thing *&& returnit2() { return std::move(global_rvalue_ref_ptr1); }
Thing const*&& returnit3() { return std::move(global_rvalue_ref_ptr2); }
Thing *const&& returnit4() { return std::move(global_rvalue_ref_ptr3); }
Thing const*const&& returnit5() { return std::move(global_rvalue_ref_ptr4); }

void takeit1(Thing && t) {}
void takeit2(Thing *&& t) {}
void takeit3(Thing const*&& t) {}
void takeit4(Thing *const&& t) {}
void takeit5(Thing const*const&& t) {}

struct Contain {
  Thing && m_ref;
  Thing *&& m_ref_ptr1;
  Thing const*&& m_ref_ptr2;
  Thing *const&& m_ref_ptr3;
  Thing const*const &&m_ref_ptr4;

  Contain(Thing&&r, Thing*&& r1, Thing const*&& r2, Thing *const&& r3, Thing const*const && r4) :
    m_ref(std::move(r)),
    m_ref_ptr1(std::move(r1)),
    m_ref_ptr2(std::move(r2)),
    m_ref_ptr3(std::move(r3)),
    m_ref_ptr4(std::move(r4))
    {}
};
%}


%inline %{
int && int_global_rvalue_ref = 5;
int *&& int_global_rvalue_ref_ptr1 = 0;
int const*&& int_global_rvalue_ref_ptr2 = 0;
int *const&& int_global_rvalue_ref_ptr3 = 0;
int const*const &&int_global_rvalue_ref_ptr4 = 0;

int && int_returnit1() { return std::move(int_global_rvalue_ref); }
int *&& int_returnit2() { return std::move(int_global_rvalue_ref_ptr1); }
int const*&& int_returnit3() { return std::move(int_global_rvalue_ref_ptr2); }
int *const&& int_returnit4() { return std::move(int_global_rvalue_ref_ptr3); }
int const*const&& int_returnit5() { return std::move(int_global_rvalue_ref_ptr4); }

void int_takeit1(int && t) {}
void int_takeit2(int *&& t) {}
void int_takeit3(int const*&& t) {}
void int_takeit4(int *const&& t) {}
void int_takeit5(int const*const&& t) {}

struct IContain {
  int && m_ref;
  int *&& m_ref_ptr1;
  int const*&& m_ref_ptr2;
  int *const&& m_ref_ptr3;
  int const*const &&m_ref_ptr4;

  IContain(int&& r, int*&& r1, int const*&& r2, int *const&& r3, int const*const && r4) :
    m_ref(std::move(r)),
    m_ref_ptr1(std::move(r1)),
    m_ref_ptr2(std::move(r2)),
    m_ref_ptr3(std::move(r3)),
    m_ref_ptr4(std::move(r4))
    {}
};
%}
