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
    def gcd(x, y):
        while True:
            with _dafny.label():
                if (y) == (0):
                    return x
                elif True:
                    in0_ = y
                    in1_ = _dafny.euclidian_modulus(x, y)
                    x = in0_
                    y = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def GCDIterative(x, y):
        g: int = int(0)
        d_0_a_: int
        d_0_a_ = x
        d_1_b_: int
        d_1_b_ = y
        while (d_1_b_) != (0):
            d_2_oldA_: int
            d_2_oldA_ = d_0_a_
            d_3_oldB_: int
            d_3_oldB_ = d_1_b_
            d_1_b_ = _dafny.euclidian_modulus(d_2_oldA_, d_3_oldB_)
            d_0_a_ = d_3_oldB_
        g = d_0_a_
        return g

    @staticmethod
    def TestGCD():
        d_0_r0_: int
        out0_: int
        out0_ = default__.GCDIterative(0, 0)
        d_0_r0_ = out0_
        d_1_r1_: int
        out1_: int
        out1_ = default__.GCDIterative(10, 0)
        d_1_r1_ = out1_
        d_2_r2_: int
        out2_: int
        out2_ = default__.GCDIterative(0, 7)
        d_2_r2_ = out2_
        d_3_r3_: int
        out3_: int
        out3_ = default__.GCDIterative(17, 13)
        d_3_r3_ = out3_
        d_4_r4_: int
        out4_: int
        out4_ = default__.GCDIterative(54, 24)
        d_4_r4_ = out4_
        d_5_r5_: int
        out5_: int
        out5_ = default__.GCDIterative(48, 180)
        d_5_r5_ = out5_
        d_6_r6_: int
        out6_: int
        out6_ = default__.GCDIterative(8, 12)
        d_6_r6_ = out6_

    @staticmethod
    def Main(noArgsParameter__):
        default__.TestGCD()
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "All GCD test cases passed!\n"))).VerbatimString(False))

