#
# Perl5 script for testing simple example

use example;
package example;

print get_time();
print "My Variable = $My_variable","\n";
for ($i = 0; $i < 14; $i++) {
    $n = fact($i);
    print "$i factorial is $n\n";
}

for ($i = 1; $i < 250; $i++) {
    for ($j = 1; $j < 250; $j++) {
	$n = mod($i,$j);
	$My_variable = $My_variable + $n;
    }
}

print "My_variable = ", $My_variable, "\n";


