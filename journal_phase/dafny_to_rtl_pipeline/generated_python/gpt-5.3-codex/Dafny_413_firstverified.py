import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import SelectionSortModule as SelectionSortModule

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: SelectionSortModule.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: SelectionSortModule

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def IsSorted(a, lo, hi):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((lo) <= (d_0_i_)) and ((d_0_i_) < (d_1_j_))) and ((d_1_j_) < (hi))) or (((a)[d_0_i_]) <= ((a)[d_1_j_]))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange((d_0_i_) + (1), hi), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(lo, hi), True, lambda0_)

    @staticmethod
    def SelectionSort(a):
        d_0_n_: int
        d_0_n_ = (a).length(0)
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (d_0_n_):
            d_2_min_: int
            d_2_min_ = d_1_i_
            d_3_j_: int
            d_3_j_ = (d_1_i_) + (1)
            while (d_3_j_) < (d_0_n_):
                if ((a)[d_3_j_]) < ((a)[d_2_min_]):
                    d_2_min_ = d_3_j_
                d_3_j_ = (d_3_j_) + (1)
            if (d_2_min_) != (d_1_i_):
                d_4_tmp_: int
                d_4_tmp_ = (a)[d_1_i_]
                (a)[(d_1_i_)] = (a)[d_2_min_]
                (a)[(d_2_min_)] = d_4_tmp_
            d_1_i_ = (d_1_i_) + (1)
