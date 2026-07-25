import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Triple as Triple

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Triple.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Triple

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def triple(x):
        r: int = int(0)
        r = (3) * (x)
        return r
