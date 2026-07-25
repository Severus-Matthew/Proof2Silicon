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
    def SelectionSort(a):
        d_0_n_: int
        d_0_n_ = (a).length(0)
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (d_0_n_):
            d_2_minIndex_: int
            d_2_minIndex_ = d_1_i_
            d_3_j_: int
            d_3_j_ = (d_1_i_) + (1)
            while (d_3_j_) < (d_0_n_):
                if ((a)[d_3_j_]) < ((a)[d_2_minIndex_]):
                    d_2_minIndex_ = d_3_j_
                d_3_j_ = (d_3_j_) + (1)
            d_4_temp_: int
            d_4_temp_ = (a)[d_1_i_]
            (a)[(d_1_i_)] = (a)[d_2_minIndex_]
            (a)[(d_2_minIndex_)] = d_4_temp_
            d_1_i_ = (d_1_i_) + (1)

    @staticmethod
    def sorted_(s):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((0) <= (d_0_i_)) and ((d_0_i_) < (d_1_j_))) and ((d_1_j_) < (len(s)))) or (((s)[d_0_i_]) <= ((s)[d_1_j_]))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange((d_0_i_) + (1), len(s)), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(0, len(s)), True, lambda0_)

