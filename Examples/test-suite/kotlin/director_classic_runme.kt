@file:JvmName("director_classic_runme")

import director_classic.*

val debug = false

fun check(person: Person, expected: String) {
    var ret: String
    // Normal target language polymorphic call
    ret = person.id()
    if (debug)
        System.out.println(ret)
    if (ret != expected)
        throw RuntimeException("Failed. Received: " + ret + " Expected: " + expected)

    // Polymorphic call from C++
    val caller = Caller()
    caller.setCallback(person)
    ret = caller.call()
    if (debug)
        System.out.println(ret)
    if (ret != expected)
        throw RuntimeException("Failed. Received: " + ret + " Expected: " + expected)

    // Polymorphic call of object created in target language and passed to C++ and back again
    val baseclass = caller.baseClass()
    ret = baseclass!!.id()
    if (debug)
        System.out.println(ret)
    if (ret != expected)
        throw RuntimeException("Failed. Received: " + ret + " Expected: " + expected)

    caller.resetCallback()
    if (debug)
        System.out.println("----------------------------------------")
}

class TargetLangPerson : Person() {
    override fun id(): String {
        return "TargetLangPerson"
    }
}

class TargetLangChild : Child() {
    override fun id(): String {
        return "TargetLangChild"
    }
}

class TargetLangGrandChild : GrandChild() {
    override fun id(): String {
        return "TargetLangGrandChild"
    }
}

// Semis - don't override id() in target language
class TargetLangSemiPerson : Person()

class TargetLangSemiChild : Child()

class TargetLangSemiGrandChild : GrandChild()

// Orphans - don't override id() in C++
class TargetLangOrphanPerson : OrphanPerson() {
    override fun id(): String {
        return "TargetLangOrphanPerson"
    }
}

class TargetLangOrphanChild : OrphanChild() {
    override fun id(): String {
        return "TargetLangOrphanChild"
    }
}

// Duals - id() makes an upcall to the base id()
class TargetLangDualPerson : Person() {
    override fun id(): String {
        return "TargetLangDualPerson + " + super.id()
    }
}

class TargetLangDualChild : Child() {
    override fun id(): String {
        return "TargetLangDualChild + " + super.id()
    }
}

class TargetLangDualGrandChild : GrandChild() {
    override fun id(): String {
        return "TargetLangDualGrandChild + " + super.id()
    }
}

// Mix Orphans and Duals
class TargetLangDualOrphanPerson : OrphanPerson() {
    override fun id(): String {
        return "TargetLangDualOrphanPerson + " + super.id()
    }
}

class TargetLangDualOrphanChild : OrphanChild() {
    override fun id(): String {
        return "TargetLangDualOrphanChild + " + super.id()
    }
}

fun main() {
    try {
        System.loadLibrary("director_classic")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val person = Person()
        check(person, "Person")
        person.delete()
    }
    run {
        val person = Child()
        check(person, "Child")
        person.delete()
    }
    run {
        val person = GrandChild()
        check(person, "GrandChild")
        person.delete()
    }
    run {
        val person = TargetLangPerson()
        check(person, "TargetLangPerson")
        person.delete()
    }
    run {
        val person = TargetLangChild()
        check(person, "TargetLangChild")
        person.delete()
    }
    run {
        val person = TargetLangGrandChild()
        check(person, "TargetLangGrandChild")
        person.delete()
    }

    // Semis - don't override id() in target language
    run {
        val person = TargetLangSemiPerson()
        check(person, "Person")
        person.delete()
    }
    run {
        val person = TargetLangSemiChild()
        check(person, "Child")
        person.delete()
    }
    run {
        val person = TargetLangSemiGrandChild()
        check(person, "GrandChild")
        person.delete()
    }

    // Orphans - don't override id() in C++
    run {
        val person = OrphanPerson()
        check(person, "Person")
        person.delete()
    }
    run {
        val person = OrphanChild()
        check(person, "Child")
        person.delete()
    }
    run {
        val person = TargetLangOrphanPerson()
        check(person, "TargetLangOrphanPerson")
        person.delete()
    }
    run {
        val person = TargetLangOrphanChild()
        check(person, "TargetLangOrphanChild")
        person.delete()
    }

    // Duals - id() makes an upcall to the base id()
    run {
        val person = TargetLangDualPerson()
        check(person, "TargetLangDualPerson + Person")
        person.delete()
    }
    run {
        val person = TargetLangDualChild()
        check(person, "TargetLangDualChild + Child")
        person.delete()
    }
    run {
        val person = TargetLangDualGrandChild()
        check(person, "TargetLangDualGrandChild + GrandChild")
        person.delete()
    }

    // Mix Orphans and Duals
    run {
        val person = TargetLangDualOrphanPerson()
        check(person, "TargetLangDualOrphanPerson + Person")
        person.delete()
    }
    run {
        val person = TargetLangDualOrphanChild()
        check(person, "TargetLangDualOrphanChild + Child")
        person.delete()
    }
}
