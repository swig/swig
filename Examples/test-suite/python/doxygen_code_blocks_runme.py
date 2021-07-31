import doxygen_code_blocks
import inspect
import string
import sys
import comment_verifier

comment_verifier.check(inspect.getdoc(doxygen_code_blocks.function),
    """\
Test for code blocks

.. code-block:: c++

    simple code block

More advanced usage with C++ characters:

.. code-block:: c++

    std::vector<int> first;                                // empty vector of ints
    std::vector<int> second (4,100);                       // four ints with value 100
    std::vector<int> third (second.begin(),second.end());  // iterating through second
    std::vector<int> fourth (third);                       // a copy of third
     // the iterator constructor can also be used to construct from arrays:
    int myints[] = {16,2,77,29};
    std::vector<int> fifth (myints, myints + sizeof(myints) / sizeof(int) );

    std::cout << "The contents of fifth are:";
    for (std::vector<int>::iterator it = fifth.begin(); it != fifth.end(); ++it)
      std::cout << ' ' << *it;
    std::cout << '\\n';

A code block for C:

.. code-block:: c

    printf("hello world");

A code block for Java:

.. code-block:: java

    public class HelloWorld {
        public static void main(String[] args) {
            // Prints "Hello, World" to the terminal window.
            System.out.println("Hello, World");
        }
    }

A code block for python:

.. code-block:: python

    print('hello world')

A python doctest example:

>>> 1 + 1
2""")
