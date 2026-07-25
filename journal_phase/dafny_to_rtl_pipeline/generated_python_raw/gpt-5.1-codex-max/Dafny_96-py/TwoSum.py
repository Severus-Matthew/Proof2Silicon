import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: TwoSum

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def twoSum(nums, target):
        sum1: int = int(0)
        sum2: int = int(0)
        d_0_m_: _dafny.Map
        d_0_m_ = _dafny.Map({})
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < ((nums).length(0)):
            d_2_complement_: int
            d_2_complement_ = (target) - ((nums)[d_1_i_])
            if (d_2_complement_) in (d_0_m_):
                sum1 = (d_0_m_)[d_2_complement_]
                sum2 = d_1_i_
                return sum1, sum2
            d_0_m_ = (d_0_m_).set((nums)[d_1_i_], d_1_i_)
            d_1_i_ = (d_1_i_) + (1)
        sum1 = -1
        sum2 = -1
        return sum1, sum2

