// This file has a BOM for UTF-8
// Notes for displaying UTF-8 properly in Windows: https://stackoverflow.com/questions/49476326/displaying-unicode-in-powershell

using System;
using li_std_wstringNamespace;

public class runme
{
    static private void check_equal(char a, char b)
    {
        if (a != b)
            throw new Exception("char failed '" + a + "' != '" + b + "'");
    }

    static private void display_bytes(string s)
    {
        Console.Write("[");
        if (s != null)
        {
            foreach (char x in s)
            {
                int n = Convert.ToInt32(x);
                Console.Write(n.ToString("X") + " ");
            }
        }
        else
            Console.Write("null");
        Console.WriteLine("]");
    }

    static private void check_equal(string a, string b)
    {
        if (li_std_wstring.trace) {
            Console.WriteLine("check_equal {0} {1}", a, b);
            display_bytes(a);
            display_bytes(b);
        }
        if (a != b)
          throw new Exception("string failed '" + a + "' != '" + b + "'");
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

        check_equal(li_std_wstring.test_ccvalue(null), null);

        try {
            li_std_wstring.test_value(null);
            throw new Exception("NULL check failed");
        } catch (ArgumentNullException) {
        }

        try {
            li_std_wstring.test_reference(null);
            throw new Exception("NULL check failed");
        } catch (ArgumentNullException e) {
            if (!e.Message.Contains("is null"))
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

        /* Tricky, std::wstring portability problem.
         * std::wstring is 2 bytes on Windows, 4 bytes on Linux, LPWSTR is 2 bytes.
         */
        string ss = "abc";
        if (!li_std_wstring.test_equal_abc(ss))
            throw new Exception("Not equal " + ss);

        ss = "JP: 日本語";
        if (!li_std_wstring.test_equal_jp(ss))
            throw new Exception("Not equal " + ss);

        ss = "DE: Kröpeliner Straße";
        if (!li_std_wstring.test_equal_de(ss))
            throw new Exception("Not equal " + ss);

        ss = "RU: Война и мир";
        if (!li_std_wstring.test_equal_ru(ss))
            throw new Exception("Not equal " + ss);

        try {
            li_std_wstring.test_throw();
        } catch (Exception e) {
            check_equal(e.Message, "throwing test_throw");
        }

        try {
            li_std_wstring.test_throw_jp();
        } catch (Exception e) {
            check_equal(e.Message, "JP: 日本語");
        }

        try {
            li_std_wstring.test_throw_ref_jp();
        } catch (Exception e) {
            check_equal(e.Message, "JP: 日本語");
        }

        try {
            li_std_wstring.test_throw_wchar_t_ptr();
        } catch (Exception e) {
            check_equal(e.Message, "JP: 日本語");
        }

        x = "abc\0def";
        // Unlike other languages, embedded NULL in std::string not supported
        // check_equal(li_std_wstring.test_value(x), x);
        check_equal(li_std_wstring.test_value(x), "abc");
        check_equal(li_std_wstring.test_ccvalue(x), "abc");
        check_equal(li_std_wstring.test_wchar_overload(x), "abc");

        // Member variables
        var s = new wchar_test_struct();
        s.wchar_t_member = h;
        check_equal(s.wchar_t_member, h);
        s.wchar_t_ptr_member = x;
        check_equal(s.wchar_t_ptr_member, "abc");
        s.wchar_t_ptr_member = ss;
        check_equal(s.wchar_t_ptr_member, ss);

        {
            // Unicode strings
            // Strings below are UTF8 in this file, but .NET holds them internally as UTF16
            // DE: https://www.utf8-chartable.de/
            // RU: https://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024
            string[] test_strings = {
                "JP: 日本語", "DE: Kröpeliner Straße" , "RU: Война и мир", "EN: War and Peace"
            };

            foreach (string expected in test_strings)
            {
                if (li_std_wstring.trace)
                    Console.WriteLine("expected (C#): " + expected);
                string received = li_std_wstring.test_value(expected);
                check_equal(received, expected);
            }

            foreach (string expected in test_strings)
            {
                string received = li_std_wstring.test_const_reference(expected);
                check_equal(received, expected);
            }

            foreach (string expected in test_strings)
            {
                string received = li_std_wstring.test_ccvalue(expected);
                check_equal(received, expected);
            }

            foreach (string expected in test_strings)
            {
                s.wchar_t_ptr_member = expected;
                string received = s.wchar_t_ptr_member;
                check_equal(received, expected);
            }

            /* Not working for Japanese and Russian characters on Windows, okay on Linux
             * Is fixed by adding CharSet=CharSet.Unicode to the DllImport, so change to:
             * [global::System.Runtime.InteropServices.DllImport("li_std_wstring", CharSet=global::System.Runtime.InteropServices.CharSet.Unicode, EntryPoint="CSharp_li_std_wstringNamespace_test_wcvalue")]
             * Needs a SWIG code change to support this
            foreach (string test_string in test_strings)
            {
                foreach (char expected in test_string)
                {
                    char received = li_std_wstring.test_wcvalue(expected);
                    check_equal(received, expected);
                }
            }
            */
        }
    }
}

