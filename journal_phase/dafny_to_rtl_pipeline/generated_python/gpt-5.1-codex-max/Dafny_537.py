import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import f as f

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: f.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: f

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def max_(x, y):
        if (x) >= (y):
            return x
        elif True:
            return y

    @staticmethod
    def Example(a, b, c):
        x: int = int(0)
        x = default__.max_(a, default__.max_(b, c))
        return x
