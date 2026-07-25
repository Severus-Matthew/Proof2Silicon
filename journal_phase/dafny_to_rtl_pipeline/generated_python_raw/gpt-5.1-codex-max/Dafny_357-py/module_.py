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
    def ComputeFactorial(n):
        res: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        res = 1
        while (d_0_i_) < (n):
            d_0_i_ = (d_0_i_) + (1)
            res = (res) * (d_0_i_)
        return res

    @staticmethod
    def Main(noArgsParameter__):
        d_0_r0_: int
        out0_: int
        out0_ = default__.ComputeFactorial(0)
        d_0_r0_ = out0_
        d_1_r1_: int
        out1_: int
        out1_ = default__.ComputeFactorial(1)
        d_1_r1_ = out1_
        d_2_r5_: int
        out2_: int
        out2_ = default__.ComputeFactorial(5)
        d_2_r5_ = out2_
        d_3_r6_: int
        out3_: int
        out3_ = default__.ComputeFactorial(6)
        d_3_r6_ = out3_
        d_4_r7_: int
        out4_: int
        out4_ = default__.ComputeFactorial(7)
        d_4_r7_ = out4_

