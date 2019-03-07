using System;
using System.Collections.Generic;
using li_std_setNamespace;

public class runme
{
    static void checkThat(bool mustBeTrue, string message)
    {
        if (!mustBeTrue)
            throw new Exception("Test that the set " + message + " failed");
    }

    static void Main()
    {
        StringSet ss = new StringSet();

        // Check the interface methods first.
        ISet<string> s = ss;

        checkThat(s.Count == 0, "is initially empty");
        checkThat(!s.Contains("key"), "doesn't contain inexistent element");
        checkThat(!s.Remove("key"), "returns false when removing inexistent element");

        checkThat(s.Add("key"), "returns true when adding a new element");
        checkThat(!s.Add("key"), "returns false when adding an existing element");
        checkThat(s.Contains("key"), "contains the just added element");
        checkThat(s.Remove("key"), "returns true when removing an existing element");
        checkThat(s.Count == 0, "is empty again");

        checkThat(s.Add("key1"), "Add(key1) returns true");
        checkThat(s.Add("key2"), "Add(key2) returns true");
        checkThat(s.Add("key3"), "Add(key3) returns true");

        // Also check a different interface, providing a different Add() (sic!).
        ICollection<string> coll = ss;
        coll.Add("key");
        checkThat(ss.Count == 4, "contains 4 elements");

        // Now use object-specific methods, mimicking HashSet<>.
        string val;
        checkThat(ss.TryGetValue("key1", out val), "could retrieve existing item");
        checkThat(val.Equals("key1"), "value was returned correctly by TryGetValue()");
        checkThat(!ss.TryGetValue("no-such-key", out val), "couldn't retrieve inexistent item");
        checkThat(val == null, "value was reset after failed TryGetValue()");

        IList<string> list = new List<string>();
        foreach (string str in ss) {
            list.Add(str);
        }
        checkThat(list.Count == 4, "copy contains 4 elements");

        ss.Clear();
        checkThat(ss.Count == 0, "is empty after Clear()");
    }
}
