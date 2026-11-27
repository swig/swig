
import cpp11_noexcept.*;

public class cpp11_noexcept_runme {

  static {
    try {
      System.loadLibrary("cpp11_noexcept");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // A pointer to a noexcept function converts to a pointer to the function without noexcept
    if (cpp11_noexcept.noexceptCallIntFunc(cpp11_noexcept.noexceptGetAddTwo(), 1) != 3)
      throw new RuntimeException("noexceptCallIntFunc failed");
    if (cpp11_noexcept.noexceptCallNoExceptFunc(cpp11_noexcept.noexceptGetAddTwo(), 2) != 4)
      throw new RuntimeException("noexceptCallNoExceptFunc failed");

    // noexcept in an abstract declarator
    if (cpp11_noexcept.noexceptCallUnnamed(cpp11_noexcept.noexceptGetAddTwo(), 4) != 6)
      throw new RuntimeException("noexceptCallUnnamed failed");
    if (cpp11_noexcept.noexceptCallDefault(5) != 7)
      throw new RuntimeException("noexceptCallDefault failed");
    if (cpp11_noexcept.noexceptCallNoExceptFunc(cpp11_noexcept.noexceptGetAddTwoTrailing(), 6) != 8)
      throw new RuntimeException("noexceptGetAddTwoTrailing failed");
    NoExceptFuncPtrHolder h = new NoExceptFuncPtrHolder(cpp11_noexcept.noexceptGetAddTwo());
    if (cpp11_noexcept.noexceptCallNoExceptFunc(h.getPtr(), 7) != 9)
      throw new RuntimeException("NoExceptFuncPtrHolder failed");
    NoExceptMemberFunc member = new NoExceptMemberFunc();
    if (cpp11_noexcept.noexceptCallMemberFunc(cpp11_noexcept.noexceptGetAddThree(), member, 1) != 4)
      throw new RuntimeException("noexceptCallMemberFunc failed");

    // noexcept in a function typedef or alias
    if (cpp11_noexcept.noexceptCallFuncType(cpp11_noexcept.noexceptGetAddTwo(), 1) != 3)
      throw new RuntimeException("noexceptCallFuncType failed");
    if (cpp11_noexcept.noexceptCallFuncPtrAlias(cpp11_noexcept.noexceptGetAddTwo(), 2) != 4)
      throw new RuntimeException("noexceptCallFuncPtrAlias failed");
    if (cpp11_noexcept.noexceptCallFuncPtrTrailing(cpp11_noexcept.noexceptGetAddTwo(), 3) != 5)
      throw new RuntimeException("noexceptCallFuncPtrTrailing failed");
    if (cpp11_noexcept.noexceptCallMemberFuncPtrAlias(cpp11_noexcept.noexceptGetAddThree(), member, 2) != 5)
      throw new RuntimeException("noexceptCallMemberFuncPtrAlias failed");
    if (cpp11_noexcept.noexceptCallMemberFuncPtrTrailing(cpp11_noexcept.noexceptGetAddThree(), member, 3) != 6)
      throw new RuntimeException("noexceptCallMemberFuncPtrTrailing failed");
    if (new NoExceptFuncTypeMember().addFour(1) != 5)
      throw new RuntimeException("NoExceptFuncTypeMember failed");

    // The declarators after the first in a list
    NoExceptFuncPtrMembers members = new NoExceptFuncPtrMembers();
    members.setPtr2(cpp11_noexcept.noexceptGetAddTwo2());
    if (cpp11_noexcept.noexceptCallNoExceptFunc(members.getPtr2(), 4) != 6)
      throw new RuntimeException("NoExceptFuncPtrMembers failed");
    if (cpp11_noexcept.noexceptCallFuncType2(cpp11_noexcept.noexceptGetAddTwo2(), 5) != 7)
      throw new RuntimeException("noexceptCallFuncType2 failed");

    // The in typemap with locals supplies the function pointer
    if (cpp11_noexcept.noexceptCallLocals(8) != 10)
      throw new RuntimeException("noexceptCallLocals failed");
  }
}
