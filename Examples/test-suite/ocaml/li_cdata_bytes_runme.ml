open Swig
open Li_cdata_bytes

let m = _predefStr '();;
let s = _cdata '(m, 512) as string;;

for i = 0 to 255 do
  let c = (String.get s i) in
  let v = (Char.code c) in
  assert (v = i);
  let i2 = i + 256 in
  let c2 = (String.get s i2) in
  let v2 = (Char.code c2) in
  assert (v2 = i);
done;;

let s2 = ref ("");;

for i = 0 to 255 do
  let d = 255 - i in
  let c = (Char.chr d) in
  let s0 = (String.make 1 c) in
  s2 := (String.cat !s2 s0);
done;;

let _ =
  let s3 = (String.cat !s2 !s2) in
  let m2 = _malloc '(512) in
  let _ = _memmove '(m2, (C_string s3)) in
  let r = _verifyBytes '(m2) as int in
  let _ = _free '(m2) in
  assert (r = 0);
;;
