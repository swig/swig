open Swig
open Template_default_arg_overloaded_extend

let _ =
  let rs = new_ResultSet '() and sp = new_SearchPoint '() in
  assert (rs -> go_get_method (0, sp) as int = -1);
  assert (rs -> go_get_method (0, sp, 100) as int = 100);
  assert (rs -> go_get_template (0, sp) as int = -2);
  assert (rs -> go_get_template (0, sp, 100) as int = 100);

  assert (rs -> over () as string = "over(int)");
  assert (rs -> over (10) as string = "over(int)");
  assert (rs -> over (sp) as string = "over(giai2::SearchPoint, int)");
  assert (rs -> over (sp, 10) as string = "over(giai2::SearchPoint, int)");
  assert (rs -> over (true, sp) as string = "over(bool, gaia2::SearchPoint, int)");
  assert (rs -> over (true, sp, 10) as string = "over(bool, gaia2::SearchPoint, int)");
;;
