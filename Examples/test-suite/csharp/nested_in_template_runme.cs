using System;
using nested_in_templateNamespace;

public class runme {
    static void Main() {
        var cd = new OuterTemplate1.ConcreteDerived(8.8);
        if (cd.m_value != 8.8)
            throw new Exception("ConcreteDerived not created correctly");
    }
}
