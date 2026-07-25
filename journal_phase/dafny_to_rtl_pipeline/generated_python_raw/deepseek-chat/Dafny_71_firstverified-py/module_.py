import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def MultiplyMatrices(A, B):
        C: _dafny.Array = _dafny.Array(None, 0, 0)
        d_0_rowsA_: int
        d_0_rowsA_ = (A).length(0)
        d_1_colsA_: int
        d_1_colsA_ = (A).length(1)
        d_2_colsB_: int
        d_2_colsB_ = (B).length(1)
        nw0_ = _dafny.Array(int(0), d_0_rowsA_, d_2_colsB_)
        C = nw0_
        hi0_ = d_0_rowsA_
        for d_3_i_ in range(0, hi0_):
            hi1_ = d_2_colsB_
            for d_4_j_ in range(0, hi1_):
                d_5_sum_: int
                d_5_sum_ = 0
                hi2_ = d_1_colsA_
                for d_6_k_ in range(0, hi2_):
                    d_5_sum_ = (d_5_sum_) + (((A)[d_3_i_, d_6_k_]) * ((B)[d_6_k_, d_4_j_]))
                (C)[(d_3_i_), (d_4_j_)] = d_5_sum_
        return C

    @staticmethod
    def SumProduct(A, B, i, j):
        if ((A).length(1)) == (0):
            return 0
        elif True:
            return default__.SumProductK(A, B, i, j, (A).length(1))

    @staticmethod
    def SumProductK(A, B, i, j, k):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (k) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (((A)[i, (k) - (1)]) * ((B)[(k) - (1), j])) + (d_0___accumulator_)
                    in0_ = A
                    in1_ = B
                    in2_ = i
                    in3_ = j
                    in4_ = (k) - (1)
                    A = in0_
                    B = in1_
                    i = in2_
                    j = in3_
                    k = in4_
                    raise _dafny.TailCall()
                break

