using System;
using csharp_argument_defaults_featureNamespace;

public class runme {
    static void Main() {
        Foo foo = new Foo(1);
        foo.bar(1); //shutup compiler warning
        Foo bar = new Foo(1, c:3);

        if(bar.bar(1) != 7)
            throw new ApplicationException("bar.bar(1) != 7");
        if(bar.bar(1, 4, 4) != 9)
            throw new ApplicationException("bar.bar(1, 4, 4) != 9");
        if(bar.bar(1, y:3) != 8)
            throw new ApplicationException("bar.bar(1, y:3) != 8");
        if(bar.bat() != 6)
            throw new ApplicationException("bar.bat() != 6");
        if(bar.bat(3,3) != 9)
            throw new ApplicationException("bar.bat(3,3) != 9");
        if(bar.zoo() != 5)
            throw new ApplicationException("bar.zoo() != 5");
        if(bar.lengthOfString() != 5)
            throw new ApplicationException("bar.lengthOfString() != 5");
        if(bar.zoo(x:"to") != 2)
            throw new ApplicationException("bar.zoo(x:\"to\" != 2");
        if(bar.pi() != System.Math.PI)
            throw new ApplicationException("bar.pi() != Math.PI");
        if(bar.valueofenum(t:EnumerationType.three) != 3)
            throw new ApplicationException("bar.valueofenum(t:EnumerationType.three) != 3");
        if(bar.valueofenum() != 2)
            throw new ApplicationException("bar.valueofenum() != 2");
        if(bar.valueofchar() != 99)
            throw new ApplicationException("bar.valueofchar() != 99");
        if(bar.valueofchar(c:'d') != 100)
            throw new ApplicationException("bar.valueofchar(c:'d') != 100");

        if(Foo.sbar(1) != 7)
            throw new ApplicationException("Foo.sbar(1) != 7");
        if(Foo.sbar(1, 4, 4) != 9)
            throw new ApplicationException("Foo.sbar(1, 4, 4) != 9");
        if(Foo.sbar(1, y:3) != 8)
            throw new ApplicationException("Foo.sbar(1, y:3) != 8");
        if(Foo.sbat() != 6)
            throw new ApplicationException("Foo.sbat() != 6");
        if(Foo.sbat(3,3) != 9)
            throw new ApplicationException("Foo.sbat(3,3) != 9");

        if(csharp_argument_defaults_feature.gbar(1) != 7)
            throw new ApplicationException("gbar(1) != 7");
        if(csharp_argument_defaults_feature.gbar(1, 4, 4) != 9)
            throw new ApplicationException("gbar(1, 4, 4) != 9");
        if(csharp_argument_defaults_feature.gbar(1, y:3) != 8)
            throw new ApplicationException("gbar(1, y:3) != 8");
        if(csharp_argument_defaults_feature.gbat() != 6)
            throw new ApplicationException("gbat() != 6");
        if(csharp_argument_defaults_feature.gbat(3,3) != 9)
            throw new ApplicationException("gbat(3,3) != 9");

        var iface = new AnImplementation();
        if(iface.foo() != 6)
            throw new ApplicationException("AnImplementation::foo() != 6");
        if(iface.foo(z:5) != 7)
            throw new ApplicationException("AnImplementation::foo(z:4) != 7");
    }
}
