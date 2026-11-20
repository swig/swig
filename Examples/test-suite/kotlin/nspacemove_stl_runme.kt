@file:JvmName("nspacemove_stl_runme")

fun main() {
    try {
        System.loadLibrary("nspacemove_stl")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val vi = nspacemove_stlPackage.CPlusPlus.Standard.Ints.VectorInt()
    val vs = nspacemove_stlPackage.CPlusPlus.Standard.Strings.VectorString()
    val mii = nspacemove_stlPackage.CPlusPlus.Maps.MapIntInt()
    val mis = nspacemove_stlPackage.CPlusPlus.Maps.MapIntString()

    nspacemove_stlPackage.nspacemove_stl.test_vector_int(vi)
    nspacemove_stlPackage.nspacemove_stl.test_vector_string(vs)
    nspacemove_stlPackage.nspacemove_stl.test_map_int(mii)
    nspacemove_stlPackage.nspacemove_stl.test_map_string(mis)
}
