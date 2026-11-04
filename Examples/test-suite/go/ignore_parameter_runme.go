package main

import "swigtests/ignore_parameter"

func check(what string, actual, expected interface{}) {
	if actual != expected {
		panic(what)
	}
}

func main() {
	check("jaguar", ignore_parameter.Jaguar(200, 0), "hello")
	check("lotus", ignore_parameter.Lotus("foo", 1), 101)
	check("tvr", ignore_parameter.Tvr("bar", 2), 8.8)
	check("ferrari", ignore_parameter.Ferrari(), 101)
	check("called_argout", ignore_parameter.GetCalled_argout(), 1)
	check("called_freearg", ignore_parameter.GetCalled_freearg(), 1)
	check("fiat", ignore_parameter.Fiat(17), 17)

	car := ignore_parameter.NewSportsCars()
	check("daimler", car.Daimler(200, 0), "hello")
	check("astonmartin", car.Astonmartin("foo", 1), 101)
	check("bugatti", car.Bugatti("bar", 2), 8.8)
	check("lamborghini", car.Lamborghini(), 101)
	check("maseratti", car.Maseratti(289), 289)
	check("audi", car.Audi(), 8.8)
	ignore_parameter.DeleteSportsCars(car)

	ignore_parameter.DeleteMiniCooper(ignore_parameter.NewMiniCooper(200, 0))
	ignore_parameter.DeleteMorrisMinor(ignore_parameter.NewMorrisMinor("baz", 0))
	ignore_parameter.DeleteFordAnglia(ignore_parameter.NewFordAnglia("quux", 200))
	ignore_parameter.DeleteAustinAllegro(ignore_parameter.NewAustinAllegro())
}
