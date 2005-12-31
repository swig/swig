using System;
using System.Threading;
using operator_overloadNamespace;

public class runme
{
  static void Main() 
  {
    Op op = new Op(100);
    op++;
    if (op.i != 101) throw new Exception("operator++ failed");
    op--;
    if (op.i != 100) throw new Exception("operator-- failed");
  }
}


