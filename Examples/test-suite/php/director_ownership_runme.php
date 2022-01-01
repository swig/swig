<?php
require "tests.php";

check::functions(array('make_content'));
check::classes(array('ContentBase','ContentDerived','Container','director_ownership'));
// No new vars
check::globals(array());

function set_content_and_release(Container $container, ContentBase $content) {
  $content->thisown = false;
  $container->set_content($content);
}

$container = new Container();

// make a content in PHP (newobject is 1)
$content_php = new ContentDerived();

// make a content in C++ (newobject is 1)
$content_cpp = make_content();

set_content_and_release($container, $content_php);
check::equal($container->get_content()->get_name(), "ContentDerived", "get_content() not ContentDerived");

set_content_and_release($container, $content_cpp);
check::equal($container->get_content()->get_name(), "ContentDerived", "get_content() not ContentDerived");

check::done();
