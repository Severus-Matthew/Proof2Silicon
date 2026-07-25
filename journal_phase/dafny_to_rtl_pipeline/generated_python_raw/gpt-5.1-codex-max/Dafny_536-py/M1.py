import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import M0 as M0

# Module: M1

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Demo(x):
        result: bool = False
        d_0_p_: M0.Container
        nw0_ = M0.Container()
        nw0_.ctor__()
        d_0_p_ = nw0_
        (d_0_p_).Add(x)
        d_1_c_: bool
        out0_: bool
        out0_ = (d_0_p_).Contains(x)
        d_1_c_ = out0_
        (d_0_p_).Remove(x)
        d_2_c2_: bool
        out1_: bool
        out1_ = (d_0_p_).Contains(x)
        d_2_c2_ = out1_
        result = d_1_c_
        return result

