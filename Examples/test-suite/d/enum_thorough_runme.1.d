module enum_thorough_runme;

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
    if (ReallyAnInteger != 200) throw new Exception("Test Anon 1 failed");
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
    if (s.speedTest1(speed) != speed) throw new Exception("speedTest 1 failed");
    if (s.speedTest2(speed) != speed) throw new Exception("speedTest 2 failed");
    if (s.speedTest3(speed) != speed) throw new Exception("speedTest 3 failed");
    if (s.speedTest4(speed) != speed) throw new Exception("speedTest 4 failed");
    if (s.speedTest5(speed) != speed) throw new Exception("speedTest 5 failed");
    if (s.speedTest6(speed) != speed) throw new Exception("speedTest 6 failed");
    if (s.speedTest7(speed) != speed) throw new Exception("speedTest 7 failed");
    if (s.speedTest8(speed) != speed) throw new Exception("speedTest 8 failed");

    if (speedTest1(speed) != speed) throw new Exception("speedTest Global 1 failed");
    if (speedTest2(speed) != speed) throw new Exception("speedTest Global 2 failed");
    if (speedTest3(speed) != speed) throw new Exception("speedTest Global 3 failed");
    if (speedTest4(speed) != speed) throw new Exception("speedTest Global 4 failed");
    if (speedTest5(speed) != speed) throw new Exception("speedTest Global 5 failed");
  }
  {
    auto s = new SpeedClass();
    auto slow = SpeedClass.speed.slow;
    auto lightning = SpeedClass.speed.lightning;

    if (s.mySpeedtd1 != slow) throw new Exception("mySpeedtd1 1 failed");
    if (cast(int)s.mySpeedtd1 != 10) throw new Exception("mySpeedtd1 2 failed");

    s.mySpeedtd1 = lightning;
    if (s.mySpeedtd1 != lightning) throw new Exception("mySpeedtd1 3 failed");
    if (cast(int)s.mySpeedtd1 != 31) throw new Exception("mySpeedtd1 4 failed");
  }
  {
    if (namedanonTest1(namedanon.NamedAnon2) != namedanon.NamedAnon2) throw new Exception("namedanonTest 1 failed");
  }
  {
    auto val = twonames.TwoNames2;
    if (twonamesTest1(val) != val) throw new Exception("twonamesTest 1 failed");
    if (twonamesTest2(val) != val) throw new Exception("twonamesTest 2 failed");
    if (twonamesTest3(val) != val) throw new Exception("twonamesTest 3 failed");
  }
  {
    auto t = new TwoNamesStruct();
    auto val = TwoNamesStruct.twonames.TwoNamesStruct1;
    if (t.twonamesTest1(val) != val) throw new Exception("twonamesTest 1 failed");
    if (t.twonamesTest2(val) != val) throw new Exception("twonamesTest 2 failed");
    if (t.twonamesTest3(val) != val) throw new Exception("twonamesTest 3 failed");
  }
  {
    auto val = namedanonspace.NamedAnonSpace2;
    if (namedanonspaceTest1(val) != val) throw new Exception("namedanonspaceTest 1 failed");
    if (namedanonspaceTest2(val) != val) throw new Exception("namedanonspaceTest 2 failed");
    if (namedanonspaceTest3(val) != val) throw new Exception("namedanonspaceTest 3 failed");
    if (namedanonspaceTest4(val) != val) throw new Exception("namedanonspaceTest 4 failed");
  }
  {
    auto t = new TemplateClassInt();
    auto galileo = TemplateClassInt.scientists.galileo;
    if (t.scientistsTest1(galileo) != galileo) throw new Exception("scientistsTest 1 failed");
    if (t.scientistsTest2(galileo) != galileo) throw new Exception("scientistsTest 2 failed");
    if (t.scientistsTest3(galileo) != galileo) throw new Exception("scientistsTest 3 failed");
    if (t.scientistsTest4(galileo) != galileo) throw new Exception("scientistsTest 4 failed");
    if (t.scientistsTest5(galileo) != galileo) throw new Exception("scientistsTest 5 failed");
    if (t.scientistsTest6(galileo) != galileo) throw new Exception("scientistsTest 6 failed");
    if (t.scientistsTest7(galileo) != galileo) throw new Exception("scientistsTest 7 failed");
    if (t.scientistsTest8(galileo) != galileo) throw new Exception("scientistsTest 8 failed");
    if (t.scientistsTest9(galileo) != galileo) throw new Exception("scientistsTest 9 failed");
//      if (t.scientistsTestA(galileo) != galileo) throw new Exception("scientistsTest A failed");
    if (t.scientistsTestB(galileo) != galileo) throw new Exception("scientistsTest B failed");
//      if (t.scientistsTestC(galileo) != galileo) throw new Exception("scientistsTest C failed");
    if (t.scientistsTestD(galileo) != galileo) throw new Exception("scientistsTest D failed");
    if (t.scientistsTestE(galileo) != galileo) throw new Exception("scientistsTest E failed");
    if (t.scientistsTestF(galileo) != galileo) throw new Exception("scientistsTest F failed");
    if (t.scientistsTestG(galileo) != galileo) throw new Exception("scientistsTest G failed");
    if (t.scientistsTestH(galileo) != galileo) throw new Exception("scientistsTest H failed");
    if (t.scientistsTestI(galileo) != galileo) throw new Exception("scientistsTest I failed");
    if (t.scientistsTestJ(galileo) != galileo) throw new Exception("scientistsTest J failed");

    if (scientistsTest1(galileo) != galileo) throw new Exception("scientistsTest Global 1 failed");
    if (scientistsTest2(galileo) != galileo) throw new Exception("scientistsTest Global 2 failed");
    if (scientistsTest3(galileo) != galileo) throw new Exception("scientistsTest Global 3 failed");
    if (scientistsTest4(galileo) != galileo) throw new Exception("scientistsTest Global 4 failed");
    if (scientistsTest5(galileo) != galileo) throw new Exception("scientistsTest Global 5 failed");
    if (scientistsTest6(galileo) != galileo) throw new Exception("scientistsTest Global 6 failed");
    if (scientistsTest7(galileo) != galileo) throw new Exception("scientistsTest Global 7 failed");
    if (scientistsTest8(galileo) != galileo) throw new Exception("scientistsTest Global 8 failed");
  }
  {
    auto t = new TClassInt();
    auto bell = TClassInt.scientists.bell;
    auto galileo = TemplateClassInt.scientists.galileo;
    if (t.scientistsNameTest1(bell) != bell) throw new Exception("scientistsNameTest 1 failed");
    if (t.scientistsNameTest2(bell) != bell) throw new Exception("scientistsNameTest 2 failed");
    if (t.scientistsNameTest3(bell) != bell) throw new Exception("scientistsNameTest 3 failed");
    if (t.scientistsNameTest4(bell) != bell) throw new Exception("scientistsNameTest 4 failed");
    if (t.scientistsNameTest5(bell) != bell) throw new Exception("scientistsNameTest 5 failed");
    if (t.scientistsNameTest6(bell) != bell) throw new Exception("scientistsNameTest 6 failed");
    if (t.scientistsNameTest7(bell) != bell) throw new Exception("scientistsNameTest 7 failed");
    if (t.scientistsNameTest8(bell) != bell) throw new Exception("scientistsNameTest 8 failed");
    if (t.scientistsNameTest9(bell) != bell) throw new Exception("scientistsNameTest 9 failed");
//      if (t.scientistsNameTestA(bell) != bell) throw new Exception("scientistsNameTest A failed");
    if (t.scientistsNameTestB(bell) != bell) throw new Exception("scientistsNameTest B failed");
//      if (t.scientistsNameTestC(bell) != bell) throw new Exception("scientistsNameTest C failed");
    if (t.scientistsNameTestD(bell) != bell) throw new Exception("scientistsNameTest D failed");
    if (t.scientistsNameTestE(bell) != bell) throw new Exception("scientistsNameTest E failed");
    if (t.scientistsNameTestF(bell) != bell) throw new Exception("scientistsNameTest F failed");
    if (t.scientistsNameTestG(bell) != bell) throw new Exception("scientistsNameTest G failed");
    if (t.scientistsNameTestH(bell) != bell) throw new Exception("scientistsNameTest H failed");
    if (t.scientistsNameTestI(bell) != bell) throw new Exception("scientistsNameTest I failed");

    if (t.scientistsNameSpaceTest1(bell) != bell) throw new Exception("scientistsNameSpaceTest 1 failed");
    if (t.scientistsNameSpaceTest2(bell) != bell) throw new Exception("scientistsNameSpaceTest 2 failed");
    if (t.scientistsNameSpaceTest3(bell) != bell) throw new Exception("scientistsNameSpaceTest 3 failed");
    if (t.scientistsNameSpaceTest4(bell) != bell) throw new Exception("scientistsNameSpaceTest 4 failed");
    if (t.scientistsNameSpaceTest5(bell) != bell) throw new Exception("scientistsNameSpaceTest 5 failed");
    if (t.scientistsNameSpaceTest6(bell) != bell) throw new Exception("scientistsNameSpaceTest 6 failed");
    if (t.scientistsNameSpaceTest7(bell) != bell) throw new Exception("scientistsNameSpaceTest 7 failed");

    if (t.scientistsOtherTest1(galileo) != galileo) throw new Exception("scientistsOtherTest 1 failed");
    if (t.scientistsOtherTest2(galileo) != galileo) throw new Exception("scientistsOtherTest 2 failed");
    if (t.scientistsOtherTest3(galileo) != galileo) throw new Exception("scientistsOtherTest 3 failed");
    if (t.scientistsOtherTest4(galileo) != galileo) throw new Exception("scientistsOtherTest 4 failed");
    if (t.scientistsOtherTest5(galileo) != galileo) throw new Exception("scientistsOtherTest 5 failed");
    if (t.scientistsOtherTest6(galileo) != galileo) throw new Exception("scientistsOtherTest 6 failed");
    if (t.scientistsOtherTest7(galileo) != galileo) throw new Exception("scientistsOtherTest 7 failed");

    if (scientistsNameTest1(bell) != bell) throw new Exception("scientistsNameTest Global 1 failed");
    if (scientistsNameTest2(bell) != bell) throw new Exception("scientistsNameTest Global 2 failed");
    if (scientistsNameTest3(bell) != bell) throw new Exception("scientistsNameTest Global 3 failed");
    if (scientistsNameTest4(bell) != bell) throw new Exception("scientistsNameTest Global 4 failed");
    if (scientistsNameTest5(bell) != bell) throw new Exception("scientistsNameTest Global 5 failed");
    if (scientistsNameTest6(bell) != bell) throw new Exception("scientistsNameTest Global 6 failed");
    if (scientistsNameTest7(bell) != bell) throw new Exception("scientistsNameTest Global 7 failed");

    if (scientistsNameSpaceTest1(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 1 failed");
    if (scientistsNameSpaceTest2(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 2 failed");
    if (scientistsNameSpaceTest3(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 3 failed");
    if (scientistsNameSpaceTest4(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 4 failed");
    if (scientistsNameSpaceTest5(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 5 failed");
    if (scientistsNameSpaceTest6(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 6 failed");
    if (scientistsNameSpaceTest7(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 7 failed");

    if (scientistsNameSpaceTest8(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 8 failed");
    if (scientistsNameSpaceTest9(bell) != bell) throw new Exception("scientistsNameSpaceTest Global 9 failed");
    if (scientistsNameSpaceTestA(bell) != bell) throw new Exception("scientistsNameSpaceTest Global A failed");
    if (scientistsNameSpaceTestB(bell) != bell) throw new Exception("scientistsNameSpaceTest Global B failed");
    if (scientistsNameSpaceTestC(bell) != bell) throw new Exception("scientistsNameSpaceTest Global C failed");
    if (scientistsNameSpaceTestD(bell) != bell) throw new Exception("scientistsNameSpaceTest Global D failed");
    if (scientistsNameSpaceTestE(bell) != bell) throw new Exception("scientistsNameSpaceTest Global E failed");

    if (scientistsNameSpaceTestF(bell) != bell) throw new Exception("scientistsNameSpaceTest Global F failed");
    if (scientistsNameSpaceTestG(bell) != bell) throw new Exception("scientistsNameSpaceTest Global G failed");
    if (scientistsNameSpaceTestH(bell) != bell) throw new Exception("scientistsNameSpaceTest Global H failed");
    if (scientistsNameSpaceTestI(bell) != bell) throw new Exception("scientistsNameSpaceTest Global I failed");
    if (scientistsNameSpaceTestJ(bell) != bell) throw new Exception("scientistsNameSpaceTest Global J failed");
    if (scientistsNameSpaceTestK(bell) != bell) throw new Exception("scientistsNameSpaceTest Global K failed");
    if (scientistsNameSpaceTestL(bell) != bell) throw new Exception("scientistsNameSpaceTest Global L failed");
  }
  {
    auto val = newname.argh;
    if (renameTest1(val) != val) throw new Exception("renameTest Global 1 failed");
    if (renameTest2(val) != val) throw new Exception("renameTest Global 2 failed");
  }
  {
    auto n = new NewNameStruct();
    if (n.renameTest1(NewNameStruct.enumeration.bang) != NewNameStruct.enumeration.bang) throw new Exception("renameTest 1 failed");
    if (n.renameTest2(NewNameStruct.enumeration.bang) != NewNameStruct.enumeration.bang) throw new Exception("renameTest 2 failed");
    if (n.renameTest3(NewNameStruct.simplerenamed.simple1) != NewNameStruct.simplerenamed.simple1) throw new Exception("renameTest 3 failed");
    if (n.renameTest4(NewNameStruct.doublenamerenamed.doublename1) != NewNameStruct.doublenamerenamed.doublename1) throw new Exception("renameTest 4 failed");
    if (n.renameTest5(NewNameStruct.doublenamerenamed.doublename1) != NewNameStruct.doublenamerenamed.doublename1) throw new Exception("renameTest 5 failed");
    if (n.renameTest6(NewNameStruct.singlenamerenamed.singlename1) != NewNameStruct.singlenamerenamed.singlename1) throw new Exception("renameTest 6 failed");
  }
  {
    if (renameTest3(NewNameStruct.enumeration.bang) != NewNameStruct.enumeration.bang) throw new Exception("renameTest Global 3 failed");
    if (renameTest4(NewNameStruct.simplerenamed.simple1) != NewNameStruct.simplerenamed.simple1) throw new Exception("renameTest Global 4 failed");
    if (renameTest5(NewNameStruct.doublenamerenamed.doublename1) != NewNameStruct.doublenamerenamed.doublename1) throw new Exception("renameTest Global 5 failed");
    if (renameTest6(NewNameStruct.doublenamerenamed.doublename1) != NewNameStruct.doublenamerenamed.doublename1) throw new Exception("renameTest Global 6 failed");
    if (renameTest7(NewNameStruct.singlenamerenamed.singlename1) != NewNameStruct.singlenamerenamed.singlename1) throw new Exception("renameTest Global 7 failed");
  }
  {
    auto t = new TreesClass();
    auto pine = TreesClass.trees.pine;

    if (t.treesTest1(pine) != pine) throw new Exception("treesTest 1 failed");
    if (t.treesTest2(pine) != pine) throw new Exception("treesTest 2 failed");
    if (t.treesTest3(pine) != pine) throw new Exception("treesTest 3 failed");
    if (t.treesTest4(pine) != pine) throw new Exception("treesTest 4 failed");
    if (t.treesTest5(pine) != pine) throw new Exception("treesTest 5 failed");
    if (t.treesTest6(pine) != pine) throw new Exception("treesTest 6 failed");
    if (t.treesTest7(pine) != pine) throw new Exception("treesTest 7 failed");
    if (t.treesTest8(pine) != pine) throw new Exception("treesTest 8 failed");
    if (t.treesTest9(pine) != pine) throw new Exception("treesTest 9 failed");
    if (t.treesTestA(pine) != pine) throw new Exception("treesTest A failed");
    if (t.treesTestB(pine) != pine) throw new Exception("treesTest B failed");
    if (t.treesTestC(pine) != pine) throw new Exception("treesTest C failed");
    if (t.treesTestD(pine) != pine) throw new Exception("treesTest D failed");
    if (t.treesTestE(pine) != pine) throw new Exception("treesTest E failed");
    if (t.treesTestF(pine) != pine) throw new Exception("treesTest F failed");
    if (t.treesTestG(pine) != pine) throw new Exception("treesTest G failed");
    if (t.treesTestH(pine) != pine) throw new Exception("treesTest H failed");
    if (t.treesTestI(pine) != pine) throw new Exception("treesTest I failed");
    if (t.treesTestJ(pine) != pine) throw new Exception("treesTest J failed");
    if (t.treesTestK(pine) != pine) throw new Exception("treesTest K failed");
    if (t.treesTestL(pine) != pine) throw new Exception("treesTest L failed");
    if (t.treesTestM(pine) != pine) throw new Exception("treesTest M failed");
    if (t.treesTestN(pine) != pine) throw new Exception("treesTest N failed");
    if (t.treesTestO(pine) != pine) throw new Exception("treesTest O failed");

    if (treesTest1(pine) != pine) throw new Exception("treesTest Global 1 failed");
    if (treesTest2(pine) != pine) throw new Exception("treesTest Global 2 failed");
    if (treesTest3(pine) != pine) throw new Exception("treesTest Global 3 failed");
    if (treesTest4(pine) != pine) throw new Exception("treesTest Global 4 failed");
    if (treesTest5(pine) != pine) throw new Exception("treesTest Global 5 failed");
    if (treesTest6(pine) != pine) throw new Exception("treesTest Global 6 failed");
    if (treesTest7(pine) != pine) throw new Exception("treesTest Global 7 failed");
    if (treesTest8(pine) != pine) throw new Exception("treesTest Global 8 failed");
    if (treesTest9(pine) != pine) throw new Exception("treesTest Global 9 failed");
    if (treesTestA(pine) != pine) throw new Exception("treesTest Global A failed");
    if (treesTestB(pine) != pine) throw new Exception("treesTest Global B failed");
    if (treesTestC(pine) != pine) throw new Exception("treesTest Global C failed");
    if (treesTestD(pine) != pine) throw new Exception("treesTest Global D failed");
    if (treesTestE(pine) != pine) throw new Exception("treesTest Global E failed");
    if (treesTestF(pine) != pine) throw new Exception("treesTest Global F failed");
    if (treesTestG(pine) != pine) throw new Exception("treesTest Global G failed");
    if (treesTestH(pine) != pine) throw new Exception("treesTest Global H failed");
    if (treesTestI(pine) != pine) throw new Exception("treesTest Global I failed");
    if (treesTestJ(pine) != pine) throw new Exception("treesTest Global J failed");
    if (treesTestK(pine) != pine) throw new Exception("treesTest Global K failed");
    if (treesTestL(pine) != pine) throw new Exception("treesTest Global L failed");
    if (treesTestM(pine) != pine) throw new Exception("treesTest Global M failed");
//      if (treesTestN(pine) != pine) throw new Exception("treesTest Global N failed");
    if (treesTestO(pine) != pine) throw new Exception("treesTest Global O failed");
    if (treesTestP(pine) != pine) throw new Exception("treesTest Global P failed");
    if (treesTestQ(pine) != pine) throw new Exception("treesTest Global Q failed");
    if (treesTestR(pine) != pine) throw new Exception("treesTest Global R failed");
  }
  {
    auto h = new HairStruct();
    auto ginger = HairStruct.hair.ginger;

    if (h.hairTest1(ginger) != ginger) throw new Exception("hairTest 1 failed");
    if (h.hairTest2(ginger) != ginger) throw new Exception("hairTest 2 failed");
    if (h.hairTest3(ginger) != ginger) throw new Exception("hairTest 3 failed");
    if (h.hairTest4(ginger) != ginger) throw new Exception("hairTest 4 failed");
    if (h.hairTest5(ginger) != ginger) throw new Exception("hairTest 5 failed");
    if (h.hairTest6(ginger) != ginger) throw new Exception("hairTest 6 failed");
    if (h.hairTest7(ginger) != ginger) throw new Exception("hairTest 7 failed");
    if (h.hairTest8(ginger) != ginger) throw new Exception("hairTest 8 failed");
    if (h.hairTest9(ginger) != ginger) throw new Exception("hairTest 9 failed");
    if (h.hairTestA(ginger) != ginger) throw new Exception("hairTest A failed");
    if (h.hairTestB(ginger) != ginger) throw new Exception("hairTest B failed");

    auto red = colour.red;
    if (h.colourTest1(red) != red) throw new Exception("colourTest HairStruct 1 failed");
    if (h.colourTest2(red) != red) throw new Exception("colourTest HairStruct 2 failed");
    if (h.namedanonTest1(namedanon.NamedAnon2) != namedanon.NamedAnon2) throw new Exception("namedanonTest HairStruct 1 failed");
    if (h.namedanonspaceTest1(namedanonspace.NamedAnonSpace2) != namedanonspace.NamedAnonSpace2) throw new Exception("namedanonspaceTest HairStruct 1 failed");

    auto fir = TreesClass.trees.fir;
    if (h.treesGlobalTest1(fir) != fir) throw new Exception("treesGlobalTest1 HairStruct 1 failed");
    if (h.treesGlobalTest2(fir) != fir) throw new Exception("treesGlobalTest1 HairStruct 2 failed");
    if (h.treesGlobalTest3(fir) != fir) throw new Exception("treesGlobalTest1 HairStruct 3 failed");
    if (h.treesGlobalTest4(fir) != fir) throw new Exception("treesGlobalTest1 HairStruct 4 failed");
  }
  {
    auto blonde = HairStruct.hair.blonde;
    if (hairTest1(blonde) != blonde) throw new Exception("hairTest Global 1 failed");
    if (hairTest2(blonde) != blonde) throw new Exception("hairTest Global 2 failed");
    if (hairTest3(blonde) != blonde) throw new Exception("hairTest Global 3 failed");
    if (hairTest4(blonde) != blonde) throw new Exception("hairTest Global 4 failed");
    if (hairTest5(blonde) != blonde) throw new Exception("hairTest Global 5 failed");
    if (hairTest6(blonde) != blonde) throw new Exception("hairTest Global 6 failed");
    if (hairTest7(blonde) != blonde) throw new Exception("hairTest Global 7 failed");
    if (hairTest8(blonde) != blonde) throw new Exception("hairTest Global 8 failed");
    if (hairTest9(blonde) != blonde) throw new Exception("hairTest Global 9 failed");
    if (hairTestA(blonde) != blonde) throw new Exception("hairTest Global A failed");
    if (hairTestB(blonde) != blonde) throw new Exception("hairTest Global B failed");
    if (hairTestC(blonde) != blonde) throw new Exception("hairTest Global C failed");

    if (hairTestA1(blonde) != blonde) throw new Exception("hairTest Global A1 failed");
    if (hairTestA2(blonde) != blonde) throw new Exception("hairTest Global A2 failed");
    if (hairTestA3(blonde) != blonde) throw new Exception("hairTest Global A3 failed");
    if (hairTestA4(blonde) != blonde) throw new Exception("hairTest Global A4 failed");
    if (hairTestA5(blonde) != blonde) throw new Exception("hairTest Global A5 failed");
    if (hairTestA6(blonde) != blonde) throw new Exception("hairTest Global A6 failed");
    if (hairTestA7(blonde) != blonde) throw new Exception("hairTest Global A7 failed");
    if (hairTestA8(blonde) != blonde) throw new Exception("hairTest Global A8 failed");
    if (hairTestA9(blonde) != blonde) throw new Exception("hairTest Global A9 failed");
    if (hairTestAA(blonde) != blonde) throw new Exception("hairTest Global AA failed");
    if (hairTestAB(blonde) != blonde) throw new Exception("hairTest Global AB failed");
    if (hairTestAC(blonde) != blonde) throw new Exception("hairTest Global AC failed");

    if (hairTestB1(blonde) != blonde) throw new Exception("hairTest Global B1 failed");
    if (hairTestB2(blonde) != blonde) throw new Exception("hairTest Global B2 failed");
    if (hairTestB3(blonde) != blonde) throw new Exception("hairTest Global B3 failed");
    if (hairTestB4(blonde) != blonde) throw new Exception("hairTest Global B4 failed");
    if (hairTestB5(blonde) != blonde) throw new Exception("hairTest Global B5 failed");
    if (hairTestB6(blonde) != blonde) throw new Exception("hairTest Global B6 failed");
    if (hairTestB7(blonde) != blonde) throw new Exception("hairTest Global B7 failed");
    if (hairTestB8(blonde) != blonde) throw new Exception("hairTest Global B8 failed");
    if (hairTestB9(blonde) != blonde) throw new Exception("hairTest Global B9 failed");
    if (hairTestBA(blonde) != blonde) throw new Exception("hairTest Global BA failed");
    if (hairTestBB(blonde) != blonde) throw new Exception("hairTest Global BB failed");
    if (hairTestBC(blonde) != blonde) throw new Exception("hairTest Global BC failed");

    if (hairTestC1(blonde) != blonde) throw new Exception("hairTest Global C1 failed");
    if (hairTestC2(blonde) != blonde) throw new Exception("hairTest Global C2 failed");
    if (hairTestC3(blonde) != blonde) throw new Exception("hairTest Global C3 failed");
    if (hairTestC4(blonde) != blonde) throw new Exception("hairTest Global C4 failed");
    if (hairTestC5(blonde) != blonde) throw new Exception("hairTest Global C5 failed");
    if (hairTestC6(blonde) != blonde) throw new Exception("hairTest Global C6 failed");
    if (hairTestC7(blonde) != blonde) throw new Exception("hairTest Global C7 failed");
    if (hairTestC8(blonde) != blonde) throw new Exception("hairTest Global C8 failed");
    if (hairTestC9(blonde) != blonde) throw new Exception("hairTest Global C9 failed");
    if (hairTestCA(blonde) != blonde) throw new Exception("hairTest Global CA failed");
    if (hairTestCB(blonde) != blonde) throw new Exception("hairTest Global CB failed");
    if (hairTestCC(blonde) != blonde) throw new Exception("hairTest Global CC failed");
  }
  {
    auto f = new FirStruct();
    auto blonde = HairStruct.hair.blonde;

    if (f.hairTestFir1(blonde) != blonde) throw new Exception("hairTestFir 1 failed");
    if (f.hairTestFir2(blonde) != blonde) throw new Exception("hairTestFir 2 failed");
    if (f.hairTestFir3(blonde) != blonde) throw new Exception("hairTestFir 3 failed");
    if (f.hairTestFir4(blonde) != blonde) throw new Exception("hairTestFir 4 failed");
    if (f.hairTestFir5(blonde) != blonde) throw new Exception("hairTestFir 5 failed");
    if (f.hairTestFir6(blonde) != blonde) throw new Exception("hairTestFir 6 failed");
    if (f.hairTestFir7(blonde) != blonde) throw new Exception("hairTestFir 7 failed");
    if (f.hairTestFir8(blonde) != blonde) throw new Exception("hairTestFir 8 failed");
    if (f.hairTestFir9(blonde) != blonde) throw new Exception("hairTestFir 9 failed");
    if (f.hairTestFirA(blonde) != blonde) throw new Exception("hairTestFir A failed");
  }
  {
    GlobalInstance = globalinstance2;
    if (GlobalInstance != globalinstance2) throw new Exception("GlobalInstance 1 failed");

    auto i = new Instances();
    i.MemberInstance = Instances.memberinstance3;
    if (i.MemberInstance != Instances.memberinstance3) throw new Exception("MemberInstance 1 failed");
  }
  // ignore enum item tests start
  {
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_zero) != 0) throw new Exception("ignoreATest 0 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_three) != 3) throw new Exception("ignoreATest 3 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_ten) != 10) throw new Exception("ignoreATest 10 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_eleven) != 11) throw new Exception("ignoreATest 11 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirteen) != 13) throw new Exception("ignoreATest 13 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_fourteen) != 14) throw new Exception("ignoreATest 14 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_twenty) != 20) throw new Exception("ignoreATest 20 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirty) != 30) throw new Exception("ignoreATest 30 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirty_two) != 32) throw new Exception("ignoreATest 32 failed");
    if (cast(int)ignoreATest(IgnoreTest.IgnoreA.ignoreA_thirty_three) != 33) throw new Exception("ignoreATest 33 failed");
  }
  {
    if (cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_eleven) != 11) throw new Exception("ignoreBTest 11 failed");
    if (cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_twelve) != 12) throw new Exception("ignoreBTest 12 failed");
    if (cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_thirty_one) != 31) throw new Exception("ignoreBTest 31 failed");
    if (cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_thirty_two) != 32) throw new Exception("ignoreBTest 32 failed");
    if (cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_forty_one) != 41) throw new Exception("ignoreBTest 41 failed");
    if (cast(int)ignoreBTest(IgnoreTest.IgnoreB.ignoreB_forty_two) != 42) throw new Exception("ignoreBTest 42 failed");
  }
  {
    if (cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_ten) != 10) throw new Exception("ignoreCTest 10 failed");
    if (cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_twelve) != 12) throw new Exception("ignoreCTest 12 failed");
    if (cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_thirty) != 30) throw new Exception("ignoreCTest 30 failed");
    if (cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_thirty_two) != 32) throw new Exception("ignoreCTest 32 failed");
    if (cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_forty) != 40) throw new Exception("ignoreCTest 40 failed");
    if (cast(int)ignoreCTest(IgnoreTest.IgnoreC.ignoreC_forty_two) != 42) throw new Exception("ignoreCTest 42 failed");
  }
  {
    if (cast(int)ignoreDTest(IgnoreTest.IgnoreD.ignoreD_twenty_one) != 21) throw new Exception("ignoreDTest 21 failed");
    if (cast(int)ignoreDTest(IgnoreTest.IgnoreD.ignoreD_twenty_two) != 22) throw new Exception("ignoreDTest 22 failed");
  }
  {
    if (cast(int)ignoreETest(IgnoreTest.IgnoreE.ignoreE_zero) != 0) throw new Exception("ignoreETest 0 failed");
    if (cast(int)ignoreETest(IgnoreTest.IgnoreE.ignoreE_twenty_one) != 21) throw new Exception("ignoreETest 21 failed");
    if (cast(int)ignoreETest(IgnoreTest.IgnoreE.ignoreE_twenty_two) != 22) throw new Exception("ignoreETest 22 failed");
  }
  // ignore enum item tests end
  {
    if (cast(int)repeatTest(repeat.one) != 1) throw new Exception("repeatTest 1 failed");
    if (cast(int)repeatTest(repeat.initial) != 1) throw new Exception("repeatTest 2 failed");
    if (cast(int)repeatTest(repeat.two) != 2) throw new Exception("repeatTest 3 failed");
    if (cast(int)repeatTest(repeat.three) != 3) throw new Exception("repeatTest 4 failed");
    if (cast(int)repeatTest(repeat.llast) != 3) throw new Exception("repeatTest 5 failed");
    if (cast(int)repeatTest(repeat.end) != 3) throw new Exception("repeatTest 6 failed");
  }
}
