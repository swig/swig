Dim constover, p, f

Set constover = CreateObject("constover.constover")

p = constover.test("test")
If p <> "test" Then
  WScript.Echo "test failed!"
  WScript.Quit 1
End If

p = constover.test_pconst("test")
If p <> "test_pconst" Then
  WScript.Echo "test_pconst failed!"
  WScript.Quit 1
End If

Set f = CreateObject("constover.Foo")

p = f.test("test")
If p <> "test" Then
  WScript.Echo "member-test failed!"
  WScript.Quit 1
End If

p = f.test_pconst("test")
If p <> "test_pconst" Then
  WScript.Echo "member-test_pconst failed!"
  WScript.Quit 1
End If

p = f.test_constm("test")
If p <> "test_constmethod" Then
  WScript.Echo "member-test_constm failed!"
  WScript.Quit 1
End If

p = f.test_pconstm("test")
If p <> "test_pconstmethod" Then
  WScript.Echo "member-test_pconstm failed!"
  WScript.Quit 1
End If

