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
    def gcdSpec(self, x, y):
        _this = self
        while True:
            with _dafny.label():
                if (y) == (0):
                    return x
                elif True:
                    in0_ = _this
                    in1_ = y
                    in2_ = _dafny.euclidian_modulus(x, y)
                    _this = in0_
                    
                    x = in1_
                    y = in2_
                    raise _dafny.TailCall()
                break

    def GCD(self, a, b):
        g: int = int(0)
        d_0_x_: int
        d_0_x_ = a
        d_1_y_: int
        d_1_y_ = b
        while (d_1_y_) != (0):
            d_2_temp_: int
            d_2_temp_ = _dafny.euclidian_modulus(d_0_x_, d_1_y_)
            d_0_x_ = d_1_y_
            d_1_y_ = d_2_temp_
        g = d_0_x_
        return g

    def CSpec(self, n):
        d_0___accumulator_ = 0
        _this = self
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (_dafny.euclidian_division(((n) * ((n) + (1))) * ((n) + (2)), 6)) + (d_0___accumulator_)
                    in0_ = _this
                    in1_ = (n) - (1)
                    _this = in0_
                    
                    n = in1_
                    raise _dafny.TailCall()
                break

    def C(self, n):
        result: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        d_1_acc_: int
        d_1_acc_ = 0
        while (d_0_i_) < (n):
            d_0_i_ = (d_0_i_) + (1)
            d_1_acc_ = (d_1_acc_) + (_dafny.euclidian_division(((d_0_i_) * ((d_0_i_) + (1))) * ((d_0_i_) + (2)), 6))
        result = d_1_acc_
        return result

    def Main(self, noArgsParameter__):
        d_0_g1_: int
        out0_: int
        out0_ = (self).GCD(48, 18)
        d_0_g1_ = out0_
        d_1_g2_: int
        out1_: int
        out1_ = (self).GCD(0, 0)
        d_1_g2_ = out1_
        d_2_g3_: int
        out2_: int
        out2_ = (self).GCD(7, 0)
        d_2_g3_ = out2_
        d_3_g4_: int
        out3_: int
        out3_ = (self).GCD(0, 9)
        d_3_g4_ = out3_
        d_4_c5_: int
        out4_: int
        out4_ = (self).C(5)
        d_4_c5_ = out4_

    @staticmethod
    def StaticMain(args):
        d_5_b_ = Program()
        d_5_b_.Main(args)
