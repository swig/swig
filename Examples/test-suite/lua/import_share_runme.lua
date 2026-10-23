require("import_share_a")
require("import_share_c")
require("import_share_b")

-- Test cross-module type cast: DenseMatrix (module B) to Operator (module A)
local dm = import_share_b.DenseMatrix(100, 200)
local height = import_share_a.Operator_Height(dm)
assert(height == 100, "Expected 100, got " .. height)

-- Test factory function: Make_DenseMatrix (module C) returns Operator*
local op = import_share_c.Make_DenseMatrix(50, 60)
height = import_share_a.Operator_Height(op)
assert(height == 50, "Expected 50, got " .. height)
