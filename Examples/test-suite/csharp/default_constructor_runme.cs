using System;

public class runme
{
    static void Main() 
    {
        // calling protected destructor test
        try {
            using (G g = new G()) {
            }
            throw new Exception("Protected destructor exception should have been thrown");
        } catch (MethodAccessException e) {
        }

        // calling private destructor test
        try {
            using (FFF f = new FFF()) {
            }
            throw new Exception("Private destructor exception should have been thrown");
        } catch (MethodAccessException e) {
        }
    }
}
