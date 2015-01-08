%module python_default_args

%pythondefaultargs;

// Turn off the feature for the tricky cases that can't be handled
%nopythondefaultargs trickyvalue3; // 'mode=0644' is okay in Python 2, but no Python 3
%nopythondefaultargs seek;
%nopythondefaultargs Space::Klass::inc;
%nopythondefaultargs DerivedEnumClass::accelerate;

%include "default_args.i"
