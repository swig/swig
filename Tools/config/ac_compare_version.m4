dnl @synopsis AC_COMPARE_VERSION\
dnl  (version-a, version-b, action-if-greater, action-if-equal, action-if-less)
dnl 
dnl This macro compares two version numbers and executes the indicated action
dnl based on whether they're equal or one is greater than the other.
dnl It's needed to determine whether ocaml is new enough that the incompatible
dnl change 'loc' -> '_loc' is present in this version of camlp4.
dnl 
dnl It's implemented from scratch just for SWIG by arty.
dnl
dnl @category Misc
dnl @author arty
dnl @version 2006-11-02
dnl @license GPLWithACException

AC_DEFUN([AC_COMPARE_VERSION], [
	# Split the version into units.
	ver_a="[$1]"
	ver_b="[$2]"
	nodots_a=`echo $ver_a | sed -e 's/\./ /g'`
	condition="equal"
	isolate_b_regex='\([[0-9]]\+\).*'
	for ver_part in $nodots_a ; do
		b_ver_part=`echo "$ver_b" | sed -e 's/'"$isolate_b_regex"'/\1/'`
		if test \( "$ver_part" -lt "$b_ver_part" \) -a \( "x$condition" == "xequal" \) ; then
			condition=less
		elif test \( "$ver_part" -gt "$b_ver_part" \) -a \( "x$condition" == "xequal" \) ; then
			condition=greater
		fi
		isolate_b_regex='[[0-9]]\+\.'"$isolate_b_regex"
	done

	if test "x$condition" == "xequal" ; then
		[$4]
	elif test "x$condition" == "xless" ; then
		[$3]
	elif test "x$condition" == "xgreater" ; then
		[$5]
	fi
])