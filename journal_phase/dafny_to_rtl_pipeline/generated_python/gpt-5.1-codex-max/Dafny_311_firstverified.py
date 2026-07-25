import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Min as Min

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Min.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Min

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def MinOfTwo(a, b):
        minValue: int = int(0)
        if (a) <= (b):
            minValue = a
        elif True:
            minValue = b
        return minValue

    @staticmethod
    def TestMin():
        d_0_x_: int
        d_0_x_ = 10
        d_1_y_: int
        d_1_y_ = 0
        d_2_m_: int
        out0_: int
        out0_ = default__.MinOfTwo(d_0_x_, d_1_y_)
        d_2_m_ = out0_
        out1_: int
        out1_ = default__.MinOfTwo(5, 5)
        d_2_m_ = out1_
        out2_: int
        out2_ = default__.MinOfTwo(-3, 2)
        d_2_m_ = out2_
