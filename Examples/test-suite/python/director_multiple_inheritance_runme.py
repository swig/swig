import director_multiple_inheritance as st

class TestBCD(st.B, st.C, st.D):
    def __init__(self):
        st.B.__init__(self)
        st.C.__init__(self)
        st.D.__init__(self)

class TestBDC(st.B, st.C, st.D):
    def __init__(self):
        st.B.__init__(self)
        st.D.__init__(self)
        st.C.__init__(self)

class TestCBD(st.B, st.C, st.D):
    def __init__(self):
        st.C.__init__(self)
        st.B.__init__(self)
        st.D.__init__(self)

def dotest(test):
    e = st.E()
    if e.testE(test) != 5:
        raise RuntimeError(e.testE(test))

    f = st.F()
    if f.testF(test) != 6:
        raise RuntimeError(f.testF(test))

    t = st.T()
    if t.testT(test) != 20:
        raise RuntimeError(t.testT(test))

dotest(TestBCD())
dotest(TestCBD())
dotest(TestBDC())
