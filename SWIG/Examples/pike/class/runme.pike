import .example;

int main()
{
    // ----- Object creation -----

    write("Creating some objects:\n");
    Circle c = Circle(10.0);
    // write("    Created circle " + (string) c + ".\n");
    write("    Created circle.\n");
    Square s = Square(10.0);
    // write("    Created square " + (string) s + ".\n");
    write("    Created square.\n");

    // ----- Access a static member -----

    // write("\nA total of " + Shape->nshapes + " shapes were created\n");

    // ----- Member data access -----

    // Set the location of the object

    // c->x = 20.0;
    // c->y = 30.0;
    c->x_set(20.0);
    c->y_set(30.0);

    // s->x = -10.0;
    // s->y = 5.0;
    s->x_set(-10.0);
    s->y_set(5.0);

    write("\nHere is their current position:\n");
    // write(sprintf("    Circle = (%f, %f)\n", c->x, c->y));
    // write(sprintf("    Square = (%f, %f)\n", s->x, s->y));
    write(sprintf("    Circle = (%f, %f)\n", c->x_get(), c->y_get()));
    write(sprintf("    Square = (%f, %f)\n", s->x_get(), s->y_get()));

    // ----- Call some methods -----

    write("\nHere are some properties of the shapes:\n");
    write("   The circle:\n");
    write(sprintf("        area      = %f.\n", c->area()));
    write(sprintf("        perimeter = %f.\n", c->perimeter()));
    // write("   " + (string) s + ".\n");
    write("   The square:\n");
    write(sprintf("        area      = %f.\n", s->area()));
    write(sprintf("        perimeter = %f.\n", s->perimeter()));

    write("\nGuess I'll clean up now\n");

    // Note: this invokes the virtual destructor
    // del c;
    // del s;

    // s = 3;
    // write(sprintf("%d shapes remain\n", Shape->nshapes));
    write("Goodbye\n");
    
    return 0;
}
