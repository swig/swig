from python_enum_strong_scoped import *
#
# Color0:
#
if type(GRAY) != int:
    raise RuntimeError("Failed: type(GRAY) != int (but %r)" % type(GRAY))
if type(LIGHTGRAY) != int:
    raise RuntimeError("Failed: type(LIGHTGRAY) != int (but %r)" % type(LIGHTGRAY))

if type(get_Color0_GRAY()) != int:
    raise RuntimeError("Failed: type(get_Color0_GRAY()) != int (but %r)" % type(get_Color0_GRAY()))
if type(get_Color0_LIGHTGRAY()) != int:
    raise RuntimeError("Failed: type(get_Color0_LIGHTGRAY()) != int (but %r)" % type(get_Color0_LIGHTGRAY()))

if GRAY != 0:
    raise RuntimeError("Failed: GRAY !=  0 (but %r)" % GRAY)
if LIGHTGRAY != 1:
    raise RuntimeError("Failed: LIGHTGRAY !=  1 (but %r)" % LIGHTGRAY)

if get_Color0_GRAY() != 0:
    raise RuntimeError("Failed: get_Color0_GRAY() != 0 (but %r)" % get_Color0_GRAY())
if get_Color0_LIGHTGRAY() != 1:
    raise RuntimeError("Failed: get_Color0_LIGHTGRAY() !=  1 (but %r)" % get_Color0_LIGHTGRAY())

#
# Color1:
# 
if type(RED) != Color1:
    raise RuntimeError("Failed: type(RED) != Color1 (but %r)" % type(RED))
if type(GREEN) != Color1:
    raise RuntimeError("Failed: type(RED) != Color1 (but %r)" % type(GREEN))
if type(BLUE) != Color1:
    raise RuntimeError("Failed: type(RED) != Color1 (but %r)" % type(BLUE))

if intval(RED) != 0:
    raise RuntimeError("Failed: intval(RED) != 0 (but %r)" % intval(RED))
if intval(GREEN) != 1:
    raise RuntimeError("Failed: intval(GREEN) != 1 (but %r)" % intval(GREEN))
if intval(BLUE) != 2:
    raise RuntimeError("Failed: intval(BLUE) != 2 (but %r)" % intval(BLUE))

if intval_r(RED) != 0:
    raise RuntimeError("Failed: intval_r(RED) != 0 (but %r)" % intval(RED))
if intval_r(GREEN) != 1:
    raise RuntimeError("Failed: intval_r(GREEN) != 1 (but %r)" % intval(GREEN))
if intval_r(BLUE) != 2:
    raise RuntimeError("Failed: intval_r(BLUE) != 2 (but %r)" % intval(BLUE))

if intval_p(RED) != 0:
    raise RuntimeError("Failed: intval_p(RED) != 0 (but %r)" % intval(RED))
if intval_p(GREEN) != 1:
    raise RuntimeError("Failed: intval_p(GREEN) != 1 (but %r)" % intval(GREEN))
if intval_p(BLUE) != 2:
    raise RuntimeError("Failed: intval_p(BLUE) != 2 (but %r)" % intval(BLUE))

if intval_cr(RED) != 0:
    raise RuntimeError("Failed: intval_cr(RED) != 0 (but %r)" % intval(RED))
if intval_cr(GREEN) != 1:
    raise RuntimeError("Failed: intval_cr(GREEN) != 1 (but %r)" % intval(GREEN))
if intval_cr(BLUE) != 2:
    raise RuntimeError("Failed: intval_cr(BLUE) != 2 (but %r)" % intval(BLUE))

if intval_cp(RED) != 0:
    raise RuntimeError("Failed: intval_cp(RED) != 0 (but %r)" % intval(RED))
if intval_cp(GREEN) != 1:
    raise RuntimeError("Failed: intval_cp(GREEN) != 1 (but %r)" % intval(GREEN))
if intval_cp(BLUE) != 2:
    raise RuntimeError("Failed: intval_cp(BLUE) != 2 (but %r)" % intval(BLUE))

if type(get_Color1_RED()) != Color1:
    raise RuntimeError("Failed: type(get_Color1_RED()) != Color1 (but %r)" % type(get_Color1_RED()))
if type(get_Color1_GREEN()) != Color1:
    raise RuntimeError("Failed: type(get_Color1_RED()) != Color1 (but %r)" % type(get_Color1_GREEN()))
if type(get_Color1_BLUE()) != Color1:
    raise RuntimeError("Failed: type(get_Color1_RED()) != Color1 (but %r)" % type(get_Color1_BLUE()))

if intval(get_Color1_RED()) != 0:
    raise RuntimeError("Failed: intval(get_Color1_RED()) != 0 (but %r)" % intval(get_Color1_RED()))
if intval(get_Color1_GREEN()) != 1:
    raise RuntimeError("Failed: intval(get_Color1_GREEN()) != 1 (but %r)" % intval(get_Color1_GREEN()))
if intval(get_Color1_BLUE()) != 2:
    raise RuntimeError("Failed: intval(get_Color1_BLUE()) != 2 (but %r)" % intval(get_Color1_BLUE()))

if intval_r(get_Color1_RED()) != 0:
    raise RuntimeError("Failed: intval_r(get_Color1_RED()) != 0 (but %r)" % intval(get_Color1_RED()))
if intval_r(get_Color1_GREEN()) != 1:
    raise RuntimeError("Failed: intval_r(get_Color1_GREEN()) != 1 (but %r)" % intval(get_Color1_GREEN()))
if intval_r(get_Color1_BLUE()) != 2:
    raise RuntimeError("Failed: intval_r(get_Color1_BLUE()) != 2 (but %r)" % intval(get_Color1_BLUE()))

if intval_p(get_Color1_RED()) != 0:
    raise RuntimeError("Failed: intval_p(get_Color1_RED()) != 0 (but %r)" % intval(get_Color1_RED()))
if intval_p(get_Color1_GREEN()) != 1:
    raise RuntimeError("Failed: intval_p(get_Color1_GREEN()) != 1 (but %r)" % intval(get_Color1_GREEN()))
if intval_p(get_Color1_BLUE()) != 2:
    raise RuntimeError("Failed: intval_p(get_Color1_BLUE()) != 2 (but %r)" % intval(get_Color1_BLUE()))

if intval_cr(get_Color1_RED()) != 0:
    raise RuntimeError("Failed: intval_cr(get_Color1_RED()) != 0 (but %r)" % intval(get_Color1_RED()))
if intval_cr(get_Color1_GREEN()) != 1:
    raise RuntimeError("Failed: intval_cr(get_Color1_GREEN()) != 1 (but %r)" % intval(get_Color1_GREEN()))
if intval_cr(get_Color1_BLUE()) != 2:
    raise RuntimeError("Failed: intval_cr(get_Color1_BLUE()) != 2 (but %r)" % intval(get_Color1_BLUE()))

if intval_cp(get_Color1_RED()) != 0:
    raise RuntimeError("Failed: intval_cp(get_Color1_RED()) != 0 (but %r)" % intval(get_Color1_RED()))
if intval_cp(get_Color1_GREEN()) != 1:
    raise RuntimeError("Failed: intval_cp(get_Color1_GREEN()) != 1 (but %r)" % intval(get_Color1_GREEN()))
if intval_cp(get_Color1_BLUE()) != 2:
    raise RuntimeError("Failed: intval_cp(get_Color1_BLUE()) != 2 (but %r)" % intval(get_Color1_BLUE()))

#
# Color2:
# 
if type(Color2.CYAN) != int:
    raise RuntimeError("Failed: type(Color2.CYAN) != int (but %r)" % type(Color2.CYAN))
if type(Color2.MAGENTA) != int:
    raise RuntimeError("Failed: type(Color2.MAGENTA) != int (but %r)" % type(Color2.MAGENTA))
if type(Color2.YELLOW) != int:
    raise RuntimeError("Failed: type(Color2.YELLOW) != int (but %r)" % type(Color2.YELLOW))
if type(Color2.BLACK) != int:
    raise RuntimeError("Failed: type(Color2.BLACK) != int (but %r)" % type(Color2.BLACK))

if Color2.CYAN != 20:
    raise RuntimeError("Failed: Color2.CYAN != 20 (but %r)" % Color2.CYAN)
if Color2.MAGENTA != 21:
    raise RuntimeError("Failed: Color2.MAGENTA != 21 (but %r)" % Color2.MAGENTA)
if Color2.YELLOW != 22:
    raise RuntimeError("Failed: Color2.YELLOW != 22 (but %r)" % Color2.YELLOW)
if Color2.BLACK != 23:
    raise RuntimeError("Failed: Color2.BLACK != 23 (but %r)" % Color2.BLACK)

if type(get_Color2_CYAN()) != int:
    raise RuntimeError("Failed: type(get_Color2_CYAN()) != int (but %r)" % type(get_Color2_CYAN()))
if type(get_Color2_MAGENTA()) != int:
    raise RuntimeError("Failed: type(get_Color2_MAGENTA()) != int (but %r)" % type(get_Color2_MAGENTA()))
if type(get_Color2_YELLOW()) != int:
    raise RuntimeError("Failed: type(get_Color2_YELLOW()) != int (but %r)" % type(get_Color2_YELLOW()))
if type(get_Color2_BLACK()) != int:
    raise RuntimeError("Failed: type(get_Color2_BLACK()) != int (but %r)" % type(get_Color2_BLACK()))

if get_Color2_CYAN() != 20:
    raise RuntimeError("Failed: get_Color2_CYAN() != 20 (but %r)" % get_Color2_CYAN())
if get_Color2_MAGENTA() != 21:
    raise RuntimeError("Failed: get_Color2_MAGENTA() != 21 (but %r)" % get_Color2_MAGENTA())
if get_Color2_YELLOW() != 22:
    raise RuntimeError("Failed: get_Color2_YELLOW() != 22 (but %r)" % get_Color2_YELLOW())
if get_Color2_BLACK() != 23:
    raise RuntimeError("Failed: get_Color2_BLACK() != 23 (but %r)" % get_Color2_BLACK())

#
# Color 3:
#
if type(Color3.BROWN) != Color3:
    raise RuntimeError("Failed: type(Color3.BROWN) != Color3 (but %r)" % type(Color3.BROWN))
if intval(Color3.BROWN) != 31:
    raise RuntimeError("Failed: intval(Color3.BROWN) != 31 (but %r)" % intval(Color3.BROWN))
if intval_r(Color3.BROWN) != 31:
    raise RuntimeError("Failed: intval_r(Color3.BROWN) != 31 (but %r)" % intval_r(Color3.BROWN))
if intval_p(Color3.BROWN) != 31:
    raise RuntimeError("Failed: intval_p(Color3.BROWN) != 31 (but %r)" % intval_p(Color3.BROWN))
if intval_cr(Color3.BROWN) != 31:
    raise RuntimeError("Failed: intval_cr(Color3.BROWN) != 31 (but %r)" % intval_cr(Color3.BROWN))
if intval_cp(Color3.BROWN) != 31:
    raise RuntimeError("Failed: intval_cp(Color3.BROWN) != 31 (but %r)" % intval_cp(Color3.BROWN))

if type(get_Color3_BROWN()) != Color3:
    raise RuntimeError("Failed: type(get_Color3_BROWN()) != Color3 (but %r)" % type(get_Color3_BROWN()))
if intval(get_Color3_BROWN()) != 31:
    raise RuntimeError("Failed: intval(get_Color3_BROWN()) != 31 (but %r)" % intval(get_Color3_BROWN()))
if intval_r(get_Color3_BROWN()) != 31:
    raise RuntimeError("Failed: intval_r(get_Color3_BROWN()) != 31 (but %r)" % intval_r(get_Color3_BROWN()))
if intval_p(get_Color3_BROWN()) != 31:
    raise RuntimeError("Failed: intval_p(get_Color3_BROWN()) != 31 (but %r)" % intval_p(get_Color3_BROWN()))
if intval_cr(get_Color3_BROWN()) != 31:
    raise RuntimeError("Failed: intval_cr(get_Color3_BROWN()) != 31 (but %r)" % intval_cr(get_Color3_BROWN()))
if intval_cp(get_Color3_BROWN()) != 31:
    raise RuntimeError("Failed: intval_cp(get_Color3_BROWN()) != 31 (but %r)" % intval_cp(get_Color3_BROWN()))

#
# Color 4:
#
if type(Color4.C4_BROWN) != int:
    raise RuntimeError("Failed: type(Color4.C4_BROWN) == %r" % type(Color4.C4_BROWN))
if Color4.C4_BROWN != intval(Color3.BROWN):
    raise RuntimeError("Failed: Color4.C4_BROWN != %r (but %r)" % (intval(Color3.BROWN), Color4.C4_BROWN))

if type(get_Color4_C4_BROWN()) != int:
    raise RuntimeError("Failed: type(get_Color4_C4_BROWN()) == %r" % type(get_Color4_C4_BROWN()))
if get_Color4_C4_BROWN() != intval(Color3.BROWN):
    raise RuntimeError("Failed: get_Color4_C4_BROWN() != %r (but %r)" % (intval(Color3.BROWN), get_Color4_C4_BROWN()))
