exec("swigtest.start", -1);

// A function with parameter bb cannot be called, as Scilab expects its argout typemap to add an output, which it does not
checkequal(jaguar(200, 0), "hello", "jaguar(200, 0)");
checkequal(tvr("bar", 2), 8.8, "tvr(""bar"", 2)");
checkequal(fiat(17), 17, "fiat(17)");

car = new_SportsCars();
checkequal(SportsCars_daimler(car, 200, 0), "hello", "SportsCars_daimler(car, 200, 0)");
checkequal(SportsCars_bugatti(car, "bar", 2), 8.8, "SportsCars_bugatti(car, ""bar"", 2)");
checkequal(SportsCars_maseratti(car, 289), 289, "SportsCars_maseratti(car, 289)");
checkequal(SportsCars_audi(car), 8.8, "SportsCars_audi(car)");
delete_SportsCars(car);

delete_MiniCooper(new_MiniCooper(200, 0));
delete_FordAnglia(new_FordAnglia("quux", 200));

exec("swigtest.quit", -1);
