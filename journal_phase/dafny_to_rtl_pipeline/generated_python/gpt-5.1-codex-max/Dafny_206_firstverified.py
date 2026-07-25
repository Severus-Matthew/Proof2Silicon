import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import BarrierCheck as BarrierCheck

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: BarrierCheck.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: BarrierCheck

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def CheckBarrier(a, p):
        isBarrier: bool = False
        d_0_incBefore_: bool
        d_0_incBefore_ = True
        if (p) == ((a).length(0)):
            d_0_incBefore_ = False
        elif True:
            d_1_i_: int
            d_1_i_ = 0
            while (d_1_i_) < (p):
                if not(((a)[d_1_i_]) < ((a)[(d_1_i_) + (1)])):
                    d_0_incBefore_ = False
                d_1_i_ = (d_1_i_) + (1)
        d_2_lessAfter_: bool
        d_2_lessAfter_ = True
        if (p) < ((a).length(0)):
            d_3_k_: int
            d_3_k_ = (p) + (1)
            while (d_3_k_) < ((a).length(0)):
                if not(((a)[p]) < ((a)[d_3_k_])):
                    d_2_lessAfter_ = False
                d_3_k_ = (d_3_k_) + (1)
        isBarrier = (((p) < ((a).length(0))) and (d_0_incBefore_)) and (d_2_lessAfter_)
        return isBarrier

    @staticmethod
    def Main(noArgsParameter__):
        d_0_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_arr_ = nw0_
        (d_0_arr_)[(0)] = 1
        (d_0_arr_)[(1)] = 2
        (d_0_arr_)[(2)] = 5
        (d_0_arr_)[(3)] = 10
        (d_0_arr_)[(4)] = 20
        d_1_p_: int
        d_1_p_ = 2
        d_2_check_: bool
        out0_: bool
        out0_ = default__.CheckBarrier(d_0_arr_, d_1_p_)
        d_2_check_ = out0_
