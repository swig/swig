exec("swigtest.start", -1);

testString = "Scilab test string";

if UCharFunction(testString) <> testString then swigtesterror(); end
if SCharFunction(testString) <> testString then swigtesterror(); end
if CUCharFunction(testString) <> testString then swigtesterror(); end
if CSCharFunction(testString) <> testString then swigtesterror(); end
//if CharFunction(testString) <> testString then swigtesterror(); end
//if CCharFunction(testString) <> testString then swigtesterror(); end

try
  tNumber = new_TNumber()
catch
  swigtesterror();
end
//TNumber_DigitsMemberA_get()
//TNumber_DigitsMemberA_set
//TNumber_DigitsMemberB_get()
//TNumber_DigitsMemberB_set
try
  delete_TNumber(tNumber)
catch
  swigtesterror();
end

try
  directorTest = new_DirectorTest();
catch
  swigtesterror();
end

if DirectorTest_UCharFunction(directorTest, testString) <> testString then swigtesterror(); end
if DirectorTest_SCharFunction(directorTest, testString) <> testString then swigtesterror(); end
if DirectorTest_CUCharFunction(directorTest, testString) <> testString then swigtesterror(); end
if DirectorTest_CSCharFunction(directorTest, testString) <> testString then swigtesterror(); end
//if DirectorTest_CharFunction(directorTest, testString) <> testString then swigtesterror(); end
//if DirectorTest_CCharFunction(directorTest, testString) <> testString then swigtesterror(); end
try
  delete_DirectorTest(directorTest);
catch
  swigtesterror();
end

exec("swigtest.quit", -1);
