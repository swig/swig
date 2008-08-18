Dim dc

Set dc = CreateObject("default_constructor.default_constructor")

Dim obj, res

res = 0

Rem This should work

Set obj = dc.A.new_A()
obj = empty

Set obj = dc.AA.new_AA()
obj = empty

Set obj = dc.CC.new_CC()
obj = empty

Set obj = dc.EE.new_EE()
obj = empty

Set obj = dc.F.new_F()
obj = empty

Set obj = dc.FFF.new_FFF()
obj = empty

Set obj = dc.G.new_G()
obj = empty

Set obj = dc.GG.new_GG()
obj = empty

Set obj = dc.HH.new_HH(1,1)
obj = empty

Rem These cases should not work

On Error Resume Next

Set obj = dc.B.new_B()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_B created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.BB.new_BB()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_BB created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.C.new_C()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_C created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.D.new_D()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_D created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.DD.new_DD()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_DD created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.AD.new_AD()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_AD created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.E.new_E()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_E created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = dc.EB.new_EB()
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_EB created."
  res = 1
End If
obj = empty
Err.Clear

Rem Now let's test the alternate construction method (CreateObject)

On Error Goto 0

Rem This should work

Set obj = CreateObject("default_constructor.A")
obj = empty

Set obj = CreateObject("default_constructor.AA")
obj = empty

Set obj = CreateObject("default_constructor.CC")
obj = empty

Set obj = CreateObject("default_constructor.EE")
obj = empty

Set obj = CreateObject("default_constructor.F")
obj = empty

Set obj = CreateObject("default_constructor.FFF")
obj = empty

Set obj = CreateObject("default_constructor.G")
obj = empty

Set obj = CreateObject("default_constructor.GG")
obj = empty

Rem These cases should not work

On Error Resume Next

Set obj = CreateObject("default_constructor.B")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_B created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.BB")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_BB created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.C")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_C created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.D")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_D created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.DD")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_DD created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.AD")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_AD created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.E")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_E created."
  res = 1
End If
obj = empty
Err.Clear

Set obj = CreateObject("default_constructor.EB")
If Err.Number = 0 Then
  WScript.Echo "Whoa. new_EB created."
  res = 1
End If
obj = empty
Err.Clear

WScript.Quit res
