import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: IterativeMath

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def fibRec(n):
        if (n) <= (1):
            return n
        elif True:
            return (default__.fibRec((n) - (1))) + (default__.fibRec((n) - (2)))

    @staticmethod
    def factRec(n):
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
    def gcdRec(a, b):
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
    def FibIter(n):
        f: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        d_1_a_: int
        d_1_a_ = 0
        d_2_b_: int
        d_2_b_ = 1
        while (d_0_i_) < (n):
            d_3_next_: int
            d_3_next_ = (d_1_a_) + (d_2_b_)
            d_1_a_ = d_2_b_
            d_2_b_ = d_3_next_
            d_0_i_ = (d_0_i_) + (1)
        f = d_1_a_
        return f

    @staticmethod
    def FactIter(n):
        f: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        f = 1
        while (d_0_i_) < (n):
            d_0_i_ = (d_0_i_) + (1)
            f = (f) * (d_0_i_)
        return f

    @staticmethod
    def GcdIter(a, b):
        g: int = int(0)
        d_0_x_: int
        d_0_x_ = a
        d_1_y_: int
        d_1_y_ = b
        while (d_1_y_) != (0):
            d_2_temp_: int
            d_2_temp_ = d_1_y_
            d_1_y_ = _dafny.euclidian_modulus(d_0_x_, d_1_y_)
            d_0_x_ = d_2_temp_
        g = d_0_x_
        return g

    @staticmethod
    def Check(n, m, a, b):
        d_0_f_: int
        out0_: int
        out0_ = default__.FibIter(n)
        d_0_f_ = out0_
        d_1_fac_: int
        out1_: int
        out1_ = default__.FactIter(m)
        d_1_fac_ = out1_
        d_2_g_: int
        out2_: int
        out2_ = default__.GcdIter(a, b)
        d_2_g_ = out2_

    @_dafny.classproperty
    def MAX(instance):
        return 1000
