@file:JvmName("class_scope_namespace_runme")

import class_scope_namespace.*

fun main() {
    try {
        System.loadLibrary("class_scope_namespace")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = A()
    val b = B()
    val c = C()
    val d = D()
    val e = E()
    val f = F()
    val g = G()
    val h = H.HH()
    val i = I_.II()
    val j = J()
    val k = K()
    val l = L()
    val m = M()

    a.aa(a, a, a)
    b.bb(b, b)
    c.cc(c, c)
    d.dd(d, d, d)
    e.ee(e, e, e)
    f.ff(f, f, f, f)
    g.gg(g, g)
    h.hh(h)
    i.ii(i, i)
    j.jj(j, j, j)
    k.kk(k, k, k)
    l.ll(l, l, l)
    m.mm(m, m, m)

    class_scope_namespace.aaa(a, a, a)
    class_scope_namespace.bbb(b, b)
    class_scope_namespace.ccc(c, c)
    class_scope_namespace.ddd(d, d, d)
    class_scope_namespace.eee(e, e, e)
    class_scope_namespace.fff(f, f, f, f)
    class_scope_namespace.ggg(g, g)
    class_scope_namespace.hhh(h)
    class_scope_namespace.iii(i, i)
    class_scope_namespace.jjj(j, j, j)
    class_scope_namespace.kkk(k, k, k)
    class_scope_namespace.lll(l, l, l)
    class_scope_namespace.mmm(m, m, m)
}
