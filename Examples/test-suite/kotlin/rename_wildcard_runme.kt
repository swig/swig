@file:JvmName("rename_wildcard_runme")

import rename_wildcard.*

fun main() {
    try {
        System.loadLibrary("rename_wildcard")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Wildcard check
    run {
        GlobalWildStruct().mm1()
        GlobalWildTemplateStructInt().mm1()
        SpaceWildStruct().mm1()
        SpaceWildTemplateStructInt().mm1()
    }
    // No declaration
    run {
        GlobalWildStruct().mm2a()
        GlobalWildTemplateStructInt().mm2b()
        SpaceWildStruct().mm2c()
        SpaceWildTemplateStructInt().mm2d()

        GlobalWildTemplateStructInt().tt2b()
        SpaceWildTemplateStructInt().tt2d()
    }
    // With declaration
    run {
        GlobalWildStruct().mm3a()
        GlobalWildTemplateStructInt().mm3b()
        SpaceWildStruct().mm3c()
        SpaceWildTemplateStructInt().mm3d()

        GlobalWildTemplateStructInt().tt3b()
        SpaceWildTemplateStructInt().tt3d()
    }
    // Global override too
    run {
        GlobalWildStruct().mm4a()
        GlobalWildTemplateStructInt().mm4b()
        SpaceWildStruct().mm4c()
        SpaceWildTemplateStructInt().mm4d()

        GlobalWildTemplateStructInt().tt4b()
        SpaceWildTemplateStructInt().tt4d()
    }
    // %extend renames
    run {
        GlobalWildStruct().mm5a()
        GlobalWildTemplateStructInt().mm5b()
        SpaceWildStruct().mm5c()
        SpaceWildTemplateStructInt().mm5d()

        GlobalWildTemplateStructInt().tt5b()
        SpaceWildTemplateStructInt().tt5d()
    }
    // operators
    run {
        GlobalWildStruct().opinta()
        GlobalWildTemplateStructInt().opintb()
        SpaceWildStruct().opintc()
        SpaceWildTemplateStructInt().opintd()

        GlobalWildTemplateStructInt().opdoubleb()
        SpaceWildTemplateStructInt().opdoubled()
    }
    // Wildcard renames expected for these
    run {
        NoChangeStruct().mm1()
        NoChangeStruct().mm2()
        NoChangeStruct().mm3()
        NoChangeStruct().mm4()
        NoChangeStruct().mm5()
        NoChangeStruct().opint()
        SpaceNoChangeStruct().mm1()
        SpaceNoChangeStruct().mm2()
        SpaceNoChangeStruct().mm3()
        SpaceNoChangeStruct().mm4()
        SpaceNoChangeStruct().mm5()
        SpaceNoChangeStruct().opint()
    }
}
