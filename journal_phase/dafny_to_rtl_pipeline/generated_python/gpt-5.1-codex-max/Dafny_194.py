import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import FirstZeroFinder as FirstZeroFinder

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: FirstZeroFinder.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: FirstZeroFinder

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def FirstZeroIndex(a):
        idx: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) == (0):
                idx = d_0_i_
                return idx
            d_0_i_ = (d_0_i_) + (1)
        idx = -1
        return idx

    @staticmethod
    def Main(noArgsParameter__):
        d_0_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_arr_ = nw0_
        (d_0_arr_)[(0)] = 1
        (d_0_arr_)[(1)] = 2
        (d_0_arr_)[(2)] = 0
        (d_0_arr_)[(3)] = 3
        (d_0_arr_)[(4)] = 0
        d_1_res_: int
        out0_: int
        out0_ = default__.FirstZeroIndex(d_0_arr_)
        d_1_res_ = out0_
