import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class Program:
    def  __init__(self):
        pass

    def __dafnystr__(self) -> str:
        return "_module.Program"
    @staticmethod
    def Max(arr):
        m: int = int(0)
        m = (arr)[0]
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((arr).length(0)):
            if ((arr)[d_0_i_]) > (m):
                m = (arr)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return m

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 15)
        d_0_a_ = nw0_
        (d_0_a_)[(0)] = 0
        (d_0_a_)[(1)] = 2
        (d_0_a_)[(2)] = 1
        (d_0_a_)[(3)] = 2
        (d_0_a_)[(4)] = 3
        (d_0_a_)[(5)] = 4
        (d_0_a_)[(6)] = 5
        (d_0_a_)[(7)] = 6
        (d_0_a_)[(8)] = 7
        (d_0_a_)[(9)] = 8
        (d_0_a_)[(10)] = 9
        (d_0_a_)[(11)] = 10
        (d_0_a_)[(12)] = 11
        (d_0_a_)[(13)] = 12
        (d_0_a_)[(14)] = 13
        d_1_mx_: int
        out0_: int
        out0_ = Program.Max(d_0_a_)
        d_1_mx_ = out0_

