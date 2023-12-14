var template_default_arg_overloaded_extend = require("template_default_arg_overloaded_extend");

function check(flag) {
  if (!flag) {
    throw new Error("failed");
  }
}

var rs = new template_default_arg_overloaded_extend.ResultSet();

check(/* await */(rs.go_get_method(0, new template_default_arg_overloaded_extend.SearchPoint())) == -1);
check(/* await */(rs.go_get_method(0, new template_default_arg_overloaded_extend.SearchPoint(), 100)) == 100);

check(/* await */(rs.go_get_template(0, new template_default_arg_overloaded_extend.SearchPoint())) == -2);
check(/* await */(rs.go_get_template(0, new template_default_arg_overloaded_extend.SearchPoint(), 100)) == 100);

check(/* await */(rs.over()) == "over(int)");
check(/* await */(rs.over(10)) == "over(int)");
check(/* await */(rs.over(new template_default_arg_overloaded_extend.SearchPoint())) == "over(giai2::SearchPoint, int)");
check(/* await */(rs.over(new template_default_arg_overloaded_extend.SearchPoint(), 10)) == "over(giai2::SearchPoint, int)");
check(/* await */(rs.over(true, new template_default_arg_overloaded_extend.SearchPoint())) == "over(bool, gaia2::SearchPoint, int)");
check(/* await */(rs.over(true, new template_default_arg_overloaded_extend.SearchPoint(), 10)) == "over(bool, gaia2::SearchPoint, int)");
