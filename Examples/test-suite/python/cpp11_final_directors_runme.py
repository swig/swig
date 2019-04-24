import cpp11_final_directors

class Derived2(cpp11_final_directors.Derived):

    def meth(self):
        return 3


b = Derived2()
if b.meth() != 3:
    raise RuntimeError
