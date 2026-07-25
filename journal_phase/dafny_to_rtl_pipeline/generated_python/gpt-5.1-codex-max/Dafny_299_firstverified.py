import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import ElementWiseSubtraction as ElementWiseSubtraction

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: ElementWiseSubtraction.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: ElementWiseSubtraction

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def ElementWiseSubtract(a, b):
        result: _dafny.Array = _dafny.Array(None, 0)
        d_0_n_: int
        d_0_n_ = (a).length(0)
        nw0_ = _dafny.Array(int(0), d_0_n_)
        result = nw0_
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (d_0_n_):
            (result)[(d_1_i_)] = ((a)[d_1_i_]) - ((b)[d_1_i_])
            d_1_i_ = (d_1_i_) + (1)
        return result
