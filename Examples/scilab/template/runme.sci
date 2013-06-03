function printShape(shape, name)
    printf("\nShape %s position:\n", name);
    printf("  (x, y) = (%f, %f)\n", ShapeDouble_x_get(shape), ShapeDouble_y_get(shape))

    printf("\nShape %s properties:\n", name);
    printf("  area      = %f\n", ShapeDouble_area(shape));
    printf("  perimeter = %f\n", ShapeDouble_perimeter(shape));

    printf("\n");
endfunction

exec loader.sce;

printf("Creating some objects:\n");
c = new_CircleDouble(10);
s = new_SquareDouble(10);

printf("\nA total of %i shapes were created\n", ShapeDouble_getNbShapes());

ShapeDouble_move(c, 20, 30);
ShapeDouble_move(s, -10, 0);

printShape(c, "circle");
printShape(s, "square");

printf("\nGuess I will clean up now\n");

delete_CircleDouble(c);
delete_SquareDouble(s);

printf("%i shapes remain\n", ShapeDouble_getNbShapes());

