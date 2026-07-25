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
    def Divides(d, n):
        if (d) == (0):
            return (n) == (0)
        elif True:
            return (_dafny.euclidian_modulus(n, d)) == (0)

    @staticmethod
    def GCD(a, b):
        while True:
            with _dafny.label():
                if (b) == (0):
                    return a
                elif True:
                    in0_ = b
                    in1_ = _dafny.euclidian_modulus(a, b)
                    a = in0_
                    b = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def ComputeGcd(a0, b0):
        g: int = int(0)
        d_0_x_: int
        d_0_x_ = a0
        d_1_y_: int
        d_1_y_ = b0
        while (d_1_y_) != (0):
            d_2_r_: int
            d_2_r_ = _dafny.euclidian_modulus(d_0_x_, d_1_y_)
            d_0_x_ = d_1_y_
            d_1_y_ = d_2_r_
        g = d_0_x_
        return g

    @staticmethod
    def MinSecondValueFirst(a):
        min_: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        min_ = ((a)[0])[1]
        while (d_0_i_) < ((a).length(0)):
            if (((a)[d_0_i_])[1]) < (min_):
                min_ = ((a)[d_0_i_])[1]
            d_0_i_ = (d_0_i_) + (1)
        return min_

    @staticmethod
    def Main(noArgsParameter__):
        d_0_x_: int
        d_0_x_ = 48
        d_1_y_: int
        d_1_y_ = 18
        d_2_g_: int
        out0_: int
        out0_ = default__.ComputeGcd(d_0_x_, d_1_y_)
        d_2_g_ = out0_
        d_3_g2_: int
        out1_: int
        out1_ = default__.ComputeGcd(7, 13)
        d_3_g2_ = out1_
        d_4_g3_: int
        out2_: int
        out2_ = default__.ComputeGcd(0, 25)
        d_4_g3_ = out2_
        d_5_arr_: _dafny.Array
        nw0_ = _dafny.Array(_dafny.Seq({}), 2)
        d_5_arr_ = nw0_
        (d_5_arr_)[(0)] = _dafny.SeqWithoutIsStrInference([5, 3, 7])
        (d_5_arr_)[(1)] = _dafny.SeqWithoutIsStrInference([1, -2, 4])
        d_6_m_: int
        out3_: int
        out3_ = default__.MinSecondValueFirst(d_5_arr_)
        d_6_m_ = out3_

