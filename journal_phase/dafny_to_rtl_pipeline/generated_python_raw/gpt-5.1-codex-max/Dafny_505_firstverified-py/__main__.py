# Dafny program Dafny_505_firstverified.dfy compiled into Python
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny

import ComparisonProperties
try:
    dafnyArgs = [_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, a)) for a in sys.argv]
    ComparisonProperties.default__.Main(dafnyArgs)
except _dafny.HaltException as e:
    _dafny.print("[Program halted] " + e.message + "\n")
    sys.exit(1)
