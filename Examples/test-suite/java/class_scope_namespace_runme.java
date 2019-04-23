
import class_scope_namespace.*;

public class class_scope_namespace_runme {

  static {
    try {
      System.loadLibrary("class_scope_namespace");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
    A a = new A();
    B b = new B();
    C c = new C();
    D d = new D();
    E e = new E();
    F f = new F();
    G g = new G();
    H.HH h = new H.HH();
    I_.II i = new I_.II();
    J j = new J();
    K k = new K();
    L l = new L();
    M m = new M();

    a.aa(a, a, a);
    b.bb(b, b);
    c.cc(c, c);
    d.dd(d, d, d);
    e.ee(e, e, e);
    f.ff(f, f, f, f);
    g.gg(g, g);
    h.hh(h);
    i.ii(i, i);
    j.jj(j, j, j);
    k.kk(k, k, k);
    l.ll(l, l, l);
    m.mm(m, m, m);

    class_scope_namespace.aaa(a, a, a);
    class_scope_namespace.bbb(b, b);
    class_scope_namespace.ccc(c, c);
    class_scope_namespace.ddd(d, d, d);
    class_scope_namespace.eee(e, e, e);
    class_scope_namespace.fff(f, f, f, f);
    class_scope_namespace.ggg(g, g);
    class_scope_namespace.hhh(h);
    class_scope_namespace.iii(i, i);
    class_scope_namespace.jjj(j, j, j);
    class_scope_namespace.kkk(k, k, k);
    class_scope_namespace.lll(l, l, l);
    class_scope_namespace.mmm(m, m, m);
  }
}
