import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import MultiplyElements as MultiplyElements

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: MultiplyElements.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: MultiplyElements

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def MultiplyElements(a, b):
        result: _dafny.Seq = _dafny.Seq({})
        d_0_len_: int
        d_0_len_ = len(a)
        d_1_tmp_: _dafny.Array
        nw0_ = _dafny.Array(int(0), d_0_len_)
        d_1_tmp_ = nw0_
        d_2_i_: int
        d_2_i_ = 0
        while (d_2_i_) < (d_0_len_):
            (d_1_tmp_)[(d_2_i_)] = ((a)[d_2_i_]) * ((b)[d_2_i_])
            d_2_i_ = (d_2_i_) + (1)
        result = _dafny.SeqWithoutIsStrInference((d_1_tmp_)[::])
        return result
