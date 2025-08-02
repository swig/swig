import doxygen_overloads
import inspect
import comment_verifier

if inspect.getdoc(doxygen_overloads.overloadWithNoDoc) is not None:
    raise Exception("No docstring expected for overloadWithNoDoc.")

comment_verifier.check(inspect.getdoc(doxygen_overloads.overloadWithFirstDoc),
    "Doc for first overload.")

comment_verifier.check(inspect.getdoc(doxygen_overloads.overloadWithSecondDoc),
    "Doc for second overload.")

comment_verifier.check(inspect.getdoc(doxygen_overloads.overloadWithBothDocs),
    r"""*Overload 1:*
Doc for both overloads, first.

|

*Overload 2:*
Doc for both overloads, second.""")

comment_verifier.check(inspect.getdoc(doxygen_overloads.overloadWithSomeDocs),
    r"""*Overload 1:*
Doc for some overloads, first.

|

*Overload 2:*
Doc for some overloads, third.""")

comment_verifier.check(inspect.getdoc(doxygen_overloads.overloadWithSomeOtherDocs),
    r"""*Overload 1:*
Doc for some other overloads, first.

|

*Overload 2:*
Doc for some other overloads, second.""")

comment_verifier.check(inspect.getdoc(doxygen_overloads.S.staticOverloadWithFirstDoc),
    "Doc for first static overload.")

comment_verifier.check(inspect.getdoc(doxygen_overloads.S.memberOverloadWithFirstDoc),
    "Doc for first member overload.")

# As mentioned in doxygen_parsing_runme.py, docstrings for __init__ can't be specified when using "-builtin", so skip these checks in this case.
if not doxygen_overloads.is_python_builtin():
    # Do not check for ClassWithNoDoc ctor docstring, as Python provides a standard one
    # ('Initialize self.  See help(type(self)) for accurate signature.') if none is explicitly specified.

    comment_verifier.check(inspect.getdoc(doxygen_overloads.ClassWithFirstDoc.__init__),
        "Doc for first ctor.")

    comment_verifier.check(inspect.getdoc(doxygen_overloads.ClassWithSecondDoc.__init__),
        "Doc for second ctor.")

    comment_verifier.check(inspect.getdoc(doxygen_overloads.ClassWithBothDocs.__init__),
        r"""*Overload 1:*
Doc for both ctors, first.

|

*Overload 2:*
Doc for both ctors, second.""")

    comment_verifier.check(inspect.getdoc(doxygen_overloads.ClassWithSomeDocs.__init__),
        r"""*Overload 1:*
Doc for some ctors, first.

|

*Overload 2:*
Doc for some ctors, third.""")

    comment_verifier.check(inspect.getdoc(doxygen_overloads.ClassWithSomeOtherDocs.__init__),
        r"""*Overload 1:*
Doc for some other ctors, first.

|

*Overload 2:*
Doc for some other ctors, second.""")
