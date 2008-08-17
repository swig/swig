Dim apply_strings, TEST_MESSAGE

Set apply_strings = CreateObject("apply_strings.apply_strings")
TEST_MESSAGE = "A message from target language to the C++ world and back again."

If apply_strings.UCharFunction(TEST_MESSAGE) <> TEST_MESSAGE Then
  WScript.Echo "UCharFunction failed"
  WScript.Quit 1
End If

If apply_strings.SCharFunction(TEST_MESSAGE) <> TEST_MESSAGE Then
  WScript.Echo "SCharFunction failed"
  WScript.Quit 1
End If

Dim pChar

Rem Will fail currently
Set pChar = apply_strings.CharFunction(null)
If pChar <> null Then
  WScript.Echo "CharFunction failed"
  WScript.Quit 1
End If

