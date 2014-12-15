// Test the goin, goout, and goargout typemaps.

%module go_inout

%{
#include <string>
#include <vector>
#include <stdint.h>
%}

%inline
%{

struct MyStruct {
  std::string str;
};

struct RetStruct {
  std::string str;
};

%}

// Write a typemap that calls C++ by converting in and out of JSON.

%go_import("encoding/json", "bytes", "encoding/binary")

%insert(go_header)
%{

type In json.Marshaler

%}

%typemap(gotype) MyStruct "In"

%typemap(imtype) MyStruct "string"

%typemap(goin) MyStruct
%{
	{
		b, err := $input.MarshalJSON()
		if err != nil {
			panic(err)
		}
		$result = string(b)
	}
%}

%typemap(in) MyStruct
%{
  $1.str.assign($input.p, $input.n);
%}

%typemap(gotype) RetStruct "map[string]interface{}"

%typemap(imtype) RetStruct "string"

%typemap(out) RetStruct
%{
  $result = _swig_makegostring($1.str.data(), $1.str.length());
%}

%typemap(goout) RetStruct
%{
	if err := json.Unmarshal([]byte($1), &$result); err != nil {
		panic(err)
	}
%}

%inline
%{

RetStruct Same(MyStruct s)
{
  RetStruct r;
  r.str = s.str;
  return r;
}

%}

%inline
%{

struct MyArray {
  std::vector<std::string> strings;
};

static uint64_t getuint64(const char* s) {
  uint64_t ret = 0;
  for (int i = 0; i < 8; i++, s++) {
    ret |= static_cast<uint64_t>(*s) << i * 8;
  }
  return ret;
}

static void putuint64(std::string *s, size_t off, uint64_t v) {
  for (int i = 0; i < 8; i++) {
    (*s)[off + i] = (v >> (i * 8)) & 0xff;
  }
}

%}

%typemap(gotype) MyArray* "*[]string"

%typemap(imtype) MyArray* "*string"

// Encode the slice as a single string, with length prefixes.
%typemap(goin) MyArray*
%{
	{
		var buf bytes.Buffer
		bin := binary.LittleEndian
		var b [8]byte
		bin.PutUint64(b[:], uint64(len(*$input)))
		buf.Write(b[:])
		for _, s := range *$input {
			bin.PutUint64(b[:], uint64(len(s)))
			buf.Write(b[:])
			buf.WriteString(s)
		}
		str := buf.String()
		$result = &str
	}
%}

// Unpack the string holding the packed slice.
%typemap(in) MyArray* (MyArray t)
%{
  {
    _gostring_ *s = $input;
    const char *p = static_cast<const char *>(s->p);
    uint64_t len = getuint64(p);
    p += 8;
    t.strings.resize(len);
    for (uint64_t i = 0; i < len; i++) {
      uint64_t slen = getuint64(p);
      p += 8;
      t.strings[i].assign(p, slen);
      p += slen;
    }
    $1 = &t;
  }
%}

// Pack the vector into a string.
%typemap(argout) MyArray*
%{
  {
    size_t tot = 8;
    std::vector<std::string>::const_iterator p;
    for (p = $1->strings.begin(); p != $1->strings.end(); ++p) {
      tot += 8 + p->size();
    }
    std::string str;
    str.resize(tot);
    putuint64(&str, 0, $1->strings.size());
    size_t off = 8;
    for (p = $1->strings.begin(); p != $1->strings.end(); ++p) {
      putuint64(&str, off, p->size());
      off += 8;
      str.replace(off, p->size(), *p);
      off += p->size();
    }
    *$input = _swig_makegostring(str.data(), str.size());
  }
%}

// Unpack the string into a []string.
%typemap(goargout) MyArray*
%{
	{
		str := *$input
		bin := binary.LittleEndian
		size := bin.Uint64([]byte(str[:8]))
		str = str[8:]
		r := make([]string, size)
		for i := range r {
			len := bin.Uint64([]byte(str[:8]))
			str = str[8:]
			r[i] = str[:len]
			str = str[len:]
		}
		*$1 = r
	}
  
%}

%inline
%{
void DoubleArray(MyArray* v) {
  size_t size = v->strings.size();
  for (size_t i = 0; i < size; i++) {
    v->strings.push_back(v->strings[i] + v->strings[i]);
  }
}
%}
