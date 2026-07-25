import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Foo

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Reverse(a):
        d_0_i_: int
        d_0_i_ = 0
        d_1_j_: int
        d_1_j_ = ((a).length(0)) - (1)
        while (d_0_i_) < (d_1_j_):
            d_2_tmp_: int
            d_2_tmp_ = (a)[d_0_i_]
            (a)[(d_0_i_)] = (a)[d_1_j_]
            (a)[(d_1_j_)] = d_2_tmp_
            d_0_i_ = (d_0_i_) + (1)
            d_1_j_ = (d_1_j_) - (1)

    @staticmethod
    def Foo(a, b):
        pass
        pass

