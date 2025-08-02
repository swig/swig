using System;
using cpp11_constexpr_friendNamespace;

public class cpp11_constexpr_friend_runme {
  public static void Main() {
    FriendA fa10 = new FriendA(10);
    FriendA fa20 = new FriendA(20);
    if (!cpp11_constexpr_friend.isEqual(fa10, fa10))
      throw new Exception("Friend fa10 fa10 fail");
    if (cpp11_constexpr_friend.isEqual(fa10, fa20))
      throw new Exception("Friend fa10 fa20 fail");

    FriendB fb10 = new FriendB(10);
    FriendB fb20 = new FriendB(20);
    if (!cpp11_constexpr_friend.isEqual(fb10, fb10))
      throw new Exception("Friend fb10 fb10 fail");
    if (cpp11_constexpr_friend.isEqual(fb10, fb20))
      throw new Exception("Friend fb10 fb20 fail");
  }
}
