import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: MaxModule

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Max2(a, b):
        c: int = int(0)
        if (a) > (b):
            c = a
        elif True:
            c = b
        return c

    @staticmethod
    def Testing(x, y, z):
        m: int = int(0)
        d_0_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 3)
        d_0_arr_ = nw0_
        (d_0_arr_)[(0)] = x
        (d_0_arr_)[(1)] = y
        (d_0_arr_)[(2)] = z
        d_1_m01_: int
        out0_: int
        out0_ = default__.Max2((d_0_arr_)[0], (d_0_arr_)[1])
        d_1_m01_ = out0_
        out1_: int
        out1_ = default__.Max2(d_1_m01_, (d_0_arr_)[2])
        m = out1_
        return m

    @staticmethod
    def Main(noArgsParameter__):
        d_0_x_: int
        d_0_x_ = 10
        d_1_y_: int
        d_1_y_ = 20
        d_2_z_: int
        d_2_z_ = 5
        d_3_m_: int
        out0_: int
        out0_ = default__.Testing(d_0_x_, d_1_y_, d_2_z_)
        d_3_m_ = out0_

