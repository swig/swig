/* Helper function to return tuples.
 * Jonah Beckford
 *
 * Derived from Lib/python/fragments.i; Author: Robin Dunn
 *
 * 
 */

%fragment("list_output_helper","header") %{
static C_word list_output_helper(C_word **ptr, C_word target, C_word o) 
  /* Prepends 'o' to list 'target'.  ptr must be from C_alloc and have
     room for 3 C_words. */
{
  if (!target || C_truep (C_undefinedp (target))) {  
    target = C_pair (ptr, o, C_SCHEME_END_OF_LIST);
  } else { 
    target = C_pair (ptr, o, target);
  }
  return target;
}
%}
