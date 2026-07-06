@file:JvmName("special_variables_runme")

import special_variables.*

fun verify(received: String, expected: String) {
    if (received != expected)
        throw RuntimeException("Incorrect, received: " + received)
}

fun main() {
    try {
        System.loadLibrary("special_variables")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    verify(special_variables.ExceptionVars(1.0, 2.0),
           "result = Space::exceptionvars(arg1,arg2);  Space::exceptionvars  ExceptionVars   Java_special_1variables_special_1variablesJNI_ExceptionVars  ")

    verify(special_variables.overloadedmethod(),
           "result = Space::overloadedmethod();  Space::overloadedmethod  overloadedmethod  __SWIG_1 Java_special_1variables_special_1variablesJNI_overloadedmethod_1_1SWIG_11  ")

    verify(special_variables.overloadedmethod(10.0),
          "result = Space::overloadedmethod(arg1);  Space::overloadedmethod  overloadedmethod  __SWIG_0 Java_special_1variables_special_1variablesJNI_overloadedmethod_1_1SWIG_10  ")

    var a = ABC(0, 0.0)
    verify(special_variables.declaration, "SpaceNamespace::ABC::ABC(int,double) SpaceNamespace::ABC::ABC(int,double)")
    a = ABC()
    verify(special_variables.declaration, "SpaceNamespace::ABC::ABC() SpaceNamespace::ABC::ABC()")
    a.instancemethod(1)
    verify(special_variables.declaration, "short * SpaceNamespace::ABC::instancemethod(int) SpaceNamespace::ABC::instancemethod(int)")
    a.instancemethod(1, false)
    verify(special_variables.declaration, "short * SpaceNamespace::ABC::instancemethod(int,bool) SpaceNamespace::ABC::instancemethod(int,bool)")
    a.constmethod(1)
    verify(special_variables.declaration, "short * SpaceNamespace::ABC::constmethod(int) const SpaceNamespace::ABC::constmethod(int) const")
    ABC.staticmethod(0, false)
    verify(special_variables.declaration, "short * SpaceNamespace::ABC::staticmethod(int,bool) SpaceNamespace::ABC::staticmethod(int,bool)")
    a.delete()
    verify(special_variables.declaration, "SpaceNamespace::ABC::~ABC() SpaceNamespace::ABC::~ABC()")
    val abc = TemplateABC()
    verify(special_variables.declaration, "SpaceNamespace::Template< SpaceNamespace::ABC >::Template() SpaceNamespace::Template< SpaceNamespace::ABC >::Template()")
    abc.tmethod(ABC())
    verify(special_variables.declaration, "std::string SpaceNamespace::Template< SpaceNamespace::ABC >::tmethod(SpaceNamespace::ABC) SpaceNamespace::Template< SpaceNamespace::ABC >::tmethod(SpaceNamespace::ABC)")
    abc.delete()
    verify(special_variables.declaration, "SpaceNamespace::Template< SpaceNamespace::ABC >::~Template() SpaceNamespace::Template< SpaceNamespace::ABC >::~Template()")
    special_variables.globtemplate(TemplateABC())
    verify(special_variables.declaration, "void SpaceNamespace::globtemplate(SpaceNamespace::Template< SpaceNamespace::ABC >) SpaceNamespace::globtemplate(SpaceNamespace::Template< SpaceNamespace::ABC >)")
}
