import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: RollingMax

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def IsPrefixMax(s, i, m):
        def lambda0_(forall_var_0_):
            d_0_k_: int = forall_var_0_
            return not (((0) <= (d_0_k_)) and ((d_0_k_) <= (i))) or (((s)[d_0_k_]) <= (m))

        def lambda1_(exists_var_0_):
            d_1_k_: int = exists_var_0_
            return (((0) <= (d_1_k_)) and ((d_1_k_) <= (i))) and (((s)[d_1_k_]) == (m))

        return (_dafny.quantifier(_dafny.IntegerRange(0, (i) + (1)), True, lambda0_)) and (_dafny.quantifier(_dafny.IntegerRange(0, (i) + (1)), False, lambda1_))

    @staticmethod
    def RollingMax(input_):
        output: _dafny.Array = _dafny.Array(None, 0)
        d_0_n_: int
        d_0_n_ = (input_).length(0)
        nw0_ = _dafny.Array(int(0), d_0_n_)
        output = nw0_
        if (d_0_n_) > (0):
            d_1_maxVal_: int
            d_1_maxVal_ = (input_)[0]
            (output)[(0)] = d_1_maxVal_
            d_2_i_: int
            d_2_i_ = 1
            while (d_2_i_) < (d_0_n_):
                if ((input_)[d_2_i_]) > (d_1_maxVal_):
                    d_1_maxVal_ = (input_)[d_2_i_]
                (output)[(d_2_i_)] = d_1_maxVal_
                d_2_i_ = (d_2_i_) + (1)
        return output

