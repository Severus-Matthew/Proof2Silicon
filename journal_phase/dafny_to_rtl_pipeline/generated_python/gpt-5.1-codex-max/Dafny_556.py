import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import SquareEvaluation as SquareEvaluation

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: SquareEvaluation.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: SquareEvaluation

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def sum_(a, b):
        return (a) + (b)

    @staticmethod
    def ComputeSquare(x):
        r: int = int(0)
        z: int = int(0)
        d_0_acc_: int
        d_0_acc_ = 0
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (x):
            d_0_acc_ = (d_0_acc_) + (x)
            d_1_i_ = (d_1_i_) + (1)
        r = d_0_acc_
        z = default__.sum_(x, x)
        return r, z

    @staticmethod
    def Test(x):
        d_0_r_: int
        d_1_z_: int
        out0_: int
        out1_: int
        out0_, out1_ = default__.ComputeSquare(x)
        d_0_r_ = out0_
        d_1_z_ = out1_
