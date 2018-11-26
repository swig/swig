using System;
using nested_in_templateNamespace;

public class runme {
    static void Main() {
        var cd = new OuterTemplate1.ConcreteDerived(88);
        if (cd.m_value != 88)
            throw new Exception("ConcreteDerived not created correctly");
    }
}
