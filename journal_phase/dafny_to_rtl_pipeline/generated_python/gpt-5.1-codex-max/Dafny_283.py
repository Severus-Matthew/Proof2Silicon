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
    def factorialSpec(n):
        d_0___accumulator_ = 1
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (1) * (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (d_0___accumulator_) * (n)
                    in0_ = (n) - (1)
                    n = in0_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def cubeSpec(size):
        return ((size) * (size)) * (size)

    @staticmethod
    def IterativeFactorial(n):
        res: int = int(0)
        d_0_acc_: int
        d_0_acc_ = 1
        d_1_i_: int
        d_1_i_ = 1
        while (d_1_i_) <= (n):
            d_0_acc_ = (d_0_acc_) * (d_1_i_)
            d_1_i_ = (d_1_i_) + (1)
        res = d_0_acc_
        return res

    @staticmethod
    def CubeVolume(size):
        volume: int = int(0)
        volume = 0
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) <= (size):
            volume = (volume) + ((size) * (size))
            d_0_i_ = (d_0_i_) + (1)
        return volume

    @staticmethod
    def Main(noArgsParameter__):
        d_0_f0_: int
        out0_: int
        out0_ = default__.IterativeFactorial(0)
        d_0_f0_ = out0_
        d_1_f5_: int
        out1_: int
        out1_ = default__.IterativeFactorial(5)
        d_1_f5_ = out1_
        d_2_f7_: int
        out2_: int
        out2_ = default__.IterativeFactorial(7)
        d_2_f7_ = out2_
        d_3_c2_: int
        out3_: int
        out3_ = default__.CubeVolume(2)
        d_3_c2_ = out3_
        d_4_c3_: int
        out4_: int
        out4_ = default__.CubeVolume(3)
        d_4_c3_ = out4_

