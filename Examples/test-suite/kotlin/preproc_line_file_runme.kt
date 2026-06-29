@file:JvmName("preproc_line_file_runme")

import preproc_line_file.*

fun testFile(file: String, suffix: String) {
    val FILENAME_WINDOWS2 = "Examples\\test-suite\\java\\..\\preproc_line_file.i"
    val FILENAME_UNIX2 = "Examples/test-suite/java/../preproc_line_file.i"

    val FILENAME_WINDOWS3 = "..\\.\\..\\preproc_line_file.i"
    val FILENAME_UNIX3 = ".././../preproc_line_file.i"

    if (!file.endsWith(FILENAME_UNIX2 + suffix) && !file.endsWith(FILENAME_WINDOWS2 + suffix) &&
        !file.endsWith(FILENAME_UNIX3 + suffix) && !file.endsWith(FILENAME_WINDOWS3 + suffix))
        throw RuntimeException("file \"" + file + "\" doesn't end with " + FILENAME_UNIX2 + suffix + " or " + FILENAME_UNIX3 + suffix)
}

fun main() {
    try {
        System.loadLibrary("preproc_line_file")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val myline = preproc_line_file.MYLINE
    val myline_adjusted = preproc_line_file.MYLINE_ADJUSTED
    if (myline != 4)
        throw RuntimeException("preproc failure")
    if (myline + 100 + 1 != myline_adjusted)
        throw RuntimeException("preproc failure")

    testFile(preproc_line_file.MYFILE!!, "")
    testFile(preproc_line_file.MYFILE_ADJUSTED!!, ".bak")

    if (preproc_line_file.MY_STRINGNUM_A != "my15")
        throw RuntimeException("preproc failed MY_STRINGNUM_A")

    if (preproc_line_file.MY_STRINGNUM_B != "my16")
        throw RuntimeException("preproc failed MY_STRINGNUM_B")

    if (preproc_line_file.thing27 != -1)
        throw RuntimeException("preproc failure")

    if (preproc_line_file.thing28 != -2)
        throw RuntimeException("preproc failure")

    if (preproc_line_file.MYLINE2 != 30)
        throw RuntimeException("preproc failure")

    // SillyStruct.LINE_NUMBER, SillyMacroClass.LINE_NUM, SillyMulMacroStruc.LINE_NUM
    // and Slash.LINE_NUM are %ignore'd for non-Java targets in the interface file.

    if (preproc_line_file.INLINE_LINE != 87)
        throw RuntimeException("preproc failure")

    testFile(preproc_line_file.INLINE_FILE!!, "")
}
