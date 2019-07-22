using System;
using li_std_wstringNamespace;

public class runme
{
    static private void check_equal(char a, char b)
    {
      if (a != b)
        throw new Exception("failed " + a + " " + b);
    }

    static private void check_equal(string a, string b)
    {
      if (a != b)
        throw new Exception("failed " + a + " " + b);
    }

    static void Main() 
    {
        char h = 'h';
        check_equal(li_std_wstring.test_wcvalue(h), h);

        string x = "abc";
        check_equal(li_std_wstring.test_ccvalue(x), x);
        check_equal(li_std_wstring.test_cvalue(x), x);

        check_equal(li_std_wstring.test_wchar_overload(x), x);
        check_equal(li_std_wstring.test_wchar_overload(), null);

        li_std_wstring.test_pointer(null);
        li_std_wstring.test_const_pointer(null);

        try {
            li_std_wstring.test_value(null);
            throw new Exception("NULL check failed");
        } catch (ArgumentNullException) {
        }

        try {
              li_std_wstring.test_reference(null);
              throw new Exception("NULL check failed");
        } catch (ArgumentNullException e) {
            if (!e.Message.Contains("type is null"))
                throw new Exception("Missing text " + e);
        }
        try {
            li_std_wstring.test_const_reference(null);
            throw new Exception("NULL check failed");
        } catch (ArgumentNullException e) {
            if (!e.Message.Contains("null wstring"))
                throw new Exception("Missing text " + e);
        }

        x = "hello";
        check_equal(li_std_wstring.test_const_reference(x), x);

        /* TODO
        string s = "abc";
        if (!li_std_wstring.test_equal_abc(s))
            throw new Exception("Not equal " + s);

        try {
            li_std_wstring.test_throw();
        } catch (Exception e) {
            check_equal(e.Message, "throwing test_throw");
        }

        x = "abc\0def";
        check_equal(li_std_wstring.test_value(x), x);
        check_equal(li_std_wstring.test_ccvalue(x), "abc");
        check_equal(li_std_wstring.test_wchar_overload(x), "abc");
        */

    }
}

