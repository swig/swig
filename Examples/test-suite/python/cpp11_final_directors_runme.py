import cpp11_final_directors


class Derived2(cpp11_final_directors.Derived):

    def meth(self):
        return 3

    def finalinderived(self):
        return 98

    def finalinderived2(self):
        return 99


b = Derived2()
if b.meth() != 3:
    raise RuntimeError

# meth is overridable, so C++ calls into Python for it
if cpp11_final_directors.call_meth(b) != 3:
    raise RuntimeError

# The final overrides are not directed, so C++ keeps its own implementations
if cpp11_final_directors.call_finalinderived(b) != 11:
    raise RuntimeError
if cpp11_final_directors.call_finalinderived2(b) != 21:
    raise RuntimeError
