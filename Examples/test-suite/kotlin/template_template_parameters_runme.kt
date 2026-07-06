@file:JvmName("template_template_parameters_runme")

import template_template_parameters.*

fun main() {
    try {
        System.loadLibrary("template_template_parameters")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Test part 1
    val listBool = ListFastBool()
    listBool.item = true
    val x_boolean = listBool.allotype
    if (listBool.item != true)
        throw RuntimeException("Failed")

    val listDouble = ListDefaultDouble()
    listDouble.item = 10.2
    val x_double = listDouble.allotype
    if (listDouble.item != 10.2)
        throw RuntimeException("Failed")

    // Test part 2
    val floatTestStruct = FloatTestStruct()
    val floatContainer2 = floatTestStruct.x!!
    floatContainer2.x = 8.1f
    val intTestStruct = IntTestStruct()
    val intContainer1 = intTestStruct.x!!
    intContainer1.x = 91
    if (intContainer1.x != 91)
        throw RuntimeException("Failed")
    if (intTestStruct.x!!.x != 91)
        throw RuntimeException("Failed")
    val intTestStructReturned = template_template_parameters.TestStructContainer1Method(intTestStruct)
    if (intTestStructReturned.x!!.x != 101)
        throw RuntimeException("Failed")

    // Test part 3
    val mfi99 = MyFootInt99()
    mfi99.OperatorPlusEquals(mfi99)
}
