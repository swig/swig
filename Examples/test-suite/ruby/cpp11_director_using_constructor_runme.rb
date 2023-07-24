#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'cpp11_director_using_constructor'

include Cpp11_director_using_constructor

# Public base constructors
a = PublicDerived1.new(0, "hi").meth()
a = PublicDerived2.new().meth()
a = PublicDerived2.new(0, "hi").meth()
a = PublicDerived3.new().meth()
a = PublicDerived3.new(0, "hi").meth()
a = PublicDerived4.new().meth()
a = PublicDerived5.new().meth()

# Protected base constructors
# Cannot test most of these as the constructors are protected
ProtectedDerived5.new()

# Mix of public and overloaded constructors
MixedDerived1a.new(0, "hi").meth()
MixedDerived1a.new().meth()
MixedDerived1b.new(0, "hi").meth()
MixedDerived1b.new().meth()

MixedDerived2a.new(0, "hi").meth()
MixedDerived2a.new().meth()
MixedDerived2b.new(0, "hi").meth()
MixedDerived2b.new().meth()

MixedDerived2c.new(0, "hi").meth()
MixedDerived2c.new().meth()
MixedDerived2c.new(0).meth()

MixedDerived2d.new(0, "hi").meth()
MixedDerived2d.new().meth()
MixedDerived2d.new(0).meth()

MixedDerived3a.new(0, "hi").meth()
MixedDerived3a.new().meth()
MixedDerived3b.new(0, "hi").meth()
MixedDerived3b.new().meth()

MixedDerived3c.new(0, "hi").meth()
MixedDerived3c.new().meth()
MixedDerived3c.new(0).meth()

MixedDerived3d.new(0, "hi").meth()
MixedDerived3d.new().meth()
MixedDerived3d.new(0).meth()

MixedDerived4a.new(0, "hi").meth()
MixedDerived4a.new().meth()
MixedDerived4b.new(0, "hi").meth()
MixedDerived4b.new().meth()

MixedDerived4c.new().meth()
MixedDerived4c.new(0).meth()

MixedDerived4d.new().meth()
MixedDerived4d.new(0).meth()

MixedDerived4e.new().meth()

MixedDerived4f.new().meth()

# Mix of protected base constructors and overloading
ProotDerived1a.new().meth()

ProotDerived1b.new(0, "hi").meth()
ProotDerived1b.new().meth()

ProotDerived1c.new(0, "hi").meth()
ProotDerived1c.new().meth()

ProotDerived1d.new(0).meth()
ProotDerived1d.new().meth()

ProotDerived1e.new(0).meth()
ProotDerived1e.new().meth()

ProotDerived2a.new(0, "hi").meth()

ProotDerived2b.new(0, "hi").meth()

ProotDerived2c.new(0, "hi").meth()
ProotDerived2c.new().meth()

ProotDerived2d.new(0, "hi").meth()
ProotDerived2d.new().meth()

ProotDerived2e.new(0, "hi").meth()
ProotDerived2e.new().meth()

ProotDerived2f.new(0, "hi").meth()
ProotDerived2f.new().meth()
ProotDerived2f.new(0).meth()

# Missing base
# HiddenDerived1()

# Templates and public base constructors (derive from non-template)
TemplatePublicDerived1Int.new(0, "hi").meth()
TemplatePublicDerived2Int.new().meth()
TemplatePublicDerived2Int.new(0, "hi").meth()
TemplatePublicDerived3Int.new().meth()
TemplatePublicDerived3Int.new(0, "hi").meth()
TemplatePublicDerived4Int.new().meth()
TemplatePublicDerived5Int.new().meth()

# Templates and public base constructors (derive from template)
TemplPublicDerived1Int.new(0, "hi").meth()
TemplPublicDerived2Int.new().meth()
TemplPublicDerived2Int.new(0, "hi").meth()
TemplPublicDerived3Int.new().meth()
TemplPublicDerived3Int.new(0, "hi").meth()
TemplPublicDerived4Int.new().meth()
TemplPublicDerived5Int.new().meth()
TemplPublicDerived6Int.new(0, "hi").meth()
TemplPublicDerived6Int.new().meth()
