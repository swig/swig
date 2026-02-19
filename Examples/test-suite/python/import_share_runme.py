import import_share_c
import import_share_b
import import_share_a

dm = import_share_b.DenseMatrix(100, 200)
# dm = import_share_c.Make_DenseMatrix(10, 20)
height = import_share_a.Operator_Height(dm)
print(height)
