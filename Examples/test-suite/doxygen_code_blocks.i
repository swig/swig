%module doxygen_code_blocks

// This test is only used with Python

%inline %{

/**
 * \brief Test for code blocks
 *
 * \code
 * simple code block
 * \endcode
 *
 * More advanced usage with C++ characters:
 * \code
 * std::vector<int> first;                                // empty vector of ints
 * std::vector<int> second (4,100);                       // four ints with value 100
 * std::vector<int> third (second.begin(),second.end());  // iterating through second
 * std::vector<int> fourth (third);                       // a copy of third
 *  // the iterator constructor can also be used to construct from arrays:
 * int myints[] = {16,2,77,29};
 * std::vector<int> fifth (myints, myints + sizeof(myints) / sizeof(int) );
 *
 * std::cout << "The contents of fifth are:";
 * for (std::vector<int>::iterator it = fifth.begin(); it != fifth.end(); ++it)
 *   std::cout << ' ' << *it;
 * std::cout << '\n'; 
 * \endcode
 *
 * A code block for C:
 * \code{.c}
 * printf("hello world");
 * \endcode
 *
 * A code block for Java:
 * \code{.java}
 * public class HelloWorld {
 *     public static void main(String[] args) {
 *         // Prints "Hello, World" to the terminal window.
 *         System.out.println("Hello, World");
 *     }
 * }
 * \endcode
 * 
 * A code block for python:
 * \code{.py}
 * print('hello world')
 * \endcode
 *
 * A python doctest example:
 * \code{.py}
 * >>> 1 + 1
 * 2
 * \endcode
 */
int function()
{
    return 0;
}  


%}
