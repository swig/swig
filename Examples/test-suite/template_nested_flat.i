%module template_nested_flat

// Test nested templates ("flatnested" version of template_nested.i)

%feature ("flatnested");

%include "template_nested.i"
