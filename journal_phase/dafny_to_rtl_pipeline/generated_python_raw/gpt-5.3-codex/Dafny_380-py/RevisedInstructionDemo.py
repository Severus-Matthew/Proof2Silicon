import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: RevisedInstructionDemo

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def IsMaxAt(a, idx):
        def lambda0_(forall_var_0_):
            d_0_k_: int = forall_var_0_
            return not (((0) <= (d_0_k_)) and ((d_0_k_) < ((a).length(0)))) or (((a)[d_0_k_]) <= ((a)[idx]))

        return (((0) <= (idx)) and ((idx) < ((a).length(0)))) and (_dafny.quantifier(_dafny.IntegerRange(0, (a).length(0)), True, lambda0_))

    @staticmethod
    def FindMaxIndex(a):
        idx: int = int(0)
        idx = 0
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((a).length(0)):
            if ((a)[idx]) < ((a)[d_0_i_]):
                idx = d_0_i_
            d_0_i_ = (d_0_i_) + (1)
        return idx

    @staticmethod
    def ComputeMaxValue(a):
        m: int = int(0)
        d_0_idx_: int
        out0_: int
        out0_ = default__.FindMaxIndex(a)
        d_0_idx_ = out0_
        m = (a)[d_0_idx_]
        return m

    @staticmethod
    def Demo():
        d_0_s_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 1)
        d_0_s_ = nw0_
        (d_0_s_)[(0)] = 42
        d_1_si_: int
        out0_: int
        out0_ = default__.FindMaxIndex(d_0_s_)
        d_1_si_ = out0_
        d_2_b_: _dafny.Array
        nw1_ = _dafny.Array(int(0), 6)
        d_2_b_ = nw1_
        rhs0_ = -7
        rhs1_ = 3
        rhs2_ = 3
        rhs3_ = -2
        rhs4_ = 1
        rhs5_ = 0
        lhs0_ = d_2_b_
        lhs1_ = 0
        lhs2_ = d_2_b_
        lhs3_ = 1
        lhs4_ = d_2_b_
        lhs5_ = 2
        lhs6_ = d_2_b_
        lhs7_ = 3
        lhs8_ = d_2_b_
        lhs9_ = 4
        lhs10_ = d_2_b_
        lhs11_ = 5
        lhs0_[lhs1_] = rhs0_
        lhs2_[lhs3_] = rhs1_
        lhs4_[lhs5_] = rhs2_
        lhs6_[lhs7_] = rhs3_
        lhs8_[lhs9_] = rhs4_
        lhs10_[lhs11_] = rhs5_
        d_3_bi_: int
        out1_: int
        out1_ = default__.FindMaxIndex(d_2_b_)
        d_3_bi_ = out1_
        d_4_bm_: int
        out2_: int
        out2_ = default__.ComputeMaxValue(d_2_b_)
        d_4_bm_ = out2_

