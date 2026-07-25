import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import AbsMax as AbsMax

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: AbsMax.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: AbsMax

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Abs(x):
        y: int = int(0)
        if (x) < (0):
            y = (0) - (x)
        elif True:
            y = x
        return y

    @staticmethod
    def Max(a, b):
        c: int = int(0)
        if (a) >= (b):
            c = a
        elif True:
            c = b
        return c
