import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: IterativeMathOps

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def fibSpec(n):
        if (n) < (2):
            return n
        elif True:
            return (default__.fibSpec((n) - (1))) + (default__.fibSpec((n) - (2)))

    @staticmethod
    def factSpec(n):
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
    def gcdSpec(a, b):
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
    def fibIter(n):
        r: int = int(0)
        if (n) == (0):
            r = 0
            return r
        d_0_i_: int
        d_0_i_ = 1
        d_1_a_: int
        d_1_a_ = 0
        d_2_b_: int
        d_2_b_ = 1
        d_3_c_: int
        d_3_c_ = 1
        while (d_0_i_) < (n):
            d_3_c_ = (d_1_a_) + (d_2_b_)
            d_1_a_ = d_2_b_
            d_2_b_ = d_3_c_
            d_0_i_ = (d_0_i_) + (1)
        r = d_3_c_
        return r

    @staticmethod
    def factIter(n):
        r: int = int(0)
        if (n) == (0):
            r = 1
            return r
        d_0_i_: int
        d_0_i_ = 1
        d_1_acc_: int
        d_1_acc_ = 1
        while (d_0_i_) < (n):
            d_0_i_ = (d_0_i_) + (1)
            d_1_acc_ = (d_1_acc_) * (d_0_i_)
        r = d_1_acc_
        return r

    @staticmethod
    def gcdIter(a, b):
        g: int = int(0)
        d_0_x_: int
        d_0_x_ = a
        d_1_y_: int
        d_1_y_ = b
        while (d_1_y_) != (0):
            d_2_t_: int
            d_2_t_ = _dafny.euclidian_modulus(d_0_x_, d_1_y_)
            d_0_x_ = d_1_y_
            d_1_y_ = d_2_t_
        g = d_0_x_
        return g

    @staticmethod
    def demoLetInfixMod(m, n):
        sum_: int = int(0)
        rem: int = int(0)
        d_0_s_: int
        d_0_s_ = (m) + (n)
        sum_ = d_0_s_
        rem = _dafny.euclidian_modulus(m, n)
        return sum_, rem

