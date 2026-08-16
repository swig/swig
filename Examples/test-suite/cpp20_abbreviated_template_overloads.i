%module cpp20_abbreviated_template_overloads

// Overload identity of C++20 abbreviated function templates.
//
//   - Two %template instantiations of one abbreviated function template given the same target
//     language name are overloads of each other, told apart by the types they instantiate to,
//     exactly as two instantiations of an explicitly written template are.

// A target language with one numeric type keeps one of the two scaled overloads and drops the other.
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED, SWIGWARN_LANG_OVERLOAD_SHADOW) scaled;

%inline %{
// One abbreviated function template instantiated twice under one name.  The value returned
// says which instantiation ran, so a dispatcher that reaches the wrong one shows up.
int scaled(auto x) { return int(x * 10); }
%}

%template(scaled) scaled<int>;
%template(scaled) scaled<double>;
