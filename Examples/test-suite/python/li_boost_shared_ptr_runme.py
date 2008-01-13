import li_boost_shared_ptr
import gc

debug = False

# simple shared_ptr usage - created in C++
class li_boost_shared_ptr_runme:
  def main(self):
    if (debug):
      System.out.println("Started")

    li_boost_shared_ptr.debug_shared = debug

    # Change loop count to run for a long time to monitor memory
    loopCount = 1 #5000
    for i in range (0,loopCount):
      self.runtest()

    if (li_boost_shared_ptr.Klass.getTotal_count() != 0):
      raise RuntimeError("Klass.total_count=", li_boost_shared_ptr.Klass.getTotal_count())

    wrapper_count = li_boost_shared_ptr.shared_ptr_wrapper_count() 
    if (wrapper_count != li_boost_shared_ptr.NOT_COUNTING):
      if (wrapper_count != 0):
        raise RuntimeError("shared_ptr wrapper count not zero: ", wrapper_count)

    if (debug):
      System.out.println("Finished")

  def runtest(self):
    # simple shared_ptr usage - created in C++
    k = li_boost_shared_ptr.Klass("me oh my")
    val = k.getValue()
    self.verifyValue("me oh my", val)
    self.verifyCount(1, k)

    # simple shared_ptr usage - not created in C++
    k = li_boost_shared_ptr.factorycreate()
    val = k.getValue()
    self.verifyValue("factorycreate", val)
    self.verifyCount(1, k)

    # pass by shared_ptr
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointertest(k)
    val = kret.getValue()
    self.verifyValue("me oh my smartpointertest", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # pass by shared_ptr pointer
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointerpointertest(k)
    val = kret.getValue()
    self.verifyValue("me oh my smartpointerpointertest", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # pass by shared_ptr reference
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointerreftest(k)
    val = kret.getValue()
    self.verifyValue("me oh my smartpointerreftest", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # pass by shared_ptr pointer reference
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointerpointerreftest(k)
    val = kret.getValue()
    self.verifyValue("me oh my smartpointerpointerreftest", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # const pass by shared_ptr
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.constsmartpointertest(k)
    val = kret.getValue()
    self.verifyValue("me oh my", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # const pass by shared_ptr pointer
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.constsmartpointerpointertest(k)
    val = kret.getValue()
    self.verifyValue("me oh my", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # const pass by shared_ptr reference
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.constsmartpointerreftest(k)
    val = kret.getValue()
    self.verifyValue("me oh my", val)
    self.verifyCount(2, k)
    self.verifyCount(2, kret)

    # pass by value
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.valuetest(k)
    val = kret.getValue()
    self.verifyValue("me oh my valuetest", val)
    self.verifyCount(1, k)
    self.verifyCount(1, kret)

    # pass by pointer
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.pointertest(k)
    val = kret.getValue()
    self.verifyValue("me oh my pointertest", val)
    self.verifyCount(1, k)
    self.verifyCount(1, kret)

    # pass by reference
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.reftest(k)
    val = kret.getValue()
    self.verifyValue("me oh my reftest", val)
    self.verifyCount(1, k)
    self.verifyCount(1, kret)

    # pass by pointer reference
    k = li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.pointerreftest(k)
    val = kret.getValue()
    self.verifyValue("me oh my pointerreftest", val)
    self.verifyCount(1, k)
    self.verifyCount(1, kret)

    # null tests
    k = None

    if (li_boost_shared_ptr.smartpointertest(k) != None):
      raise RuntimeError("return was not null")

    if (li_boost_shared_ptr.smartpointerpointertest(k) != None):
      raise RuntimeError("return was not null")

    if (li_boost_shared_ptr.smartpointerreftest(k) != None):
      raise RuntimeError("return was not null")

    if (li_boost_shared_ptr.smartpointerpointerreftest(k) != None):
      raise RuntimeError("return was not null")

    if (li_boost_shared_ptr.nullsmartpointerpointertest(None) != "null pointer"):
      raise RuntimeError("not null smartpointer pointer")

    try:
      li_boost_shared_ptr.valuetest(k)
      raise RuntimeError("Failed to catch null pointer")
    except ValueError:
      pass

    if (li_boost_shared_ptr.pointertest(k) != None):
      raise RuntimeError("return was not null")

    try:
      li_boost_shared_ptr.reftest(k)
      raise RuntimeError("Failed to catch null pointer")
    except ValueError:
      pass

    # $owner
    k = li_boost_shared_ptr.pointerownertest()
    val = k.getValue()
    self.verifyValue("pointerownertest", val)
    self.verifyCount(1, k)
    k = li_boost_shared_ptr.smartpointerpointerownertest()
    val = k.getValue()
    self.verifyValue("smartpointerpointerownertest", val)
    self.verifyCount(1, k)

  def verifyValue(self, expected, got):
    if (expected != got):
      raise RuntimeError("verify value failed. Expected: ", expected, " Got: ", got)

  def verifyCount(self, expected, k):
    got = li_boost_shared_ptr.use_count(k)
    if (expected != got):
      raise RuntimeError("verify use_count failed. Expected: ", expected, " Got: ", got)

runme = li_boost_shared_ptr_runme()
runme.main()

