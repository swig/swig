using System;

public class runme {
    static void Main() {

        NDouble d = new NDouble(3.5);
        NInt i = new NInt(2);

        //
        // These two natural 'copy' forms fail because no covariant (polymorphic) return types 
        // are supported in C#. 
        //
        // NDouble dc = d.copy();
        // NInt ic = i.copy();

        //
        // Unlike C++, we have to downcast instead.
        //
        NDouble dc = (NDouble)d.copy();
        NInt ic = (NInt)i.copy();

        NDouble ddc = NDouble.narrow(dc);
        NInt dic = NInt.narrow(ic);

        virtual_poly.incr(ic);
        if ( (i.get() + 1) != ic.get() )
            throw new Exception("incr test failed");
  }
}
