import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: FactorialModule

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
    def FactorialIterative(n):
        res: int = int(0)
        d_0_product_: int
        d_0_product_ = 1
        d_1_i_: int
        d_1_i_ = 1
        while (d_1_i_) <= (n):
            d_0_product_ = (d_0_product_) * (d_1_i_)
            d_1_i_ = (d_1_i_) + (1)
        res = d_0_product_
        return res

    @staticmethod
    def TestFactorial(n):
        res: int = int(0)
        d_0_product_: int
        d_0_product_ = 1
        d_1_i_: int
        d_1_i_ = 1
        while (d_1_i_) <= (n):
            d_0_product_ = (d_0_product_) * (d_1_i_)
            d_1_i_ = (d_1_i_) + (1)
        res = d_0_product_
        return res

    @staticmethod
    def Demo():
        d_0_r0_: int
        out0_: int
        out0_ = default__.FactorialIterative(0)
        d_0_r0_ = out0_
        d_1_r1_: int
        out1_: int
        out1_ = default__.FactorialIterative(1)
        d_1_r1_ = out1_
        d_2_r5_: int
        out2_: int
        out2_ = default__.FactorialIterative(5)
        d_2_r5_ = out2_
        d_3_r3_: int
        out3_: int
        out3_ = default__.TestFactorial(3)
        d_3_r3_ = out3_

