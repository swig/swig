package example

// FooBarGo is a superset of FooBarAbs and hence FooBarGo can be used as a drop
// in replacement for FooBarAbs but the reverse causes a compile time error.
type FooBarGo interface {
	FooBarAbs
	deleteFooBarAbs()
	IsFooBarGo()
}

// Via embedding fooBarGo "inherits" all methods of FooBarAbs.
type fooBarGo struct {
	FooBarAbs
}

func (fbgs *fooBarGo) deleteFooBarAbs() {
	DeleteDirectorFooBarAbs(fbgs.FooBarAbs)
}

// The IsFooBarGo method ensures that FooBarGo is a superset of FooBarAbs.
// This is also how the class hierarchy gets represented by the SWIG generated
// wrapper code.  For an instance FooBarCpp has the IsFooBarAbs and IsFooBarCpp
// methods.
func (fbgs *fooBarGo) IsFooBarGo() {}

// Go type that defines the DirectorInterface. It contains the Foo and Bar
// methods that overwrite the respective virtual C++ methods on FooBarAbs.
type overwrittenMethodsOnFooBarAbs struct {
	// Backlink to FooBarAbs so that the rest of the class can be used by the
	// overridden methods.
	fb FooBarAbs

	// If additional constructor arguments have been given they are typically
	// stored here so that the overriden methods can use them.
}

func (om *overwrittenMethodsOnFooBarAbs) Foo() string {
	// DirectorFooBarAbsFoo calls the base method FooBarAbs::Foo.
	return "Go " + DirectorFooBarAbsFoo(om.fb)
}

func (om *overwrittenMethodsOnFooBarAbs) Bar() string {
	return "Go Bar"
}

func NewFooBarGo() FooBarGo {
	// Instantiate FooBarAbs with selected methods overridden.  The methods that
	// will be overwritten are defined on overwrittenMethodsOnFooBarAbs and have
	// a compatible signature to the respective virtual C++ methods.
	// Furthermore additional constructor arguments will be typically stored in
	// the overwrittenMethodsOnFooBarAbs struct.
	om := &overwrittenMethodsOnFooBarAbs{}
	fb := NewDirectorFooBarAbs(om)
	om.fb = fb // Backlink causes cycle as fb.v = om!

	fbgs := &fooBarGo{FooBarAbs: fb}
	// The memory of the FooBarAbs director object instance can be automatically
	// freed once the FooBarGo instance is garbage collected by uncommenting the
	// following line.  Please make sure to understand the runtime.SetFinalizer
	// specific gotchas before doing this.  Furthemore DeleteFooBarGo should be
	// deleted if a finalizer is in use or the fooBarGo struct needs additional
	// data to prevent double deletion.
	// runtime.SetFinalizer(fbgs, FooBarGo.deleteFooBarAbs)
	return fbgs
}

// Recommended to be removed if runtime.SetFinalizer is in use.
func DeleteFooBarGo(fbg FooBarGo) {
	fbg.deleteFooBarAbs()
}
