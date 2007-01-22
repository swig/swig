/* Small change to the standard carrays.i
renaming the field to __getitem__ & __setitem__ 
for operator[] access

Thanks to Fabian Franz <FabianFranz@gmx.de> for suggesting this 
*/
%rename(__getitem) *::getitem; // the v=X[i] (get operator)
%rename(__setitem) *::setitem; // the X[i]=v (set operator)

%include <../carrays.i>
