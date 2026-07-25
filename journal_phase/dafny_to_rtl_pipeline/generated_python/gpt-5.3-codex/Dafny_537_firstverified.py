import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import F as F

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: F.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: F

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Main(noArgsParameter__):
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "namespace f\n"))).VerbatimString(False))
