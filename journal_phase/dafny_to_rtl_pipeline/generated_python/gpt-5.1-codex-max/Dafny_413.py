import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import SelectionSort as SelectionSort

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: SelectionSort.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: SelectionSort

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def sorted_(s):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((0) <= (d_0_i_)) and ((d_0_i_) < (d_1_j_))) and ((d_1_j_) < (len(s)))) or (((s)[d_0_i_]) <= ((s)[d_1_j_]))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange((d_0_i_) + (1), len(s)), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(0, len(s)), True, lambda0_)

    @staticmethod
    def SelectionSort(arr):
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((arr).length(0)):
            d_1_minIdx_: int
            d_1_minIdx_ = d_0_i_
            d_2_j_: int
            d_2_j_ = (d_0_i_) + (1)
            while (d_2_j_) < ((arr).length(0)):
                if ((arr)[d_2_j_]) < ((arr)[d_1_minIdx_]):
                    d_1_minIdx_ = d_2_j_
                d_2_j_ = (d_2_j_) + (1)
            if (d_1_minIdx_) != (d_0_i_):
                d_3_tmp_: int
                d_3_tmp_ = (arr)[d_0_i_]
                (arr)[(d_0_i_)] = (arr)[d_1_minIdx_]
                (arr)[(d_1_minIdx_)] = d_3_tmp_
            d_0_i_ = (d_0_i_) + (1)
