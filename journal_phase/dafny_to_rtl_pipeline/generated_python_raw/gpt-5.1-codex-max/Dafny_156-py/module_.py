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
    def Max(a):
        m: int = int(0)
        m = (a)[0]
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) > (m):
                m = (a)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return m

    @staticmethod
    def Main(noArgsParameter__):
        d_0_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_arr_ = nw0_
        (d_0_arr_)[(0)] = 3
        (d_0_arr_)[(1)] = 17
        (d_0_arr_)[(2)] = 9
        (d_0_arr_)[(3)] = 17
        (d_0_arr_)[(4)] = -5
        d_1_maximum_: int
        out0_: int
        out0_ = default__.Max(d_0_arr_)
        d_1_maximum_ = out0_
        d_2_k_: int
        with _dafny.label("_ASSIGN_SUCH_THAT_d_0"):
            assign_such_that_0_: int
            for assign_such_that_0_ in _dafny.IntegerRange(0, (d_0_arr_).length(0)):
                d_2_k_ = assign_such_that_0_
                if (((0) <= (d_2_k_)) and ((d_2_k_) < ((d_0_arr_).length(0)))) and (((d_0_arr_)[d_2_k_]) == (d_1_maximum_)):
                    raise _dafny.Break("_ASSIGN_SUCH_THAT_d_0")
            raise Exception("assign-such-that search produced no value")
            pass

