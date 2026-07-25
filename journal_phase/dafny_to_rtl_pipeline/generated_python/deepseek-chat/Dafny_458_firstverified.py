import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import FindMax as FindMax

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: FindMax.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: FindMax

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def FindMax(a):
        max_: int = int(0)
        max_ = (a)[0]
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) > (max_):
                max_ = (a)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return max_
