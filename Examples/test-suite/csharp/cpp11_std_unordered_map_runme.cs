using System;
using System.Collections.Generic;
using cpp11_std_unordered_mapNamespace;

public class runme
{
  static void checkThat(bool mustBeTrue)
  {
    if (!mustBeTrue)
    {
      throw new Exception("checkThat failed");
    }
  }

  static void Main()
  {
    global::System.Collections.Generic.IDictionary<string, int> sim = new UnorderedMapStringInt();
    global::System.Collections.Generic.IDictionary<int, int> iim = new UnorderedMapIntInt();

    checkThat(((UnorderedMapStringInt)sim).IsEmpty);
    checkThat(((UnorderedMapIntInt)iim).IsEmpty);

    checkThat(sim.Count == 0);
    checkThat(iim.Count == 0);

    int myInt;
    checkThat(!sim.TryGetValue("key", out myInt));
    checkThat(!iim.TryGetValue(1, out myInt));

    checkThat(!sim.ContainsKey("key"));
    checkThat(!iim.ContainsKey(1));

    sim.Add("key", 2);
    iim.Add(1, 2);

    checkThat(sim.Count == 1);
    checkThat(iim.Count == 1);

    checkThat(sim["key"] == 2);
    checkThat(iim[1] == 2);

    checkThat(sim.Remove("key"));
    checkThat(iim.Remove(1));

    checkThat(sim.Count == 0);
    checkThat(iim.Count == 0);

    checkThat(!sim.TryGetValue("key", out myInt));
    checkThat(!iim.TryGetValue(1, out myInt));

    checkThat(!sim.Remove("key"));
    checkThat(!iim.Remove(1));

    sim["key"] = 2;
    iim[1] = 2;

    sim.Clear();
    iim.Clear();
    checkThat(sim.Count == 0);
    checkThat(iim.Count == 0);

    sim["key1"] = 1;
    iim[1] = 1;
    sim["key2"] = 2;
    iim[2] = 2;

    checkThat(sim.Count == 2);
    checkThat(iim.Count == 2);
    checkThat(sim["key1"] == 1);
    checkThat(iim[1] == 1);
    checkThat(sim["key2"] == 2);
    checkThat(iim[2] == 2);

    sim["key1"] = 3;
    iim[1] = 3;

    checkThat(sim.Count == 2);
    checkThat(iim.Count == 2);
    checkThat(sim["key1"] == 3);
    checkThat(iim[1] == 3);

    {
      int collectionSize = 20;
      UnorderedMapStringInt simap = new UnorderedMapStringInt();
      for (int i = 0; i < collectionSize; i++)
      {
          int val = i * 18;
          simap.Add(i.ToString(), val);
      }

      // Keys and Values test
      IList<string> keys = new List<string>(simap.Keys);
      IList<int> values = new List<int>(simap.Values);
      Dictionary<string, int> check = new Dictionary<string, int>();
      if (keys.Count != collectionSize)
        throw new Exception("Keys count test failed");

      if (values.Count != collectionSize)
        throw new Exception("Values count test failed");

      for (int i = 0; i < keys.Count; i++)
      {
        if (simap[keys[i]] != values[i])
          throw new Exception("Keys and values test failed for index " + i);
        check.Add(keys[i], values[i]);
      }

      for (int i = 0; i < collectionSize; i++)
      {
        if (!check.ContainsKey(i.ToString()))
          throw new Exception("Keys and Values ContainsKey test " + i + " failed");
      }

      // CopyTo() test
      {
        KeyValuePair<string, int>[] outputarray = new KeyValuePair<string, int>[collectionSize];
        simap.CopyTo(outputarray);
        foreach (KeyValuePair<string, int> val in outputarray)
        {
          if (simap[val.Key] != val.Value)
            throw new Exception("CopyTo (1) test failed, index:" + val.Key);
        }
      }
    }
  }
}
