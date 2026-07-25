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
    def Reverse(a):
        d_0_n_: int
        d_0_n_ = (a).length(0)
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (_dafny.euclidian_division(d_0_n_, 2)):
            d_2_j_: int
            d_2_j_ = ((d_0_n_) - (1)) - (d_1_i_)
            d_3_tmp_: int
            d_3_tmp_ = (a)[d_1_i_]
            (a)[(d_1_i_)] = (a)[d_2_j_]
            (a)[(d_2_j_)] = d_3_tmp_
            d_1_i_ = (d_1_i_) + (1)

