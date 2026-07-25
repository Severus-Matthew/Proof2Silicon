import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Partitioning

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Partition(a, lo, hi):
        p: int = int(0)
        d_0_pivot_: int
        d_0_pivot_ = (a)[(hi) - (1)]
        d_1_i_: int
        d_1_i_ = lo
        d_2_j_: int
        d_2_j_ = lo
        while (d_2_j_) < ((hi) - (1)):
            if ((a)[d_2_j_]) <= (d_0_pivot_):
                d_3_t_: int
                d_3_t_ = (a)[d_1_i_]
                (a)[(d_1_i_)] = (a)[d_2_j_]
                (a)[(d_2_j_)] = d_3_t_
                d_1_i_ = (d_1_i_) + (1)
            d_2_j_ = (d_2_j_) + (1)
        d_4_t2_: int
        d_4_t2_ = (a)[d_1_i_]
        (a)[(d_1_i_)] = (a)[(hi) - (1)]
        index0_ = (hi) - (1)
        (a)[index0_] = d_4_t2_
        p = d_1_i_
        return p

