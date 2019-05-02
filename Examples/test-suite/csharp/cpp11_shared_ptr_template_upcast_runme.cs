// This is the cpp11_shared_ptr_template_upcast runtime testcase. It checks that SWIG generates the appropriate upcasted shared_ptr type for a template instantiation deriving from a base class.
// For this case, the expected behavior is: given a cptr with underlying type shared_ptr<Printable<Derived> >, PrintableDerived_SWIGSmartPtrUpcast returns a cptr with 
// underlying type std::shared_ptr< Derived >, where Printable<Derived> inherits from Derived.
using System;
using cpp11_shared_ptr_template_upcastNamespace;

public class cpp11_shared_ptr_template_upcast_runme
{
    static void Main()
    {
        PrintableDerived pd = cpp11_shared_ptr_template_upcast.MakePrintableDerived(20);
        pd.GetResult();
        pd.GetFormatted();
    }
}
