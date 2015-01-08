%module python_default_args

%pythondefaultargs;

// Turn off the feature for the tricky cases that can't be handled
%nopythondefaultargs seek;
%nopythondefaultargs Space::Klass::inc;
%nopythondefaultargs DerivedEnumClass::accelerate;

%include "default_args.i"
