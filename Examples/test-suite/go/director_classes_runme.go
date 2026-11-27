package main

import "fmt"
import . "swigtests/director_classes"

func check(expected, actual interface{}) {
	if expected != actual {
		panic(fmt.Sprintf("expected %v but got %v", expected, actual))
	}
}

type GoDerived struct { // Implement director_classes.Derived
}
func (self *GoDerived) Val(x DoubleHolder) DoubleHolder { return x }
func (self *GoDerived) Ref(x DoubleHolder) DoubleHolder { return x }
func (self *GoDerived) Ptr(x DoubleHolder) DoubleHolder { return x }
func (self *GoDerived) ConstPtr(x DoubleHolder) DoubleHolder { return x }
func (self *GoDerived) ConstPtrRef(x DoubleHolder) DoubleHolder { return x }
func (self *GoDerived) FullyOverloaded(a ...interface{}) string {
    fmt.Printf("== call GoDerived::FullyOverloaded\n")
	if _, ok := a[0].(bool); ok {
        return "GoDerived::FullyOverloaded(bool)"
    }
    return "GoDerived::FullyOverloaded(int)"
}
func (self *GoDerived) SemiOverloaded(a int) string {
    return "GoDerived::SemiOverloaded(int)"
}
func (self *GoDerived) DefaultParms(a ...interface{}) string {
    fmt.Printf("== call GoDerived::DefaultParms\n")
    return "GoDerived::DefaultParms(int)"
}

func makeCalls(caller Caller, base Base, name string, TODO bool) {
    caller.Set(base)
    dh := NewDoubleHolder(444.555)
    check(caller.ValCall(dh).GetVal(), dh.GetVal())
    check(caller.RefCall(dh).GetVal(), dh.GetVal())
    check(caller.PtrCall(dh).GetVal(), dh.GetVal())
    check(caller.ConstPtrCall(dh).GetVal(), dh.GetVal())
    check(caller.ConstPtrRefCall(dh).GetVal(), dh.GetVal())
    if (!TODO) {
        // Fail to call GoDerived::FullyOverloadedCall()
        check(caller.FullyOverloadedCall(1), name + "::FullyOverloaded(int)")
        check(caller.FullyOverloadedCall(false), name + "::FullyOverloaded(bool)")
    }
    check(caller.SemiOverloadedCall(-678), name + "::SemiOverloaded(int)")
    check(caller.SemiOverloadedCall(false), "Base::SemiOverloaded(bool)")
    if (!TODO) {
        // Fail to call GoDerived::DefaultParmsCall()
        check(caller.DefaultParmsCall(10, 2.2), name + "::DefaultParms(int, double)")
        check(caller.DefaultParmsCall(10), name + "::DefaultParms(int)")
    }
    DeleteDoubleHolder(dh)
    caller.Reset()
}

func main() {
    c := NewCaller()
    b := NewBase(100)
    makeCalls(c, b, "Base", false)
    DeleteBase(b)
    d := NewDerived(200)
    makeCalls(c, d.SwigGetBase(), "Derived", false)
    DeleteDerived(d)
    var goDerived GoDerived
    g := NewDirectorDerived(&goDerived, 300)
    makeCalls(c, g.SwigGetBase(), "GoDerived", true)
    DeleteDirectorDerived(g)
    DeleteCaller(c)
}
