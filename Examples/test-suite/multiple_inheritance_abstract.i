%module  multiple_inheritance_abstract

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include "feature_interface.i"
DECLARE_INTERFACE_RENAME(ABase1, ABase1, SWIGTYPE_ABase1)
DECLARE_INTERFACE_RENAME(CBase1, CBase1, SWIGTYPE_CBase1)
DECLARE_INTERFACE_RENAME(CBase2, CBase2, SWIGTYPE_CBase2)
#endif

%inline %{
  struct CBase1 {
    virtual void cbase1x() {
      return;
    } 
    virtual int cbase1y() {
      return 1;
    }
    int cbase1z() {
      return 10;
    }
    virtual ~CBase1() {
    }
  };

  struct CBase2 {
    virtual int cbase2() {
      return 2;
    }
    virtual ~CBase2() {
    }
  };

  struct ABase1 {
    virtual int abase1() = 0;
    virtual ~ABase1() {
    }
  };

  struct Derived1 : CBase2, CBase1 {
    virtual int cbase1y() {
      return 3;
    }
    virtual void cbase1x() {
      return;
    }
    virtual int cbase2() {
      return 4;
    }
    virtual CBase2 *clone() {
      return new Derived1(*this);
    }
  };

  struct Derived2 : CBase1, ABase1 {
    virtual int abase1() {
      return 5;
    }
    virtual void cbase1x() {
      return;
    }
    virtual int cbase1y() {
      return 6;
    }
    virtual CBase1 *clone() {
      return new Derived2(*this);
    }
  };

  struct Derived3 : ABase1, CBase1, CBase2 {
    virtual int cbase1y() {
      return 7;
    }
    virtual int cbase2() {
      return 8;
    }
    virtual int abase1() {
      return 9;
    }
    virtual void cbase1x() {
    }
    virtual ABase1 *clone() {
      return new Derived3(*this);
    }
  };

  ABase1 *InputDerived3(Derived3 d) {
    return d.clone();
  }
  int InputValueCBase1(CBase1 cb1) {
    return cb1.cbase1y();
  }
  int InputValueCBase2(CBase2 cb2) {
    return cb2.cbase2();
  }

  int InputPtrABase1(ABase1 *pab1) {
    return pab1->abase1();
  }
  int InputPtrCBase1(CBase1 *pcb1) {
    return pcb1->cbase1y();
  }
  int InputPtrCBase2(CBase2 *pcb2) {
    return pcb2->cbase2();
  }

  int InputRefABase1(ABase1 &rab1) {
    return rab1.abase1();
  }
  int InputRefCBase1(CBase1 &rcb1) {
    return rcb1.cbase1y();
  }
  int InputRefCBase2(CBase2 &rcb2) {
    return rcb2.cbase2();
  }
%}
