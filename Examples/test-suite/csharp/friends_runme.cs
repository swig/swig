using System;
using friendsNamespace;

public class friends_runme {
  private static void check_equal(int a, int b) {
    if (a != b)
      throw new Exception("Not equal " + a + " != " + b);
  }

  public static void Main() {
    A a = new A(2);

    if (friends.get_val1(a) != 2)
      throw new Exception("failed");
    if (friends.get_val2(a) != 4)
      throw new Exception("failed");
    if (friends.get_val3(a) != 6)
      throw new Exception("failed");

    // nice overload working fine
    if (friends.get_val1(1,2,3) != 1)
      throw new Exception("failed");

    B b = new B(3);

    // David's case
    if (friends.mix(a,b) != 5)
      throw new Exception("failed");

    D_i di = new D_i(2);
    D_d dd = new D_d(3.3);

    // incredible template overloading working just fine
    if (friends.get_val1(di) != 2)
      throw new Exception("failed");
    if (friends.get_val1(dd) != 3.3)
      throw new Exception("failed");

    friends.set(di, 4);
    friends.set(dd, 1.3);

    if (friends.get_val1(di) != 4)
      throw new Exception("failed");
    if (friends.get_val1(dd) != 1.3)
      throw new Exception("failed");

    if (friends.chum_blah() != 1234)
      throw new Exception("failed");
    if (friends.mate_blah() != 4321)
      throw new Exception("failed");

    Foe foe = new Foe(111);
    check_equal(friends.friend_definition(), 10);
    check_equal(friends.friend_declaration(), 11);
    check_equal(friends.friend_args_definition(foe), 111);
    check_equal(friends.friend_args_declaration(foe), 111);

    check_equal(friends.friend_definition_compiler(), 20);
    check_equal(friends.friend_declaration_compiler(), 21);
    check_equal(friends.friend_args_definition_compiler(foe), 111);
    check_equal(friends.friend_args_declaration_compiler(foe), 111);
  }
}

