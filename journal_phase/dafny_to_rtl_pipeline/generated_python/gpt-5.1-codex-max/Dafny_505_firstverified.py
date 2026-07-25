import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import ComparisonProperties as ComparisonProperties

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: ComparisonProperties.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: ComparisonProperties

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def cmp(x, y):
        if (x) < (y):
            return -1
        elif (x) == (y):
            return 0
        elif True:
            return 1

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: int
        d_0_a_ = 3
        d_1_b_: int
        d_1_b_ = 5
        d_2_c_: int
        d_2_c_ = 5
