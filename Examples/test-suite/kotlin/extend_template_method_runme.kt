@file:JvmName("extend_template_method_runme")

import extend_template_method.*

fun main() {
    try {
        System.loadLibrary("extend_template_method")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val em = ExtendMe()

        run {
            val ret_double = em.do_stuff_double(1, 1.1)
            if (ret_double != 1.1)
                throw RuntimeException("double failed " + ret_double)
            val ret_string = em.do_stuff_string(1, "hello there")
            if (ret_string != "hello there")
                throw RuntimeException("string failed " + ret_string)
        }
        run {
            val ret_double = em.do_overloaded_stuff(1.1)
            if (ret_double != 1.1)
                throw RuntimeException("double failed " + ret_double)
            val ret_string = em.do_overloaded_stuff("hello there")
            if (ret_string != "hello there")
                throw RuntimeException("string failed " + ret_string)
        }
        if (ExtendMe.static_method(123) != 123)
            throw RuntimeException("static_method failed")
        val em2 = ExtendMe(123)
    }
    run {
        val em = TemplateExtend()

        run {
            val ret_double = em.do_template_stuff_double(1, 1.1)
            if (ret_double != 1.1)
                throw RuntimeException("double failed " + ret_double)
            val ret_string = em.do_template_stuff_string(1, "hello there")
            if (ret_string != "hello there")
                throw RuntimeException("string failed " + ret_string)
        }
        run {
            val ret_double = em.do_template_overloaded_stuff(1.1)
            if (ret_double != 1.1)
                throw RuntimeException("double failed " + ret_double)
            val ret_string = em.do_template_overloaded_stuff("hello there")
            if (ret_string != "hello there")
                throw RuntimeException("string failed " + ret_string)
        }
        if (TemplateExtend.static_template_method(123) != 123)
            throw RuntimeException("static_template_method failed")
        val em2 = TemplateExtend(123)
    }
}
