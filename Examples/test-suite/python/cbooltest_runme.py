import cbooltest

if not cbooltest.do_or(True, False):
    raise RuntimeError("bad _Bool support")

if cbooltest.do_and(True, False):
    raise RuntimeError("bad _Bool support")

if not cbooltest.TRUE_CONSTANT:
    raise RuntimeError("bad _Bool support")

if cbooltest.FALSE_CONSTANT:
    raise RuntimeError("bad _Bool support")
