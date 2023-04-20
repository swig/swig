using System;
using director_wstringNamespace;

public class runme
{
    static void Main()
    {
        runme r = new runme();
        r.run();
    }

    void run()
    {
        director_wstring_B b = new director_wstring_B("hello");

        b.get(0);
        if (b.get_first() != "hello world!")
            throw new ApplicationException("Incorrect get_first:" + b.get_first());

        b.call_process_func();
        if (b.smem != "hello")
            throw new ApplicationException("Incorrect smem:" + b.smem);

        b.call_process_wstring_func();
        if (b.smem != "hello (wstring)")
            throw new ApplicationException("Incorrect smem:" + b.smem);

        b.call_process_wstring_ref_func();
        if (b.smem != "hello (wstring ref)")
            throw new ApplicationException("Incorrect smem:" + b.smem);
    }
}

class director_wstring_B : A
{
    public String smem;
    public director_wstring_B(String first) : base(first)
    {
    }
    public override String get_first()
    {
        return base.get_first() + " world!";
    }
    public override void process_text(String s)
    {
        this.smem = s;
    }
    public override void process_wstring_text(String s)
    {
        this.smem = s + " (wstring)";
    }
    public override void process_wstring_ref_text(String s)
    {
        this.smem = s + " (wstring ref)";
    }
}
