using System;
using System.Threading;
using operator_overloadNamespace;

public class runme
{
  static void Main() 
  {
    Op.sanity_check();
    {
      Op op = new Op(100);
      Op opNew = op++;
      if (op.i != 101) throw new Exception("operator++ postfix failed (op)");
      if (opNew.i != 100) throw new Exception("operator++ postfix failed (opNew)");
    }
    {
      Op op = new Op(100);
      Op opNew = op--;
      if (op.i != 99) throw new Exception("operator-- postfix failed (op)");
      if (opNew.i != 100) throw new Exception("operator-- postfix failed (opNew)");
    }
    {
      Op op = new Op(100);
      Op opNew = ++op;
      if (op.i != 101) throw new Exception("operator++ prefix failed (op)");
      if (opNew.i != 101) throw new Exception("operator++ prefix failed (opNew)");
    }
    {
      Op op = new Op(100);
      Op opNew = --op;
      if (op.i != 99) throw new Exception("operator-- prefix failed (op)");
      if (opNew.i != 99) throw new Exception("operator-- prefix failed (opNew)");
    }

    // overloaded operator class
    Op k = new OpDerived(3);
    int check_k = k.IntCast();
    Assert(check_k == 6);

    // operator== handling
    {
      Op op = new Op(100);
      Op op100 = new Op(100);
      Op op101 = new Op(101);
      bool isEqual = op == op100;
      if (!isEqual) throw new Exception("operator== failed (op == op100)");
      isEqual = op100 == op;
      if (!isEqual) throw new Exception("operator== failed (op100 == op)");

      isEqual = op == op101;
      if (isEqual) throw new Exception("operator== failed (op == op101)");
      isEqual = op101 == op;
      if (isEqual) throw new Exception("operator== failed (op101 == op)");

      Op opRef = op;
      isEqual = op == opRef;
      if (!isEqual) throw new Exception("operator== failed (op == opRef)");
      isEqual = opRef == op;
      if (!isEqual) throw new Exception("operator== failed (opRef == op)");

      isEqual = op == null;
      if (isEqual) throw new Exception("operator== failed (op == null)");

      isEqual = null == op;
      if (isEqual) throw new Exception("operator== failed (null == op)");
    }
  }

  public static void Assert(bool b) {
    if (!b)
      throw new Exception("Assertion failed");
  }
}

