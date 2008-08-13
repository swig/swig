Dim vp

Set vp = WScript.CreateObject("virtual_poly.virtual_poly")

Dim d, i
Set d = vp.NDouble.new_NDouble(3.5)
Set i = vp.NInt.new_NInt(2)


Rem We are using IDispatch/OLE Automation - no downcast should be needed
Rem for covariant functions

Dim dc, ic
Set dc = d.copy()
Set ic = i.copy()

Dim ddc, dic
Set ddc = vp.NDouble.narrow(dc)
Set dic = vp.NInt.narrow(ic)


Rem This fails, probably due to a bug in memory management code
Set dc = ddc
Set ic = dic

vp.incr(dic)

If (i.get() + 1) <> ic.get() Then
  WScript.Echo "incr test failed"
  WScript.Quit(1)
End If


Rem Checking a pure user downcast

Dim n1, n2, dn1, dn2
Set n1 = d.copy()
Set n2 = d.nnumber()
Set dn1 = vp.NDouble.narrow(n1)
Set dn2 = vp.NDouble.narrow(n2)

If dn1.get() <> dn2.get() Then
  WScript.Echo "copy/narrow test failed"
  WScript.Quit(1)
End If


Rem Checking the ref polymorphic case

Dim nr, dr1, dr2
Set nr = d.ref_this()
Set dr1 = vp.NDouble.narrow(nr)
Set dr2 = d.ref_this()

If dr1.get() <> dr2.get() Then
  WScript.Echo "copy/narrow test failed"
  WScript.Quit(1)
End If

