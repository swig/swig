
def check(got, expected):
  #if got is Null
  #  raise RuntimeError('Expected comment string\n')
  #gotStr = string.replace(got, ' ', '')
  #gotStr = string.replace(gotStr, '\n', '')
  # gotStr = string.replace(gotStr, '\t', '')
  #expectedStr = string.replace(expected, ' ', '')
  #expectedStr = string.replace(expectedStr, '\n', '')
  #expectedStr = string.replace(expectedStr, '\t', '')

  if got == None:  # when there is no commant attached to a class or function
      got = ''

  if not got == expected:
    print("\n\n////////////////////////////////////////////////////////////////////////")

    expectedFileName = "expected.txt"
    gotFileName = "got.txt"
    print("Output is also saved to files '" + expectedFileName + \
                                   "' and '" + gotFileName + "'")

    expectedFile = open(expectedFileName, "w")
    expectedFile.write(expected)
    expectedFile.close()
    gotFile = open(gotFileName, "w")
    gotFile.write(got)
    gotFile.close()
    raise RuntimeError("Expected: [" + str(expected) + "]\n" + "Got     : [" + str(got) + "]\n")
