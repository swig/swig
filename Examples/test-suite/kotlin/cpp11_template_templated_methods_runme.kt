@file:JvmName("cpp11_template_templated_methods_runme")

import cpp11_template_templated_methods.*

fun main() {
    try {
        System.loadLibrary("cpp11_template_templated_methods")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // assign test
    run {
        val ov = OctetVector()
        val o = octet(111)
        ov.add(o)
        val sc = SimpleContainer(ov)
        val orlv = OctetResourceLimitedVector()
        orlv.assign(sc.begin(), sc.end())
        val collection = orlv.getCollection()
        if (collection.size != 1)
            throw RuntimeException("wrong size")
        val oo = collection.get(0)
        if (oo.num != 111)
            throw RuntimeException("wrong val")
    }
    // assign_and_append test
    run {
        val ov = OctetVector()
        val o = octet(222)
        ov.add(o)
        val sc = SimpleContainer(ov)
        val orlv = OctetResourceLimitedVector()
        val final_octet = octet(333)
        orlv.assign_and_append(sc.begin(), sc.end(), final_octet)
        val collection = orlv.getCollection()
        if (collection.size != 2)
            throw RuntimeException("wrong size")
        var oo = collection.get(0)
        if (oo.num != 222)
            throw RuntimeException("wrong val")
        oo = collection.get(1)
        if (oo.num != 333)
            throw RuntimeException("wrong finalval")
    }
    // container_from_iterators test
    run {
        val ov = OctetVector()
        val o = octet(987)
        ov.add(o)
        val sc = SimpleContainer(ov)
        val collection = OctetResourceLimitedVector.container_from_iterators(sc.begin(), sc.end())
        if (collection.size != 1)
            throw RuntimeException("wrong collection size")
        val oo = collection.get(0)
        if (oo.num != 987)
            throw RuntimeException("wrong collection val")
    }
    // emplace_back test
    run {
        val ov = OctetVector()
        val o = octet(222)
        ov.add(o)
        val sc = SimpleContainer(ov)
        val orlv = OctetResourceLimitedVector()
        val final_octet = octet(444)
        orlv.emplace_back(final_octet)
        orlv.emplace_back()
        orlv.emplace_back(555)
        val collection = orlv.getCollection()
        if (collection.size != 3)
            throw RuntimeException("wrong size")
        var oo = collection.get(0)
        if (oo.num != 444)
            throw RuntimeException("wrong value 0")
        oo = collection.get(1)
        if (oo.num != 0)
            throw RuntimeException("wrong value 1")
        oo = collection.get(2)
        if (oo.num != 555)
            throw RuntimeException("wrong value 2")
    }
    // Variadic templated constructor in template
    run {
        val orlv = OctetResourceLimitedVector(999)
        val o = octet(888)
        val orlv2 = OctetResourceLimitedVector(o)
    }
    // Variadic static templated method in template
    run {
        var collection = OctetResourceLimitedVector.make_collection()
        if (collection.size != 0)
            throw RuntimeException("wrong make value 1111")

        collection = OctetResourceLimitedVector.make_collection(1111)
        var oo = collection.get(0)
        if (oo.num != 1111)
            throw RuntimeException("wrong make value 1111")

        val o = octet(2222)
        collection = OctetResourceLimitedVector.make_collection(o)
        oo = collection.get(0)
        if (oo.num != 2222)
            throw RuntimeException("wrong make value 2222")
    }
}
