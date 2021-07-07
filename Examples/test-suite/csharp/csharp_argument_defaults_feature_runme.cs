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
    }
}
