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
    def Sqrt5():
        return _dafny.BigRational('223606797749979e-14')

    @staticmethod
    def PentagonPerimeter(side):
        perimeter: int = int(0)
        perimeter = (5) * (side)
        return perimeter

    @staticmethod
    def PentagonArea(side):
        area: _dafny.BigRational = _dafny.BigRational()
        d_0_sqrt5_: _dafny.BigRational
        d_0_sqrt5_ = default__.Sqrt5()
        area = (((_dafny.BigRational('5e0')) * (side)) * ((_dafny.BigRational('5e0')) - (d_0_sqrt5_))) / (_dafny.BigRational('2e0'))
        return area

    @staticmethod
    def Main(noArgsParameter__):
        d_0_side_: int
        d_0_side_ = 3
        d_1_perimeter_: int
        out0_: int
        out0_ = default__.PentagonPerimeter(d_0_side_)
        d_1_perimeter_ = out0_
        d_2_rside_: _dafny.BigRational
        d_2_rside_ = _dafny.BigRational(d_0_side_, 1)
        d_3_area_: _dafny.BigRational
        out1_: _dafny.BigRational
        out1_ = default__.PentagonArea(d_2_rside_)
        d_3_area_ = out1_

