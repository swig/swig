using System;
using li_std_listNamespace;

public class li_std_list_runme {
  private static readonly int collectionSize = 20;

  public static void Main() {
    // Setup a list of int
    IntList list = new IntList();
    IntList.IntListNode node;

    for (int i = 0; i < 20; i++) {
      int nb = i * 10;
      list.Add(nb);
    }

    // Count property test
    if (list.Count != collectionSize)
      throw new Exception("Count test failed");

    // IsReadOnly property test
    if (list.IsReadOnly)
      throw new Exception("IsReadOnly test failed");

    // Contains method test
    if (!list.Contains(0))
      throw new Exception("Contains method test 1 failed");
    if (!list.Contains(2 * 10))
      throw new Exception("Contains method test 2 failed");
    if (!list.Contains(19 * 10))
      throw new Exception("Contains method test 3 failed");
    if (list.Contains(20 * 10))
      throw new Exception("Contains method test 4 failed");

    // Nodes comparison method overload
    {
      IntList.IntListNode temp = new IntList.IntListNode(3);
      if (list.First == temp)
        throw new Exception("== overload method test (1) failed");
      temp = new IntList.IntListNode(0);
      if (list.First == temp)
        throw new Exception("== overload method test (2) failed");
      IntList.IntListNode temp2 = new IntList.IntListNode(0);
      if (temp == temp2)
        throw new Exception("== overload method test (3) failed");
      if (!(list.First == list.First))
        throw new Exception("== overload method test (4) failed");
      if (list.First != list.First)
        throw new Exception("!= overload method test (1) failed");
      if (!(temp != temp2))
        throw new Exception("!= overload method test (2) failed");
      if (list.First.Equals(temp))
        throw new Exception("Equals method test failed");
      if (list.First.GetHashCode() == temp.GetHashCode())
        throw new Exception("GetHashCode method test (1) failed");
      if (list.First.GetHashCode() == list.First.GetHashCode())
        throw new Exception("GetHashCode method test (2) failed");

    }

    // Getter test
    {
      if (list.First == null)
        throw new Exception("First getter test (1) failed");
      if (list.Last == null)
        throw new Exception("Last getter test (1) failed");
      if (list.Last.Next != null)
        throw new Exception("Next getter test (1) failed");
      if (list.First.Next == null)
        throw new Exception("Next getter test (2) failed");
      if (list.First.Previous != null)
        throw new Exception("Previous getter test (1) failed");
       if (list.Last.Previous == null)
        throw new Exception("Previous getter test (2) failed");
    }

    // AddFirst method test
    node = list.AddFirst(34);
    if (list.First.Value != 34 || node.Value != 34 || node != list.First)
      throw new Exception("AddFirst method test failed");
    try {
      list.AddFirst(null);
    } catch (ArgumentNullException) {
      try {
        list.AddFirst(list.First);
      } catch (InvalidOperationException) {
      }
    }

    // RemoveFirst method test
    int tmp = list.First.Value;
    list.RemoveFirst();
    if (list.First.Value == tmp || list.First.Value != 0 * 10)
      throw new Exception("RemoveFirst method test failed");

    // AddLast method test
    node = list.AddLast(8);
    if (list.Last.Value != 8 || node.Value != 8 || node != list.Last)
      throw new Exception("AddLast method test failed");
    try {
      list.AddLast(null);
    } catch (ArgumentNullException) {
      try {
        list.AddLast(list.First);
      } catch (InvalidOperationException) {
      }
    }

    // RemoveLast method test
    int tmp2 = list.Last.Value;
    list.RemoveLast();
    if (list.Last.Value == tmp2 || list.Last.Value != (list.Count - 1) * 10)
      throw new Exception("RemoveLast method test failed");

    // AddBefore method test
    node = list.AddBefore(list.Last, 17);
    if (list.Last.Previous.Value != 17 || node.Value != 17 || node != list.Last.Previous)
      throw new Exception("AddBefore method test (1) failed");
    try {
      node = null;
      list.AddBefore(list.Last, node);
      throw new Exception("AddBefore method test (2) failed");
    } catch (ArgumentNullException) {
      try {
        node = new IntList.IntListNode(1);
        list.AddBefore(null, node);
        throw new Exception("AddBefore method test (3) failed");
      } catch (ArgumentNullException) {
        try {
          list.AddBefore(list.Last, list.First);
        } catch (InvalidOperationException) {
        }
      }
    }

    // AddAfter method test
    node = list.AddAfter(list.First, 47);
    if (list.First.Next.Value != 47 || node.Value != 47 || node != list.First.Next)
      throw new Exception("AddAfter method test (1) failed");
    try {
      node = null;
      list.AddAfter(list.First.Next, node);
      throw new Exception("AddAfter method test (2) failed");
    } catch (ArgumentNullException) {
      try {
        list.AddAfter(list.First, list.Last);
      } catch (InvalidOperationException) {
      }
    }

    // Find method test
    node = list.Find(0);
    if (node == null || node.Value != 0)
      throw new Exception("Find method test (1) failed");
    node = list.Find(47);
    if (node == null || node.Value != 47)
      throw new Exception("Find method test (2) failed");
    node = list.Find(190);
    if (node == null || node.Value != 190)
      throw new Exception("Find method test (3) failed");
    node = list.Find(-3);
    if (node != null)
      throw new Exception("Find method test (4) failed");

    // Remove method test
    if (!list.Remove(17) || list.Contains(17) || list.Last.Previous.Value == 17)
      throw new Exception("Remove method test (1) failed");
    if (!list.Remove(47) || list.Contains(47) || list.First.Next.Value == 47)
      throw new Exception("Remove method test (2) failed");
    if (!list.Remove(0) || list.Contains(0) || list.First.Value == 0)
      throw new Exception("Remove method test (3) failed");
    if (!list.Remove(190) || list.Contains(190) || list.Last.Value == 190)
      throw new Exception("Remove method test (4) failed");
    try {
      node = null;
      list.Remove(node);
      throw new Exception("Remove method test (5) failed");
    } catch (ArgumentNullException) {
      try {
          node = new IntList.IntListNode(4);
          list.Remove(node);         
          throw new Exception("Remove method test (5) failed");
      } catch (InvalidOperationException) {
      }
    }

    // ICollection constructor test
    {
      int[] intArray = new int[] { 0, 11, 22, 33, 44, 55, 33 };
      IntList il = new IntList(intArray);
      if (intArray.Length != il.Count)
        throw new Exception("ICollection constructor length check failed: " + intArray.Length + "-" + il.Count);
      node = il.First;
      for (int i = 0; i < intArray.Length; i++) {
        if (intArray[i] != node.Value)
          throw new Exception("ICollection constructor failed, index:" + i);
        node = node.Next;
      }
      try {
        new IntList((System.Collections.ICollection)null);
        throw new Exception("ICollection constructor null test failed");
      } catch (ArgumentNullException) {
      }
    }

    // Enumerator test
    {
      node = list.First;
      System.Collections.IEnumerator myEnumerator = list.GetEnumerator();
      while (myEnumerator.MoveNext()) {
        if ((int)myEnumerator.Current != node.Value)
          throw new Exception("Enumerator (1) test failed");
        node = node.Next;
      }
    }
    {
      node = list.First;
      System.Collections.Generic.IEnumerator<int> myEnumerator = list.GetEnumerator();
      while (myEnumerator.MoveNext()) {
        if (myEnumerator.Current != node.Value)
          throw new Exception("Enumerator (2) test failed");
        node = node.Next;
      }
    }
    {
      node = list.First;
      IntList.IntListEnumerator myEnumerator = list.GetEnumerator();
      while (myEnumerator.MoveNext()) {
        if (myEnumerator.Current != node.Value)
          throw new Exception("Enumerator (3) test failed");
        node = node.Next;
      }
    }
    {
      node = list.First;
      foreach (var elem in list) {
        if (elem != node.Value)
          throw new Exception("Enumerator (4) test failed");
        node = node.Next;
      }
    }
    
    // CopyTo method test
    {
      int[] outputarray = new int[collectionSize - 2];
      list.CopyTo(outputarray, 0);
      int index = 0;
      IntList.IntListNode temp = list.First;
      foreach (int val in outputarray) {
        if (temp.Value != val) {
          throw new Exception("CopyTo method test (1) failed, index:" + index);
        }
        index++;
        temp = temp.Next;
      }
    }
    {
      DoubleList inputlist = new DoubleList();
      int arrayLen = 10;
      for (int i = 0; i < arrayLen; i++) {
        double num = i * 10.1;
        inputlist.Add(num);
      }
      double[] outputarray = new double[arrayLen];
      inputlist.CopyTo(outputarray, 0);
      DoubleList.DoubleListNode temp = inputlist.First;
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i] != temp.Value)
          throw new Exception("CopyTo method test (2) failed, index:" + i);
        temp = temp.Next;
      }
    }
    {
      StructList inputlist = new StructList();
      int arrayLen = 10;
      for (int i = 0; i < arrayLen; i++)
        inputlist.Add(new Struct(i / 10.0));
      Struct[] outputarray = new Struct[arrayLen];
      inputlist.CopyTo(outputarray, 0);
      StructList.StructListNode temp = inputlist.First;
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i].num != temp.Value.num)
          throw new Exception("CopyTo method test (3) failed, index:" + i);
        temp = temp.Next;
      }
      foreach (Struct s in inputlist) {
        s.num += 20.0;
      }
      temp = inputlist.First;
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i].num != temp.Value.num)
          throw new Exception("CopyTo method test (4) failed, index:" + i);
        temp = temp.Next;
      }
    }
    try {
      list.CopyTo(null, 0);
      throw new Exception("CopyTo method test (5) failed");
    } catch (ArgumentNullException) {
    }
     
    // Clear() test
    list.Clear();
    if (list.Count != 0)
      throw new Exception("Clear method failed");

    // Finally test the methods being wrapped
    {
      IntList il = new IntList();
      for (int i = 0; i < 4; i++) {
        il.Add(i);
      }

      double x = li_std_list.average(il);
      x += li_std_list.average(new IntList(new int[] { 1, 2, 3, 4 }));

      DoubleList dlist = new DoubleList();
      for (int i = 0; i < 10; i++) {
        dlist.Add(i / 2.0);
      }
      li_std_list.halve_in_place(dlist);
    }

    // Dispose()
    {
      using (StructList ls = new StructList(new Struct[] { new Struct(0.0), new Struct(11.1) }))
      using (DoubleList ld = new DoubleList(new double[] { 0.0, 11.1 })) {  }
    }

    // More wrapped methods
    {
      FloatList l0 = li_std_list.listreal(new FloatList());
      float flo = 123.456f;
      l0.Add(flo);
      flo = l0.First.Value;

      IntList l1 = li_std_list.listint(new IntList());
      IntPtrList l2 = li_std_list.listintptr(new IntPtrList());
      IntConstPtrList l3 = li_std_list.listintconstptr(new IntConstPtrList());

      l1.Add(123);
      l2.Clear();
      l3.Clear();

      StructList l4 = li_std_list.liststruct(new StructList());
      StructPtrList l5 = li_std_list.liststructptr(new StructPtrList());
      StructConstPtrList l6 = li_std_list.liststructconstptr(new StructConstPtrList());

      l4.Add(new Struct(123));
      l5.Add(new Struct(123));
      l6.Add(new Struct(123));
    }

    // Test lists of pointers
    {
      StructPtrList inputlist = new StructPtrList();
      int arrayLen = 10;
      for (int i = 0; i < arrayLen; i++) {
        inputlist.Add(new Struct(i / 10.0));
      }
      Struct[] outputarray = new Struct[arrayLen];
      inputlist.CopyTo(outputarray, 0);
      StructPtrList.StructPtrListNode temp = inputlist.First;
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i].num != temp.Value.num)
          throw new Exception("StructPtrList test (1) failed, i:" + i);
        temp = temp.Next;
      }
      foreach (Struct s in inputlist) {
        s.num += 20.0;
      }
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i].num != 20.0 + i / 10.0)
          throw new Exception("StructPtrList test (2) failed (a deep copy was incorrectly made), i:" + i);
      }
    }

    // Test lists of const pointers
    {
      StructConstPtrList inputlist = new StructConstPtrList();
      int arrayLen = 10;
      for (int i = 0; i < arrayLen; i++) {
        inputlist.Add(new Struct(i / 10.0));
      }
      Struct[] outputarray = new Struct[arrayLen];
      inputlist.CopyTo(outputarray, 0);
      StructConstPtrList.StructConstPtrListNode temp = inputlist.First;
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i].num != temp.Value.num)
          throw new Exception("StructConstPtrList test (1) failed, i:" + i);
        temp = temp.Next;
      }
      foreach (Struct s in inputlist) {
        s.num += 20.0;
      }
      for (int i = 0; i < arrayLen; i++) {
        if (outputarray[i].num != 20.0 + i / 10.0)
          throw new Exception("StructConstPtrList test (2) failed (a deep copy was incorrectly made), i:" + i);
      }
    }
  }
}
