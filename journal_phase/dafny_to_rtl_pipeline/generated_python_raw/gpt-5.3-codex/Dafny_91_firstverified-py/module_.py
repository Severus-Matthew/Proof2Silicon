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
    def isSorted(a):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((0) <= (d_0_i_)) and ((d_0_i_) <= (d_1_j_))) and ((d_1_j_) < ((a).length(0)))) or (((a)[d_0_i_]) <= ((a)[d_1_j_]))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange(d_0_i_, (a).length(0)), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(0, ((a).length(0)) + (1)), True, lambda0_)

    @staticmethod
    def binarySearch(K, A):
        idx: int = int(0)
        d_0_lo_: int
        d_0_lo_ = 0
        d_1_hi_: int
        d_1_hi_ = ((A).length(0)) - (1)
        while (d_0_lo_) <= (d_1_hi_):
            d_2_mid_: int
            d_2_mid_ = (d_0_lo_) + (_dafny.euclidian_division((d_1_hi_) - (d_0_lo_), 2))
            if ((A)[d_2_mid_]) == (K):
                idx = d_2_mid_
                return idx
            elif ((A)[d_2_mid_]) < (K):
                d_0_lo_ = (d_2_mid_) + (1)
            elif True:
                d_1_hi_ = (d_2_mid_) - (1)
        idx = 0
        return idx

