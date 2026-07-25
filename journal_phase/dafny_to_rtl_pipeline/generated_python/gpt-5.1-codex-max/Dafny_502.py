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
    def SortedDesc(s, key):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((0) <= (d_0_i_)) and ((d_0_i_) < (d_1_j_))) and ((d_1_j_) < (len(s)))) or ((key((s)[d_1_j_])) < (key((s)[d_0_i_])))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange((d_0_i_) + (1), len(s)), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(0, len(s)), True, lambda0_)

    @staticmethod
    def SwapPreservesDistinct(a, i, j, key):
        d_0_tmp_: TypeVar('T__')
        d_0_tmp_ = (a)[i]
        (a)[(i)] = (a)[j]
        (a)[(j)] = d_0_tmp_

    @staticmethod
    def GenericSort(a, less, key):
        d_0_n_: int
        d_0_n_ = (a).length(0)
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (d_0_n_):
            d_2_maxIndex_: int
            d_2_maxIndex_ = d_1_i_
            d_3_maxKey_: int
            d_3_maxKey_ = key((a)[d_1_i_])
            d_4_j_: int
            d_4_j_ = (d_1_i_) + (1)
            while (d_4_j_) < (d_0_n_):
                if (key((a)[d_4_j_])) > (d_3_maxKey_):
                    d_2_maxIndex_ = d_4_j_
                    d_3_maxKey_ = key((a)[d_4_j_])
                d_4_j_ = (d_4_j_) + (1)
            default__.SwapPreservesDistinct(a, d_1_i_, d_2_maxIndex_, key)
            d_1_i_ = (d_1_i_) + (1)

    @staticmethod
    def ArrayMap(a, f):
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((a).length(0)):
            (a)[(d_0_i_)] = f((a)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)

