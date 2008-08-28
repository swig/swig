Dim te, foo

Set te = CreateObject("throw_exception.throw_exception")

Set foo = te.Foo.new_Foo()

Rem On Error Resume Next

foo.test_int()

If Err.Number = 0 Then
  WScript.Echo "Exception should have been thrown"
  WScript.Quit 1
End If

If Err.Description <> "C++ int exception thrown" Then
  WScript.Echo "Incorrect exception message"
  WScript.Quit 1
End If
