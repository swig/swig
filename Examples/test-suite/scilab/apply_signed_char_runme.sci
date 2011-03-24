exec("swigtest.start", -1);

smallnum = -127;
if CharValFunction(smallnum) <> smallnum then swigtesterror(); end
if CCharValFunction(smallnum) <> smallnum then swigtesterror(); end
if CCharRefFunction(smallnum) <> smallnum then swigtesterror(); end

try
  globalchar_set(smallnum);
catch
  swigtesterror();
end
if globalchar_get() <> smallnum then swigtesterror(); end

if globalconstchar_get() <> -110 then swigtesterror(); end

try
  directorTest = new_DirectorTest();
catch
  swigtesterror();
end

if DirectorTest_CharValFunction(directorTest, smallnum) <> smallnum then swigtesterror(); end
if DirectorTest_CCharValFunction(directorTest, smallnum) <> smallnum then swigtesterror(); end
if DirectorTest_CCharRefFunction(directorTest, smallnum) <> smallnum then swigtesterror(); end

// TODO Too long identifiers
//if DirectorTest_memberchar_get(directorTest) <> -111 then swigtesterror(); end
//try
//  DirectorTest_memberchar_set(directorTest, smallnum)
//catch
//  swigtesterror();
//end
//if DirectorTest_memberchar_get(directorTest) <> smallnum then swigtesterror(); end

//if DirectorTest_memberconstchar_get(directorTest) <> -112 then swigtesterror(); end

try
  delete_DirectorTest(directorTest);
catch
  swigtesterror();
end

exec("swigtest.quit", -1);
