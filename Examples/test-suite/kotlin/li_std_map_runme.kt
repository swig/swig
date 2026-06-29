@file:JvmName("li_std_map_runme")

import li_std_map.*

fun checkThat(mustBeTrue: Boolean) {
    if (!mustBeTrue) {
        throw RuntimeException("Test failed at line number " + Thread.currentThread().stackTrace[2].lineNumber)
    }
}

fun main() {
    try {
        System.loadLibrary("li_std_map")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val sim: java.util.AbstractMap<String, Int> = StringIntMap()
    val iim: java.util.AbstractMap<Int, Int> = IntIntMap()

    checkThat(sim.isEmpty())
    checkThat(iim.isEmpty())
    checkThat(sim.size == 0)
    checkThat(iim.size == 0)

    checkThat(sim.get("key") == null)
    checkThat(iim.get(1) == null)

    checkThat(!sim.containsKey("key"))
    checkThat(!iim.containsKey(1))

    checkThat(sim.put("key", 2) == null)
    checkThat(iim.put(1, 2) == null)

    checkThat(sim.size == 1)
    checkThat(iim.size == 1)
    checkThat(!sim.isEmpty())
    checkThat(!iim.isEmpty())

    checkThat(sim.get("key") == 2)
    checkThat(iim.get(1) == 2)

    checkThat(sim.remove("key") == 2)
    checkThat(iim.remove(1) == 2)

    checkThat(sim.isEmpty())
    checkThat(iim.isEmpty())
    checkThat(sim.size == 0)
    checkThat(iim.size == 0)

    checkThat(sim.get("key") == null)
    checkThat(iim.get(1) == null)

    checkThat(sim.remove("key") == null)
    checkThat(iim.remove(1) == null)

    checkThat(sim.put("key", 2) == null)
    checkThat(iim.put(1, 2) == null)

    sim.clear()
    iim.clear()
    checkThat(sim.isEmpty())
    checkThat(iim.isEmpty())

    checkThat(sim.put("key1", 1) == null)
    checkThat(iim.put(1, 1) == null)
    checkThat(sim.put("key2", 2) == null)
    checkThat(iim.put(2, 2) == null)

    checkThat(sim.size == 2)
    checkThat(iim.size == 2)
    checkThat(sim.get("key1") == 1)
    checkThat(iim.get(1) == 1)
    checkThat(sim.get("key2") == 2)
    checkThat(iim.get(2) == 2)

    checkThat(sim.put("key1", 3) == 1)
    checkThat(iim.put(1, 3) == 1)

    checkThat(sim.size == 2)
    checkThat(iim.size == 2)
    checkThat(sim.get("key1") == 3)
    checkThat(iim.get(1) == 3)

    val simEs = sim.entries
    val simDefault = HashMap<String, Int>()
    simDefault.put("key1", 3)
    simDefault.put("key2", 2)
    val simEsDefault = simDefault.entries
    checkThat(simEs.size == simEsDefault.size)
    for (entry in simEs) {
        checkThat(simEsDefault.contains(entry))
        checkThat(simDefault.containsKey(entry.key))
        checkThat(simDefault.containsValue(entry.value))

        val oldValue = entry.value
        entry.setValue(oldValue + 1)
        checkThat(sim.get(entry.key) == (oldValue + 1))
    }

    val iimEs = iim.entries
    val iimDefault = HashMap<Int, Int>()
    iimDefault.put(1, 3)
    iimDefault.put(2, 2)
    val iimEsDefault = iimDefault.entries
    checkThat(iimEs.size == iimEsDefault.size)
    for (entry in iimEs) {
        checkThat(iimEsDefault.contains(entry))
        checkThat(iimDefault.containsKey(entry.key))
        checkThat(iimDefault.containsValue(entry.value))

        val oldValue = entry.value
        entry.setValue(oldValue + 1)
        checkThat(iim.get(entry.key) == (oldValue + 1))
    }
}
