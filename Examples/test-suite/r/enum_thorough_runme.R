clargs <- commandArgs(trailing=TRUE)
source(file.path(clargs[1], "unittest.R"))

dyn.load(paste("enum_thorough", .Platform$dynlib.ext, sep=""))
source("enum_thorough.R")
cacheMetaData(1)

## Anonymous enums are not wrapped by the R module
##

# Colours - string interface, various function signatures
unittest('red', colourTest1('red'))
unittest('blue', colourTest1('blue'))
unittest('green', colourTest1('green'))


unittest('red', colourTest2('red'))
unittest('blue', colourTest2('blue'))
unittest('green', colourTest2('green'))

unittest('red', colourTest3('red'))
unittest('blue', colourTest3('blue'))
unittest('green', colourTest3('green'))

unittest('red', colourTest4('red'))
unittest('blue', colourTest4('blue'))
unittest('green', colourTest4('green'))

## Colours - underlying integers
unittest(-1, enumToInteger('red', '_colour'))
unittest(0, enumToInteger('blue', '_colour'))
unittest(10, enumToInteger('green', '_colour'))

########
## enum variable, wrapped as a function
## Is initialization to 0 a "standard"
myColour()

## Test setting and retrieving
myColour('green')
unittest('green', myColour())

########
## SpeedClass

s <- SpeedClass()
v <- "medium"
unittest(v, s$speedTest1(v))
unittest(v, s$speedTest2(v))
unittest(v, s$speedTest3(v))
unittest(v, s$speedTest4(v))
unittest(v, s$speedTest5(v))
unittest(v, s$speedTest6(v))
unittest(v, s$speedTest7(v))
unittest(v, s$speedTest8(v))

## speedTest methods not in the class

unittest(v, speedTest1(v))
unittest(v, speedTest2(v))
unittest(v, speedTest3(v))
unittest(v, speedTest4(v))
# enum reference
unittest(v, speedTest5(v))

## member access
s <- SpeedClass()
unittest("slow", s$mySpeedtd1)
# check integer value
unittest(10, enumToInteger(s$mySpeedtd1, "_SpeedClass__speed"))
# set and check
s$mySpeedtd1 <- "lightning"
unittest("lightning", s$mySpeedtd1)
unittest(31, enumToInteger(s$mySpeedtd1, "_SpeedClass__speed"))

## Named anon - not wrapped nicely, but can be retrieved:


unittest("NamedAnon2", namedanon_NamedAnon2_get())
unittest(0, enumToInteger(namedanon_NamedAnon1_get(), "_namedanon"))
unittest(1, enumToInteger(namedanon_NamedAnon2_get(), "_namedanon"))

## Twonames
v <- "TwoNames1"
unittest(v, twonamesTest1(v))
unittest(v, twonamesTest2(v))
unittest(v, twonamesTest3(v))
unittest(33, enumToInteger("TwoNames3", "_twonamestag"))

tt <- TwoNamesStruct()
v <- "TwoNamesStruct1"
unittest(v, tt$twonamesTest1(v))
unittest(v, tt$twonamesTest2(v))
unittest(v, tt$twonamesTest3(v))
## Try the wrong name
unittest(TRUE, is.na(tt$twonamesTest3("TwoNames1")))

## Namedanonspace
## can get the values

v <- namedanonspace_NamedAnonSpace2_get()
unittest(v, namedanonspaceTest1(v))
unittest(v, namedanonspaceTest2(v))
unittest(v, namedanonspaceTest3(v))
unittest(v, namedanonspaceTest4(v))

## scientists

tt <- TemplateClassInt()

g <- "galileo"
unittest(g, tt$scientistsTest1(g))
unittest(g, tt$scientistsTest2(g))
unittest(g, tt$scientistsTest3(g))
unittest(g, tt$scientistsTest4(g))
unittest(g, tt$scientistsTest5(g))
unittest(g, tt$scientistsTest6(g))
unittest(g, tt$scientistsTest7(g))
unittest(g, tt$scientistsTest8(g))
unittest(g, tt$scientistsTest9(g))

## This one is commented out in csharp too
## unittest(g, tt$scientistsTestA(g))
unittest(g, tt$scientistsTestB(g))
## This one is commented out in csharp too
## unittest(g, tt$scientistsTestC(g))
unittest(g, tt$scientistsTestD(g))
unittest(g, tt$scientistsTestE(g))
unittest(g, tt$scientistsTestF(g))
unittest(g, tt$scientistsTestG(g))
unittest(g, tt$scientistsTestH(g))
unittest(g, tt$scientistsTestI(g))
# enum reference
unittest(g, tt$scientistsTestJ(g))


unittest(g, scientistsTest1(g))
unittest(g, scientistsTest2(g))
unittest(g, scientistsTest3(g))
unittest(g, scientistsTest4(g))
unittest(g, scientistsTest5(g))
unittest(g, scientistsTest6(g))
unittest(g, scientistsTest7(g))
## enum reference
unittest(g, scientistsTest8(g))

tt <- TClassInt()
b <- "bell"
unittest(b, tt$scientistsNameTest1(b))
unittest(b, tt$scientistsNameTest2(b))
unittest(b, tt$scientistsNameTest3(b))
unittest(b, tt$scientistsNameTest4(b))
unittest(b, tt$scientistsNameTest5(b))
unittest(b, tt$scientistsNameTest6(b))
unittest(b, tt$scientistsNameTest7(b))
unittest(b, tt$scientistsNameTest8(b))
unittest(b, tt$scientistsNameTest9(b))

## This one is commented out in csharp too
## unittest(b, tt$scientistsNameTestA(b))
unittest(b, tt$scientistsNameTestB(b))
## This one is commented out in csharp too
## unittest(b, tt$scientistsNameTestC(b))
unittest(b, tt$scientistsNameTestD(b))
unittest(b, tt$scientistsNameTestE(b))
unittest(b, tt$scientistsNameTestF(b))
unittest(b, tt$scientistsNameTestG(b))
unittest(b, tt$scientistsNameTestH(b))
unittest(b, tt$scientistsNameTestI(b))


unittest(b, tt$scientistsNameSpaceTest1(b))
unittest(b, tt$scientistsNameSpaceTest2(b))
unittest(b, tt$scientistsNameSpaceTest3(b))
unittest(b, tt$scientistsNameSpaceTest4(b))
unittest(b, tt$scientistsNameSpaceTest5(b))
unittest(b, tt$scientistsNameSpaceTest6(b))
unittest(b, tt$scientistsNameSpaceTest7(b))

unittest(g, tt$scientistsOtherTest1(g))
unittest(g, tt$scientistsOtherTest2(g))
unittest(g, tt$scientistsOtherTest3(g))
unittest(g, tt$scientistsOtherTest4(g))
unittest(g, tt$scientistsOtherTest5(g))
unittest(g, tt$scientistsOtherTest6(g))
unittest(g, tt$scientistsOtherTest7(g))

## Global 
unittest(b, scientistsNameTest1(b))
unittest(b, scientistsNameTest2(b))
unittest(b, scientistsNameTest3(b))
unittest(b, scientistsNameTest4(b))
unittest(b, scientistsNameTest5(b))
unittest(b, scientistsNameTest6(b))
unittest(b, scientistsNameTest7(b))

unittest(b, scientistsNameSpaceTest1(b))
unittest(b, scientistsNameSpaceTest2(b))
unittest(b, scientistsNameSpaceTest3(b))
unittest(b, scientistsNameSpaceTest4(b))
unittest(b, scientistsNameSpaceTest5(b))
unittest(b, scientistsNameSpaceTest6(b))
unittest(b, scientistsNameSpaceTest7(b))

unittest(b, scientistsNameSpaceTest8(b))
unittest(b, scientistsNameSpaceTest9(b))
unittest(b, scientistsNameSpaceTestA(b))
unittest(b, scientistsNameSpaceTestB(b))
unittest(b, scientistsNameSpaceTestC(b))
unittest(b, scientistsNameSpaceTestD(b))
unittest(b, scientistsNameSpaceTestE(b))
unittest(b, scientistsNameSpaceTestF(b))
unittest(b, scientistsNameSpaceTestG(b))
unittest(b, scientistsNameSpaceTestH(b))
unittest(b, scientistsNameSpaceTestI(b))
unittest(b, scientistsNameSpaceTestJ(b))
unittest(b, scientistsNameSpaceTestK(b))
unittest(b, scientistsNameSpaceTestL(b))

## rename test
v <- "eek"
unittest(v, renameTest1(v))
unittest(v, renameTest2(v))

## NewName
N <- NewNameStruct()
## Only half works:
unittest("kerboom", NewNameStruct_bang_get())
## Can't put in "bang" in the call
## confirm with:
## get(".__E___OldNameStruct__enumeration")

## TreeClass

T <- TreesClass()
p <- "pine"

unittest(p, T$treesTest1(p))
unittest(p, T$treesTest2(p))
unittest(p, T$treesTest3(p))
unittest(p, T$treesTest4(p))
unittest(p, T$treesTest5(p))
unittest(p, T$treesTest6(p))
unittest(p, T$treesTest7(p))
unittest(p, T$treesTest8(p))
unittest(p, T$treesTest9(p))
unittest(p, T$treesTestA(p))
unittest(p, T$treesTestB(p))
unittest(p, T$treesTestC(p))
unittest(p, T$treesTestD(p))
unittest(p, T$treesTestE(p))
unittest(p, T$treesTestF(p))
unittest(p, T$treesTestG(p))
unittest(p, T$treesTestH(p))
unittest(p, T$treesTestI(p))
unittest(p, T$treesTestJ(p))
unittest(p, T$treesTestK(p))
unittest(p, T$treesTestL(p))
unittest(p, T$treesTestM(p))
unittest(p, T$treesTestN(p))
unittest(p, T$treesTestO(p))

unittest(p, treesTest1(p))
unittest(p, treesTest2(p))
unittest(p, treesTest3(p))
unittest(p, treesTest4(p))
unittest(p, treesTest5(p))
unittest(p, treesTest6(p))
unittest(p, treesTest7(p))
unittest(p, treesTest8(p))
unittest(p, treesTest9(p))
unittest(p, treesTestA(p))
unittest(p, treesTestB(p))
unittest(p, treesTestC(p))
unittest(p, treesTestD(p))
unittest(p, treesTestE(p))
unittest(p, treesTestF(p))
unittest(p, treesTestG(p))
unittest(p, treesTestH(p))
unittest(p, treesTestI(p))
unittest(p, treesTestJ(p))
unittest(p, treesTestK(p))
unittest(p, treesTestL(p))
unittest(p, treesTestM(p))
unittest(p, treesTestO(p))
unittest(p, treesTestP(p))
unittest(p, treesTestQ(p))
unittest(p, treesTestR(p))

## Hair
h <- HairStruct()
g <- "ginger"
unittest(g, h$hairTest1(g))
unittest(g, h$hairTest2(g))
unittest(g, h$hairTest3(g))
unittest(g, h$hairTest4(g))
unittest(g, h$hairTest5(g))
unittest(g, h$hairTest6(g))
unittest(g, h$hairTest7(g))
unittest(g, h$hairTest8(g))
unittest(g, h$hairTest9(g))
unittest(g, h$hairTestA(g))
unittest(g, h$hairTestB(g))

r <- "red"
unittest(r, h$colourTest1(r))
unittest(r, h$colourTest2(r))

nmA <- "NamedAnon1"
unittest(nmA, h$namedanonTest1(nmA))
unittest("NamedAnonSpace2", h$namedanonspaceTest1("NamedAnonSpace2"))

f <- "fir"

unittest(f, h$treesGlobalTest1(f))
unittest(f, h$treesGlobalTest2(f))
unittest(f, h$treesGlobalTest3(f))
unittest(f, h$treesGlobalTest4(f))

b <- "blonde"
unittest(b, hairTest1(b))
unittest(b, hairTest2(b))
unittest(b, hairTest3(b))
unittest(b, hairTest4(b))
unittest(b, hairTest5(b))
unittest(b, hairTest6(b))
unittest(b, hairTest7(b))
unittest(b, hairTest8(b))
unittest(b, hairTest9(b))
unittest(b, hairTestA(b))
unittest(b, hairTestB(b))
## enum reference
unittest(b, hairTestC(b))
unittest(b, hairTestA1(b))
unittest(b, hairTestA2(b))
unittest(b, hairTestA3(b))
unittest(b, hairTestA4(b))
unittest(b, hairTestA5(b))
unittest(b, hairTestA6(b))
unittest(b, hairTestA7(b))
unittest(b, hairTestA8(b))
unittest(b, hairTestA9(b))
unittest(b, hairTestAA(b))
unittest(b, hairTestAB(b))
## enum reference
unittest(b, hairTestAC(b))

unittest(b, hairTestB1(b))
unittest(b, hairTestB2(b))
unittest(b, hairTestB3(b))
unittest(b, hairTestB4(b))
unittest(b, hairTestB5(b))
unittest(b, hairTestB6(b))
unittest(b, hairTestB7(b))
unittest(b, hairTestB8(b))
unittest(b, hairTestB9(b))
unittest(b, hairTestBA(b))
unittest(b, hairTestBB(b))
## enum reference
unittest(b, hairTestBC(b))

f <- FirStruct()
b <- "blonde"

unittest(b, f$hairTestFir1(b))
unittest(b, f$hairTestFir2(b))
unittest(b, f$hairTestFir3(b))
unittest(b, f$hairTestFir4(b))
unittest(b, f$hairTestFir5(b))
unittest(b, f$hairTestFir6(b))
unittest(b, f$hairTestFir7(b))
unittest(b, f$hairTestFir8(b))
unittest(b, f$hairTestFir9(b))
unittest(b, f$hairTestFirA(b))

## Unnamed enum instance doesn't work
## Wrapper set/get exists, but there's
## no mapping between strings and integers
GlobalInstance(1)
unittest(1, GlobalInstance())

ii <- Instances()
ii$MemberInstance <- 1
unittest(1, ii$MemberInstance)

ii <- IgnoreTest()

## Testing integer values
unittest(0, enumToInteger(IgnoreTest_ignoreA_zero_get(), "_IgnoreTest__IgnoreA"))
unittest(3, enumToInteger(IgnoreTest_ignoreA_three_get(), "_IgnoreTest__IgnoreA"))
unittest(10, enumToInteger(IgnoreTest_ignoreA_ten_get(), "_IgnoreTest__IgnoreA"))

unittest(11, enumToInteger(IgnoreTest_ignoreA_eleven_get(), "_IgnoreTest__IgnoreA"))
unittest(14, enumToInteger(IgnoreTest_ignoreA_fourteen_get(), "_IgnoreTest__IgnoreA"))
unittest(20, enumToInteger(IgnoreTest_ignoreA_twenty_get(), "_IgnoreTest__IgnoreA"))
unittest(30, enumToInteger(IgnoreTest_ignoreA_thirty_get(), "_IgnoreTest__IgnoreA"))
unittest(32, enumToInteger(IgnoreTest_ignoreA_thirty_two_get(), "_IgnoreTest__IgnoreA"))
unittest(33, enumToInteger(IgnoreTest_ignoreA_thirty_three_get(), "_IgnoreTest__IgnoreA"))

unittest(11, enumToInteger(IgnoreTest_ignoreB_eleven_get(), "_IgnoreTest__IgnoreB"))
unittest(12, enumToInteger(IgnoreTest_ignoreB_twelve_get(), "_IgnoreTest__IgnoreB"))
unittest(31, enumToInteger(IgnoreTest_ignoreB_thirty_one_get(), "_IgnoreTest__IgnoreB"))
unittest(32, enumToInteger(IgnoreTest_ignoreB_thirty_two_get(), "_IgnoreTest__IgnoreB"))
unittest(41, enumToInteger(IgnoreTest_ignoreB_forty_one_get(), "_IgnoreTest__IgnoreB"))
unittest(42, enumToInteger(IgnoreTest_ignoreB_forty_two_get(), "_IgnoreTest__IgnoreB"))

unittest(10, enumToInteger(IgnoreTest_ignoreC_ten_get(), "_IgnoreTest__IgnoreC"))
unittest(12, enumToInteger(IgnoreTest_ignoreC_twelve_get(), "_IgnoreTest__IgnoreC"))
unittest(30, enumToInteger(IgnoreTest_ignoreC_thirty_get(), "_IgnoreTest__IgnoreC"))
unittest(32, enumToInteger(IgnoreTest_ignoreC_thirty_two_get(), "_IgnoreTest__IgnoreC"))
unittest(40, enumToInteger(IgnoreTest_ignoreC_forty_get(), "_IgnoreTest__IgnoreC"))
unittest(42, enumToInteger(IgnoreTest_ignoreC_forty_two_get(), "_IgnoreTest__IgnoreC"))

unittest(21, enumToInteger(IgnoreTest_ignoreD_twenty_one_get(), "_IgnoreTest__IgnoreD"))
unittest(22, enumToInteger(IgnoreTest_ignoreD_twenty_two_get(), "_IgnoreTest__IgnoreD"))

unittest(0, enumToInteger(IgnoreTest_ignoreE_zero_get(), "_IgnoreTest__IgnoreE"))
unittest(21, enumToInteger(IgnoreTest_ignoreE_twenty_one_get(), "_IgnoreTest__IgnoreE"))
unittest(22, enumToInteger(IgnoreTest_ignoreE_twenty_two_get(), "_IgnoreTest__IgnoreE"))

## confirm that an ignore directive is followed:
unittest(TRUE, is.na(ignoreCTest("ignoreC_eleven")))


## repeat test
unittest(1, enumToInteger(repeatTest("one"), "_RepeatSpace__repeat"))
unittest(1, enumToInteger(repeatTest("initial"), "_RepeatSpace__repeat"))
unittest(2, enumToInteger(repeatTest("two"), "_RepeatSpace__repeat"))
unittest(3, enumToInteger(repeatTest("three"), "_RepeatSpace__repeat"))
unittest(3, enumToInteger(repeatTest("llast"), "_RepeatSpace__repeat"))
unittest(3, enumToInteger(repeatTest("end"), "_RepeatSpace__repeat"))

## Macro test - nothing in csharp
## Note - this enum is set up with both entries the same
## This means that mapping back from the integer value to the
## string value isn't unique, so asking for "ABCD2" will return
## a string of "ABCD"
unittest("ABCD", enumWithMacroTest("ABCD"))

## Different types
unittest(10, enumToInteger(differentTypesTest("typeint"), "_DifferentSpace__DifferentTypes"))
unittest(0, enumToInteger(differentTypesTest("typeboolfalse"), "_DifferentSpace__DifferentTypes"))
unittest(1, enumToInteger(differentTypesTest("typebooltrue"), "_DifferentSpace__DifferentTypes"))
unittest(2, enumToInteger(differentTypesTest("typebooltwo"), "_DifferentSpace__DifferentTypes"))
unittest(utf8ToInt('C'), enumToInteger(differentTypesTest("typechar"), "_DifferentSpace__DifferentTypes"))
unittest(utf8ToInt('D'), enumToInteger(differentTypesTest("typedefaultint"), "_DifferentSpace__DifferentTypes"))
unittest(utf8ToInt('A') + 1, enumToInteger(differentTypesTest("typecharcompound"), "_DifferentSpace__DifferentTypes"))


## Global different types
## Test uses an anonymous type so the string mapping
## framework doesn't exist.
