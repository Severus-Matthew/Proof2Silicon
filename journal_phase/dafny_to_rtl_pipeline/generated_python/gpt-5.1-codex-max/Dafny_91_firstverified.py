import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import BinarySearch as BinarySearch

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: BinarySearch.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: BinarySearch

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def isSorted(arr):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((0) <= (d_0_i_)) and ((d_0_i_) <= (d_1_j_))) and ((d_1_j_) < ((arr).length(0)))) or (((arr)[d_0_i_]) <= ((arr)[d_1_j_]))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange(d_0_i_, (arr).length(0)), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(0, ((arr).length(0)) + (1)), True, lambda0_)

    @staticmethod
    def BinarySearch(arr, K):
        found: bool = False
        d_0_low_: int
        d_0_low_ = 0
        d_1_high_: int
        d_1_high_ = (arr).length(0)
        found = False
        while (d_0_low_) < (d_1_high_):
            d_2_mid_: int
            d_2_mid_ = (d_0_low_) + (_dafny.euclidian_division((d_1_high_) - (d_0_low_), 2))
            d_3_v_: int
            d_3_v_ = (arr)[d_2_mid_]
            if (d_3_v_) == (K):
                found = True
                return found
            elif (d_3_v_) < (K):
                d_0_low_ = (d_2_mid_) + (1)
            elif True:
                d_1_high_ = d_2_mid_
        found = False
        return found
        return found
