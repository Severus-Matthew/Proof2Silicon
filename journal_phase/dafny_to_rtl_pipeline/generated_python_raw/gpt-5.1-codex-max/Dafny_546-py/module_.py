import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class SumOfCubes:
    def  __init__(self):
        pass

    def __dafnystr__(self) -> str:
        return "_module.SumOfCubes"
    @staticmethod
    def Tri(x):
        return _dafny.euclidian_division((x) * ((x) + (1)), 2)

    @staticmethod
    def SumCubesClosed(n, m):
        return ((SumOfCubes.Tri(m)) * (SumOfCubes.Tri(m))) - ((SumOfCubes.Tri((n) - (1))) * (SumOfCubes.Tri((n) - (1))))

    @staticmethod
    def sumOfCubes(n, m):
        res: int = int(0)
        d_0_i_: int
        d_0_i_ = n
        d_1_sum_: int
        d_1_sum_ = 0
        while (d_0_i_) <= (m):
            d_1_sum_ = (d_1_sum_) + (((d_0_i_) * (d_0_i_)) * (d_0_i_))
            d_0_i_ = (d_0_i_) + (1)
        res = d_1_sum_
        return res

    @staticmethod
    def sumOfCubesFormula(n, m):
        res: int = int(0)
        res = SumOfCubes.SumCubesClosed(n, m)
        return res

    @staticmethod
    def verifyProperties():
        d_0_n_: int
        d_0_n_ = 1
        d_1_k_: int
        d_1_k_ = 10
        d_2_iterative_: int
        out0_: int
        out0_ = SumOfCubes.sumOfCubes(d_0_n_, d_1_k_)
        d_2_iterative_ = out0_
        d_3_closed_: int
        out1_: int
        out1_ = SumOfCubes.sumOfCubesFormula(d_0_n_, d_1_k_)
        d_3_closed_ = out1_
        d_4_a_: int
        d_4_a_ = 3
        d_5_b_: int
        d_5_b_ = 7
        d_6_iterative2_: int
        out2_: int
        out2_ = SumOfCubes.sumOfCubes(d_4_a_, d_5_b_)
        d_6_iterative2_ = out2_
        d_7_closed2_: int
        out3_: int
        out3_ = SumOfCubes.sumOfCubesFormula(d_4_a_, d_5_b_)
        d_7_closed2_ = out3_
        d_8_c_: int
        d_8_c_ = 5
        if ((d_4_a_) <= (d_8_c_)) and ((d_8_c_) < (d_5_b_)):
            d_9_left_: int
            out4_: int
            out4_ = SumOfCubes.sumOfCubes(d_4_a_, d_8_c_)
            d_9_left_ = out4_
            d_10_right_: int
            out5_: int
            out5_ = SumOfCubes.sumOfCubes((d_8_c_) + (1), d_5_b_)
            d_10_right_ = out5_

