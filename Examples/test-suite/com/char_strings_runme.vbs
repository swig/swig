Dim CPLUSPLUS_MSG, OTHERLAND_MSG, char_strings

CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
OTHERLAND_MSG = "Little message from the safe world."

Set char_strings = CreateObject("char_strings.char_strings")

Dim count, i, str
count = 10000

Rem get functions

For i = 0 to count - 1
  str = char_strings.GetCharHeapString()
  If str <> CPLUSPLUS_MSG Then
    WScript.Echo "Test char get 1 failed, iteration " & i
    WScript.Quit 1
  End If
  char_strings.DeleteCharHeapString()
Next

For i = 0 to count - 1
  str = char_strings.GetConstCharProgramCodeString()
  If str <> CPLUSPLUS_MSG Then
    WScript.Echo "Test char get 2 failed, iteration " & i
    WScript.Quit 1
  End If
  char_strings.DeleteCharHeapString()
Next

For i = 0 to count - 1
  str = char_strings.GetCharStaticString()
  If str <> CPLUSPLUS_MSG Then
    WScript.Echo "Test char get 3 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  str = char_strings.GetCharStaticStringFixed()
  If str <> CPLUSPLUS_MSG Then
    WScript.Echo "Test char get 4 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  str = char_strings.GetConstCharStaticStringFixed()
  If str <> CPLUSPLUS_MSG Then
    WScript.Echo "Test char get 5 failed, iteration " & i
    WScript.Quit 1
  End If
Next

Rem set functions

For i = 0 to count - 1
  If char_strings.SetCharHeapString(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char set 1 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.SetCharStaticString(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char set 2 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.SetCharArrayStaticString(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char set 3 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.SetConstCharHeapString(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char set 4 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.SetConstCharStaticString(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char set 5 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.SetConstCharArrayStaticString(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char set 6 failed, iteration " & i
    WScript.Quit 1
  End If
Next

Rem get set function

Dim ping, pong

For i = 0 to count - 1
  ping = OTHERLAND_MSG & i
  pong = char_strings.CharPingPong(ping)
  If ping <> pong Then
    WScript.Echo "Test PingPong 1 failed."
    WScript.Echo "Expected:" & ping
    WScript.Echo "Reveived:" & pong
    WScript.Quit 1
  End If
Next

Rem variables

For i = 0 to count - 1
  char_strings.global_char = OTHERLAND_MSG & i
  If char_strings.global_char <> OTHERLAND_MSG & i Then
    WScript.Echo "Test variables 1 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  char_strings.global_char_array1 = OTHERLAND_MSG & i
  If char_strings.global_char_array1 <> OTHERLAND_MSG & i Then
    WScript.Echo "Test variables 2 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  char_strings.global_char_array2 = OTHERLAND_MSG & i
  If char_strings.global_char_array2 <> OTHERLAND_MSG & i Then
    WScript.Echo "Test variables 3 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.global_const_char <> CPLUSPLUS_MSG Then
    WScript.Echo "Test variables 4 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.global_const_char_array1 <> CPLUSPLUS_MSG Then
    WScript.Echo "Test variables 5 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.global_const_char_array2 <> CPLUSPLUS_MSG Then
    WScript.Echo "Test variables 6 failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  str = char_strings.GetConstCharPointerRef()
  If str <> CPLUSPLUS_MSG Then
    WScript.Echo "Test char pointer ref get failed, iteration " & i
    WScript.Quit 1
  End If
Next

For i = 0 to count - 1
  If char_strings.SetConstCharPointerRef(OTHERLAND_MSG & i, i) = 0 Then
    WScript.Echo "Test char pointer ref set failed, iteration " & i
    WScript.Quit 1
  End If
Next
