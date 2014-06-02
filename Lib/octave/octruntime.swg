//
// octruntime.swg - Octave runtime code
//

// Insert standard SWIG runtime code
%insert("runtime") "swigrun.swg";
%insert("runtime") "swigerrors.swg";
%insert("initbeforefunc") "swiginit.swg"

// Declarations of Octave runtime code
%insert("runtime") "octrundecl.swg";

// Octave runtime functions
%insert("runtime") "octrunfunc.swg"

// Octave runtime classes
%insert("runtime") "octrunclass.swg"

// Octave runtime initialisation code
%insert("initbeforefunc") "octruninit.swg"
