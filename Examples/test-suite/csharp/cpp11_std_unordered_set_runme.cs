using System;
using System.Collections.Generic;
using cpp11_std_unordered_setNamespace;

public class runme
{
    static void checkThat(bool mustBeTrue, string message)
    {
        if (!mustBeTrue)
            throw new Exception("Test that the set " + message + " failed");
    }

    static void Main()
    {
        UnorderedSetString ss = new UnorderedSetString();

        // Check the interface methods first.
        ISet<string> s = ss;

        checkThat(((UnorderedSetString)s).IsEmpty, "is empty");
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
        checkThat(new UnorderedSetString().SetEquals(new UnorderedSetString()), "SetEquals() works for empty sets");
        checkThat(new UnorderedSetString{"foo"}.SetEquals(new UnorderedSetString{"foo"}), "SetEquals() works for non-empty sets");
        checkThat(!new UnorderedSetString{"foo"}.SetEquals(new[] {"bar"}), "SetEquals() doesn't always return true");

        ss = new UnorderedSetString{"foo", "bar", "baz"};
        ss.ExceptWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"foo", "bar"}), "ExceptWith works");

        ss = new UnorderedSetString{"foo", "bar", "baz"};
        ss.IntersectWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"baz"}), "IntersectWith works");

        checkThat(ss.IsProperSubsetOf(new[] {"bar", "baz"}), "IsProperSubsetOf works");
        checkThat(!ss.IsProperSubsetOf(new[] {"baz"}), "!IsProperSubsetOf works");
        checkThat(ss.IsSubsetOf(new[] {"bar", "baz"}), "IsSubsetOf works");
        checkThat(!ss.IsSubsetOf(new[] {"bar"}), "!IsSubsetOf works");

        ss = new UnorderedSetString{"foo", "bar", "baz"};
        checkThat(ss.IsProperSupersetOf(new[] {"bar"}), "IsProperSupersetOf works");
        checkThat(!ss.IsProperSupersetOf(new[] {"quux"}), "IsProperSupersetOf works");
        checkThat(ss.IsSupersetOf(new[] {"foo", "bar", "baz"}), "IsProperSupersetOf works");
        checkThat(!ss.IsSupersetOf(new[] {"foo", "bar", "baz", "quux"}), "IsProperSupersetOf works");

        checkThat(ss.Overlaps(new[] {"foo"}), "Overlaps works");
        checkThat(!ss.Overlaps(new[] {"moo"}), "!Overlaps works");

        ss.SymmetricExceptWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"foo", "bar", "quux"}), "SymmetricExceptWith works");

        ss = new UnorderedSetString{"foo", "bar", "baz"};
        ss.UnionWith(new[] {"baz", "quux"});
        checkThat(ss.SetEquals(new[] {"foo", "bar", "baz", "quux"}), "UnionWith works");

        // And a set of primitive type.
        UnorderedSetInt intSet = new UnorderedSetInt();
        checkThat(intSet.Count == 0, "is initially empty");
        checkThat(intSet.Add(17), "17 added successfully");
        checkThat(!intSet.Add(17), "17 not added again");
        checkThat(intSet.Count == 1, "not empty any more");
        checkThat(intSet.Add(289), "289 added successfully");
        checkThat(intSet.Count == 2, "even less empty now");

        // Test IsProperSubsetOf
        UnorderedSetInt intSet2 = new UnorderedSetInt();
        checkThat(intSet2.IsProperSubsetOf(intSet), "empty set is proper subset of non-empty set");
        checkThat(!intSet.IsProperSubsetOf(intSet2), "non-empty set is not proper subset of empty set");
        intSet2.Add(17);
        checkThat(intSet2.IsProperSubsetOf(intSet), "subset is proper subset of superset");
        checkThat(!intSet.IsProperSubsetOf(intSet2), "superset is not proper subset of subset");
        intSet2.Add(289);
        checkThat(!intSet2.IsProperSubsetOf(intSet), "superset is not proper subset of itself");
        checkThat(!intSet.IsProperSubsetOf(intSet2), "subset is not proper subset of itself");

        // Test IsProperSupersetOf
        intSet2 = new UnorderedSetInt();
        checkThat(intSet.IsProperSupersetOf(intSet2), "superset is proper superset of subset");
        checkThat(!intSet2.IsProperSupersetOf(intSet), "subset is not proper superset of superset");
        checkThat(!intSet.IsProperSupersetOf(intSet), "set is not proper superset of itself");
        checkThat(!intSet2.IsProperSupersetOf(intSet2), "subset is not proper superset of itself");
        intSet2.Add(17);
        checkThat(intSet.IsProperSupersetOf(intSet2), "superset is not proper superset of subset");
        intSet2.Add(289);
        checkThat(!intSet.IsProperSupersetOf(intSet2), "superset is not proper superset of itself");
        checkThat(!intSet2.IsProperSupersetOf(intSet), "subset is not proper superset of itself");

        // Test IsSubsetOf
        intSet2 = new UnorderedSetInt();
        checkThat(intSet2.IsSubsetOf(intSet), "empty set is subset of non-empty set");
        checkThat(!intSet.IsSubsetOf(intSet2), "non-empty set is not subset of empty set");
        intSet2.Add(17);
        checkThat(intSet2.IsSubsetOf(intSet), "subset is subset of superset");
        checkThat(!intSet.IsSubsetOf(intSet2), "superset is not subset of subset");
        intSet2.Add(289);
        checkThat(intSet2.IsSubsetOf(intSet), "superset is subset of itself");
        checkThat(intSet.IsSubsetOf(intSet2), "subset is subset of itself");

        // Test IsSupersetOf
        intSet2 = new UnorderedSetInt();
        checkThat(intSet.IsSupersetOf(intSet2), "superset is superset of subset");
        checkThat(!intSet2.IsSupersetOf(intSet), "subset is not superset of superset");
        checkThat(intSet.IsSupersetOf(intSet), "set is superset of itself");
        checkThat(intSet2.IsSupersetOf(intSet2), "subset is superset of itself");
        intSet2.Add(17);
        checkThat(intSet.IsSupersetOf(intSet2), "superset is not superset of subset");
        intSet2.Add(289);
        checkThat(intSet.IsSupersetOf(intSet2), "superset is superset of itself");
        checkThat(intSet2.IsSupersetOf(intSet), "subset is superset of itself");

        // Test Overlaps
        intSet2 = new UnorderedSetInt();
        checkThat(!intSet2.Overlaps(intSet), "empty set does not overlap non-empty set");
        checkThat(!intSet.Overlaps(intSet2), "non-empty set does not overlap empty set");
        intSet2.Add(17);
        checkThat(intSet2.Overlaps(intSet), "subset overlaps superset");
        checkThat(intSet.Overlaps(intSet2), "superset overlaps subset");
        intSet2.Add(289);
        checkThat(intSet2.Overlaps(intSet), "superset overlaps itself");
        checkThat(intSet.Overlaps(intSet2), "subset overlaps itself");

        // Test SymmetricExceptWith
        intSet2 = new UnorderedSetInt();
        intSet2.SymmetricExceptWith(intSet);
        checkThat(intSet2.SetEquals(intSet), "SymmetricExceptWith empty set works");
        intSet2.SymmetricExceptWith(intSet);
        checkThat(intSet2.Count == 0, "SymmetricExceptWith empty set twice works");
        intSet2.Add(17);
        intSet2.SymmetricExceptWith(intSet);
        checkThat(intSet2.SetEquals(new[] {289}), "SymmetricExceptWith non-empty set works");
        intSet2.SymmetricExceptWith(intSet);

        // Test UnionWith
        intSet2 = new UnorderedSetInt();
        intSet2.UnionWith(intSet); // empty set union non-empty set
        checkThat(intSet2.SetEquals(intSet), "UnionWith empty set works");
        intSet2.UnionWith(intSet); // empty set union non-empty set
        checkThat(intSet2.SetEquals(intSet), "UnionWith empty set twice works");
        intSet2.Add(17);
        intSet2.UnionWith(intSet);
        checkThat(intSet2.SetEquals(intSet), "UnionWith non-empty set works");
        intSet2.UnionWith(intSet);
        checkThat(intSet2.SetEquals(intSet), "UnionWith non-empty set twice works");

        // Test IntersectWith
        intSet2 = new UnorderedSetInt();
        intSet2.IntersectWith(intSet); // empty set intersect non-empty set
        checkThat(intSet2.Count == 0, "IntersectWith empty set works");
        intSet2.IntersectWith(intSet); // empty set intersect non-empty set
        checkThat(intSet2.Count == 0, "IntersectWith empty set twice works");
        intSet2.Add(17);
        intSet2.IntersectWith(intSet);
        checkThat(intSet2.SetEquals(new[] {17}), "IntersectWith non-empty set works");
        intSet2.IntersectWith(intSet);
        checkThat(intSet2.SetEquals(new[] {17}), "IntersectWith non-empty set twice works");

        // Test ExceptWith
        intSet2 = new UnorderedSetInt();
        intSet2.ExceptWith(intSet); // empty set except non-empty set
        checkThat(intSet2.Count == 0, "ExceptWith empty set works");
        intSet2.ExceptWith(intSet); // empty set except non-empty set
        checkThat(intSet2.Count == 0, "ExceptWith empty set twice works");
        intSet2.Add(17);
        intSet2.ExceptWith(intSet);
        checkThat(intSet2.Count == 0, "ExceptWith non-empty set works");
        intSet2.ExceptWith(intSet);
        checkThat(intSet2.Count == 0, "ExceptWith non-empty set twice works");
    }
}
