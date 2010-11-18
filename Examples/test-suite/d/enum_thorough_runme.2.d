module enum_thorough_runme;

import std.exception;
import enum_thorough.enum_thorough;
import enum_thorough.AnonStruct;
import enum_thorough.colour;
import enum_thorough.FirStruct;
import enum_thorough.HairStruct;
import enum_thorough.IgnoreTest;
import enum_thorough.Instances;
import enum_thorough.namedanon;
import enum_thorough.namedanonspace;
import enum_thorough.newname;
import enum_thorough.NewNameStruct;
import enum_thorough.repeat;
import enum_thorough.SpeedClass;
import enum_thorough.TClassInt;
import enum_thorough.TemplateClassInt;
import enum_thorough.TreesClass;
import enum_thorough.twonames;
import enum_thorough.TwoNamesStruct;

void main() {
  {
    // Anonymous enums
    int i = AnonEnum1;
    enforce(ReallyAnInteger == 200, "Test Anon 1 failed");
    i += AnonSpaceEnum1;
    i += AnonStruct.AnonStructEnum1;
  }
  {
    auto red = colour.red;
    colourTest1(red);
    colourTest2(red);
    colourTest3(red);
    colourTest4(red);
    myColour = red;
  }
  {
    auto s = new SpeedClass();
    auto speed = SpeedClass.speed.slow;
    enforce(s.speedTest1(speed) == speed, "speedTest 1 failed");
    enforce(s.speedTest2(speed) == speed, "speedTest 2 failed");
    enforce(s.speedTest3(speed) == speed, "speedTest 3 failed");
    enforce(s.speedTest4(speed) == speed, "speedTest 4 failed");
    enforce(s.speedTest5(speed) == speed, "speedTest 5 failed");
    enforce(s.speedTest6(speed) == speed, "speedTest 6 failed");
    enforce(s.speedTest7(speed) == speed, "speedTest 7 failed");
    enforce(s.speedTest8(speed) == speed, "speedTest 8 failed");

    enforce(speedTest1(speed) == speed, "speedTest Global 1 failed");
    enforce(speedTest2(speed) == speed, "speedTest Global 2 failed");
    enforce(speedTest3(speed) == speed, "speedTest Global 3 failed");
    enforce(speedTest4(speed) == speed, "speedTest Global 4 failed");
    enforce(speedTest5(speed) == speed, "speedTest Global 5 failed");
  }
  {
    auto s = new SpeedClass();
    auto slow = SpeedClass.speed.slow;
    auto lightning = SpeedClass.speed.lightning;

    enforce(s.mySpeedtd1 == slow, "mySpeedtd1 1 failed");
    enforce(cast(int)s.mySpeedtd1 == 10, "mySpeedtd1 2 failed");

    s.mySpeedtd1 = lightning;
    enforce(s.mySpeedtd1 == lightning, "mySpeedtd1 3 failed");
    enforce(cast(int)s.mySpeedtd1 == 31, "mySpeedtd1 4 failed");
  }
  {
    enforce(namedanonTest1(namedanon.NamedAnon2) == namedanon.NamedAnon2, "namedanonTest 1 failed");
  }
  {
    auto val = twonames.TwoNames2;
    enforce(twonamesTest1(val) == val, "twonamesTest 1 failed");
    enforce(twonamesTest2(val) == val, "twonamesTest 2 failed");
    enforce(twonamesTest3(val) == val, "twonamesTest 3 failed");
  }
  {
    auto t = new TwoNamesStruct();
    auto val = TwoNamesStruct.twonames.TwoNamesStruct1;
    enforce(t.twonamesTest1(val) == val, "twonamesTest 1 failed");
    enforce(t.twonamesTest2(val) == val, "twonamesTest 2 failed");
    enforce(t.twonamesTest3(val) == val, "twonamesTest 3 failed");
  }
  {
    auto val = namedanonspace.NamedAnonSpace2;
    enforce(namedanonspaceTest1(val) == val, "namedanonspaceTest 1 failed");
    enforce(namedanonspaceTest2(val) == val, "namedanonspaceTest 2 failed");
    enforce(namedanonspaceTest3(val) == val, "namedanonspaceTest 3 failed");
    enforce(namedanonspaceTest4(val) == val, "namedanonspaceTest 4 failed");
  }
  {
    auto t = new TemplateClassInt();
    auto galileo = TemplateClassInt.scientists.galileo;
    enforce(t.scientistsTest1(galileo) == galileo, "scientistsTest 1 failed");
    enforce(t.scientistsTest2(galileo) == galileo, "scientistsTest 2 failed");
    enforce(t.scientistsTest3(galileo) == galileo, "scientistsTest 3 failed");
    enforce(t.scientistsTest4(galileo) == galileo, "scientistsTest 4 failed");
    enforce(t.scientistsTest5(galileo) == galileo, "scientistsTest 5 failed");
    enforce(t.scientistsTest6(galileo) == galileo, "scientistsTest 6 failed");
    enforce(t.scientistsTest7(galileo) == galileo, "scientistsTest 7 failed");
    enforce(t.scientistsTest8(galileo) == galileo, "scientistsTest 8 failed");
    enforce(t.scientistsTest9(galileo) == galileo, "scientistsTest 9 failed");
//      enforce(t.scientistsTestA(galileo) == galileo, "scientistsTest A failed");
    enforce(t.scientistsTestB(galileo) == galileo, "scientistsTest B failed");
//      enforce(t.scientistsTestC(galileo) == galileo, "scientistsTest C failed");
    enforce(t.scientistsTestD(galileo) == galileo, "scientistsTest D failed");
    enforce(t.scientistsTestE(galileo) == galileo, "scientistsTest E failed");
    enforce(t.scientistsTestF(galileo) == galileo, "scientistsTest F failed");
    enforce(t.scientistsTestG(galileo) == galileo, "scientistsTest G failed");
    enforce(t.scientistsTestH(galileo) == galileo, "scientistsTest H failed");
    enforce(t.scientistsTestI(galileo) == galileo, "scientistsTest I failed");
    enforce(t.scientistsTestJ(galileo) == galileo, "scientistsTest J failed");

    enforce(scientistsTest1(galileo) == galileo, "scientistsTest Global 1 failed");
    enforce(scientistsTest2(galileo) == galileo, "scientistsTest Global 2 failed");
    enforce(scientistsTest3(galileo) == galileo, "scientistsTest Global 3 failed");
    enforce(scientistsTest4(galileo) == galileo, "scientistsTest Global 4 failed");
    enforce(scientistsTest5(galileo) == galileo, "scientistsTest Global 5 failed");
    enforce(scientistsTest6(galileo) == galileo, "scientistsTest Global 6 failed");
    enforce(scientistsTest7(galileo) == galileo, "scientistsTest Global 7 failed");
    enforce(scientistsTest8(galileo) == galileo, "scientistsTest Global 8 failed");
  }
  {
    auto t = new TClassInt();
    auto bell = TClassInt.scientists.bell;
    auto galileo = TemplateClassInt.scientists.galileo;
    enforce(t.scientistsNameTest1(bell) == bell, "scientistsNameTest 1 failed");
    enforce(t.scientistsNameTest2(bell) == bell, "scientistsNameTest 2 failed");
    enforce(t.scientistsNameTest3(bell) == bell, "scientistsNameTest 3 failed");
    enforce(t.scientistsNameTest4(bell) == bell, "scientistsNameTest 4 failed");
    enforce(t.scientistsNameTest5(bell) == bell, "scientistsNameTest 5 failed");
    enforce(t.scientistsNameTest6(bell) == bell, "scientistsNameTest 6 failed");
    enforce(t.scientistsNameTest7(bell) == bell, "scientistsNameTest 7 failed");
    enforce(t.scientistsNameTest8(bell) == bell, "scientistsNameTest 8 failed");
    enforce(t.scientistsNameTest9(bell) == bell, "scientistsNameTest 9 failed");
//      enforce(t.scientistsNameTestA(bell) == bell, "scientistsNameTest A failed");
    enforce(t.scientistsNameTestB(bell) == bell, "scientistsNameTest B failed");
//      enforce(t.scientistsNameTestC(bell) == bell, "scientistsNameTest C failed");
    enforce(t.scientistsNameTestD(bell) == bell, "scientistsNameTest D failed");
    enforce(t.scientistsNameTestE(bell) == bell, "scientistsNameTest E failed");
    enforce(t.scientistsNameTestF(bell) == bell, "scientistsNameTest F failed");
    enforce(t.scientistsNameTestG(bell) == bell, "scientistsNameTest G failed");
    enforce(t.scientistsNameTestH(bell) == bell, "scientistsNameTest H failed");
    enforce(t.scientistsNameTestI(bell) == bell, "scientistsNameTest I failed");

    enforce(t.scientistsNameSpaceTest1(bell) == bell, "scientistsNameSpaceTest 1 failed");
    enforce(t.scientistsNameSpaceTest2(bell) == bell, "scientistsNameSpaceTest 2 failed");
    enforce(t.scientistsNameSpaceTest3(bell) == bell, "scientistsNameSpaceTest 3 failed");
    enforce(t.scientistsNameSpaceTest4(bell) == bell, "scientistsNameSpaceTest 4 failed");
    enforce(t.scientistsNameSpaceTest5(bell) == bell, "scientistsNameSpaceTest 5 failed");
    enforce(t.scientistsNameSpaceTest6(bell) == bell, "scientistsNameSpaceTest 6 failed");
    enforce(t.scientistsNameSpaceTest7(bell) == bell, "scientistsNameSpaceTest 7 failed");

    enforce(t.scientistsOtherTest1(galileo) == galileo, "scientistsOtherTest 1 failed");
    enforce(t.scientistsOtherTest2(galileo) == galileo, "scientistsOtherTest 2 failed");
    enforce(t.scientistsOtherTest3(galileo) == galileo, "scientistsOtherTest 3 failed");
    enforce(t.scientistsOtherTest4(galileo) == galileo, "scientistsOtherTest 4 failed");
    enforce(t.scientistsOtherTest5(galileo) == galileo, "scientistsOtherTest 5 failed");
    enforce(t.scientistsOtherTest6(galileo) == galileo, "scientistsOtherTest 6 failed");
    enforce(t.scientistsOtherTest7(galileo) == galileo, "scientistsOtherTest 7 failed");

    enforce(scientistsNameTest1(bell) == bell, "scientistsNameTest Global 1 failed");
    enforce(scientistsNameTest2(bell) == bell, "scientistsNameTest Global 2 failed");
    enforce(scientistsNameTest3(bell) == bell, "scientistsNameTest Global 3 failed");
    enforce(scientistsNameTest4(bell) == bell, "scientistsNameTest Global 4 failed");
    enforce(scientistsNameTest5(bell) == bell, "scientistsNameTest Global 5 failed");
    enforce(scientistsNameTest6(bell) == bell, "scientistsNameTest Global 6 failed");
    enforce(scientistsNameTest7(bell) == bell, "scientistsNameTest Global 7 failed");

    enforce(scientistsNameSpaceTest1(bell) == bell, "scientistsNameSpaceTest Global 1 failed");
    enforce(scientistsNameSpaceTest2(bell) == bell, "scientistsNameSpaceTest Global 2 failed");
    enforce(scientistsNameSpaceTest3(bell) == bell, "scientistsNameSpaceTest Global 3 failed");
    enforce(scientistsNameSpaceTest4(bell) == bell, "scientistsNameSpaceTest Global 4 failed");
    enforce(scientistsNameSpaceTest5(bell) == bell, "scientistsNameSpaceTest Global 5 failed");
    enforce(scientistsNameSpaceTest6(bell) == bell, "scientistsNameSpaceTest Global 6 failed");
    enforce(scientistsNameSpaceTest7(bell) == bell, "scientistsNameSpaceTest Global 7 failed");

    enforce(scientistsNameSpaceTest8(bell) == bell, "scientistsNameSpaceTest Global 8 failed");
    enforce(scientistsNameSpaceTest9(bell) == bell, "scientistsNameSpaceTest Global 9 failed");
    enforce(scientistsNameSpaceTestA(bell) == bell, "scientistsNameSpaceTest Global A failed");
    enforce(scientistsNameSpaceTestB(bell) == bell, "scientistsNameSpaceTest Global B failed");
    enforce(scientistsNameSpaceTestC(bell) == bell, "scientistsNameSpaceTest Global C failed");
    enforce(scientistsNameSpaceTestD(bell) == bell, "scientistsNameSpaceTest Global D failed");
    enforce(scientistsNameSpaceTestE(bell) == bell, "scientistsNameSpaceTest Global E failed");

    enforce(scientistsNameSpaceTestF(bell) == bell, "scientistsNameSpaceTest Global F failed");
    enforce(scientistsNameSpaceTestG(bell) == bell, "scientistsNameSpaceTest Global G failed");
    enforce(scientistsNameSpaceTestH(bell) == bell, "scientistsNameSpaceTest Global H failed");
    enforce(scientistsNameSpaceTestI(bell) == bell, "scientistsNameSpaceTest Global I failed");
    enforce(scientistsNameSpaceTestJ(bell) == bell, "scientistsNameSpaceTest Global J failed");
    enforce(scientistsNameSpaceTestK(bell) == bell, "scientistsNameSpaceTest Global K failed");
    enforce(scientistsNameSpaceTestL(bell) == bell, "scientistsNameSpaceTest Global L failed");
  }
  {
    auto val = newname.argh;
    enforce(renameTest1(val) == val, "renameTest Global 1 failed");
    enforce(renameTest2(val) == val, "renameTest Global 2 failed");
  }
  {
    auto n = new NewNameStruct();
    enforce(n.renameTest1(NewNameStruct.enumeration.bang) == NewNameStruct.enumeration.bang, "renameTest 1 failed");
    enforce(n.renameTest2(NewNameStruct.enumeration.bang) == NewNameStruct.enumeration.bang, "renameTest 2 failed");
    enforce(n.renameTest3(NewNameStruct.simplerenamed.simple1) == NewNameStruct.simplerenamed.simple1, "renameTest 3 failed");
    enforce(n.renameTest4(NewNameStruct.doublenamerenamed.doublename1) == NewNameStruct.doublenamerenamed.doublename1, "renameTest 4 failed");
    enforce(n.renameTest5(NewNameStruct.doublenamerenamed.doublename1) == NewNameStruct.doublenamerenamed.doublename1, "renameTest 5 failed");
    enforce(n.renameTest6(NewNameStruct.singlenamerenamed.singlename1) == NewNameStruct.singlenamerenamed.singlename1, "renameTest 6 failed");
  }
  {
    enforce(renameTest3(NewNameStruct.enumeration.bang) == NewNameStruct.enumeration.bang, "renameTest Global 3 failed");
    enforce(renameTest4(NewNameStruct.simplerenamed.simple1) == NewNameStruct.simplerenamed.simple1, "renameTest Global 4 failed");
    enforce(renameTest5(NewNameStruct.doublenamerenamed.doublename1) == NewNameStruct.doublenamerenamed.doublename1, "renameTest Global 5 failed");
    enforce(renameTest6(NewNameStruct.doublenamerenamed.doublename1) == NewNameStruct.doublenamerenamed.doublename1, "renameTest Global 6 failed");
    enforce(renameTest7(NewNameStruct.singlenamerenamed.singlename1) == NewNameStruct.singlenamerenamed.singlename1, "renameTest Global 7 failed");
  }
  {
    auto t = new TreesClass();
    auto pine = TreesClass.trees.pine;

    enforce(t.treesTest1(pine) == pine, "treesTest 1 failed");
    enforce(t.treesTest2(pine) == pine, "treesTest 2 failed");
    enforce(t.treesTest3(pine) == pine, "treesTest 3 failed");
    enforce(t.treesTest4(pine) == pine, "treesTest 4 failed");
    enforce(t.treesTest5(pine) == pine, "treesTest 5 failed");
    enforce(t.treesTest6(pine) == pine, "treesTest 6 failed");
    enforce(t.treesTest7(pine) == pine, "treesTest 7 failed");
    enforce(t.treesTest8(pine) == pine, "treesTest 8 failed");
    enforce(t.treesTest9(pine) == pine, "treesTest 9 failed");
    enforce(t.treesTestA(pine) == pine, "treesTest A failed");
    enforce(t.treesTestB(pine) == pine, "treesTest B failed");
    enforce(t.treesTestC(pine) == pine, "treesTest C failed");
    enforce(t.treesTestD(pine) == pine, "treesTest D failed");
    enforce(t.treesTestE(pine) == pine, "treesTest E failed");
    enforce(t.treesTestF(pine) == pine, "treesTest F failed");
    enforce(t.treesTestG(pine) == pine, "treesTest G failed");
    enforce(t.treesTestH(pine) == pine, "treesTest H failed");
    enforce(t.treesTestI(pine) == pine, "treesTest I failed");
    enforce(t.treesTestJ(pine) == pine, "treesTest J failed");
    enforce(t.treesTestK(pine) == pine, "treesTest K failed");
    enforce(t.treesTestL(pine) == pine, "treesTest L failed");
    enforce(t.treesTestM(pine) == pine, "treesTest M failed");
    enforce(t.treesTestN(pine) == pine, "treesTest N failed");
    enforce(t.treesTestO(pine) == pine, "treesTest O failed");

    enforce(treesTest1(pine) == pine, "treesTest Global 1 failed");
    enforce(treesTest2(pine) == pine, "treesTest Global 2 failed");
    enforce(treesTest3(pine) == pine, "treesTest Global 3 failed");
    enforce(treesTest4(pine) == pine, "treesTest Global 4 failed");
    enforce(treesTest5(pine) == pine, "treesTest Global 5 failed");
    enforce(treesTest6(pine) == pine, "treesTest Global 6 failed");
    enforce(treesTest7(pine) == pine, "treesTest Global 7 failed");
    enforce(treesTest8(pine) == pine, "treesTest Global 8 failed");
    enforce(treesTest9(pine) == pine, "treesTest Global 9 failed");
    enforce(treesTestA(pine) == pine, "treesTest Global A failed");
    enforce(treesTestB(pine) == pine, "treesTest Global B failed");
    enforce(treesTestC(pine) == pine, "treesTest Global C failed");
    enforce(treesTestD(pine) == pine, "treesTest Global D failed");
    enforce(treesTestE(pine) == pine, "treesTest Global E failed");
    enforce(treesTestF(pine) == pine, "treesTest Global F failed");
    enforce(treesTestG(pine) == pine, "treesTest Global G failed");
    enforce(treesTestH(pine) == pine, "treesTest Global H failed");
    enforce(treesTestI(pine) == pine, "treesTest Global I failed");
    enforce(treesTestJ(pine) == pine, "treesTest Global J failed");
    enforce(treesTestK(pine) == pine, "treesTest Global K failed");
    enforce(treesTestL(pine) == pine, "treesTest Global L failed");
    enforce(treesTestM(pine) == pine, "treesTest Global M failed");
//      enforce(treesTestN(pine) == pine, "treesTest Global N failed");
    enforce(treesTestO(pine) == pine, "treesTest Global O failed");
    enforce(treesTestP(pine) == pine, "treesTest Global P failed");
    enforce(treesTestQ(pine) == pine, "treesTest Global Q failed");
    enforce(treesTestR(pine) == pine, "treesTest Global R failed");
  }
  {
    auto h = new HairStruct();
    auto ginger = HairStruct.hair.ginger;

    enforce(h.hairTest1(ginger) == ginger, "hairTest 1 failed");
    enforce(h.hairTest2(ginger) == ginger, "hairTest 2 failed");
    enforce(h.hairTest3(ginger) == ginger, "hairTest 3 failed");
    enforce(h.hairTest4(ginger) == ginger, "hairTest 4 failed");
    enforce(h.hairTest5(ginger) == ginger, "hairTest 5 failed");
    enforce(h.hairTest6(ginger) == ginger, "hairTest 6 failed");
    enforce(h.hairTest7(ginger) == ginger, "hairTest 7 failed");
    enforce(h.hairTest8(ginger) == ginger, "hairTest 8 failed");
    enforce(h.hairTest9(ginger) == ginger, "hairTest 9 failed");
    enforce(h.hairTestA(ginger) == ginger, "hairTest A failed");
    enforce(h.hairTestB(ginger) == ginger, "hairTest B failed");

    auto red = colour.red;
    enforce(h.colourTest1(red) == red, "colourTest HairStruct 1 failed");
    enforce(h.colourTest2(red) == red, "colourTest HairStruct 2 failed");
    enforce(h.namedanonTest1(namedanon.NamedAnon2) == namedanon.NamedAnon2, "namedanonTest HairStruct 1 failed");
    enforce(h.namedanonspaceTest1(namedanonspace.NamedAnonSpace2) == namedanonspace.NamedAnonSpace2, "namedanonspaceTest HairStruct 1 failed");

    auto fir = TreesClass.trees.fir;
    enforce(h.treesGlobalTest1(fir) == fir, "treesGlobalTest1 HairStruct 1 failed");
    enforce(h.treesGlobalTest2(fir) == fir, "treesGlobalTest1 HairStruct 2 failed");
    enforce(h.treesGlobalTest3(fir) == fir, "treesGlobalTest1 HairStruct 3 failed");
    enforce(h.treesGlobalTest4(fir) == fir, "treesGlobalTest1 HairStruct 4 failed");
  }
  {
    auto blonde = HairStruct.hair.blonde;
    enforce(hairTest1(blonde) == blonde, "hairTest Global 1 failed");
    enforce(hairTest2(blonde) == blonde, "hairTest Global 2 failed");
    enforce(hairTest3(blonde) == blonde, "hairTest Global 3 failed");
    enforce(hairTest4(blonde) == blonde, "hairTest Global 4 failed");
    enforce(hairTest5(blonde) == blonde, "hairTest Global 5 failed");
    enforce(hairTest6(blonde) == blonde, "hairTest Global 6 failed");
    enforce(hairTest7(blonde) == blonde, "hairTest Global 7 failed");
    enforce(hairTest8(blonde) == blonde, "hairTest Global 8 failed");
    enforce(hairTest9(blonde) == blonde, "hairTest Global 9 failed");
    enforce(hairTestA(blonde) == blonde, "hairTest Global A failed");
    enforce(hairTestB(blonde) == blonde, "hairTest Global B failed");
    enforce(hairTestC(blonde) == blonde, "hairTest Global C failed");

    enforce(hairTestA1(blonde) == blonde, "hairTest Global A1 failed");
    enforce(hairTestA2(blonde) == blonde, "hairTest Global A2 failed");
    enforce(hairTestA3(blonde) == blonde, "hairTest Global A3 failed");
    enforce(hairTestA4(blonde) == blonde, "hairTest Global A4 failed");
    enforce(hairTestA5(blonde) == blonde, "hairTest Global A5 failed");
    enforce(hairTestA6(blonde) == blonde, "hairTest Global A6 failed");
    enforce(hairTestA7(blonde) == blonde, "hairTest Global A7 failed");
    enforce(hairTestA8(blonde) == blonde, "hairTest Global A8 failed");
    enforce(hairTestA9(blonde) == blonde, "hairTest Global A9 failed");
    enforce(hairTestAA(blonde) == blonde, "hairTest Global AA failed");
    enforce(hairTestAB(blonde) == blonde, "hairTest Global AB failed");
    enforce(hairTestAC(blonde) == blonde, "hairTest Global AC failed");

    enforce(hairTestB1(blonde) == blonde, "hairTest Global B1 failed");
    enforce(hairTestB2(blonde) == blonde, "hairTest Global B2 failed");
    enforce(hairTestB3(blonde) == blonde, "hairTest Global B3 failed");
    enforce(hairTestB4(blonde) == blonde, "hairTest Global B4 failed");
    enforce(hairTestB5(blonde) == blonde, "hairTest Global B5 failed");
    enforce(hairTestB6(blonde) == blonde, "hairTest Global B6 failed");
    enforce(hairTestB7(blonde) == blonde, "hairTest Global B7 failed");
    enforce(hairTestB8(blonde) == blonde, "hairTest Global B8 failed");
    enforce(hairTestB9(blonde) == blonde, "hairTest Global B9 failed");
    enforce(hairTestBA(blonde) == blonde, "hairTest Global BA failed");
    enforce(hairTestBB(blonde) == blonde, "hairTest Global BB failed");
    enforce(hairTestBC(blonde) == blonde, "hairTest Global BC failed");

    enforce(hairTestC1(blonde) == blonde, "hairTest Global C1 failed");
    enforce(hairTestC2(blonde) == blonde, "hairTest Global C2 failed");
    enforce(hairTestC3(blonde) == blonde, "hairTest Global C3 failed");
    enforce(hairTestC4(blonde) == blonde, "hairTest Global C4 failed");
    enforce(hairTestC5(blonde) == blonde, "hairTest Global C5 failed");
    enforce(hairTestC6(blonde) == blonde, "hairTest Global C6 failed");
    enforce(hairTestC7(blonde) == blonde, "hairTest Global C7 failed");
    enforce(hairTestC8(blonde) == blonde, "hairTest Global C8 failed");
    enforce(hairTestC9(blonde) == blonde, "hairTest Global C9 failed");
    enforce(hairTestCA(blonde) == blonde, "hairTest Global CA failed");
    enforce(hairTestCB(blonde) == blonde, "hairTest Global CB failed");
    enforce(hairTestCC(blonde) == blonde, "hairTest Global CC failed");
  }
  {
    auto f = new FirStruct();
    auto blonde = HairStruct.hair.blonde;

    enforce(f.hairTestFir1(blonde) == blonde, "hairTestFir 1 failed");
    enforce(f.hairTestFir2(blonde) == blonde, "hairTestFir 2 failed");
    enforce(f.hairTestFir3(blonde) == blonde, "hairTestFir 3 failed");
    enforce(f.hairTestFir4(blonde) == blonde, "hairTestFir 4 failed");
    enforce(f.hairTestFir5(blonde) == blonde, "hairTestFir 5 failed");
    enforce(f.hairTestFir6(blonde) == blonde, "hairTestFir 6 failed");
    enforce(f.hairTestFir7(blonde) == blonde, "hairTestFir 7 failed");
    enforce(f.hairTestFir8(blonde) == blonde, "hairTestFir 8 failed");
    enforce(f.hairTestFir9(blonde) == blonde, "hairTestFir 9 failed");
    enforce(f.hairTestFirA(blonde) == blonde, "hairTestFir A failed");
  }
  {
    GlobalInstance = globalinstance2;
    enforce(GlobalInstance == globalinstance2, "GlobalInstance 1 failed");

    auto i = new Instances();
    i.MemberInstance = Instances.memberinstance3;
    enforce(i.MemberInstance == Instances.memberinstance3, "MemberInstance 1 failed");
  }
  // ignore enum item tests start
  {
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_zero) == 0, "ignoreATest 0 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_three) == 3, "ignoreATest 3 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_ten) == 10, "ignoreATest 10 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_eleven) == 11, "ignoreATest 11 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirteen) == 13, "ignoreATest 13 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_fourteen) == 14, "ignoreATest 14 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_twenty) == 20, "ignoreATest 20 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirty) == 30, "ignoreATest 30 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirty_two) == 32, "ignoreATest 32 failed");
    enforce(cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirty_three) == 33, "ignoreATest 33 failed");
  }
  {
    enforce(cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_eleven) == 11, "ignoreBTest 11 failed");
    enforce(cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_twelve) == 12, "ignoreBTest 12 failed");
    enforce(cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_thirty_one) == 31, "ignoreBTest 31 failed");
    enforce(cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_thirty_two) == 32, "ignoreBTest 32 failed");
    enforce(cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_forty_one) == 41, "ignoreBTest 41 failed");
    enforce(cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_forty_two) == 42, "ignoreBTest 42 failed");
  }
  {
    enforce(cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_ten), "ignoreCTest 10 failed");
    enforce(cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_twelve) == 12, "ignoreCTest 12 failed");
    enforce(cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_thirty) == 30, "ignoreCTest 30 failed");
    enforce(cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_thirty_two) == 32, "ignoreCTest 32 failed");
    enforce(cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_forty) == 40, "ignoreCTest 40 failed");
    enforce(cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_forty_two) == 42, "ignoreCTest 42 failed");
  }
  {
    enforce(cast(int)ignoreDTest(IgnoreTest.IgnoreD.ignoreD_twenty_one) == 21, "ignoreDTest 21 failed");
    enforce(cast(int)ignoreDTest(IgnoreTest.IgnoreD.ignoreD_twenty_two) == 22, "ignoreDTest 22 failed");
  }
  {
    enforce(cast(int)ignoreETest(IgnoreTest.IgnoreE.ignoreE_zero) == 0, "ignoreETest 0 failed");
    enforce(cast(int)ignoreETest(IgnoreTest.IgnoreE.ignoreE_twenty_one) == 21, "ignoreETest 21 failed");
    enforce(cast(int)ignoreETest(IgnoreTest.IgnoreE.ignoreE_twenty_two) == 22, "ignoreETest 22 failed");
  }
  // ignore enum item tests end
  {
    enforce(cast(int)repeatTest(repeat.one) == 1, "repeatTest 1 failed");
    enforce(cast(int)repeatTest(repeat.initial) == 1, "repeatTest 2 failed");
    enforce(cast(int)repeatTest(repeat.two) == 2, "repeatTest 3 failed");
    enforce(cast(int)repeatTest(repeat.three) == 3, "repeatTest 4 failed");
    enforce(cast(int)repeatTest(repeat.llast) == 3, "repeatTest 5 failed");
    enforce(cast(int)repeatTest(repeat.end) == 3, "repeatTest 6 failed");
  }
}
