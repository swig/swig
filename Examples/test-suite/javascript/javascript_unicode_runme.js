var str = "olé";

var copy = javascript_unicode.copy_string(str);

if (str !== copy) {
	print("Error: copy is not equal: original="+str+", copy="+copy);
}
