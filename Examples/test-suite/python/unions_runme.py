
# This is the union runtime testcase. It ensures that values within a
# union embedded within a struct can be set and read correctly.

import unions
import string

# Create new instances of SmallStruct and BigStruct for later use
small = unions.SmallStruct()
small.jill = 200

big = unions.BigStruct()
big.smallstruct = small
big.jack = 300

# Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
# Ensure values in EmbeddedUnionTest are set correctly for each.
eut = unions.EmbeddedUnionTest()

# First check the SmallStruct in EmbeddedUnionTest
eut.number = 1
eut.uni.small = small
Jill1 = eut.uni.small.jill
if (Jill1 != 200):
    raise RuntimeError("Runtime test1 failed. eut.uni.small.jill={}".format(Jill1))

Num1 = eut.number
if (Num1 != 1):
    raise RuntimeError("Runtime test2 failed. eut.number=".format(Num1))

# Secondly check the BigStruct in EmbeddedUnionTest
eut.number = 2
eut.uni.big = big
Jack1 = eut.uni.big.jack
if (Jack1 != 300):
    raise RuntimeError("Runtime test3 failed. eut.uni.big.jack={}".format(Jack1))

Jill2 = eut.uni.big.smallstruct.jill
if (Jill2 != 200):
    raise RuntimeError("Runtime test4 failed. eut.uni.big.smallstruct.jill={}".format(Jill2))

Num2 = eut.number
if (Num2 != 2):
    raise RuntimeError("Runtime test5 failed. eut.number={}".format(Num2))
