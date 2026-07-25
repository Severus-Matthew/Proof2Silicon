import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Barrier as Barrier

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Barrier.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Barrier

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def IsBarrier(a, p):
        def lambda0_(forall_var_0_):
            d_0_i_: int = forall_var_0_
            return not (((0) <= (d_0_i_)) and ((d_0_i_) < (p))) or (((a)[d_0_i_]) < ((a)[p]))

        def lambda1_(forall_var_1_):
            d_1_j_: int = forall_var_1_
            return not (((p) < (d_1_j_)) and ((d_1_j_) < ((a).length(0)))) or (((a)[p]) < ((a)[d_1_j_]))

        return ((((0) <= (p)) and ((p) < ((a).length(0)))) and (_dafny.quantifier(_dafny.IntegerRange(0, p), True, lambda0_))) and (_dafny.quantifier(_dafny.IntegerRange((p) + (1), (a).length(0)), True, lambda1_))

    @staticmethod
    def FindBarrier(a):
        p: int = int(0)
        p = 0
        return p
