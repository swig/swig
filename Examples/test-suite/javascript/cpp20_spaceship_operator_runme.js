var cpp20_spaceship_operator = require("cpp20_spaceship_operator");

function check_equal(a, b) {
    if (a != b) {
        throw new Error("{} is not equal to {}".format(a, b));
    }
}

check_equal(cpp20_spaceship_operator.ALIEN, 1);
check_equal(cpp20_spaceship_operator.SPACE, 1);
check_equal(cpp20_spaceship_operator.COMET, 1);
check_equal(cpp20_spaceship_operator.v, 42);

x = new cpp20_spaceship_operator.A(1);
y = new cpp20_spaceship_operator.A(2);

check_equal(cpp20_spaceship_operator.spaceship(x, y) < 0, true);
check_equal(cpp20_spaceship_operator.spaceship(x, x), 0);
check_equal(cpp20_spaceship_operator.spaceship(y, x) > 0, true);

check_equal(cpp20_spaceship_operator.f(), 42);
