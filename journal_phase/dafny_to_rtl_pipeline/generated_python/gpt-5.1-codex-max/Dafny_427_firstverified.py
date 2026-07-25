import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Mult as Mult

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Mult.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Mult

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Multiply(x, y):
        r: int = int(0)
        d_0_m_: int
        d_0_m_ = x
        d_1_n_: int
        d_1_n_ = y
        r = 0
        while (d_0_m_) > (0):
            r = (r) + (d_1_n_)
            d_0_m_ = (d_0_m_) - (1)
        return r
