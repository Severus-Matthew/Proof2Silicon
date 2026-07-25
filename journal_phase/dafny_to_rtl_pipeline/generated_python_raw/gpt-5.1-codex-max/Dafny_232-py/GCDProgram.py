import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: GCDProgram

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Abs(n):
        if (n) < (0):
            return (0) - (n)
        elif True:
            return n

    @staticmethod
    def gcdSpec(x, y):
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
    def ComputeGCD(a, b):
        g: int = int(0)
        d_0_x_: int
        d_0_x_ = default__.Abs(a)
        d_1_y_: int
        d_1_y_ = default__.Abs(b)
        while (d_1_y_) != (0):
            d_2_t_: int
            d_2_t_ = d_1_y_
            d_1_y_ = _dafny.euclidian_modulus(d_0_x_, d_1_y_)
            d_0_x_ = d_2_t_
        g = d_0_x_
        return g

    @staticmethod
    def Add(a, b):
        c: int = int(0)
        d_0_x_: int
        d_0_x_ = a
        d_1_y_: int
        d_1_y_ = b
        c = d_0_x_
        d_2_k_: int
        d_2_k_ = d_1_y_
        while (d_2_k_) > (0):
            c = (c) + (1)
            d_2_k_ = (d_2_k_) - (1)
        return c

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: int
        d_0_a_ = 10
        d_1_b_: int
        d_1_b_ = 5
        d_2_g1_: int
        out0_: int
        out0_ = default__.ComputeGCD(d_0_a_, d_1_b_)
        d_2_g1_ = out0_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "GCD of "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_0_a_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " and "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_b_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " is "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_2_g1_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
        d_0_a_ = -10
        d_1_b_ = 5
        d_3_g2_: int
        out1_: int
        out1_ = default__.ComputeGCD(d_0_a_, d_1_b_)
        d_3_g2_ = out1_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "GCD of "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_0_a_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " and "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_b_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " is "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_3_g2_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
        d_4_s_: int
        out2_: int
        out2_ = default__.Add(3, 4)
        d_4_s_ = out2_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "Sum of 3 and 4 is "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_4_s_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

