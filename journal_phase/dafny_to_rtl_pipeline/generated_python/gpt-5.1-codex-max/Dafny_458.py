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
    def isMaxIndex(a, idx):
        def lambda0_(forall_var_0_):
            d_0_j_: int = forall_var_0_
            return not (((0) <= (d_0_j_)) and ((d_0_j_) < ((a).length(0)))) or (((a)[idx]) >= ((a)[d_0_j_]))

        return (((0) <= (idx)) and ((idx) < ((a).length(0)))) and (_dafny.quantifier(_dafny.IntegerRange(0, (a).length(0)), True, lambda0_))

    @staticmethod
    def FindMax(a):
        max__index: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        max__index = 0
        d_1_max__value_: int
        d_1_max__value_ = (a)[0]
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) > (d_1_max__value_):
                max__index = d_0_i_
                d_1_max__value_ = (a)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return max__index
