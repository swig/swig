using System;
using director_char_arrayNamespace;

public class director_char_array_runme
{
  static void check(int got, int expected, string what) {
    if (got != expected)
      throw new Exception(what + " got " + got + " expected " + expected);
  }

  static void Main()
  {
    Director d = new Director();
    check(d.call_take_array(), 4, "take_array");
    check(d.call_take_const_array(), 4, "take_const_array");
    check(d.call_take_array_ref(), 4, "take_array_ref");
    check(d.call_take_const_array_ref(), 4, "take_const_array_ref");
    check(d.call_take_array_short(), 2, "take_array short");
    check(d.call_take_array_ref_short(), 2, "take_array_ref short");
    check(d.call_is_null_array(), 1, "is_null_array");
  }
}

public class Director : CharArrayDirector {
  public override int take_array(string s) { return s.Length; }
  public override int take_const_array(string s) { return s.Length; }
  public override int take_array_ref(string s) { return s.Length; }
  public override int take_const_array_ref(string s) { return s.Length; }
  public override int is_null_array(string s) { return s == null ? 1 : 0; }
}
