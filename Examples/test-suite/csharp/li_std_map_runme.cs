/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * li_std_map_runme.cs
 *
 * SWIG C# tester for std_map.i
 * Implementation by Yuval Baror (http://yuval.bar-or.org)
 *
 * This class tests all the functionality of the std_map.i wrapper.
 * Upon successful testing, the main function doesn't print out anything.
 * If any error is found - it will be printed on the screen.
 * ----------------------------------------------------------------------------- */

using System;
using System.Collections.Generic;
using li_std_mapNamespace;

public class li_std_map_runme {

    private static readonly int collectionSize = 20;
    private static readonly int midCollection = collectionSize / 2;

    public static void Main()
    {
        // Set up an int int map
        IntIntMap iimap = new IntIntMap();
        for (int i = 0; i < collectionSize; i++)
        {
            int val = i * 18;
            iimap.Add(i, val);
        }

        // Count property test
        if (iimap.Count != collectionSize)
            throw new Exception("Count test failed");

        // IsReadOnly property test
        if (iimap.IsReadOnly)
            throw new Exception("IsReadOnly test failed");

        // Item indexing test
        iimap[0] = 200;
        if (iimap[0] != 200)
            throw new Exception("Item property test failed");
        iimap[0] = 0 * 18;

        // ContainsKey() test
        for (int i = 0; i < collectionSize; i++)
        {
            if (!iimap.ContainsKey(i))
                throw new Exception("ContainsKey test " + i + " failed");
        }

        // ContainsKey() test
        for (int i = 0; i < collectionSize; i++)
        {
            if (!iimap.Contains(new KeyValuePair<int, int>(i, i * 18)))
                throw new Exception("Contains test " + i + " failed");
        }

        // TryGetValue() test
        int value;
        bool rc = iimap.TryGetValue(3, out value);
        if (rc != true || value != (3 * 18))
            throw new Exception("TryGetValue test 1 failed");

        rc = iimap.TryGetValue(-1, out value);
        if (rc != false)
            throw new Exception("TryGetValue test 2 failed");

        // Keys and Values test
        {
            IList<int> keys = new List<int>(iimap.Keys);
            IList<int> values = new List<int>(iimap.Values);
            if (keys.Count != collectionSize)
                throw new Exception("Keys count test failed");

            if (values.Count != collectionSize)
                throw new Exception("Values count test failed");

            for (int i = 0; i < keys.Count; i++)
            {
                if (iimap[keys[i]] != values[i])
                    throw new Exception("Keys and values test failed for index " + i);
            }
        }

        // Add and Remove test
        for (int i = 100; i < 103; i++)
        {
            iimap.Add(i, i * 18);
            if (!iimap.ContainsKey(i) || iimap[i] != (i * 18))
                throw new Exception("Add test failed for index " + i);

            iimap.Remove(i);
            if (iimap.ContainsKey(i))
                throw new Exception("Remove test failed for index " + i);
        }

        for (int i = 200; i < 203; i++)
        {
            iimap.Add(new KeyValuePair<int, int>(i, i * 18));
            if (!iimap.ContainsKey(i) || iimap[i] != (i * 18))
                throw new Exception("Add explicit test failed for index " + i);

            iimap.Remove(new KeyValuePair<int, int>(i, i * 18));
            if (iimap.ContainsKey(i))
                throw new Exception("Remove explicit test failed for index " + i);
        }

        // Duplicate key test
        try
        {
            iimap.Add(3, 0);
            throw new Exception("Adding duplicate key test failed");
        }
        catch (ArgumentException)
        {
        }

        // CopyTo() test
        {
            KeyValuePair<int, int>[] outputarray = new KeyValuePair<int, int>[collectionSize];
            iimap.CopyTo(outputarray);
            foreach (KeyValuePair<int, int> val in outputarray)
            {
                if (iimap[val.Key] != val.Value)
                    throw new Exception("CopyTo (1) test failed, index:" + val.Key);
            }
        }
        {
            KeyValuePair<int, int>[] outputarray = new KeyValuePair<int, int>[midCollection + collectionSize];
            iimap.CopyTo(outputarray, midCollection);
            for (int i = midCollection; i < midCollection + collectionSize; i++)
            {
                KeyValuePair<int, int> val = outputarray[i];
                if (iimap[val.Key] != val.Value)
                    throw new Exception("CopyTo (2) test failed, index:" + val.Key);
            }
        }
        {
            KeyValuePair<int, int>[] outputarray = new KeyValuePair<int, int>[collectionSize - 1];
            try
            {
                iimap.CopyTo(outputarray);
                throw new Exception("CopyTo (4) test failed");
            }
            catch (ArgumentException)
            {
            }
        }

        // Clear test
        iimap.Clear();
        if (iimap.Count != 0)
            throw new Exception("Clear test failed");

        // Test wrapped methods
        for (int i = 1; i <= 5; i++)
        {
            iimap[i] = i;
        }
        double avg = li_std_map.keyAverage(iimap);
        if (avg != 3.0)
            throw new Exception("Wrapped method keyAverage test failed. Got " + avg);

        // Test a map with a new specialized type (Struct)
        {
            IntStructMap ismap = new IntStructMap();
            for (int i = 0; i < 10; i++)
            {
                ismap.Add(i, new Struct(i * 10.1));
            }

            if (ismap.Count != 10)
                throw new Exception("Count test on specialized map failed");

            foreach (KeyValuePair<int, Struct> p in ismap)
            {
                if ((p.Key * 10.1) != p.Value.num)
                    throw new Exception("Iteration test on specialized map failed for index " + p.Key);
            }
        }

        // Test a map of pointers
        {
            IntStructPtrMap ispmap = new IntStructPtrMap();
            for (int i = 0; i < 10; i++)
            {
                ispmap.Add(i, new Struct(i * 10.1));
            }

            if (ispmap.Count != 10)
                throw new Exception("Count test on specialized pointer map failed");

            foreach (KeyValuePair<int, Struct> p in ispmap)
            {
                if ((p.Key * 10.1) != p.Value.num)
                    throw new Exception("Iteration test on specialized pointer map failed for index " + p.Key);
            }
        }
        {
            IntStructConstPtrMap iscpmap = new IntStructConstPtrMap();
            for (int i = 0; i < 10; i++)
            {
                iscpmap.Add(i, new Struct(i * 10.1));
            }

            if (iscpmap.Count != 10)
                throw new Exception("Count test on specialized const pointer map failed");

            foreach (KeyValuePair<int, Struct> p in iscpmap)
            {
                if ((p.Key * 10.1) != p.Value.num)
                    throw new Exception("Iteration test on specialized const pointer map failed for index " + p.Key);
            }
        }

        // Test non-specialized map
        {
            StructIntMap limap = new StructIntMap();
            Struct s7 = new Struct(7);
            Struct s8 = new Struct(8);
            limap.set(s7 , 8);
            if (limap.get(s7) != 8)
                throw new Exception("Assignment test on non-specialized map failed");

            if (!limap.has_key(s7))
                throw new Exception("Key test (1) on non-specialized map failed");

            if (limap.has_key(s8))
                throw new Exception("Key test (2) on non-specialized map failed");
        }

        // All done
    }
}

