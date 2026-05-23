import import_share_a
import import_share_c
import import_share_b

# Test cross-module type cast: DenseMatrix (module B) to Operator (module A)
dm = import_share_b.DenseMatrix(100, 200)
height = import_share_a.Operator_Height(dm)
if height != 100:
    raise RuntimeError("Expected 100, got " + str(height))

# Test factory function: Make_DenseMatrix (module C) returns Operator*
op = import_share_c.Make_DenseMatrix(50, 60)
height = import_share_a.Operator_Height(op)
if height != 50:
    raise RuntimeError("Expected 50, got " + str(height))
