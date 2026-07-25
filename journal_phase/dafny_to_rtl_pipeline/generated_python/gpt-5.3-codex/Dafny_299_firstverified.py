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
        c: _dafny.Array = _dafny.Array(None, 0)
        nw0_ = _dafny.Array(int(0), (a).length(0))
        c = nw0_
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((a).length(0)):
            (c)[(d_0_i_)] = ((a)[d_0_i_]) - ((b)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)
        return c
