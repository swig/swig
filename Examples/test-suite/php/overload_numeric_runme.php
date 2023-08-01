<?php
require "tests.php";

$nums = new Nums();
$limits = new Limits();

check::equal($nums->over(0), "signed char", '$nums->over(0)');
check::equal($nums->over(0.0), "float", '$nums->over(0.0)');

check::equal($nums->over($limits->schar_min()), "signed char", '$nums->over($limits->schar_min())');
check::equal($nums->over($limits->schar_max()), "signed char", '$nums->over($limits->schar_max())');

check::equal($nums->over($limits->schar_min() - 1), "short", '$nums->over($limits->schar_min() - 1)');
check::equal($nums->over($limits->schar_max() + 1), "short", '$nums->over($limits->schar_max() + 1)');
check::equal($nums->over($limits->shrt_min()), "short", '$nums->over($limits->shrt_min())');
check::equal($nums->over($limits->shrt_max()), "short", '$nums->over($limits->shrt_max())');

check::equal($nums->over($limits->shrt_min() - 1), "int", '$nums->over($limits->shrt_min() - 1)');
check::equal($nums->over($limits->shrt_max() + 1), "int", '$nums->over($limits->shrt_max() + 1)');
check::equal($nums->over($limits->int_min()), "int", '$nums->over($limits->int_min())');
check::equal($nums->over($limits->int_max()), "int", '$nums->over($limits->int_max())');

check::equal($nums->over($limits->flt_min()), "float", '$nums->over($limits->flt_min())');
check::equal($nums->over($limits->flt_max()), "float", '$nums->over($limits->flt_max())');

check::equal($nums->over($limits->flt_max() * 10), "double", '$nums->over($limits->flt_max() * 10)');
check::equal($nums->over(-$limits->flt_max() * 10), "double", '$nums->over(-$limits->flt_max() * 10)');
check::equal($nums->over($limits->dbl_max()), "double", '$nums->over($limits->dbl_max())');
check::equal($nums->over(-$limits->dbl_max()), "double", '$nums->over(-$limits->dbl_max())');

check::equal($nums->over(INF), "float", '$nums->over(INF)');
check::equal($nums->over(-INF), "float", '$nums->over(-INF)');
check::equal($nums->over(NAN), "float", '$nums->over(NAN)');

// Just check if the following are accepted without exceptions being thrown
$nums->doublebounce(INF);
$nums->doublebounce(-INF);
$nums->doublebounce(NAN);

check::done();
