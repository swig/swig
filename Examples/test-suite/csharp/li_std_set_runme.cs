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

        // Check set-theoretic methods.
        checkThat(new StringSet().SetEquals(new StringSet()), "SetEquals() works for empty sets");
        checkThat(new StringSet{"foo"}.SetEquals(new StringSet{"foo"}), "SetEquals() works for non-empty sets");
        checkThat(!new StringSet{"foo"}.SetEquals(new[] {"bar"}), "SetEquals() doesn't always return true");

        ss = new StringSet{"foo", "bar", "baz"};
        ss.ExceptWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"foo", "bar"}), "ExceptWith works");

        ss = new StringSet{"foo", "bar", "baz"};
        ss.IntersectWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"baz"}), "IntersectWith works");

        checkThat(ss.IsProperSubsetOf(new[] {"bar", "baz"}), "IsProperSubsetOf works");
        checkThat(!ss.IsProperSubsetOf(new[] {"baz"}), "!IsProperSubsetOf works");
        checkThat(ss.IsSubsetOf(new[] {"bar", "baz"}), "IsSubsetOf works");
        checkThat(!ss.IsSubsetOf(new[] {"bar"}), "!IsSubsetOf works");

        ss = new StringSet{"foo", "bar", "baz"};
        checkThat(ss.IsProperSupersetOf(new[] {"bar"}), "IsProperSupersetOf works");
        checkThat(!ss.IsProperSupersetOf(new[] {"quux"}), "IsProperSupersetOf works");
        checkThat(ss.IsSupersetOf(new[] {"foo", "bar", "baz"}), "IsProperSupersetOf works");
        checkThat(!ss.IsSupersetOf(new[] {"foo", "bar", "baz", "quux"}), "IsProperSupersetOf works");

        checkThat(ss.Overlaps(new[] {"foo"}), "Overlaps works");
        checkThat(!ss.Overlaps(new[] {"moo"}), "!Overlaps works");

        ss.SymmetricExceptWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"foo", "bar", "quux"}), "SymmetricExceptWith works");

        ss = new StringSet{"foo", "bar", "baz"};
        ss.UnionWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"foo", "bar", "baz", "quux"}), "UnionWith works");

        // Check a set of another type.
        FooSet fooSet = new FooSet();
        ISet<Foo> fooISet = fooSet;
        checkThat(fooISet.Count == 0, "is initially empty");
        checkThat(fooISet.Add(new Foo(17)), "added successfully");
        checkThat(fooISet.Count == 1, "is not empty any more");

        // And a set of primitive type.
        IntSet intSet = new IntSet();
        checkThat(intSet.Count == 0, "is initially empty");
        checkThat(intSet.Add(17), "17 added successfully");
        checkThat(!intSet.Add(17), "17 not added again");
        checkThat(intSet.Count == 1, "not empty any more");
        checkThat(intSet.Add(289), "289 added successfully");
        checkThat(intSet.Count == 2, "even less empty now");
    }
}
