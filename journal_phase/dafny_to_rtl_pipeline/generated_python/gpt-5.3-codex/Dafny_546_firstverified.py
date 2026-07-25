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
    def Main(noArgsParameter__):
        d_0_n_: int
        d_0_n_ = 10
        d_1_i_: int
        d_1_i_ = 0
        d_2_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), d_0_n_)
        d_2_a_ = nw0_
        while (d_1_i_) < (d_0_n_):
            (d_2_a_)[(d_1_i_)] = (d_1_i_) * (d_1_i_)
            d_1_i_ = (d_1_i_) + (1)
        d_3_s_: _dafny.Seq
        d_3_s_ = _dafny.SeqWithoutIsStrInference((d_2_a_)[::])
        d_4_sum_: int
        d_4_sum_ = 0
        d_1_i_ = 0
        while (d_1_i_) < (d_0_n_):
            d_4_sum_ = (d_4_sum_) + ((d_2_a_)[d_1_i_])
            d_1_i_ = (d_1_i_) + (1)

