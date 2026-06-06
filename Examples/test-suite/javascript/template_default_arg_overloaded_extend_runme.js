var template_default_arg_overloaded_extend = require("template_default_arg_overloaded_extend");

function check(flag) {
  if (!flag) {
    throw new Error("failed");
  }
}

rs = new template_default_arg_overloaded_extend.ResultSet();

check(rs.go_get_method(0, new template_default_arg_overloaded_extend.SearchPoint()) == -1);
check(rs.go_get_method(0, new template_default_arg_overloaded_extend.SearchPoint(), 100) == 100);

check(rs.go_get_template(0, new template_default_arg_overloaded_extend.SearchPoint()) == -2);
check(rs.go_get_template(0, new template_default_arg_overloaded_extend.SearchPoint(), 100) == 100);

check(rs.over() == "over(int)");
check(rs.over(10) == "over(int)");
check(rs.over(new template_default_arg_overloaded_extend.SearchPoint()) == "over(giai2::SearchPoint, int)");
check(rs.over(new template_default_arg_overloaded_extend.SearchPoint(), 10) == "over(giai2::SearchPoint, int)");
check(rs.over(true, new template_default_arg_overloaded_extend.SearchPoint()) == "over(bool, gaia2::SearchPoint, int)");
check(rs.over(true, new template_default_arg_overloaded_extend.SearchPoint(), 10) == "over(bool, gaia2::SearchPoint, int)");
